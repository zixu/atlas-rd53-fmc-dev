-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKcu105_SFP_10GbE.vhd
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
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKcu105_SFP_10GbE is
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
      fmcScl     : inout sl;
      fmcSda     : inout sl;
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
end AtlasRd53FmcXilinxKcu105_SFP_10GbE;

architecture top_level of AtlasRd53FmcXilinxKcu105_SFP_10GbE is

   constant DMA_CLK_FREQ_C : real := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,                       -- 64-bit data interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 2,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

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

   signal phyReady  : sl;
   signal speed1000 : sl := '0';
   signal speed100  : sl := '0';
   signal speed10   : sl := '0';
   signal linkUp    : sl := '0';

   signal efuse    : slv(31 downto 0);
   signal localMac : slv(47 downto 0);

   signal ibMacMaster : AxiStreamMasterType;
   signal ibMacSlave  : AxiStreamSlaveType;
   signal obMacMaster : AxiStreamMasterType;
   signal obMacSlave  : AxiStreamSlaveType;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   led(7) <= linkUp;
   led(6) <= speed1000;
   led(5) <= speed100;
   led(4) <= speed100;
   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= phyReady;

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
         O => refClk300MHz);

   U_SysclkRstSync : entity surf.RstSync
      port map (
         clk      => refClk300MHz,
         asyncRst => extRst,
         syncRst  => refRst300MHz);

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
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtClkP          => sfpClk156P,
         gtClkN          => sfpClk156N,
         -- MGT Ports
         gtTxP(0)        => sfpTxP(0),
         gtTxN(0)        => sfpTxN(0),
         gtRxP(0)        => sfpRxP(0),
         gtRxN(0)        => sfpRxN(0));

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
         BUILD_FMC_I2C_G   => true,
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
         fmcScl        => fmcScl,
         fmcSda        => fmcSda,
         fmcLaP        => fmcHpcLaP,
         fmcLaN        => fmcHpcLaN);

end top_level;
