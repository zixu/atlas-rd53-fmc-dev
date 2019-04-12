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
      SIMULATION_G : boolean := false);
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

   component AtlasRd53HsSelectioBank66
      port (
         rx_cntvaluein_8            : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_8           : out std_logic_vector(8 downto 0);
         rx_ce_8                    : in  std_logic;
         rx_inc_8                   : in  std_logic;
         rx_load_8                  : in  std_logic;
         rx_en_vtc_8                : in  std_logic;
         rx_cntvaluein_13           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_13          : out std_logic_vector(8 downto 0);
         rx_ce_13                   : in  std_logic;
         rx_inc_13                  : in  std_logic;
         rx_load_13                 : in  std_logic;
         rx_en_vtc_13               : in  std_logic;
         rx_cntvaluein_15           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_15          : out std_logic_vector(8 downto 0);
         rx_ce_15                   : in  std_logic;
         rx_inc_15                  : in  std_logic;
         rx_load_15                 : in  std_logic;
         rx_en_vtc_15               : in  std_logic;
         rx_cntvaluein_17           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_17          : out std_logic_vector(8 downto 0);
         rx_ce_17                   : in  std_logic;
         rx_inc_17                  : in  std_logic;
         rx_load_17                 : in  std_logic;
         rx_en_vtc_17               : in  std_logic;
         rx_cntvaluein_19           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_19          : out std_logic_vector(8 downto 0);
         rx_ce_19                   : in  std_logic;
         rx_inc_19                  : in  std_logic;
         rx_load_19                 : in  std_logic;
         rx_en_vtc_19               : in  std_logic;
         rx_cntvaluein_34           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_34          : out std_logic_vector(8 downto 0);
         rx_ce_34                   : in  std_logic;
         rx_inc_34                  : in  std_logic;
         rx_load_34                 : in  std_logic;
         rx_en_vtc_34               : in  std_logic;
         rx_cntvaluein_36           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_36          : out std_logic_vector(8 downto 0);
         rx_ce_36                   : in  std_logic;
         rx_inc_36                  : in  std_logic;
         rx_load_36                 : in  std_logic;
         rx_en_vtc_36               : in  std_logic;
         rx_cntvaluein_39           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_39          : out std_logic_vector(8 downto 0);
         rx_ce_39                   : in  std_logic;
         rx_inc_39                  : in  std_logic;
         rx_load_39                 : in  std_logic;
         rx_en_vtc_39               : in  std_logic;
         rx_cntvaluein_49           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_49          : out std_logic_vector(8 downto 0);
         rx_ce_49                   : in  std_logic;
         rx_inc_49                  : in  std_logic;
         rx_load_49                 : in  std_logic;
         rx_en_vtc_49               : in  std_logic;
         rx_clk                     : in  std_logic;
         fifo_rd_clk_8              : in  std_logic;
         fifo_rd_clk_13             : in  std_logic;
         fifo_rd_clk_15             : in  std_logic;
         fifo_rd_clk_17             : in  std_logic;
         fifo_rd_clk_19             : in  std_logic;
         fifo_rd_clk_34             : in  std_logic;
         fifo_rd_clk_36             : in  std_logic;
         fifo_rd_clk_39             : in  std_logic;
         fifo_rd_clk_49             : in  std_logic;
         fifo_rd_en_8               : in  std_logic;
         fifo_rd_en_13              : in  std_logic;
         fifo_rd_en_15              : in  std_logic;
         fifo_rd_en_17              : in  std_logic;
         fifo_rd_en_19              : in  std_logic;
         fifo_rd_en_34              : in  std_logic;
         fifo_rd_en_36              : in  std_logic;
         fifo_rd_en_39              : in  std_logic;
         fifo_rd_en_49              : in  std_logic;
         fifo_empty_8               : out std_logic;
         fifo_empty_13              : out std_logic;
         fifo_empty_15              : out std_logic;
         fifo_empty_17              : out std_logic;
         fifo_empty_19              : out std_logic;
         fifo_empty_34              : out std_logic;
         fifo_empty_36              : out std_logic;
         fifo_empty_39              : out std_logic;
         fifo_empty_49              : out std_logic;
         dly_rdy_bsc1               : out std_logic;
         dly_rdy_bsc2               : out std_logic;
         dly_rdy_bsc3               : out std_logic;
         dly_rdy_bsc5               : out std_logic;
         dly_rdy_bsc6               : out std_logic;
         dly_rdy_bsc7               : out std_logic;
         rst_seq_done               : out std_logic;
         shared_pll0_clkoutphy_out  : out std_logic;
         pll0_clkout0               : out std_logic;
         rst                        : in  std_logic;
         clk                        : in  std_logic;
         riu_clk                    : in  std_logic;
         pll0_locked                : out std_logic;
         bg0_pin6_nc                : in  std_logic;
         bg2_pin6_nc                : in  std_logic;
         bg3_pin6_nc                : in  std_logic;
         data2_0p_8                 : in  std_logic;
         data_to_fabric_data2_0p_8  : out std_logic_vector(7 downto 0);
         data2_0n_9                 : in  std_logic;
         data1_3p_13                : in  std_logic;
         data_to_fabric_data1_3p_13 : out std_logic_vector(7 downto 0);
         data1_3n_14                : in  std_logic;
         data1_2p_15                : in  std_logic;
         data_to_fabric_data1_2p_15 : out std_logic_vector(7 downto 0);
         data1_2n_16                : in  std_logic;
         data1_1p_17                : in  std_logic;
         data_to_fabric_data1_1p_17 : out std_logic_vector(7 downto 0);
         data1_1n_18                : in  std_logic;
         data1_0p_19                : in  std_logic;
         data_to_fabric_data1_0p_19 : out std_logic_vector(7 downto 0);
         data1_0n_20                : in  std_logic;
         data0_2p_34                : in  std_logic;
         data_to_fabric_data0_2p_34 : out std_logic_vector(7 downto 0);
         data0_2n_35                : in  std_logic;
         data0_1p_36                : in  std_logic;
         data_to_fabric_data0_1p_36 : out std_logic_vector(7 downto 0);
         data0_1n_37                : in  std_logic;
         data0_0p_39                : in  std_logic;
         data_to_fabric_data0_0p_39 : out std_logic_vector(7 downto 0);
         data0_0n_40                : in  std_logic;
         data0_3p_49                : in  std_logic;
         data_to_fabric_data0_3p_49 : out std_logic_vector(7 downto 0);
         data0_3n_50                : in  std_logic
         );
   end component;

   component AtlasRd53HsSelectioBank67
      port (
         rx_cntvaluein_26           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_26          : out std_logic_vector(8 downto 0);
         rx_ce_26                   : in  std_logic;
         rx_inc_26                  : in  std_logic;
         rx_load_26                 : in  std_logic;
         rx_en_vtc_26               : in  std_logic;
         rx_cntvaluein_32           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_32          : out std_logic_vector(8 downto 0);
         rx_ce_32                   : in  std_logic;
         rx_inc_32                  : in  std_logic;
         rx_load_32                 : in  std_logic;
         rx_en_vtc_32               : in  std_logic;
         rx_cntvaluein_36           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_36          : out std_logic_vector(8 downto 0);
         rx_ce_36                   : in  std_logic;
         rx_inc_36                  : in  std_logic;
         rx_load_36                 : in  std_logic;
         rx_en_vtc_36               : in  std_logic;
         rx_cntvaluein_39           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_39          : out std_logic_vector(8 downto 0);
         rx_ce_39                   : in  std_logic;
         rx_inc_39                  : in  std_logic;
         rx_load_39                 : in  std_logic;
         rx_en_vtc_39               : in  std_logic;
         rx_cntvaluein_41           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_41          : out std_logic_vector(8 downto 0);
         rx_ce_41                   : in  std_logic;
         rx_inc_41                  : in  std_logic;
         rx_load_41                 : in  std_logic;
         rx_en_vtc_41               : in  std_logic;
         rx_cntvaluein_43           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_43          : out std_logic_vector(8 downto 0);
         rx_ce_43                   : in  std_logic;
         rx_inc_43                  : in  std_logic;
         rx_load_43                 : in  std_logic;
         rx_en_vtc_43               : in  std_logic;
         rx_cntvaluein_47           : in  std_logic_vector(8 downto 0);
         rx_cntvalueout_47          : out std_logic_vector(8 downto 0);
         rx_ce_47                   : in  std_logic;
         rx_inc_47                  : in  std_logic;
         rx_load_47                 : in  std_logic;
         rx_en_vtc_47               : in  std_logic;
         rx_clk                     : in  std_logic;
         fifo_rd_clk_26             : in  std_logic;
         fifo_rd_clk_32             : in  std_logic;
         fifo_rd_clk_36             : in  std_logic;
         fifo_rd_clk_39             : in  std_logic;
         fifo_rd_clk_41             : in  std_logic;
         fifo_rd_clk_43             : in  std_logic;
         fifo_rd_clk_47             : in  std_logic;
         fifo_rd_en_26              : in  std_logic;
         fifo_rd_en_32              : in  std_logic;
         fifo_rd_en_36              : in  std_logic;
         fifo_rd_en_39              : in  std_logic;
         fifo_rd_en_41              : in  std_logic;
         fifo_rd_en_43              : in  std_logic;
         fifo_rd_en_47              : in  std_logic;
         fifo_empty_26              : out std_logic;
         fifo_empty_32              : out std_logic;
         fifo_empty_36              : out std_logic;
         fifo_empty_39              : out std_logic;
         fifo_empty_41              : out std_logic;
         fifo_empty_43              : out std_logic;
         fifo_empty_47              : out std_logic;
         dly_rdy_bsc4               : out std_logic;
         dly_rdy_bsc5               : out std_logic;
         dly_rdy_bsc6               : out std_logic;
         dly_rdy_bsc7               : out std_logic;
         rst_seq_done               : out std_logic;
         shared_pll0_clkoutphy_out  : out std_logic;
         pll0_clkout0               : out std_logic;
         rst                        : in  std_logic;
         clk                        : in  std_logic;
         riu_clk                    : in  std_logic;
         pll0_locked                : out std_logic;
         bg3_pin6_nc                : in  std_logic;
         data2_1p_26                : in  std_logic;
         data_to_fabric_data2_1p_26 : out std_logic_vector(7 downto 0);
         data2_1n_27                : in  std_logic;
         data2_2p_32                : in  std_logic;
         data_to_fabric_data2_2p_32 : out std_logic_vector(7 downto 0);
         data2_2n_33                : in  std_logic;
         data3_3p_36                : in  std_logic;
         data_to_fabric_data3_3p_36 : out std_logic_vector(7 downto 0);
         data3_3n_37                : in  std_logic;
         data3_2p_39                : in  std_logic;
         data_to_fabric_data3_2p_39 : out std_logic_vector(7 downto 0);
         data3_2n_40                : in  std_logic;
         data3_1p_41                : in  std_logic;
         data_to_fabric_data3_1p_41 : out std_logic_vector(7 downto 0);
         data3_1n_42                : in  std_logic;
         data3_0p_43                : in  std_logic;
         data_to_fabric_data3_0p_43 : out std_logic_vector(7 downto 0);
         data3_0n_44                : in  std_logic;
         data2_3p_47                : in  std_logic;
         data_to_fabric_data2_3p_47 : out std_logic_vector(7 downto 0);
         data2_3n_48                : in  std_logic
         );
   end component;

   signal clock160MHz : sl;
   signal reset160MHz : sl;
   signal locked      : sl;
   signal reset       : sl;

   signal dlyConfig : Slv9Array(15 downto 0) := (others => (others => '0'));
   signal empty     : slv(15 downto 0);
   signal rdEn      : slv(15 downto 0);


begin

   clk160MHz <= clock160MHz;
   rst160MHz <= reset160MHz;

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

   GEN_VEC :
   for i in 15 downto 0 generate
      dlyConfig(i)(8 downto 4) <= dlyCfg(i);
      rdEn(i)                  <= not(empty(i));
   end generate GEN_VEC;

   U_Bank66 : AtlasRd53HsSelectioBank66
      port map (
         rx_clk                     => ref160Clk,
         dly_rdy_bsc1               => open,
         dly_rdy_bsc2               => open,
         dly_rdy_bsc3               => open,
         dly_rdy_bsc5               => open,
         dly_rdy_bsc6               => open,
         dly_rdy_bsc7               => open,
         rst_seq_done               => open,
         shared_pll0_clkoutphy_out  => open,
         pll0_clkout0               => clock160MHz,
         rst                        => reset160MHz,
         clk                        => clock160MHz,
         riu_clk                    => clock160MHz,
         pll0_locked                => locked,
         bg0_pin6_nc                => '0',
         bg2_pin6_nc                => '0',
         bg3_pin6_nc                => '0',
         -- DATA[0][0]
         data0_0p_39                => dPortDataP(0)(0),
         data0_0n_40                => dPortDataN(0)(0),
         data_to_fabric_data0_0p_39 => serDesData(0),
         rx_cntvaluein_39           => dlyConfig(0),
         rx_cntvalueout_39          => open,
         rx_ce_39                   => '0',
         rx_inc_39                  => '0',
         rx_load_39                 => '1',
         rx_en_vtc_39               => '0',
         fifo_rd_clk_39             => clock160MHz,
         fifo_rd_en_39              => rdEn(0),
         fifo_empty_39              => empty(0),
         -- DATA[0][1]
         data0_1p_36                => dPortDataP(0)(1),
         data0_1n_37                => dPortDataN(0)(1),
         data_to_fabric_data0_1p_36 => serDesData(1),
         rx_cntvaluein_36           => dlyConfig(1),
         rx_cntvalueout_36          => open,
         rx_ce_36                   => '0',
         rx_inc_36                  => '0',
         rx_load_36                 => '1',
         rx_en_vtc_36               => '0',
         fifo_rd_clk_36             => clock160MHz,
         fifo_rd_en_36              => rdEn(1),
         fifo_empty_36              => empty(1),
         -- DATA[0][2]
         data0_2p_34                => dPortDataP(0)(2),
         data0_2n_35                => dPortDataN(0)(2),
         data_to_fabric_data0_2p_34 => serDesData(2),
         rx_cntvaluein_34           => dlyConfig(2),
         rx_cntvalueout_34          => open,
         rx_ce_34                   => '0',
         rx_inc_34                  => '0',
         rx_load_34                 => '1',
         rx_en_vtc_34               => '0',
         fifo_rd_clk_34             => clock160MHz,
         fifo_rd_en_34              => rdEn(2),
         fifo_empty_34              => empty(2),
         -- DATA[0][3]
         data0_3p_49                => dPortDataP(0)(3),
         data0_3n_50                => dPortDataN(0)(3),
         data_to_fabric_data0_3p_49 => serDesData(3),
         rx_cntvaluein_49           => dlyConfig(3),
         rx_cntvalueout_49          => open,
         rx_ce_49                   => '0',
         rx_inc_49                  => '0',
         rx_load_49                 => '1',
         rx_en_vtc_49               => '0',
         fifo_rd_clk_49             => clock160MHz,
         fifo_rd_en_49              => rdEn(3),
         fifo_empty_49              => empty(3),
         -- DATA[1][0]
         data1_0p_19                => dPortDataP(1)(0),
         data1_0n_20                => dPortDataN(1)(0),
         data_to_fabric_data1_0p_19 => serDesData(4),
         rx_cntvaluein_19           => dlyConfig(4),
         rx_cntvalueout_19          => open,
         rx_ce_19                   => '0',
         rx_inc_19                  => '0',
         rx_load_19                 => '1',
         rx_en_vtc_19               => '0',
         fifo_rd_clk_19             => clock160MHz,
         fifo_rd_en_19              => rdEn(4),
         fifo_empty_19              => empty(4),
         -- DATA[1][1]
         data1_1p_17                => dPortDataP(1)(1),
         data1_1n_18                => dPortDataN(1)(1),
         data_to_fabric_data1_1p_17 => serDesData(5),
         rx_cntvaluein_17           => dlyConfig(5),
         rx_cntvalueout_17          => open,
         rx_ce_17                   => '0',
         rx_inc_17                  => '0',
         rx_load_17                 => '1',
         rx_en_vtc_17               => '0',
         fifo_rd_clk_17             => clock160MHz,
         fifo_rd_en_17              => rdEn(5),
         fifo_empty_17              => empty(5),
         -- DATA[1][2]
         data1_2p_15                => dPortDataP(1)(2),
         data1_2n_16                => dPortDataN(1)(2),
         data_to_fabric_data1_2p_15 => serDesData(6),
         rx_cntvaluein_15           => dlyConfig(6),
         rx_cntvalueout_15          => open,
         rx_ce_15                   => '0',
         rx_inc_15                  => '0',
         rx_load_15                 => '1',
         rx_en_vtc_15               => '0',
         fifo_rd_clk_15             => clock160MHz,
         fifo_rd_en_15              => rdEn(6),
         fifo_empty_15              => empty(6),
         -- DATA[1][3]
         data1_3p_13                => dPortDataP(1)(3),
         data1_3n_14                => dPortDataN(1)(3),
         data_to_fabric_data1_3p_13 => serDesData(7),
         rx_cntvaluein_13           => dlyConfig(7),
         rx_cntvalueout_13          => open,
         rx_ce_13                   => '0',
         rx_inc_13                  => '0',
         rx_load_13                 => '1',
         rx_en_vtc_13               => '0',
         fifo_rd_clk_13             => clock160MHz,
         fifo_rd_en_13              => rdEn(7),
         fifo_empty_13              => empty(7),
         -- DATA[2][0]
         data2_0p_8                 => dPortDataP(2)(0),
         data2_0n_9                 => dPortDataN(2)(0),
         data_to_fabric_data2_0p_8  => serDesData(8),
         rx_cntvaluein_8            => dlyConfig(8),
         rx_cntvalueout_8           => open,
         rx_ce_8                    => '0',
         rx_inc_8                   => '0',
         rx_load_8                  => '1',
         rx_en_vtc_8                => '0',
         fifo_rd_clk_8              => clock160MHz,
         fifo_rd_en_8               => rdEn(8),
         fifo_empty_8               => empty(8));

   U_Bank67 : AtlasRd53HsSelectioBank67
      port map (
         rx_clk                     => ref160Clk,
         dly_rdy_bsc4               => open,
         dly_rdy_bsc5               => open,
         dly_rdy_bsc6               => open,
         dly_rdy_bsc7               => open,
         rst_seq_done               => open,
         shared_pll0_clkoutphy_out  => open,
         pll0_clkout0               => open,
         rst                        => reset160MHz,
         clk                        => clock160MHz,
         riu_clk                    => clock160MHz,
         pll0_locked                => open,
         bg3_pin6_nc                => '0',
         -- DATA[2][1]
         data2_1p_26                => dPortDataP(2)(1),
         data2_1n_27                => dPortDataN(2)(1),
         data_to_fabric_data2_1p_26 => serDesData(9),
         rx_cntvaluein_26           => dlyConfig(9),
         rx_cntvalueout_26          => open,
         rx_ce_26                   => '0',
         rx_inc_26                  => '0',
         rx_load_26                 => '1',
         rx_en_vtc_26               => '0',
         fifo_rd_clk_26             => clock160MHz,
         fifo_rd_en_26              => rdEn(9),
         fifo_empty_26              => empty(9),
         -- DATA[2][2]
         data2_2p_32                => dPortDataP(2)(2),
         data2_2n_33                => dPortDataN(2)(2),
         data_to_fabric_data2_2p_32 => serDesData(10),
         rx_cntvaluein_32           => dlyConfig(10),
         rx_cntvalueout_32          => open,
         rx_ce_32                   => '0',
         rx_inc_32                  => '0',
         rx_load_32                 => '1',
         rx_en_vtc_32               => '0',
         fifo_rd_clk_32             => clock160MHz,
         fifo_rd_en_32              => rdEn(10),
         fifo_empty_32              => empty(10),
         -- DATA[2][3]
         data2_3p_47                => dPortDataP(2)(3),
         data2_3n_48                => dPortDataN(2)(3),
         data_to_fabric_data2_3p_47 => serDesData(11),
         rx_cntvaluein_47           => dlyConfig(11),
         rx_cntvalueout_47          => open,
         rx_ce_47                   => '0',
         rx_inc_47                  => '0',
         rx_load_47                 => '1',
         rx_en_vtc_47               => '0',
         fifo_rd_clk_47             => clock160MHz,
         fifo_rd_en_47              => rdEn(11),
         fifo_empty_47              => empty(11),
         -- DATA[3][0]
         data3_0p_43                => dPortDataP(3)(0),
         data3_0n_44                => dPortDataN(3)(0),
         data_to_fabric_data3_0p_43 => serDesData(12),
         rx_cntvaluein_43           => dlyConfig(12),
         rx_cntvalueout_43          => open,
         rx_ce_43                   => '0',
         rx_inc_43                  => '0',
         rx_load_43                 => '1',
         rx_en_vtc_43               => '0',
         fifo_rd_clk_43             => clock160MHz,
         fifo_rd_en_43              => rdEn(12),
         fifo_empty_43              => empty(12),
         -- DATA[3][1]
         data3_1p_41                => dPortDataP(3)(1),
         data3_1n_42                => dPortDataN(3)(1),
         data_to_fabric_data3_1p_41 => serDesData(13),
         rx_cntvaluein_41           => dlyConfig(13),
         rx_cntvalueout_41          => open,
         rx_ce_41                   => '0',
         rx_inc_41                  => '0',
         rx_load_41                 => '1',
         rx_en_vtc_41               => '0',
         fifo_rd_clk_41             => clock160MHz,
         fifo_rd_en_41              => rdEn(13),
         fifo_empty_41              => empty(13),
         -- DATA[3][2]
         data3_2p_39                => dPortDataP(3)(2),
         data3_2n_40                => dPortDataN(3)(2),
         data_to_fabric_data3_2p_39 => serDesData(14),
         rx_cntvaluein_39           => dlyConfig(14),
         rx_cntvalueout_39          => open,
         rx_ce_39                   => '0',
         rx_inc_39                  => '0',
         rx_load_39                 => '1',
         rx_en_vtc_39               => '0',
         fifo_rd_clk_39             => clock160MHz,
         fifo_rd_en_39              => rdEn(14),
         fifo_empty_39              => empty(14),
         -- DATA[3][3]
         data3_3p_36                => dPortDataP(3)(3),
         data3_3n_37                => dPortDataN(3)(3),
         data_to_fabric_data3_3p_36 => serDesData(15),
         rx_cntvaluein_36           => dlyConfig(15),
         rx_cntvalueout_36          => open,
         rx_ce_36                   => '0',
         rx_inc_36                  => '0',
         rx_load_36                 => '1',
         rx_en_vtc_36               => '0',
         fifo_rd_clk_36             => clock160MHz,
         fifo_rd_en_36              => rdEn(15),
         fifo_empty_36              => empty(15));

end mapping;
