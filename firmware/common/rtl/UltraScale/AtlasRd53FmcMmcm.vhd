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
      -- Timing Clocks Interface
      clk640MHz : out sl;
      clk160MHz : out sl;
      -- Timing Resets Interface
      rst640MHz : out sl;
      rst160MHz : out sl);
end AtlasRd53FmcMmcm;

architecture mapping of AtlasRd53FmcMmcm is

begin

   U_MMCM : entity work.ClockManagerUltraScale
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
         CLKOUT1_DIVIDE_G   => 8,       -- 160 MHz = 1.28 GHz/8
         CLKOUT2_DIVIDE_G   => 16,      -- 80 MHz = 1.28 GHz/16
         CLKOUT3_DIVIDE_G   => 32)      -- 40 MHz = 1.28 GHz/32
      port map(
         clkIn     => pllClk,
         rstIn     => pllRst,
         -- Clock Outputs
         clkOut(0) => clk640MHz,
         clkOut(1) => clk160MHz,
         -- Reset Outputs
         rstOut(0) => rst640MHz,
         rstOut(1) => rst160MHz);

end mapping;
