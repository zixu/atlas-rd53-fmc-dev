-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcSimMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: FMC mapping
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcSimMapping is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- mDP DATA/CMD Interface
      dPortDataP : in    Slv4Array(3 downto 0);
      dPortDataN : in    Slv4Array(3 downto 0);
      dPortCmdP  : out   slv(3 downto 0);
      dPortCmdN  : out   slv(3 downto 0);
      -- FMC LPC Ports
      fmcLaP     : inout slv(33 downto 0);
      fmcLaN     : inout slv(33 downto 0));
end AtlasRd53FmcSimMapping;

architecture mapping of AtlasRd53FmcSimMapping is

begin

   GEN_PLL_CLK :
   for i in 1 downto 0 generate
      U_ClkRst : entity surf.ClkRst
         generic map (
            CLK_PERIOD_G      => 6.237 ns,
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => fmcLaP(i),
            clkN => fmcLaN(i));
   end generate GEN_PLL_CLK;

   GEN_DP :
   for i in 3 downto 0 generate

      dPortCmdP(i) <= fmcLaP(5+i*5);
      dPortCmdN(i) <= fmcLaN(5+i*5);

      GEN_LANE :
      for j in 3 downto 0 generate
         fmcLaP(6+i*5+j) <= dPortDataN(i)(3-j); -- Inverted and lane reversal
         fmcLaN(6+i*5+j) <= dPortDataP(i)(3-j); -- Inverted and lane reversal
      end generate GEN_LANE;

   end generate GEN_DP;

end mapping;