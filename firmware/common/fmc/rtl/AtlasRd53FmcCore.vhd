-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RX PHY Core module
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.I2cPkg.all;

entity AtlasRd53FmcCore is
   generic (
      TPD_G             : time     := 1 ns;
      BUILD_INFO_G      : BuildInfoType;
      SIMULATION_G      : boolean  := false;
      BUILD_FMC_I2C_G   : boolean  := false;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      DMA_CLK_FREQ_G    : real;         -- units of Hz
      VALID_THOLD_G     : positive := 128;  -- Hold until enough to burst into the interleaving MUX
      XIL_DEVICE_G      : string   := "7SERIES";
      SYNTH_MODE_G      : string   := "inferred";
      MEMORY_TYPE_G     : string   := "block");
   port (
      -- I/O Delay Interfaces
      iDelayCtrlRdy : in    sl := '0';
      -- DMA Interface (dmaClk domain)
      dmaClk        : in    sl;
      dmaRst        : in    sl;
      dmaObMasters  : in    AxiStreamMasterArray(1 downto 0);
      dmaObSlaves   : out   AxiStreamSlaveArray(1 downto 0);
      dmaIbMasters  : out   AxiStreamMasterArray(1 downto 0);
      dmaIbSlaves   : in    AxiStreamSlaveArray(1 downto 0);
      -- Misc. Interfaces
      fpgaPllClkIn  : in    sl := '0';
      -- FMC LPC Ports
      fmcScl        : inout sl := 'Z';
      fmcSda        : inout sl := 'Z';
      fmcLaP        : inout slv(33 downto 0);
      fmcLaN        : inout slv(33 downto 0));
end AtlasRd53FmcCore;

architecture mapping of AtlasRd53FmcCore is

   constant RX_EQ_I2C_CONFIG_C : I2cAxiLiteDevArray(0 to 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010110",      -- DS32EV400
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian                   
         repeatStart => '1'));          -- Repeat Start 

   constant FMC_FRU_CONFIG_C : I2cAxiLiteDevArray(0 to 0) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010000",      -- 2kbit PROM
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian                   
         repeatStart => '0'));          -- Repeat Start          

   constant PLL_RX_EQ_I2C_CONFIG_C : I2cAxiLiteDevArray(0 to 1) := (
      0              => RX_EQ_I2C_CONFIG_C(0),
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1011000",      -- LMK61E2
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian   
         repeatStart => '1'));          -- Repeat Start          

   constant NUM_AXIL_MASTERS_C : positive := 13;

   constant RX_INDEX_C      : natural := 0;  -- [3:0]
   constant I2C_INDEX_C     : natural := 4;  -- [7:4]
   constant PLL_INDEX_C     : natural := 8;
   constant EMU_INDEX_C     : natural := 9;  -- [10:9]
   constant VERSION_INDEX_C : natural := 11;
   constant FMC_FRU_INDEX_C : natural := 12;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"0000_0000", 20, 16);

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal emuTimingMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal emuTimingSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal mDataMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal mDataSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal sConfigMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal sConfigSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal mConfigMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal mConfigSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal clk160MHz : sl;
   signal rst160MHz : sl;

   signal pllRst : slv(3 downto 0);
   signal pllCsL : sl;
   signal pllSck : sl;
   signal pllSdi : sl;
   signal pllSdo : sl;

   signal dPortCmdP : slv(3 downto 0);
   signal dPortCmdN : slv(3 downto 0);

   signal serDesData : Slv8Array(15 downto 0);
   signal dlyLoad    : slv(15 downto 0);
   signal dlyCfg     : Slv9Array(15 downto 0);

   signal i2cScl : slv(3 downto 0);
   signal i2cSda : slv(3 downto 0);

begin

   -------------------
   -- FMC Port Mapping
   -------------------
   U_FmcMapping : entity work.AtlasRd53FmcMapping
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         -- Deserialization Interface
         serDesData    => serDesData,
         dlyLoad       => dlyLoad,
         dlyCfg        => dlyCfg,
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- Timing/Trigger Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz,
         -- PLL Clocking Interface
         fpgaPllClkIn  => fpgaPllClkIn,
         -- PLL SPI Interface
         pllRst        => pllRst,
         pllCsL        => pllCsL,
         pllSck        => pllSck,
         pllSdi        => pllSdi,
         pllSdo        => pllSdo,
         -- mDP CMD Interface
         dPortCmdP     => dPortCmdP,
         dPortCmdN     => dPortCmdN,
         -- I2C Interface
         i2cScl        => i2cScl,
         i2cSda        => i2cSda,
         -- FMC LPC Ports
         fmcLaP        => fmcLaP,
         fmcLaN        => fmcLaN);

   ---------------
   -- SRPv3 Module
   ---------------
   U_SRPv3 : entity work.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => DMA_AXIS_CONFIG_G)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain) 
         sAxisClk         => dmaClk,
         sAxisRst         => dmaRst,
         sAxisMaster      => dmaObMasters(1),
         sAxisSlave       => dmaObSlaves(1),
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => dmaClk,
         mAxisRst         => dmaRst,
         mAxisMaster      => dmaIbMasters(1),
         mAxisSlave       => dmaIbSlaves(1),
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => dmaClk,
         axilRst          => dmaRst,
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => dmaClk,
         axiClkRst           => dmaRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   --------------------
   -- AxiVersion Module
   --------------------         
   U_AxiVersion : entity work.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         CLK_PERIOD_G => (1.0/DMA_CLK_FREQ_G),
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         axiReadMaster  => axilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => axilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => axilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(VERSION_INDEX_C),
         axiClk         => dmaClk,
         axiRst         => dmaRst);

   ----------------------------------
   -- Emulation Timing/Trigger Module
   ----------------------------------
   U_EmuTiming : entity work.AtlasRd53EmuTiming
      generic map(
         TPD_G         => TPD_G,
         NUM_AXIS_G    => 4,
         ADDR_WIDTH_G  => 10,
         SYNTH_MODE_G  => SYNTH_MODE_G,
         MEMORY_TYPE_G => MEMORY_TYPE_G)
      port map(
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => dmaClk,
         axilRst          => dmaRst,
         axilReadMasters  => axilReadMasters(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilReadSlaves   => axilReadSlaves(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilWriteMasters => axilWriteMasters(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilWriteSlaves  => axilWriteSlaves(EMU_INDEX_C+1 downto EMU_INDEX_C),
         -- Streaming RD53 Trig Interface (clk160MHz domain)
         clk160MHz        => clk160MHz,
         rst160MHz        => rst160MHz,
         emuTimingMasters => emuTimingMasters,
         emuTimingSlaves  => emuTimingSlaves);


   NOT_SIM : if (SIMULATION_G = false) generate

      --------------------
      -- AXI-Lite: PLL SPI
      --------------------
      U_PLL : entity work.Si5345
         generic map (
            TPD_G              => TPD_G,
            MEMORY_INIT_FILE_G => "Si5345-RevD-Registers-160MHz.mem",
            CLK_PERIOD_G       => (1/DMA_CLK_FREQ_G),
            SPI_SCLK_PERIOD_G  => (1/10.0E+6))  -- 1/(10 MHz SCLK)
         port map (
            -- AXI-Lite Register Interface
            axiClk         => dmaClk,
            axiRst         => dmaRst,
            axiReadMaster  => axilReadMasters(PLL_INDEX_C),
            axiReadSlave   => axilReadSlaves(PLL_INDEX_C),
            axiWriteMaster => axilWriteMasters(PLL_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(PLL_INDEX_C),
            -- SPI Ports
            coreSclk       => pllSck,
            coreSDin       => pllSdo,
            coreSDout      => pllSdi,
            coreCsb        => pllCsL);

      ---------------------------
      -- AXI-Lite: I2C Reg Access
      ---------------------------
      U_PLL_RX_QUAL : entity work.AxiI2cRegMaster
         generic map (
            TPD_G          => TPD_G,
            DEVICE_MAP_G   => PLL_RX_EQ_I2C_CONFIG_C,
            -- I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
            I2C_SCL_FREQ_G => 100.0E+3,  -- units of Hz
            AXI_CLK_FREQ_G => DMA_CLK_FREQ_G)
         port map (
            -- I2C Ports
            scl            => i2cScl(0),
            sda            => i2cSda(0),
            -- AXI-Lite Register Interface
            axiReadMaster  => axilReadMasters(I2C_INDEX_C),
            axiReadSlave   => axilReadSlaves(I2C_INDEX_C),
            axiWriteMaster => axilWriteMasters(I2C_INDEX_C),
            axiWriteSlave  => axilWriteSlaves(I2C_INDEX_C),
            -- Clocks and Resets
            axiClk         => dmaClk,
            axiRst         => dmaRst);

      GEN_I2C :
      for i in 3 downto 1 generate
         U_RX_QUAL_ONLY : entity work.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               DEVICE_MAP_G   => RX_EQ_I2C_CONFIG_C,
               -- I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               I2C_SCL_FREQ_G => 100.0E+3,  -- units of Hz
               AXI_CLK_FREQ_G => DMA_CLK_FREQ_G)
            port map (
               -- I2C Ports
               scl            => i2cScl(i),
               sda            => i2cSda(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => axilReadMasters(i+I2C_INDEX_C),
               axiReadSlave   => axilReadSlaves(i+I2C_INDEX_C),
               axiWriteMaster => axilWriteMasters(i+I2C_INDEX_C),
               axiWriteSlave  => axilWriteSlaves(i+I2C_INDEX_C),
               -- Clocks and Resets
               axiClk         => dmaClk,
               axiRst         => dmaRst);
      end generate GEN_I2C;


      BUILD_FMC_I2C : if (BUILD_FMC_I2C_G = true) generate

         U_FMC_FRU : entity work.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               DEVICE_MAP_G   => FMC_FRU_CONFIG_C,
               I2C_SCL_FREQ_G => 100.0E+3,  -- units of Hz
               AXI_CLK_FREQ_G => DMA_CLK_FREQ_G)
            port map (
               -- I2C Ports
               scl            => fmcScl,
               sda            => fmcSda,
               -- AXI-Lite Register Interface
               axiReadMaster  => axilReadMasters(FMC_FRU_INDEX_C),
               axiReadSlave   => axilReadSlaves(FMC_FRU_INDEX_C),
               axiWriteMaster => axilWriteMasters(FMC_FRU_INDEX_C),
               axiWriteSlave  => axilWriteSlaves(FMC_FRU_INDEX_C),
               -- Clocks and Resets
               axiClk         => dmaClk,
               axiRst         => dmaRst);

      end generate;

   end generate;

   ------------------------   
   -- Rd53 CMD/DATA Modules
   ------------------------   
   GEN_DP :
   for i in 3 downto 0 generate
      U_Core : entity work.AtlasRd53Core
         generic map (
            TPD_G         => TPD_G,
            RX_MAPPING_G  => (0 => "11", 1 => "10", 2 => "01", 3 => "00"),  -- lane reversal in FMC layout
            AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
            VALID_THOLD_G => VALID_THOLD_G,
            SIMULATION_G  => SIMULATION_G,
            XIL_DEVICE_G  => XIL_DEVICE_G,
            SYNTH_MODE_G  => SYNTH_MODE_G)
         port map (
            -- I/O Delay Interfaces
            pllRst          => pllRst(i),
            -- AXI-Lite Interface
            axilClk         => dmaClk,
            axilRst         => dmaRst,
            axilReadMaster  => axilReadMasters(i+RX_INDEX_C),
            axilReadSlave   => axilReadSlaves(i+RX_INDEX_C),
            axilWriteMaster => axilWriteMasters(i+RX_INDEX_C),
            axilWriteSlave  => axilWriteSlaves(i+RX_INDEX_C),
            -- Streaming EMU Trig Interface (clk160MHz domain)
            emuTimingMaster => emuTimingMasters(i),
            emuTimingSlave  => emuTimingSlaves(i),
            -- Streaming Data/Config Interface (axisClk domain)
            axisClk         => dmaClk,
            axisRst         => dmaRst,
            mDataMaster     => mDataMasters(i),
            mDataSlave      => mDataSlaves(i),
            sConfigMaster   => sConfigMasters(i),
            sConfigSlave    => sConfigSlaves(i),
            mConfigMaster   => mConfigMasters(i),
            mConfigSlave    => mConfigSlaves(i),
            -- Timing/Trigger Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- Deserialization Interface
            serDesData      => serDesData(4*i+3 downto 4*i),
            dlyLoad         => dlyLoad(4*i+3 downto 4*i),
            dlyCfg          => dlyCfg(4*i+3 downto 4*i),
            -- RD53 ASIC Serial Ports
            dPortCmdP       => dPortCmdP(i),
            dPortCmdN       => dPortCmdN(i));
   end generate GEN_DP;

   U_Mux : entity work.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         NUM_SLAVES_G         => 8,
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => false,
         ILEAVE_REARB_G       => VALID_THOLD_G,
         PIPE_STAGES_G        => 1)
      port map (
         -- Clock and reset
         axisClk                  => dmaClk,
         axisRst                  => dmaRst,
         -- Slaves
         sAxisMasters(3 downto 0) => mConfigMasters,
         sAxisMasters(7 downto 4) => mDataMasters,
         sAxisSlaves(3 downto 0)  => mConfigSlaves,
         sAxisSlaves(7 downto 4)  => mDataSlaves,
         -- Master
         mAxisMaster              => dmaIbMasters(0),
         mAxisSlave               => dmaIbSlaves(0));

   U_DeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => 4,
         PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => dmaClk,
         axisRst      => dmaRst,
         -- Slave         
         sAxisMaster  => dmaObMasters(0),
         sAxisSlave   => dmaObSlaves(0),
         -- Masters
         mAxisMasters => sConfigMasters,
         mAxisSlaves  => sConfigSlaves);

end mapping;
