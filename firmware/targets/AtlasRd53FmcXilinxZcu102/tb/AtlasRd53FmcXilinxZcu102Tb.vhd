-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxZcu102Tb.vhd
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

use work.StdRtlPkg.all;
use work.BuildInfoPkg.all;

entity AtlasRd53FmcXilinxZcu102Tb is end AtlasRd53FmcXilinxZcu102Tb;

architecture testbed of AtlasRd53FmcXilinxZcu102Tb is

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
   signal cnt     : slv(3 downto 0)               := (others => '0');
   signal hit     : slv(CNT_SIZE_C-1 downto 0)    := (others => '0');
   signal hitPntr : natural range 0 to CNT_SIZE_C := 0;

   signal dPortRstL  : sl                    := '0';
   signal dPortDataP : Slv4Array(3 downto 0) := (others => x"0");
   signal dPortDataN : Slv4Array(3 downto 0) := (others => x"F");
   signal dPortHitP  : Slv4Array(3 downto 0) := (others => x"0");
   signal dPortHitN  : Slv4Array(3 downto 0) := (others => x"F");
   signal dPortCmdP  : slv(3 downto 0)       := x"0";
   signal dPortCmdN  : slv(3 downto 0)       := x"F";

   signal sfpClk156P : sl := '0';
   signal sfpClk156N : sl := '1';

   signal fmcHpc0LaP : slv(33 downto 0) := (others => 'Z');
   signal fmcHpc0LaN : slv(33 downto 0) := (others => 'Z');
   signal fmcHpc1LaP : slv(29 downto 0) := (others => 'Z');
   signal fmcHpc1LaN : slv(29 downto 0) := (others => 'Z');

begin

   ---------------------------------------------------
   -- Only simulating 1 of the 4 DPORT pair interfaces
   ---------------------------------------------------
   GEN_VEC : for i in 0 downto 0 generate
      U_ASIC : Rd53aWrapper
         port map (
            HIT_CLK         => hitClk,
            HIT             => hit,
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

   U_FmcMapping : entity work.AtlasRd53FmcSimMapping
      generic map (
         TPD_G => TPD_G)
      port map (
         -- mDP DATA/CMD Interface
         dPortDataP => dPortDataP,
         dPortDataN => dPortDataN,
         dPortCmdP  => dPortCmdP,
         dPortCmdN  => dPortCmdN,
         -- FMC LPC Ports
         fmcLaP     => fmcHpc0LaP,
         fmcLaN     => fmcHpc0LaN);

   U_ClkPgp : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,   -- 156.25 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => sfpClk156P,
         clkN => sfpClk156N,
         rstL => dPortRstL);

   U_Fpga : entity work.AtlasRd53FmcXilinxZcu102
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => true,
         BUILD_INFO_G => BUILD_INFO_C)
      port map (
         -- FMC Interface
         fmcHpc0LaP => fmcHpc0LaP,
         fmcHpc0LaN => fmcHpc0LaN,
         fmcHpc1LaP => fmcHpc1LaP,
         fmcHpc1LaN => fmcHpc1LaN,
         -- SFP Interface
         sfpClk156P => sfpClk156P,
         sfpClk156N => sfpClk156N,
         sfpTxP     => open,
         sfpTxN     => open,
         sfpRxP     => (others => '0'),
         sfpRxN     => (others => '1'));

end testbed;
