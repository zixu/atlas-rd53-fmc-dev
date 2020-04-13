-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKc705Pcie.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: AXI PCIe Core for Xilinx KC705 board (PCIe GEN2 x 4 lanes)
--
-- https://www.xilinx.com/products/boards-and-kits/kc705.html
--
-- Note: Using the QSPI (not BPI) for booting from PROM.
--       J3 needs to have the jumper installed
--       SW13 needs to be in the "00001" position to set FPGA.M[2:0] = "001"
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKc705Pcie is
   generic (
      TPD_G          : time    := 1 ns;
      ROGUE_SIM_EN_G : boolean := false;
      BUILD_INFO_G   : BuildInfoType);
   port (
      ---------------------
      --  Application Ports
      ---------------------
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
      sfpRxN     : in    sl;
      -------------------
      --  Top Level Ports
      -------------------
      -- System Ports
      emcClk     : in    sl;
      -- Boot Memory Ports
      bootCsL    : out   sl;
      bootMosi   : out   sl;
      bootMiso   : in    sl;
      -- PCIe Ports
      pciRstL    : in    sl;
      pciRefClkP : in    sl;            -- 100 MHz
      pciRefClkN : in    sl;            -- 100 MHz
      pciRxP     : in    slv(3 downto 0);
      pciRxN     : in    slv(3 downto 0);
      pciTxP     : out   slv(3 downto 0);
      pciTxN     : out   slv(3 downto 0));
end AtlasRd53FmcXilinxKc705Pcie;

architecture top_level of AtlasRd53FmcXilinxKc705Pcie is

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

   U_MMCM : entity surf.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => ROGUE_SIM_EN_G,
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

   U_TermGt : entity surf.Gtxe2ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 1)
      port map (
         refClk   => sfpClk125,
         gtRxP(0) => sfpRxP,
         gtRxN(0) => sfpRxN,
         gtTxP(0) => sfpTxP,
         gtTxN(0) => sfpTxN);

   -----------------------
   -- axi-pcie-core module
   -----------------------
   U_Core : entity axi_pcie_core.XilinxKc705Core
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
         ROGUE_SIM_PORT_NUM_G => 8000,
         ROGUE_SIM_CH_COUNT_G => 8,
         BUILD_INFO_G         => BUILD_INFO_G,
         DMA_SIZE_G           => 2)
      port map (
         ------------------------
         --  Top Level Interfaces
         ------------------------
         -- DMA Interfaces
         dmaClk         => dmaClk,
         dmaRst         => dmaRst,
         dmaObMasters   => dmaObMasters,
         dmaObSlaves    => dmaObSlaves,
         dmaIbMasters   => dmaIbMasters,
         dmaIbSlaves    => dmaIbSlaves,
         -- Application AXI-Lite Interfaces [0x00080000:0x00FFFFFF]
         appClk         => dmaClk,
         appRst         => dmaRst,
         ------------------------------------------------------------------------------------------------------
         -- Not using IOMEMORY interface because the slow I2C transactions would bottleneck the CPU performance
         -- We will use SRPv3 on the DMA to do register access through a messaging protocol instead
         ------------------------------------------------------------------------------------------------------
         appReadMaster  => open,
         appReadSlave   => AXI_LITE_READ_SLAVE_EMPTY_OK_C,
         appWriteMaster => open,
         appWriteSlave  => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C,
         -------------------
         --  Top Level Ports
         -------------------
         -- System Ports
         emcClk         => emcClk,
         -- Boot Memory Ports
         bootCsL        => bootCsL,
         bootMosi       => bootMosi,
         bootMiso       => bootMiso,
         -- PCIe Ports
         pciRstL        => pciRstL,
         pciRefClkP     => pciRefClkP,
         pciRefClkN     => pciRefClkN,
         pciRxP         => pciRxP,
         pciRxN         => pciRxN,
         pciTxP         => pciTxP,
         pciTxN         => pciTxN);

   -------------
   -- FMC Module
   -------------
   U_App : entity work.AtlasRd53FmcCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         SIMULATION_G      => ROGUE_SIM_EN_G,
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

