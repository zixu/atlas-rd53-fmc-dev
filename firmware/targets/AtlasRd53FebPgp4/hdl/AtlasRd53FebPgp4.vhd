-------------------------------------------------------------------------------
-- File       : AtlasRd53FebPgp4.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top-Level module using four lanes of 6.0 Gbps PGPv4 communication
--
-- Note: 10 Gbps is the standard link rate for PGPv4.  This means the back-end
--       receiver will need to have special firmware to run at this
--       non-standard rate of 6 Gpbs
--
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
use surf.SsiPkg.all;
use surf.Pgp4Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FebPgp4 is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- RD53 ASIC Serial Ports
      dPortDataP    : in  Slv4Array(3 downto 0);
      dPortDataN    : in  Slv4Array(3 downto 0);
      dPortCmdP     : out slv(3 downto 0);
      dPortCmdN     : out slv(3 downto 0);
      -- Reference Clock
      refClk160MHzP : in  sl;
      refClk160MHzN : in  sl;
      -- QSFP Ports
      led           : out slv(3 downto 0);
      qsfpLpMode    : out sl;
      qsfpRst       : out sl;
      qsfpSel       : out sl;
      -- PGP Ports
      pgpClkP       : in  sl;
      pgpClkN       : in  sl;
      pgpRxP        : in  slv(3 downto 0);
      pgpRxN        : in  slv(3 downto 0);
      pgpTxP        : out slv(3 downto 0);
      pgpTxN        : out slv(3 downto 0));
end AtlasRd53FebPgp4;

architecture top_level of AtlasRd53FebPgp4 is

   constant DMA_CLK_FREQ_C    : real                := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := PGP4_AXIS_CONFIG_C;

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaObMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(1 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal pgpRefClkDiv2 : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   signal pgpRxIn  : Pgp4RxInType  := PGP4_RX_IN_INIT_C;
   signal pgpRxOut : Pgp4RxOutType := PGP4_RX_OUT_INIT_C;

   signal pgpTxIn  : Pgp4TxInType  := PGP4_TX_IN_INIT_C;
   signal pgpTxOut : Pgp4TxOutType := PGP4_TX_OUT_INIT_C;

   signal pgpTxMasters : AxiStreamMasterArray(8 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpTxSlaves  : AxiStreamSlaveArray(8 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal pgpRxMasters : AxiStreamMasterArray(8 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpRxSlaves  : AxiStreamSlaveArray(8 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal pgpRxCtrl    : AxiStreamCtrlArray(8 downto 0)   := (others => AXI_STREAM_CTRL_UNUSED_C);

   signal pgpClk : sl;
   signal pgpRst : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   qsfpLpMode <= '0';
   qsfpRst    <= dmaRst;
   qsfpSel    <= '1';

   led(3) <= pgpRxOut.linkReady;
   led(2) <= pgpTxOut.linkReady;
   led(1) <= not(dmaRst);
   led(0) <= '1';

   U_MMCM : entity surf.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 2,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 6.0,
         CLKOUT0_DIVIDE_F_G => 3.125,   -- 300 MHz = 937.5 MHz/3.125
         CLKOUT1_DIVIDE_G   => 6)       -- 156.25 MHz = 937.5 MHz/6
      port map(
         clkIn     => pgpRefClkDiv2,
         clkOut(0) => refClk300MHz,
         clkOut(1) => dmaClk,
         rstOut(0) => refRst300MHz,
         rstOut(1) => dmaRst);

   U_IDELAYCTRL : IDELAYCTRL
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   U_PGPv4 : entity surf.Pgp4Gtx7Wrapper
      generic map(
         TPD_G         => TPD_G,
         NUM_LANES_G   => 1,
         NUM_VC_G      => 9,
         RATE_G        => "6.25Gbps",
         REFCLK_FREQ_G => 312.5E+6,
         EN_PGP_MON_G  => false,
         EN_GT_DRP_G   => false,
         EN_QPLL_DRP_G => false)
      port map (
         -- Stable Clock and Reset
         stableClk         => dmaClk,
         stableRst         => dmaRst,
         -- Gt Serial IO
         pgpGtTxP(0)       => pgpTxP(0),
         pgpGtTxN(0)       => pgpTxN(0),
         pgpGtRxP(0)       => pgpRxP(0),
         pgpGtRxN(0)       => pgpRxN(0),
         -- GT Clocking
         pgpRefClkP        => pgpClkP,
         pgpRefClkN        => pgpClkN,
         pgpRefClkDiv2Bufg => pgpRefClkDiv2,
         -- Clocking
         pgpClk(0)         => pgpClk,
         pgpClkRst(0)      => pgpRst,
         -- Non VC Rx Signals
         pgpRxIn(0)        => pgpRxIn,
         pgpRxOut(0)       => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn(0)        => pgpTxIn,
         pgpTxOut(0)       => pgpTxOut,
         -- Frame Transmit Interface
         pgpTxMasters      => pgpTxMasters,
         pgpTxSlaves       => pgpTxSlaves,
         -- Frame Receive Interface
         pgpRxMasters      => pgpRxMasters,
         pgpRxCtrl         => pgpRxCtrl,
         pgpRxSlaves       => pgpRxSlaves,
         -- AXI-Lite Register Interface (axilClk domain)
         axilClk           => dmaClk,
         axilRst           => dmaRst,
         axilReadMaster    => AXI_LITE_READ_MASTER_INIT_C,
         axilReadSlave     => open,
         axilWriteMaster   => AXI_LITE_WRITE_MASTER_INIT_C,
         axilWriteSlave    => open);

   U_Gtxe2ChannelDummy : entity surf.Gtxe2ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 3)
      port map (
         refClk => dmaClk,
         gtRxP  => pgpRxP(3 downto 1),
         gtRxN  => pgpRxN(3 downto 1),
         gtTxP  => pgpTxP(3 downto 1),
         gtTxN  => pgpTxN(3 downto 1));

   -----------------------
   -- PGPv3-to-DMA Mapping
   -----------------------
   U_Mapping : entity work.AtlasRd53Pgp4
      generic map (
         TPD_G => TPD_G)
      port map (
         -- DMA Interface (dmaClk domain)
         dmaClk       => dmaClk,
         dmaRst       => dmaRst,
         dmaObMasters => dmaObMasters,
         dmaObSlaves  => dmaObSlaves,
         dmaIbMasters => dmaIbMasters,
         dmaIbSlaves  => dmaIbSlaves,
         -- PGP Ports
         pgpClk       => pgpClk,
         pgpRst       => pgpRst,
         pgpTxMasters => pgpTxMasters,
         pgpTxSlaves  => pgpTxSlaves,
         pgpRxMasters => pgpRxMasters,
         pgpRxSlaves  => pgpRxSlaves,
         pgpRxCtrl    => pgpRxCtrl);

   -------------
   -- FEB Module
   -------------
   U_App : entity work.AtlasRd53FebCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DMA_CLK_FREQ_G    => DMA_CLK_FREQ_C,
         XIL_DEVICE_G      => "7SERIES")
      port map (
         -- I/O Delay Interfaces
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- DMA Interface (dmaClk domain)
         dmaClk        => dmaClk,
         dmaRst        => dmaRst,
         dmaObMasters  => dmaObMasters,
         dmaObSlaves   => dmaObSlaves,
         dmaIbMasters  => dmaIbMasters,
         dmaIbSlaves   => dmaIbSlaves,
         -- RD53 ASIC Serial Ports
         dPortDataP    => dPortDataP,
         dPortDataN    => dPortDataN,
         dPortCmdP     => dPortCmdP,
         dPortCmdN     => dPortCmdN,
         -- Reference Clock
         refClk160MHzP => refClk160MHzP,
         refClk160MHzN => refClk160MHzN);

end top_level;
