-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_10GbE.vhd
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_10GbE is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst     : in    sl;
      led        : out   slv(7 downto 0);
      -- FMC Interface
      fmcHpc0LaP : inout slv(33 downto 0);
      fmcHpc0LaN : inout slv(33 downto 0);
      fmcHpc1LaP : inout slv(29 downto 0);
      fmcHpc1LaN : inout slv(29 downto 0);
      -- SFP Interface
      sfpClk156P : in    sl;
      sfpClk156N : in    sl;
      sfpEnTx    : out   slv(3 downto 0) := x"F";
      sfpTxP     : out   slv(3 downto 0);
      sfpTxN     : out   slv(3 downto 0);
      sfpRxP     : in    slv(3 downto 0);
      sfpRxN     : in    slv(3 downto 0));
end AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_10GbE;

architecture TOP_LEVEL of AtlasRd53FmcXilinxZcu102_WithoutPS_SFP_10GbE is

   constant DMA_CLK_FREQ_C : real := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,                        -- 64-bit data interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 2,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   signal efuse    : slv(31 downto 0);
   signal localMac : slv(47 downto 0);

   signal ibMacMaster : AxiStreamMasterType;
   signal ibMacSlave  : AxiStreamSlaveType;
   signal obMacMaster : AxiStreamMasterType;
   signal obMacSlave  : AxiStreamSlaveType;

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
   signal phyReady      : sl;
   signal phyRst        : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   led(0) <= '1';
   led(1) <= not(extRst);
   led(2) <= extRst;
   led(3) <= not(refRst300MHz);
   led(4) <= iDelayCtrlRdy;
   led(5) <= not(dmaRst);
   led(6) <= not(phyRst);
   led(7) <= phyReady;

   --------------------------
   -- Reference 300 MHz clock 
   --------------------------
   U_MMCM : entity surf.ClockManagerUltraScale
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
         clkIn     => dmaClk,
         clkOut(0) => refClk300MHz,
         clkOut(1) => open,
         rstOut(0) => refRst300MHz,
         rstOut(1) => open);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   U_10GigE : entity surf.TenGigEthGthUltraScaleWrapper
      generic map (
         TPD_G             => TPD_G,
         NUM_LANE_G        => 1,
         -- QUAD PLL Configurations
         QPLL_REFCLK_SEL_G => "001",
         -- AXI Streaming Configurations
         AXIS_CONFIG_G     => (others => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac(0)     => localMac,
         -- Streaming DMA Interface 
         dmaClk(0)       => dmaClk,
         dmaRst(0)       => dmaRst,
         dmaIbMasters(0) => obMacMaster,
         dmaIbSlaves(0)  => obMacSlave,
         dmaObMasters(0) => ibMacMaster,
         dmaObSlaves(0)  => ibMacSlave,
         -- Misc. Signals
         extRst          => extRst,
         coreClk         => dmaClk,
         coreRst         => dmaRst,
         phyReady(0)     => phyReady,
         phyRst(0)       => phyRst,
         -- Transceiver Debug Interface
         gtTxPreCursor   => "00011",
         gtTxPostCursor  => "00011",
         gtTxDiffCtrl    => "11111",
         -- MGT Clock Port
         gtClkP          => sfpClk156P,
         gtClkN          => sfpClk156N,
         -- MGT Ports
         gtTxP(0)        => sfpTxP(0),
         gtTxN(0)        => sfpTxN(0),
         gtRxP(0)        => sfpRxP(0),
         gtRxN(0)        => sfpRxN(0));

   U_TERM_GTs : entity surf.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 3)
      port map (
         refClk => dmaClk,
         gtRxP  => sfpRxP(3 downto 1),
         gtRxN  => sfpRxN(3 downto 1),
         gtTxP  => sfpTxP(3 downto 1),
         gtTxN  => sfpTxN(3 downto 1));

   U_EFuse : EFUSE_USR
      port map (
         EFUSEUSR => efuse);

   localMac(23 downto 0)  <= x"56_00_08";  -- 08:00:56:XX:XX:XX (big endian SLV)   
   localMac(47 downto 24) <= efuse(31 downto 8);

   ----------------------
   -- RUDP Wrapper Module
   ----------------------
   U_RUDP : entity work.RudpServers
      generic map (
         TPD_G             => TPD_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         CLK_FREQUENCY_G   => DMA_CLK_FREQ_C,
         IP_ADDR_G         => x"0A02A8C0",  -- Set the default IP address before DHCP: 192.168.2.10 = x"0A02A8C0"
         DHCP_G            => false,
         JUMBO_G           => false)
      port map (
         -- Clock and Reset
         dmaClk       => dmaClk,
         dmaRst       => dmaRst,
         -- ETH interface
         localMac     => localMac,
         ibMacMaster  => ibMacMaster,
         ibMacSlave   => ibMacSlave,
         obMacMaster  => obMacMaster,
         obMacSlave   => obMacSlave,
         -- DMA Interface
         dmaObMasters => dmaObMasters,
         dmaObSlaves  => dmaObSlaves,
         dmaIbMasters => dmaIbMasters,
         dmaIbSlaves  => dmaIbSlaves);

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
