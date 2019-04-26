-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKc705_SFP_PGPv3.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for Xilinx KC705 board (PGPv3 on the SFP)
--
-- https://www.xilinx.com/products/boards-and-kits/kc705.html
--
--       ------------------------------------------------------------
--       Refer to UG801(v1.9): Table 1-16: PHY Default Interface Mode
--       ------------------------------------------------------------
--       J29: Jumper over pins 2-3 (non-default)
--       J30: Jumper over pins 2-3 (non-default)
--       J64: No jumper  (default)
--       ------------------------------------------------------------
--
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.Pgp3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKc705_SFP_PGPv3 is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst     : in    sl;
      led        : out   slv(7 downto 0);
      -- FMC Interface
      fmcHpcLaP  : inout slv(33 downto 0);
      fmcHpcLaN  : inout slv(33 downto 0);
      fmcLpcLaP  : inout slv(33 downto 0);
      fmcLpcLaN  : inout slv(33 downto 0);
      -- SFP Interface
      sfpClk125P : in    sl;
      sfpClk125N : in    sl;
      sfpTxP     : out   sl;
      sfpTxN     : out   sl;
      sfpRxP     : in    sl;
      sfpRxN     : in    sl);
end AtlasRd53FmcXilinxKc705_SFP_PGPv3;

architecture top_level of AtlasRd53FmcXilinxKc705_SFP_PGPv3 is

   constant DMA_CLK_FREQ_C    : real                := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := PGP3_AXIS_CONFIG_C;

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaObMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(1 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal sfpClk125     : sl;
   signal sfpClk62p5    : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   signal pgpRxIn  : Pgp3RxInType  := PGP3_RX_IN_INIT_C;
   signal pgpRxOut : Pgp3RxOutType := PGP3_RX_OUT_INIT_C;

   signal pgpTxIn  : Pgp3TxInType  := PGP3_TX_IN_INIT_C;
   signal pgpTxOut : Pgp3TxOutType := PGP3_TX_OUT_INIT_C;

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

   U_MMCM : entity work.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 2,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 16.0,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 15.0,
         CLKOUT0_DIVIDE_F_G => 3.125,   -- 300 MHz = 937.5 MHz/3.125    
         CLKOUT1_DIVIDE_G   => 6)       -- 156.25 MHz = 937.5 MHz/6     
      port map(
         clkIn     => sfpClk62p5,
         rstIn     => dmaRst,
         clkOut(0) => refClk300MHz,
         clkOut(1) => dmaClk,
         rstOut(0) => refRst300MHz,
         rstOut(1) => dmaRst);

   U_IDELAYCTRL : IDELAYCTRL
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   U_PGPv3 : entity work.Pgp3Gtx7Wrapper
      generic map(
         TPD_G         => TPD_G,
         NUM_LANES_G   => 1,
         NUM_VC_G      => 9,
         RATE_G        => "6.25Gbps",
         REFCLK_TYPE_G => PGP3_REFCLK_125_C,
         EN_PGP_MON_G  => false,
         EN_GTH_DRP_G  => false,
         EN_QPLL_DRP_G => false)
      port map (
         -- Stable Clock and Reset
         stableClk         => dmaClk,
         stableRst         => dmaRst,
         -- Gt Serial IO
         pgpGtTxP(0)       => sfpTxP,
         pgpGtTxN(0)       => sfpTxN,
         pgpGtRxP(0)       => sfpRxP,
         pgpGtRxN(0)       => sfpRxN,
         -- GT Clocking
         pgpRefClkP        => sfpClk125P,
         pgpRefClkN        => sfpClk125N,
         pgpRefClkDiv2Bufg => sfpClk62p5,
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
         
   -----------------------
   -- PGPv3-to-DMA Mapping
   -----------------------
   U_Mapping : entity work.AtlasRd53Pgp3
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
         -- FMC LPC Ports
         fmcLaP        => fmcHpcLaP,
         fmcLaN        => fmcHpcLaN);

end top_level;
