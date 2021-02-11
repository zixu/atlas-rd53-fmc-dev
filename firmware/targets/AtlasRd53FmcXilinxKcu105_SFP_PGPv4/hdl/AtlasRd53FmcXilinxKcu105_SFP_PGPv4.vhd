-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKcu105_SFP_PGPv4.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 FMC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 FMC DEV', including this file,
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

entity AtlasRd53FmcXilinxKcu105_SFP_PGPv4 is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst     : in    sl;
      led        : out   slv(7 downto 0);
      -- ETH GT Pins
      ethClkP    : in    sl;
      ethClkN    : in    sl;
      ethRxP     : in    sl;
      ethRxN     : in    sl;
      ethTxP     : out   sl;
      ethTxN     : out   sl;
      -- ETH external PHY pins
      phyMdc     : out   sl;
      phyMdio    : inout sl;
      phyRstN    : out   sl;            -- active low
      phyIrqN    : in    sl;            -- active low
      -- 300Mhz System Clock
      sysClk300P : in    sl;
      sysClk300N : in    sl;
      -- FMC Interface
      fmcHpcLaP  : inout slv(33 downto 0);
      fmcHpcLaN  : inout slv(33 downto 0);
      fmcLpcLaP  : inout slv(33 downto 0);
      fmcLpcLaN  : inout slv(33 downto 0);
      -- SFP Interface
      sfpClk156P : in    sl;
      sfpClk156N : in    sl;
      sfpTxP     : out   slv(1 downto 0);
      sfpTxN     : out   slv(1 downto 0);
      sfpRxP     : in    slv(1 downto 0);
      sfpRxN     : in    slv(1 downto 0));
end AtlasRd53FmcXilinxKcu105_SFP_PGPv4;

architecture top_level of AtlasRd53FmcXilinxKcu105_SFP_PGPv4 is

   constant DMA_CLK_FREQ_C    : real                := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := PGP4_AXIS_CONFIG_C;

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaObMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(1 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal sysClk300NB   : sl;
   signal sysClk300     : sl;
   signal sysRst300     : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;
   signal iDelayCtrlRdy : sl;

   signal refClk  : sl;
   signal refRst  : sl;

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

   led(7) <= pgpRxOut.linkReady;
   led(6) <= pgpRxOut.linkReady;
   led(5) <= pgpRxOut.linkReady;
   led(4) <= pgpRxOut.linkReady;
   led(3) <= pgpTxOut.linkReady;
   led(2) <= pgpTxOut.linkReady;
   led(1) <= pgpTxOut.linkReady;
   led(0) <= '1';

   U_SysClk300IBUFDS : IBUFDS
      generic map (
         DIFF_TERM    => false,
         IBUF_LOW_PWR => false)
      port map (
         I  => sysClk300P,
         IB => sysClk300N,
         O  => sysClk300);

   U_SysclkBUFG : BUFG
      port map (
         I => sysClk300,
         O => refClk);

   U_SysclkRstSync : entity surf.RstSync
      port map (
         clk      => refClk,
         asyncRst => extRst,
         syncRst  => refRst);

   U_MMCM : entity surf.ClockManagerUltrascale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 2,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 3.333,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 3.125,
         CLKOUT0_DIVIDE_F_G => 3.125,   -- 300 MHz = 937.5 MHz/3.125
         CLKOUT1_DIVIDE_G   => 6)       -- 156.25 MHz = 937.5 MHz/6
      port map(
         clkIn     => refClk,
         rstIn     => refRst,
         clkOut(0) => refClk300MHz,
         clkOut(1) => dmaClk,
         rstOut(0) => refRst300MHz,
         rstOut(1) => dmaRst);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   U_PGPv3 : entity surf.Pgp4GthUsWrapper
      generic map(
         TPD_G         => TPD_G,
         NUM_LANES_G   => 1,
         NUM_VC_G      => 9,
         RATE_G        => "6.25Gbps",
         EN_PGP_MON_G  => false,
         EN_GTH_DRP_G  => false,
         EN_QPLL_DRP_G => false)
      port map (
         -- Stable Clock and Reset
         stableClk         => dmaClk,
         stableRst         => dmaRst,
         -- Gt Serial IO
         pgpGtTxP(0)       => sfpTxP(0),
         pgpGtTxN(0)       => sfpTxN(0),
         pgpGtRxP(0)       => sfpRxP(0),
         pgpGtRxN(0)       => sfpRxN(0),
         -- GT Clocking
         pgpRefClkP        => sfpClk156P,
         pgpRefClkN        => sfpClk156N,
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

   U_TERM_GTs : entity surf.Gthe3ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 1)
      port map (
         refClk   => refClk300MHz,
         gtRxP(0) => sfpRxP(1),
         gtRxN(0) => sfpRxN(1),
         gtTxP(0) => sfpTxP(1),
         gtTxN(0) => sfpTxN(1));

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
   -- FMC Module
   -------------
   U_App : entity work.AtlasRd53FmcCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DMA_CLK_FREQ_G    => DMA_CLK_FREQ_C,
         XIL_DEVICE_G      => "ULTRASCALE")
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
         -- FMC LPC Ports
         fmcLaP        => fmcHpcLaP,
         fmcLaN        => fmcHpcLaN);

end top_level;
