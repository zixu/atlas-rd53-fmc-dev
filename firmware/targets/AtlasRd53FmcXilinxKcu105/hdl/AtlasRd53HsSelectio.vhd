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
      XIL_DEVICE_G : string  := "ULTRASCALE");
   port (
      ref160Clk     : in  sl;
      ref160Rst     : in  sl;
      -- Deserialization Interface
      serDesData    : out Slv8Array(15 downto 0);
      dlyCfg        : in  Slv5Array(15 downto 0);
      iDelayCtrlRdy : in  sl;
      -- mDP DATA Interface
      dPortDataP    : in  Slv4Array(3 downto 0);
      dPortDataN    : in  Slv4Array(3 downto 0);
      -- Timing Clock/Reset Interface
      clk160MHz     : out sl;
      rst160MHz     : out sl);
end AtlasRd53HsSelectio;

architecture mapping of AtlasRd53HsSelectio is

   signal locked  : sl := '0';
   signal clkFb   : sl := '0';
   signal clkout0 : sl := '0';

   signal clock640MHz : sl := '0';
   signal clock160MHz : sl := '0';
   signal reset       : sl := '1';
   signal reset160MHz : sl := '1';
   signal reset640MHz : sl := '1';

begin

   clk160MHz <= clock160MHz;
   rst160MHz <= reset160MHz;

   GEN_REAL : if (SIMULATION_G = false) generate
      U_PLL : PLLE3_ADV
         generic map (
            COMPENSATION   => "INTERNAL",
            STARTUP_WAIT   => "FALSE",
            CLKIN_PERIOD   => 6.256,    -- 160 MHz
            DIVCLK_DIVIDE  => 2,
            CLKFBOUT_MULT  => 16,       -- 1.28 GHz = 160 MHz x 16 / 2 
            CLKOUT0_DIVIDE => 2,        -- 640 MHz = 1.28 GHz/2
            CLKOUT1_DIVIDE => 8)        -- 160 MHz = 1.28 GHz/8
         port map (
            DCLK        => '0',
            DRDY        => open,
            DEN         => '0',
            DWE         => '0',
            DADDR       => (others => '0'),
            DI          => (others => '0'),
            DO          => open,
            PWRDWN      => '0',
            RST         => ref160Rst,
            CLKIN       => ref160Clk,
            CLKOUTPHYEN => '0',
            CLKFBOUT    => clkFb,
            CLKFBIN     => clkFb,
            LOCKED      => locked,
            CLKOUT0     => clkout0,
            CLKOUT1     => open);
   end generate GEN_REAL;

   GEN_SIM : if (SIMULATION_G = true) generate
      U_ClkRst : entity work.ClkRst
         generic map (
            CLK_PERIOD_G      => 6.237 ns,
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => clkout0,
            rstL => locked);   
   end generate GEN_SIM;
   
   U_Bufg640 : BUFG
      port map (
         I => clkout0,
         O => clock640MHz);

   ------------------------------------------------------------------------------------------------------
   -- 160 MHz is the ISERDESE3/OSERDESE3's CLKDIV port
   -- Refer to "Figure 3-49: Sub-Optimal to Optimal Clocking Topologies for OSERDESE3" in UG949 (v2018.2)
   -- https://www.xilinx.com/support/answers/67885.html   
   ------------------------------------------------------------------------------------------------------
   U_Bufg160 : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE   => 4)       -- 160 MHz = 640 MHz/4
      port map (
         I   => clkout0,             -- 640 MHz
         CE  => '1',
         CLR => '0',
         O   => clock160MHz);        -- 160 MHz

   U_Rst160 : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => clock160MHz,
         asyncRst => locked,
         syncRst  => reset);

   U_Reset : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clock160MHz,
         rstIn  => reset,
         rstOut => reset160MHz);   

   GEN_mDP :
   for i in 3 downto 0 generate
      GEN_LANE :
      for j in 3 downto 0 generate
         U_Lane : entity work.AuroraRxLaneDeser
            generic map (
               TPD_G        => TPD_G,
               XIL_DEVICE_G => XIL_DEVICE_G)
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
               dlyCfgIn      => dlyCfg(4*i+j),
               -- Output
               dataOut       => serDesData(4*i+j));
      end generate GEN_LANE;
   end generate GEN_mDP;

end mapping;
