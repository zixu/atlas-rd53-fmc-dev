-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxZcu102DmaLoopback.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top Level Firmware Target
-------------------------------------------------------------------------------
-- This file is part of 'RCE Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'RCE Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxZcu102DmaLoopback is
   generic (
      TPD_G          : time    := 1 ns;
      BUILD_INFO_G   : BuildInfoType;
      ROGUE_SIM_EN_G : boolean := false);
   port (
      -- SFP Interface
      sfpClk156P : in  sl;
      sfpClk156N : in  sl;
      sfpTxP     : out slv(3 downto 0);
      sfpTxN     : out slv(3 downto 0);
      sfpRxP     : in  slv(3 downto 0);
      sfpRxN     : in  slv(3 downto 0));
end AtlasRd53FmcXilinxZcu102DmaLoopback;

architecture TOP_LEVEL of AtlasRd53FmcXilinxZcu102DmaLoopback is

   signal sysClk200  : sl;
   signal sysRst200  : sl;
   
   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal dmaClk      : slv(3 downto 0);
   signal dmaRst      : slv(3 downto 0);
   signal dmaIbMaster : AxiStreamMasterArray(3 downto 0);
   signal dmaIbSlave  : AxiStreamSlaveArray(3 downto 0);
   signal dmaObMaster : AxiStreamMasterArray(3 downto 0);
   signal dmaObSlave  : AxiStreamSlaveArray(3 downto 0);

begin

   -------
   -- Core
   -------
   U_Core : entity rce_gen3_fw_lib.XilinxZcu102Core
      generic map (
         TPD_G                => TPD_G,
         SIMULATION_G         => ROGUE_SIM_EN_G,
         SIM_MEM_PORT_NUM_G   => 9000,
         SIM_DMA_PORT_NUM_G   => 8000,
         SIM_DMA_CHANNELS_G   => 4,
         SIM_DMA_TDESTS_G     => 256,
         BUILD_INFO_G         => BUILD_INFO_G)
      port map (
         sysClk200          => sysClk200,
         sysClk200Rst       => sysRst200,
         -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
         axiClk             => axilClk,
         axiClkRst          => axilRst,
         extAxilReadMaster  => axilReadMaster,
         extAxilReadSlave   => axilReadSlave,
         extAxilWriteMaster => axilWriteMaster,
         extAxilWriteSlave  => axilWriteSlave,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClk,
         dmaClkRst          => dmaRst,
         dmaObMaster        => dmaObMaster,
         dmaObSlave         => dmaObSlave,
         dmaIbMaster        => dmaIbMaster,
         dmaIbSlave         => dmaIbSlave);

   ---------------
   -- DMA Loopback
   ---------------
   dmaClk      <= (others => sysClk200);
   dmaRst      <= (others => sysRst200);
   dmaIbMaster <= dmaObMaster;
   dmaObSlave  <= dmaIbSlave;

   ----------
   -- SFP GTs
   ----------
   U_TERM_GTs : entity surf.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         refClk => axilClk,
         gtRxP  => sfpRxP,
         gtRxN  => sfpRxN,
         gtTxP  => sfpTxP,
         gtTxN  => sfpTxN);

end TOP_LEVEL;
