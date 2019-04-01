-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcMmcm.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: FMC MMCM
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcMmcm is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      pllClk    : in  sl;
      pllRst    : in  sl;
      -- Timing Clock/Reset Interface
      clk640MHz : out sl;
      clk160MHz : out sl;
      rst160MHz : out sl);
end AtlasRd53FmcMmcm;

architecture mapping of AtlasRd53FmcMmcm is

   signal clkOut : slv(1 downto 0);
   signal rstOut : slv(1 downto 0);

begin

   clk640MHz <= clkOut(0);
   clk160MHz <= clkOut(1);

   U_MMCM : entity work.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         TYPE_G             => "MMCM",
         BANDWIDTH_G        => "OPTIMIZED",
         INPUT_BUFG_G       => true,
         FB_BUFG_G          => true,
         NUM_CLOCKS_G       => 2,
         CLKIN_PERIOD_G     => 6.256,   -- 160 MHz
         DIVCLK_DIVIDE_G    => 1,       -- 160 MHz = 160 MHz/1
         CLKFBOUT_MULT_F_G  => 8.0,     -- 1.28 GHz = 160 MHz x 8
         CLKOUT0_DIVIDE_F_G => 2.0,     -- 640 MHz = 1.28 GHz/2
         CLKOUT1_DIVIDE_G   => 8)       -- 160 MHz = 1.28 GHz/8
      port map(
         clkIn  => pllClk,
         rstIn  => pllRst,
         -- Clock Outputs
         clkOut => clkOut,
         -- Reset Outputs
         rstOut => rstOut);

   U_Reset : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clkOut(1),
         rstIn  => rstOut(1),
         rstOut => rst160MHz);

end mapping;
