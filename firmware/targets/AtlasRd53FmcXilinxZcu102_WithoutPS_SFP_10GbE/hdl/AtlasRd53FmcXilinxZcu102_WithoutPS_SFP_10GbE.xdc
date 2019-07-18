##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################




set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks sfpClk156P]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks sfpClk156P]
set_clock_groups -asynchronous -group [get_clocks sfpClk156P] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]]

set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP0}]
set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP1}]
set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks {clk160MHz}]
