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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxZcu102 is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      -- PGP_TYPE_G   : boolean := false;        -- False: PGPv2b
      PGP_TYPE_G   : boolean := true;        -- True: PGPv3
      PGP3_RATE_G  : string  := "6.25Gbps";
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
      sfpEnTx    : out   slv(3 downto 0) := x"F";
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

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal sfpClk156     : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   -----------
   -- RCE Core
   -----------
   U_Core : entity rce_gen3_fw_lib.XilinxZcu102Core
      generic map (
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         SIM_MEM_PORT_NUM_G => 9000,
         SIM_DMA_PORT_NUM_G => 8000,
         SIM_DMA_CHANNELS_G => 4,
         SIM_DMA_TDESTS_G   => (4*16),
         BUILD_INFO_G       => BUILD_INFO_G)
      port map (
         -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
         axiClk             => axilClk,
         axiClkRst          => axilRst,
         extAxilReadMaster  => axilReadMaster,
         extAxilReadSlave   => axilReadSlave,
         extAxilWriteMaster => axilWriteMaster,
         extAxilWriteSlave  => axilWriteSlave,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClk,
         dmaClkRst          => dmaRst,
         dmaObMaster        => dmaObMasters,
         dmaObSlave         => dmaObSlaves,
         dmaIbMaster        => dmaIbMasters,
         dmaIbSlave         => dmaIbSlaves);

   ---------------------------------------
   -- Connecting the dmaClk to the axilClk
   ---------------------------------------
   dmaClk <= (others => axilClk);
   dmaRst <= (others => axilRst);

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
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 6.0,
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 300 MHz = 937.5 MHz/3.125
      port map(
         clkIn     => sfpClk156,
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

   -------------
   -- FMC Module
   -------------
   U_App : entity work.AtlasRd53FmcCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
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
         dmaObMasters  => dmaObMasters(1 downto 0),  -- DMA[0] = DATA, DMA[1] = AXI-Lite Config
         dmaObSlaves   => dmaObSlaves(1 downto 0),
         dmaIbMasters  => dmaIbMasters(1 downto 0),
         dmaIbSlaves   => dmaIbSlaves(1 downto 0),
         -- FMC LPC Ports
         fmcLaP        => fmcHpc0LaP,
         fmcLaN        => fmcHpc0LaN);

   -----------------------
   -- PGP on the SFP cages
   -----------------------
   U_Pgp : entity work.Zcu102PgpWrapper
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => SIMULATION_G,
         ROGUE_SIM_PORT_NUM_G => 4000,
         DMA_AXIS_CONFIG_G    => RCEG3_AXIS_DMA_ACP_CONFIG_C,
         PGP_TYPE_G           => PGP_TYPE_G,
         PGP3_RATE_G          => PGP3_RATE_G,
         AXIL_CLK_FREQ_G      => 125.0E+6,  -- units of Hz
         AXI_BASE_ADDR_G      => x"A000_0000")
      port map (
         ------------------------
         --  Top Level Interfaces
         ------------------------
         -- Reference Clock
         sfpClk156       => sfpClk156,
         -- AXI-Lite Interface
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- PGP Streams (axilClk domain)
         dmaObMaster     => dmaObMasters(2),
         dmaObSlave      => dmaObSlaves(2),
         dmaIbMaster     => dmaIbMasters(2),
         dmaIbSlave      => dmaIbSlaves(2),
         -- SFP Interface
         sfpClk156P      => sfpClk156P,
         sfpClk156N      => sfpClk156N,
         sfpTxP          => sfpTxP,
         sfpTxN          => sfpTxN,
         sfpRxP          => sfpRxP,
         sfpRxN          => sfpRxN);

   --------------------------------
   -- DMA Loopback on DMA Channel#3
   --------------------------------
   dmaIbMasters(3) <= dmaObMasters(3);
   dmaObSlaves(3)  <= dmaIbSlaves(3);

end TOP_LEVEL;
