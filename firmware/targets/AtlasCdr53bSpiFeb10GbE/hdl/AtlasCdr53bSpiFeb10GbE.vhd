-------------------------------------------------------------------------------
-- File       : AtlasCdr53bSpiFeb10GbE.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top-Level module using 10 GbE communication
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
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasCdr53bSpiFeb10GbE is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- RD53 ASIC Serial Ports
      dPortDataP    : inout Slv4Array(3 downto 0);
      dPortDataN    : inout Slv4Array(3 downto 0);
      dPortCmdP     : inout slv(3 downto 0);
      dPortCmdN     : inout slv(3 downto 0);
      -- Reference Clock
      refClk160MHzP : in    sl;
      refClk160MHzN : in    sl;
      -- QSFP Ports
      led           : out   slv(3 downto 0);
      qsfpLpMode    : out   sl;
      qsfpRst       : out   sl;
      qsfpSel       : out   sl;
      -- PGP Ports
      pgpClkP       : in    sl;
      pgpClkN       : in    sl;
      pgpRxP        : in    slv(3 downto 0);
      pgpRxN        : in    slv(3 downto 0);
      pgpTxP        : out   slv(3 downto 0);
      pgpTxN        : out   slv(3 downto 0));
end AtlasCdr53bSpiFeb10GbE;

architecture top_level of AtlasCdr53bSpiFeb10GbE is

   constant DMA_CLK_FREQ_C : real := 156.25E+6;  -- Units of Hz
   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,                        -- 64-bit data interface
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

   signal phyReady : sl;

   signal efuse    : slv(31 downto 0);
   signal localMac : slv(47 downto 0);

   signal ibMacMaster : AxiStreamMasterType;
   signal ibMacSlave  : AxiStreamSlaveType;
   signal obMacMaster : AxiStreamMasterType;
   signal obMacSlave  : AxiStreamSlaveType;

begin

   qsfpLpMode <= '0';
   qsfpRst    <= dmaRst;
   qsfpSel    <= '1';

   led(3) <= phyReady;
   led(2) <= phyReady;
   led(1) <= not(dmaRst);
   led(0) <= '1';

   U_10GigE : entity surf.TenGigEthGtx7Wrapper
      generic map (
         TPD_G         => TPD_G,
         REFCLK_DIV2_G => true)         -- TRUE: gtClkP/N = 312.5 MHz
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
         phyClk          => dmaClk,
         phyRst          => dmaRst,
         phyReady(0)     => phyReady,
         -- MGT Clock Port (156.25 MHz or 312.5 MHz)
         gtClkP          => pgpClkP,
         gtClkN          => pgpClkN,
         -- MGT Ports
         gtTxP(0)        => pgpTxP(0),
         gtTxN(0)        => pgpTxN(0),
         gtRxP(0)        => pgpRxP(0),
         gtRxN(0)        => pgpRxN(0));

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
   -- FEB Module
   -------------         
   U_App : entity work.AtlasCdr53bSpiFebCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DMA_CLK_FREQ_G    => DMA_CLK_FREQ_C,
         XIL_DEVICE_G      => "7SERIES")
      port map (
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
