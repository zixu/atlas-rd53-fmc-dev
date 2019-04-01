-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxZcu102.vhd
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
use work.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxZcu102 is
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
end AtlasRd53FmcXilinxZcu102;

architecture TOP_LEVEL of AtlasRd53FmcXilinxZcu102 is

   signal axilClk : sl;
   signal axilRst : sl;

   signal dmaClk       : slv(3 downto 0);
   signal dmaRst       : slv(3 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(3 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(3 downto 0);
   signal dmaObMasters : AxiStreamMasterArray(3 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal sfpClk156     : sl;
   signal sfpClk156Bufg : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "xapp_idelay";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   dmaClk <= (others => axilClk);
   dmaRst <= (others => axilRst);

   U_IBUFDS_GTE4 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => sfpClk156P,
         IB    => sfpClk156N,
         CEB   => '0',
         ODIV2 => sfpClk156,
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => sfpClk156,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => sfpClk156Bufg);

   U_MMCM : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 6.0,
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 300 MHz = 937.5 MHz/3.125
      port map(
         clkIn     => sfpClk156Bufg,
         rstIn     => dmaRst(0),
         clkOut(0) => refClk300MHz,
         rstOut(0) => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   -------
   -- Core
   -------
   U_Core : entity work.XilinxZcu102Core
      generic map (
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         SIM_MEM_PORT_NUM_G => 9000,
         SIM_DMA_PORT_NUM_G => 8000,
         SIM_DMA_CHANNELS_G => 4,
         SIM_DMA_TDESTS_G   => 8,
         BUILD_INFO_G       => BUILD_INFO_G)
      port map (
         -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
         axiClk             => axilClk,
         axiClkRst          => axilRst,
         ------------------------------------------------------------------------------------------------------
         -- Not using IOMEMORY interface because the slow I2C transactions would bottleneck the CPU performance 
         -- We will use SRPv3 on the DMA to do register access through a messaging protocol instead
         ------------------------------------------------------------------------------------------------------
         extAxilReadMaster  => open,
         extAxilReadSlave   => AXI_LITE_READ_SLAVE_EMPTY_OK_C,
         extAxilWriteMaster => open,
         extAxilWriteSlave  => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClk,
         dmaClkRst          => dmaRst,
         dmaObMaster        => dmaObMasters,
         dmaObSlave         => dmaObSlaves,
         dmaIbMaster        => dmaIbMasters,
         dmaIbSlave         => dmaIbSlaves);

   ----------
   -- SFP GTs
   ----------
   U_TERM_GTs : entity work.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         refClk => axilClk,
         gtRxP  => sfpRxP,
         gtRxN  => sfpRxN,
         gtTxP  => sfpTxP,
         gtTxN  => sfpTxN);

   -------------
   -- FMC Module
   -------------
   U_App : entity work.AtlasRd53FmcCore
      generic map (
         TPD_G             => TPD_G,
         SIMULATION_G      => SIMULATION_G,
         DMA_AXIS_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C,
         DMA_CLK_FREQ_G    => 125.0E+6,
         XIL_DEVICE_G      => "ULTRASCALE_PLUS")
      port map (
         -- I/O Delay Interfaces
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- DMA Interface (dmaClk domain)
         dmaClk        => dmaClk(0),
         dmaRst        => dmaRst(0),
         dmaObMasters  => dmaObMasters(1 downto 0),
         dmaObSlaves   => dmaObSlaves(1 downto 0),
         dmaIbMasters  => dmaIbMasters(1 downto 0),
         dmaIbSlaves   => dmaIbSlaves(1 downto 0),
         -- FMC LPC Ports
         fmcLaP        => fmcHpc0LaP,
         fmcLaN        => fmcHpc0LaN);

   ---------------
   -- DMA Loopback
   ---------------
   dmaIbMasters(3 downto 2) <= dmaObMasters(3 downto 2);
   dmaObSlaves(3 downto 2)  <= dmaIbSlaves(3 downto 2);

end TOP_LEVEL;
