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

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcMmcm is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      pllClk          : in  sl;
      pllRst          : in  sl;
      -- Timing Clock/Reset Interface
      clk640MHz       : out sl;
      clk160MHz       : out sl;
      rst160MHz       : out sl;
      -- AXI-Lite Interface 
      axilClk         : in  sl                     := '0';
      axilRst         : in  sl                     := '0';
      axilReadMaster  : in  AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end AtlasRd53FmcMmcm;

architecture mapping of AtlasRd53FmcMmcm is

   signal locked   : sl := '0';
   signal pllClock : sl := '0';
   signal reset    : sl := '1';
   signal clkFb    : sl := '0';
   signal clkout0  : sl := '0';
   signal clkout1  : sl := '0';

   signal drpRdy  : sl               := '0';
   signal drpEn   : sl               := '0';
   signal drpWe   : sl               := '0';
   signal drpAddr : slv(6 downto 0)  := (others => '0');
   signal drpDi   : slv(15 downto 0) := (others => '0');
   signal drpDo   : slv(15 downto 0) := (others => '0');

begin

   U_AxiLiteToDrp : entity work.AxiLiteToDrp
      generic map (
         TPD_G            => TPD_G,
         COMMON_CLK_G     => true,
         EN_ARBITRATION_G => false,
         TIMEOUT_G        => 4096,
         ADDR_WIDTH_G     => 7,
         DATA_WIDTH_G     => 16)
      port map (
         -- AXI-Lite Port
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- DRP Interface
         drpClk          => axilClk,
         drpRst          => axilRst,
         drpRdy          => drpRdy,
         drpEn           => drpEn,
         drpWe           => drpWe,
         drpAddr         => drpAddr,
         drpDi           => drpDi,
         drpDo           => drpDo);

   U_BufgIn : BUFG
      port map (
         I => pllClk,
         O => pllClock);

   GEN_REAL : if (SIMULATION_G = false) generate
      U_PLL : PLLE3_ADV
         generic map (
            COMPENSATION       => "AUTO",
            STARTUP_WAIT       => "FALSE",
            CLKIN_PERIOD       => 6.256,  -- 160 MHz
            DIVCLK_DIVIDE      => 1,
            CLKFBOUT_MULT      => 8,      -- 1.28 GHz = 160 MHz x 8
            CLKOUT0_DIVIDE     => 2,      -- 640 MHz = 1.28 GHz/2
            CLKOUT1_DIVIDE     => 8,      -- 160 MHz = 1.28 GHz/8
            CLKOUT0_PHASE      => 0.0,
            CLKOUT1_PHASE      => 0.0,
            CLKOUT0_DUTY_CYCLE => 0.5,
            CLKOUT1_DUTY_CYCLE => 0.5)
         port map (
            DCLK        => axilClk,
            DRDY        => drpRdy,
            DEN         => drpEn,
            DWE         => drpWe,
            DADDR       => drpAddr,
            DI          => drpDi,
            DO          => drpDo,
            PWRDWN      => '0',
            RST         => pllRst,
            CLKIN       => pllClock,
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
            CLK_PERIOD_G      => 1.5625 ns,  -- 640 MHz
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => clkout0,
            rstL => locked);
   end generate GEN_SIM;

   U_Bufg640 : BUFG
      port map (
         I => clkout0,
         O => clk640MHz);

   ------------------------------------------------------------------------------------------------------
   -- 160 MHz is the ISERDESE3/OSERDESE3's CLKDIV port
   -- Refer to "Figure 3-49: Sub-Optimal to Optimal Clocking Topologies for OSERDESE3" in UG949 (v2018.2)
   ------------------------------------------------------------------------------------------------------
   U_Bufg160 : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)            -- 160 MHz = 640 MHz/4
      port map (
         I   => clkout0,                -- 640 MHz
         CE  => '1',
         CLR => '0',
         O   => clkout1);               -- 160 MHz

   U_Rst160 : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => clkout1,
         asyncRst => locked,
         syncRst  => reset);

   U_Reset : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clkout1,
         rstIn  => reset,
         rstOut => rst160MHz);

   clk160MHz <= clkout1;

end mapping;
