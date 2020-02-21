-------------------------------------------------------------------------------
-- File       : AtlasCdr53bSpiFebCore.vhd
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasCdr53bSpiFebCore is
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
      -- DMA Interface (dmaClk domain)
      dmaClk        : in    sl;
      dmaRst        : in    sl;
      dmaObMasters  : in    AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      dmaObSlaves   : out   AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
      dmaIbMasters  : out   AxiStreamMasterArray(1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      dmaIbSlaves   : in    AxiStreamSlaveArray(1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
      -- RD53 ASIC Serial Ports
      dPortDataP    : inout Slv4Array(3 downto 0);
      dPortDataN    : inout Slv4Array(3 downto 0);
      dPortCmdP     : inout slv(3 downto 0);
      dPortCmdN     : inout slv(3 downto 0);
      -- Reference Clock
      refClk160MHzP : in    sl;
      refClk160MHzN : in    sl);
end AtlasCdr53bSpiFebCore;

architecture mapping of AtlasCdr53bSpiFebCore is

   constant NUM_AXIL_MASTERS_C : positive := 5;

   constant RX_INDEX_C      : natural := 0;  -- [3:0]
   constant VERSION_INDEX_C : natural := 4;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"0000_0000", 20, 16);

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

begin

   ---------------
   -- SRPv3 Module
   ---------------
   U_SRPv3 : entity surf.SrpV3AxiLite
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
   U_XBAR : entity surf.AxiLiteCrossbar
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
   U_AxiVersion : entity surf.AxiVersion
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

   ------------------------   
   -- Rd53 CMD/DATA Modules
   ------------------------   
   GEN_DP :
   for i in 3 downto 0 generate
      U_Core : entity work.AtlasCdr53bSpiCore
         generic map (
            TPD_G => TPD_G)
         port map (
            -- AXI-Lite Interface
            axilClk         => dmaClk,
            axilRst         => dmaRst,
            axilReadMaster  => axilReadMasters(i+RX_INDEX_C),
            axilReadSlave   => axilReadSlaves(i+RX_INDEX_C),
            axilWriteMaster => axilWriteMasters(i+RX_INDEX_C),
            axilWriteSlave  => axilWriteSlaves(i+RX_INDEX_C),
            -- RD53 ASIC Serial Ports
            dPortDataP      => dPortDataP(i),
            dPortDataN      => dPortDataN(i),
            dPortCmdP       => dPortCmdP(i),
            dPortCmdN       => dPortCmdN(i));
   end generate GEN_DP;

end mapping;
