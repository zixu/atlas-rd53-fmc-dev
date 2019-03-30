-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcSimMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: FMC mappipng
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

   GEN_DP :
   for i in 3 downto 0 generate

      dPortCmdP(i) <= fmcLaP(5+i*5);
      dPortCmdN(i) <= fmcLaN(5+i*5);

      GEN_LANE :
      for j in 3 downto 0 generate
         fmcLaP(6+i*5+j) <= dPortDataP(i)(j);
         fmcLaN(6+i*5+j) <= dPortDataN(i)(j);
      end generate GEN_LANE;

   end generate GEN_DP;

end mapping;
