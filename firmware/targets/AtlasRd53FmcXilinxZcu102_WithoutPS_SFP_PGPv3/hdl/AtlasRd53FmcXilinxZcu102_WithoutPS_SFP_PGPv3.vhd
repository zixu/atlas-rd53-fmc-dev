-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_PGPv3.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top Level Firmware Target
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
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.Pgp3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_PGPv3 is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;  
      BUILD_INFO_G : BuildInfoType);
   port (
      -- FMC Interface
      fmcHpc0LaP : inout slv(33 downto 0);
      fmcHpc0LaN : inout slv(33 downto 0);
      fmcHpc1LaP : inout slv(29 downto 0);
      fmcHpc1LaN : inout slv(29 downto 0);
      -- SFP Interface
      sfpClk156P : in    sl;
      sfpClk156N : in    sl;
      sfpTxP     : out   slv(3 downto 0);
      sfpTxN     : out   slv(3 downto 0);
      sfpRxP     : in    slv(3 downto 0);
      sfpRxN     : in    slv(3 downto 0));
end AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_PGPv3;

architecture TOP_LEVEL of AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_PGPv3 is

   constant DMA_CLK_FREQ_C    : real                := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := PGP3_AXIS_CONFIG_C;

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

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaIbMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(1 downto 0);
   signal dmaObMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal sfpClk156     : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   --------------------------
   -- Reference 300 MHz clock 
   --------------------------
   U_MMCM : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
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
         clkIn     => sfpClk156,
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
         
   U_PGPv3 : entity work.Pgp3GthUsWrapper
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
         pgpRefClkDiv2Bufg => sfpClk156,
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
         
         
   U_TERM_GTs : entity work.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 3)
      port map (
         refClk => dmaClk,
         gtRxP  => sfpRxP(3 downto 1),
         gtRxN  => sfpRxN(3 downto 1),
         gtTxP  => sfpTxP(3 downto 1),
         gtTxN  => sfpTxN(3 downto 1));           
         
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
         SIMULATION_G      => SIMULATION_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DMA_CLK_FREQ_G    => DMA_CLK_FREQ_C,
         XIL_DEVICE_G      => "ULTRASCALE_PLUS")
      port map (
         -- I/O Delay Interfaces
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- DMA Interface (dmaClk domain)
         dmaClk        => dmaClk,
         dmaRst        => dmaRst,
         dmaObMasters  => dmaObMasters,  -- DMA[0] = DATA, DMA[1] = AXI-Lite Config
         dmaObSlaves   => dmaObSlaves,
         dmaIbMasters  => dmaIbMasters,
         dmaIbSlaves   => dmaIbSlaves,
         -- FMC LPC Ports
         fmcLaP        => fmcHpc0LaP,
         fmcLaN        => fmcHpc0LaN);

end TOP_LEVEL;
