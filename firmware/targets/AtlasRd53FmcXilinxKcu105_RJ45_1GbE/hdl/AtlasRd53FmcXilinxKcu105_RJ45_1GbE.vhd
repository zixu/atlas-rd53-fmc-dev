-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKcu105_RJ45_1GbE.vhd
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKcu105_RJ45_1GbE is
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
end AtlasRd53FmcXilinxKcu105_RJ45_1GbE;

architecture top_level of AtlasRd53FmcXilinxKcu105_RJ45_1GbE is

   constant DMA_CLK_FREQ_C : real := 125.0E+6;  -- Units of Hz
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

   signal sysClk300NB : sl;
   signal sysClk300   : sl;
   signal sysRst300   : sl;
   signal refClk300MHz   : sl;
   signal refRst300MHz   : sl;
   signal iDelayCtrlRdy   : sl;

   signal phyReady : sl;
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

   U_TERM_GTs : entity work.Gthe3ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         refClk => refClk300MHz,
         gtRxP  => sfpRxP,
         gtRxN  => sfpRxN,
         gtTxP  => sfpTxP,
         gtTxN  => sfpTxN);
         
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

   U_SysclkRstSync : entity work.RstSync
      port map (
         clk      => refClk300MHz,
         asyncRst => extRst,
         syncRst  => refRst300MHz);         
         
   U_MarvelWrap : entity work.Sgmii88E1111LvdsUltraScale
      generic map (
         TPD_G             => TPD_G,
         STABLE_CLK_FREQ_G => 300.0E+6,
         CLKOUT1_PHASE_G   => 0.0, -- Deskew the 625MHz/312.5MHz
         AXIS_CONFIG_G     => EMAC_AXIS_CONFIG_C)
      port map (
         -- clock and reset
         extRst      => extRst,
         stableClk   => refClk300MHz,
         phyClk      => dmaClk,
         phyRst      => dmaRst,
         -- Local Configurations/status
         localMac    => localMac,
         phyReady    => phyReady,
         linkUp      => linkUp,
         speed10     => speed10,
         speed100    => speed100,
         speed1000   => speed1000,
         -- Interface to Ethernet Media Access Controller (MAC)
         macClk      => dmaClk,
         macRst      => dmaRst,
         obMacMaster => obMacMaster,
         obMacSlave  => obMacSlave,
         ibMacMaster => ibMacMaster,
         ibMacSlave  => ibMacSlave,
         -- ETH external PHY Ports
         phyClkP     => ethClkP,
         phyClkN     => ethClkN,
         phyMdc      => phyMdc,
         phyMdio     => phyMdio,
         phyRstN     => phyRstN,
         phyIrqN     => phyIrqN,
         -- LVDS SGMII Ports
         sgmiiTxP    => ethTxP,
         sgmiiTxN    => ethTxN,
         sgmiiRxP    => ethRxP,
         sgmiiRxN    => ethRxN);         
         
   led(7) <= linkUp;
   led(6) <= speed1000;
   led(5) <= speed100;
   led(4) <= speed100;
   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= phyReady;         

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

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
