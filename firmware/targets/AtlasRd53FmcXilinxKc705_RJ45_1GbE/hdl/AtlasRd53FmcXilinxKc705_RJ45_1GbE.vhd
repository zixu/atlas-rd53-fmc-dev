-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKc705_RJ45_1GbE.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for Xilinx KC705 board (1 GbE on the RJ45)
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
use work.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKc705_RJ45_1GbE is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst     : in    sl;
      led        : out   slv(7 downto 0);
      -- SGMII Interface
      sgmiiTxP   : out   sl;
      sgmiiTxN   : out   sl;
      sgmiiRxP   : in    sl;
      sgmiiRxN   : in    sl;
      -- ETH external PHY pins
      phyMdc     : out   sl;
      phyMdio    : inout sl;
      phyRstN    : out   sl;            -- active low
      phyIrqN    : in    sl;            -- active low      
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
end AtlasRd53FmcXilinxKc705_RJ45_1GbE;

architecture top_level of AtlasRd53FmcXilinxKc705_RJ45_1GbE is

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

   signal sfpClk125     : sl;
   signal sfpClk62p5    : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   signal phyMdo      : sl;
   signal phyMdi      : sl;
   signal phyReady    : sl;
   signal extPhyReady : sl;
   signal phyInitRst  : sl;
   signal extPhyRstN  : sl;
   signal initDone    : sl;
   signal sp10_100    : sl := '0';
   signal sp100       : sl := '0';
   signal speed1000   : sl := '0';
   signal speed100    : sl := '0';
   signal speed10     : sl := '0';
   signal linkUp      : sl := '0';

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

   IBUFDS_GTE2_Inst : IBUFDS_GTE2
      port map (
         I     => sfpClk125P,
         IB    => sfpClk125N,
         CEB   => '0',
         ODIV2 => sfpClk62p5,
         O     => sfpClk125);

   U_MMCM : entity work.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 16.0,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 15.0,
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 300 MHz = 937.5 MHz/3.125    
      port map(
         clkIn     => sfpClk62p5,
         rstIn     => dmaRst,
         clkOut(0) => refClk300MHz,
         rstOut(0) => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   U_TermGt : entity work.Gtxe2ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 1)
      port map (
         refClk   => sfpClk125,
         gtRxP(0) => sfpRxP,
         gtRxN(0) => sfpRxN,
         gtTxP(0) => sfpTxP,
         gtTxN(0) => sfpTxN);

   U_EFuse : EFUSE_USR
      port map (
         EFUSEUSR => efuse);

   localMac(23 downto 0)  <= x"56_00_08";  -- 08:00:56:XX:XX:XX (big endian SLV)   
   localMac(47 downto 24) <= efuse(31 downto 8);

   -------------------------
   -- GigE Core for KINTEX-7
   -------------------------
   U_ETH_PHY_MAC : entity work.GigEthGtx7Wrapper
      generic map (
         TPD_G              => TPD_G,
         NUM_LANE_G         => 1,
         -- Clocking Configurations
         USE_GTREFCLK_G     => true,
         CLKIN_PERIOD_G     => 16.0,    -- 62.5 MHz
         CLKFBOUT_MULT_F_G  => 16.0,    -- 1.0 GHz
         CLKOUT0_DIVIDE_F_G => 8.0,     -- 125 MHz
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (others => EMAC_AXIS_CONFIG_C))
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
         phyClk          => dmaClk,
         phyRst          => dmaRst,
         phyReady(0)     => phyReady,
         -- MGT Ports
         gtRefClk        => sfpClk62p5,
         gtTxP(0)        => sgmiiTxP,
         gtTxN(0)        => sgmiiTxN,
         gtRxP(0)        => sgmiiRxP,
         gtRxN(0)        => sgmiiRxN);

   U_PwrUpRst0 : entity work.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '1',
         OUT_POLARITY_G => '0',
         DURATION_G     => getTimeRatio(300.0E+6, 100.0))  -- 10 ms reset
      port map (
         arst   => extRst,
         clk    => refClk300MHz,
         rstOut => extPhyRstN);

   U_PwrUpRst1 : entity work.PwrUpRst
      generic map(
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '0',
         DURATION_G     => getTimeRatio(300.0E+6, 100.0))  -- 10 ms reset
      port map (
         arst   => extPhyRstN,
         clk    => refClk300MHz,
         rstOut => extPhyReady);

   U_PhyInitRstSync : entity work.RstSync
      generic map (
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => dmaClk,
         asyncRst => extPhyReady,
         syncRst  => phyInitRst);

   U_PhyCtrl : entity work.Sgmii88E1111Mdio
      generic map (
         TPD_G => TPD_G,
         PHY_G => 7,
         DIV_G => 100)
      port map (
         clk             => dmaClk,
         rst             => phyInitRst,
         initDone        => initDone,
         speed_is_10_100 => sp10_100,
         speed_is_100    => sp100,
         linkIsUp        => linkUp,
         mdi             => phyMdi,
         mdc             => phyMdc,
         mdo             => phyMdo,
         linkIrq         => phyIrqN);

   phyRstN   <= extPhyRstN;
   speed10   <= sp10_100 and not sp100;
   speed100  <= sp10_100 and not sp100;
   speed1000 <= not sp10_100 and not sp100;

   -- Tri-state driver for phyMdio
   phyMdio <= 'Z' when phyMdo = '1' else '0';

   U_SyncMdi : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => dmaClk,
         dataIn  => phyMdio,
         dataOut => phyMdi);

   led(7) <= linkUp;
   led(6) <= speed1000;
   led(5) <= speed100;
   led(4) <= speed100;
   led(3) <= initDone;
   led(2) <= phyReady;
   led(1) <= phyReady;
   led(0) <= '1';

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

