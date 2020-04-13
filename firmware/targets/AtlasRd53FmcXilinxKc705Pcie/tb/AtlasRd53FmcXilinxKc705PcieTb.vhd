-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKc705PcieTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the FPGA module
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;

library ruckus;
use ruckus.BuildInfoPkg.all;

library atlas_rd53_fw_lib;

entity AtlasRd53FmcXilinxKc705PcieTb is end AtlasRd53FmcXilinxKc705PcieTb;

architecture testbed of AtlasRd53FmcXilinxKc705PcieTb is

   constant TPD_G      : time     := 1 ns;
   constant CNT_SIZE_C : positive := 384*400;

   component Rd53aWrapper
      port (
         HIT_CLK         : out sl;
         HIT             : in  slv(CNT_SIZE_C-1 downto 0);
         ------------------------
         -- Power-on Resets (POR)
         ------------------------
         POR_EXT_CAP_PAD : in  sl;
         -------------------------------------------------------------
         -- Clock Data Recovery (CDR) input command/data stream [SLVS]
         -------------------------------------------------------------
         CMD_P_PAD       : in  sl;
         CMD_N_PAD       : in  sl;
         -----------------------------------------------------
         -- 4x general-purpose SLVS outputs, including Hit-ORs
         -----------------------------------------------------
         GPLVDS0_P_PAD   : out sl;
         GPLVDS0_N_PAD   : out sl;
         GPLVDS1_P_PAD   : out sl;
         GPLVDS1_N_PAD   : out sl;
         GPLVDS2_P_PAD   : out sl;
         GPLVDS2_N_PAD   : out sl;
         GPLVDS3_P_PAD   : out sl;
         GPLVDS3_N_PAD   : out sl;
         ------------------------------------------------
         -- 4x serial output data links @ 1.28 Gb/s [CML]
         ------------------------------------------------
         GTX0_P_PAD      : out sl;
         GTX0_N_PAD      : out sl;
         GTX1_P_PAD      : out sl;
         GTX1_N_PAD      : out sl;
         GTX2_P_PAD      : out sl;
         GTX2_N_PAD      : out sl;
         GTX3_P_PAD      : out sl;
         GTX3_N_PAD      : out sl);
   end component;

   signal hitClk  : sl                            := '0';
   signal cnt     : slv(15 downto 0)              := (others => '0');
   signal hit     : slv(CNT_SIZE_C-1 downto 0)    := (others => '0');
   signal hitPntr : natural range 0 to CNT_SIZE_C := 0;

   signal dPortRstL  : sl                    := '0';
   signal dPortDataP : Slv4Array(3 downto 0) := (others => x"0");
   signal dPortDataN : Slv4Array(3 downto 0) := (others => x"F");
   signal dPortHitP  : Slv4Array(3 downto 0) := (others => x"0");
   signal dPortHitN  : Slv4Array(3 downto 0) := (others => x"F");
   signal dPortCmdP  : slv(3 downto 0)       := x"0";
   signal dPortCmdN  : slv(3 downto 0)       := x"F";

   signal sfpClk125P : sl := '0';
   signal sfpClk125N : sl := '1';

   signal fmcHpcLaP : slv(33 downto 0) := (others => 'Z');
   signal fmcHpcLaN : slv(33 downto 0) := (others => 'Z');
   signal fmcLpcLaP : slv(33 downto 0) := (others => 'Z');
   signal fmcLpcLaN : slv(33 downto 0) := (others => 'Z');

begin

   ---------------------------------------------------
   -- Only simulating 1 of the 4 DPORT pair interfaces
   ---------------------------------------------------
   GEN_VEC : for i in 0 downto 0 generate
      U_ASIC : Rd53aWrapper
         port map (
            HIT_CLK         => hitClk,
            -- HIT             => hit,
            HIT             => (others => '1'),
            ------------------------
            -- Power-on Resets (POR)
            ------------------------
            POR_EXT_CAP_PAD => dPortRstL,
            -------------------------------------------------------------
            -- Clock Data Recovery (CDR) input command/data stream [SLVS]
            -------------------------------------------------------------
            CMD_P_PAD       => dPortCmdP(i),
            CMD_N_PAD       => dPortCmdN(i),
            -----------------------------------------------------
            -- 4x general-purpose SLVS outputs, including Hit-ORs
            -----------------------------------------------------
            GPLVDS0_P_PAD   => dPortHitP(i)(0),
            GPLVDS0_N_PAD   => dPortHitN(i)(0),
            GPLVDS1_P_PAD   => dPortHitP(i)(1),
            GPLVDS1_N_PAD   => dPortHitN(i)(1),
            GPLVDS2_P_PAD   => dPortHitP(i)(2),
            GPLVDS2_N_PAD   => dPortHitN(i)(2),
            GPLVDS3_P_PAD   => dPortHitP(i)(3),
            GPLVDS3_N_PAD   => dPortHitN(i)(3),
            ------------------------------------------------
            -- 4x serial output data links @ 1.28 Gb/s [CML]
            ------------------------------------------------
            GTX0_P_PAD      => dPortDataP(i)(0),
            GTX0_N_PAD      => dPortDataN(i)(0),
            GTX1_P_PAD      => dPortDataP(i)(1),
            GTX1_N_PAD      => dPortDataN(i)(1),
            GTX2_P_PAD      => dPortDataP(i)(2),
            GTX2_N_PAD      => dPortDataN(i)(2),
            GTX3_P_PAD      => dPortDataP(i)(3),
            GTX3_N_PAD      => dPortDataN(i)(3));
   end generate GEN_VEC;

   U_FmcMapping : entity atlas_rd53_fw_lib.AtlasRd53FmcSimMapping
      generic map (
         TPD_G => TPD_G)
      port map (
         -- mDP DATA/CMD Interface
         dPortDataP => dPortDataP,
         dPortDataN => dPortDataN,
         dPortCmdP  => dPortCmdP,
         dPortCmdN  => dPortCmdN,
         -- FMC LPC Ports
         fmcLaP     => fmcHpcLaP,
         fmcLaN     => fmcHpcLaN);

   U_ClkPgp : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => 8.0 ns,   -- 125 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => sfpClk125P,
         clkN => sfpClk125N,
         rstL => dPortRstL);

   U_Fpga : entity work.AtlasRd53FmcXilinxKc705Pcie
      generic map (
         TPD_G          => TPD_G,
         ROGUE_SIM_EN_G => true,
         BUILD_INFO_G   => BUILD_INFO_C)
      port map (
         ---------------------
         --  Application Ports
         ---------------------
         -- FMC Interface
         fmcHpcLaP  => fmcHpcLaP,
         fmcHpcLaN  => fmcHpcLaN,
         fmcLpcLaP  => fmcLpcLaP,
         fmcLpcLaN  => fmcLpcLaN,
         -- SFP Interface
         sfpClk125P => sfpClk125P,
         sfpClk125N => sfpClk125N,
         sfpTxP     => open,
         sfpTxN     => open,
         sfpRxP     => '0',
         sfpRxN     => '1',
         --------------
         --  Core Ports
         --------------
         -- System Ports
         emcClk     => '0',
         -- Boot Memory Ports
         bootCsL    => open,
         bootMosi   => open,
         bootMiso   => '1',
         -- PCIe Ports
         pciRstL    => '1',
         pciRefClkP => '0',
         pciRefClkN => '1',
         pciRxP     => (others => '0'),
         pciRxN     => (others => '1'),
         pciTxP     => open,
         pciTxN     => open);

end testbed;
