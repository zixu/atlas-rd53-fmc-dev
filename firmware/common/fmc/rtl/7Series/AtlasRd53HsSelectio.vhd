-------------------------------------------------------------------------------
-- File       : AtlasRd53HsSelectio.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: PLL and Deserialization
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

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53HsSelectio is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      XIL_DEVICE_G : string  := "7SERIES");
   port (
      ref160Clk     : in  sl;
      ref160Rst     : in  sl;
      -- Deserialization Interface
      serDesData    : out Slv8Array(15 downto 0);
      dlyLoad       : in  slv(15 downto 0);
      dlyCfg        : in  Slv9Array(15 downto 0);
      iDelayCtrlRdy : in  sl;
      -- mDP DATA Interface
      dPortDataP    : in  Slv4Array(3 downto 0);
      dPortDataN    : in  Slv4Array(3 downto 0);
      -- Timing Clock/Reset Interface
      clk160MHz     : out sl;
      rst160MHz     : out sl);
end AtlasRd53HsSelectio;

architecture mapping of AtlasRd53HsSelectio is

   signal clock640MHz : sl;
   signal reset640MHz : sl;
   signal clock160MHz : sl;
   signal reset160MHz : sl;

begin

   clk160MHz <= clock160MHz;
   rst160MHz <= reset160MHz;

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
         clkIn     => ref160Clk,
         rstIn     => ref160Rst,
         -- Clock Outputs
         clkOut(0) => clock640MHz,
         clkOut(1) => clock160MHz,
         -- Reset Outputs
         rstOut(0) => reset640MHz,
         rstOut(1) => reset160MHz);

   GEN_mDP :
   for i in 3 downto 0 generate
      GEN_LANE :
      for j in 3 downto 0 generate
         U_Lane : entity work.AuroraRxLaneDeser
            generic map (
               TPD_G => TPD_G)
            port map (
               -- RD53 ASIC Serial Interface
               dPortDataP    => dPortDataP(i)(j),
               dPortDataN    => dPortDataN(i)(j),
               iDelayCtrlRdy => iDelayCtrlRdy,
               -- Timing Interface
               clk640MHz     => clock640MHz,
               clk160MHz     => clock160MHz,
               rst160MHz     => reset160MHz,
               -- Delay Configuration
               dlyLoad       => dlyLoad(4*i+j),
               dlyCfg        => dlyCfg(4*i+j),
               -- Output
               dataOut       => serDesData(4*i+j));
      end generate GEN_LANE;
   end generate GEN_mDP;

end mapping;
