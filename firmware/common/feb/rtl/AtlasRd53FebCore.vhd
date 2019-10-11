-------------------------------------------------------------------------------
-- File       : AtlasRd53FebCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AD53 FEB readout core module
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FebCore is
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
      iDelayCtrlRdy : in  sl := '0';
      -- DMA Interface (dmaClk domain)
      dmaClk        : in  sl;
      dmaRst        : in  sl;
      dmaObMasters  : in  AxiStreamMasterArray(1 downto 0);
      dmaObSlaves   : out AxiStreamSlaveArray(1 downto 0);
      dmaIbMasters  : out AxiStreamMasterArray(1 downto 0);
      dmaIbSlaves   : in  AxiStreamSlaveArray(1 downto 0);
      -- RD53 ASIC Serial Ports
      dPortDataP    : in  Slv4Array(3 downto 0);
      dPortDataN    : in  Slv4Array(3 downto 0);
      dPortCmdP     : out slv(3 downto 0);
      dPortCmdN     : out slv(3 downto 0);
      -- Reference Clock
      refClk160MHzP : in  sl;
      refClk160MHzN : in  sl);
end AtlasRd53FebCore;

architecture mapping of AtlasRd53FebCore is

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

   signal refClk160MHz : sl;

   signal clk640MHz : sl;
   signal rst640MHz : sl;
   signal clk160MHz : sl;
   signal rst160MHz : sl;

   signal serDesData : Slv8Array(15 downto 0);
   signal dlyCfg     : Slv9Array(15 downto 0);

begin

   U_IBUFDS : IBUFDS
      port map (
         I  => refClk160MHzP,
         IB => refClk160MHzN,
         O  => refClk160MHz);

   U_PLL : entity work.ClockManager7
      generic map(
         TPD_G            => TPD_G,
         TYPE_G           => "PLL",
         INPUT_BUFG_G     => true,
         FB_BUFG_G        => true,
         NUM_CLOCKS_G     => 2,
         CLKIN_PERIOD_G   => 6.256,     -- 160 MHz
         DIVCLK_DIVIDE_G  => 1,         -- 160 MHz = 160 MHz/1
         CLKFBOUT_MULT_G  => 8,         -- 1.28 GHz = 160 MHz x 8
         CLKOUT0_DIVIDE_G => 2,         -- 640 MHz = 1.28 GHz/2
         CLKOUT1_DIVIDE_G => 8)         -- 160 MHz = 1.28 GHz/8
      port map(
         clkIn     => refClk160MHz,
         rstIn     => dmaRst,
         -- Clock Outputs
         clkOut(0) => clk640MHz,
         clkOut(1) => clk160MHz,
         -- Reset Outputs
         rstOut(0) => rst640MHz,
         rstOut(1) => rst160MHz);

   GEN_mDP :
   for i in 3 downto 0 generate
      GEN_LANE :
      for j in 3 downto 0 generate
         U_Lane : entity work.AuroraRxLaneDeser
            generic map (
               TPD_G => TPD_G)
            port map (
               -- RD53 ASIC Serial Interface
               dPortDataP    => dPortDataP(i)(j),
               dPortDataN    => dPortDataN(i)(j),
               iDelayCtrlRdy => iDelayCtrlRdy,
               -- Timing Interface
               clk640MHz     => clk640MHz,
               clk160MHz     => clk160MHz,
               rst160MHz     => rst160MHz,
               -- Delay Configuration
               dlyCfg        => dlyCfg(4*i+j),
               -- Output
               dataOut       => serDesData(4*i+j));
      end generate GEN_LANE;
   end generate GEN_mDP;

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

   ------------------------   
   -- Rd53 CMD/DATA Modules
   ------------------------   
   GEN_DP :
   for i in 3 downto 0 generate
      U_Core : entity work.AtlasRd53Core
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
            VALID_THOLD_G => VALID_THOLD_G,
            SIMULATION_G  => SIMULATION_G,
            XIL_DEVICE_G  => XIL_DEVICE_G,
            SYNTH_MODE_G  => SYNTH_MODE_G)
         port map (
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
