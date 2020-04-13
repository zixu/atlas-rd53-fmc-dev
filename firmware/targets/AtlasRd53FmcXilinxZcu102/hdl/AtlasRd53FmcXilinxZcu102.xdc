##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { fmcHpc0LaP[0] fmcHpc0LaN[0] }]; # PLL_CLK_IN[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { fmcHpc0LaP[1] fmcHpc0LaN[1] }]; # PLL_CLK_IN[1]
set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[2] fmcHpc0LaN[2] }]; # PLL_CLK_OUT

set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[5] fmcHpc0LaN[5] }]; #  CMD[0] BANK66:(AB3/AC3)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[6] fmcHpc0LaN[6] }];   # DATA[0][0] BANK66:(AC2/AC1)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[7] fmcHpc0LaN[7] }];   # DATA[0][1] BANK66:(U5/U4)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[8] fmcHpc0LaN[8] }];   # DATA[0][2] BANK66:(V4/V3)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[9] fmcHpc0LaN[9] }];   # DATA[0][3] BANK66:(W2/W1)

set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[10] fmcHpc0LaN[10] }]; #  CMD[1] BANK66:(W5/W4)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[11] fmcHpc0LaN[11] }]; # DATA[1][0] BANK66:(AB6/AB5)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[12] fmcHpc0LaN[12] }]; # DATA[1][1] BANK66:(W7/W6)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[13] fmcHpc0LaN[13] }]; # DATA[1][2] BANK66:(AB8/AC8)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[14] fmcHpc0LaN[14] }]; # DATA[1][3] BANK66:(AC7/AC6)

set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[15] fmcHpc0LaN[15] }]; #  CMD[2] BANK66:(Y10/Y9)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[16] fmcHpc0LaN[16] }]; # DATA[2][0] BANK66:(Y12/AA12)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[17] fmcHpc0LaN[17] }]; # DATA[2][1] BANK67:(P11/N11)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[18] fmcHpc0LaN[18] }]; # DATA[2][2] BANK67:(N9/N8)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[19] fmcHpc0LaN[19] }]; # DATA[2][3] BANK67:(L13/K13)

set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[20] fmcHpc0LaN[20] }]; #  CMD[3] BANK67:(N13/M13)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[21] fmcHpc0LaN[21] }]; # DATA[3][0] BANK67:(P12/N12)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[22] fmcHpc0LaN[22] }]; # DATA[3][1] BANK67:(M15/M14)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[23] fmcHpc0LaN[23] }]; # DATA[3][2] BANK67:(L16/K16)
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { fmcHpc0LaP[24] fmcHpc0LaN[24] }]; # DATA[3][3] BANK67:(L12/K12)

set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { fmcHpc0LaP[26] fmcHpc0LaN[26] }]; # TLU_INT
set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { fmcHpc0LaP[27] fmcHpc0LaN[27] }]; # TLU_RST

set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[28] fmcHpc0LaN[28] }]; # TLU_BSY
set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc0LaP[29] fmcHpc0LaN[29] }]; # TLU_TRG_CLK

##############################################################################

####################
# Timing Constraints
####################

create_clock -name fmcHpc0LaP0 -period 6.237 [get_ports {fmcHpc0LaP[0]}]
create_clock -name fmcHpc0LaP1 -period 6.237 [get_ports {fmcHpc0LaP[1]}]

create_generated_clock -name clk300MHz [get_pins {U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]

create_generated_clock -name clk640MHz [get_pins {U_App/U_FmcMapping/U_Selectio/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk160MHz [get_pins {U_App/U_FmcMapping/U_Selectio/U_Bufg160/O}]

set_property CLOCK_DELAY_GROUP RD53_CLK_GRP [get_nets {U_App/U_FmcMapping/U_Selectio/clk160MHz[*]}] [get_nets {U_App/U_FmcMapping/U_Selectio/clk640MHz[*]}]

set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP0}]
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP1}]

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports fmcHpc0LaP[20]]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets U_App/U_FmcMapping/GEN_PLL_CLK[1].U_IBUFDS/O] 

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[0].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[0].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[1].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[1].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[2].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[2].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[3].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[3].GEN_PGP2b.U_Lane/REAL_PGP.U_Pgp/PgpGthCoreWrapper_1/U_PgpGthCore/inst/gen_gtwizard_gthe4_top.PgpGthCore_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[0].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[0].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[1].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[1].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[2].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[2].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[3].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_Pgp/GEN_LANE[3].GEN_PGP3.U_Lane/REAL_PGP.U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks fmcHpc0LaP0]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_1GigE/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_Bank66/inst/top_inst/clk_rst_top_inst/clk_scheme_inst/GEN_PLL_IN_IP_USP.plle4_adv_pll0_inst/CLKOUT0]]
