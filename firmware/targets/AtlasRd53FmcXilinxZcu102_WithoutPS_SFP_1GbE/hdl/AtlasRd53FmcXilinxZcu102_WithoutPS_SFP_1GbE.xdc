##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################



set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP0}]
set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP1}]
set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks {clk160MHz}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_Bufg160/O]] -group [get_clocks -of_objects [get_pins U_1GigE/GEN_INT_PLL.U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_1GigE/GEN_INT_PLL.U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins {U_1GigE/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_1GigE/GEN_LANE[0].U_GigEthGthUltraScale/U_GigEthGthUltraScaleCore/U0/transceiver_inst/GigEthGthUltraScaleCore_gt_i/inst/gen_gtwizard_gthe4_top.GigEthGthUltraScaleCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_1GigE/GEN_INT_PLL.U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]
