##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE } [get_ports {fmcHpcLaP[0] fmcHpcLaN[0]}]; # PLL_CLK_IN[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE } [get_ports {fmcHpcLaP[1] fmcHpcLaN[1]}]; # PLL_CLK_IN[1]
set_property -dict { IOSTANDARD LVDS }                  [get_ports {fmcHpcLaP[2] fmcHpcLaN[2]}]; # PLL_CLK_OUT

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpcLaP[5] fmcHpcLaN[5]}];   #  CMD[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[6] fmcHpcLaN[6]}];   # DATA[0][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[7] fmcHpcLaN[7]}];   # DATA[0][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[8] fmcHpcLaN[8]}];   # DATA[0][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[9] fmcHpcLaN[9]}];   # DATA[0][3]

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpcLaP[10] fmcHpcLaN[10]}]; #  CMD[1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[11] fmcHpcLaN[11]}]; # DATA[1][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[12] fmcHpcLaN[12]}]; # DATA[1][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[13] fmcHpcLaN[13]}]; # DATA[1][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[14] fmcHpcLaN[14]}]; # DATA[1][3]

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpcLaP[15] fmcHpcLaN[15]}]; #  CMD[2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[16] fmcHpcLaN[16]}]; # DATA[2][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[17] fmcHpcLaN[17]}]; # DATA[2][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[18] fmcHpcLaN[18]}]; # DATA[2][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[19] fmcHpcLaN[19]}]; # DATA[2][3]

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpcLaP[20] fmcHpcLaN[20]}]; #  CMD[3]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[21] fmcHpcLaN[21]}]; # DATA[3][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[22] fmcHpcLaN[22]}]; # DATA[3][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[23] fmcHpcLaN[23]}]; # DATA[3][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM = TRUE EQUALIZATION EQ_LEVEL } [get_ports {fmcHpcLaP[24] fmcHpcLaN[24]}]; # DATA[3][3]

##############################################################################

####################
# Timing Constraints
####################

create_clock -name fmcHpcLaP0 -period 6.237 [get_ports {fmcHpcLaP[0]}]
create_clock -name fmcHpcLaP1 -period 6.237 [get_ports {fmcHpcLaP[1]}]

create_generated_clock -name clk300MHz [get_pins {U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]

create_generated_clock -name clk640MHz [get_pins {U_App/U_FmcMapping/U_Selectio/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk160MHz [get_pins {U_App/U_FmcMapping/U_Selectio/U_Bufg160/O}]

set_property CLOCK_DELAY_GROUP RD53_CLK_GRP [get_nets {U_App/U_FmcMapping/U_Selectio/clk160MHz[*]}] [get_nets {U_App/U_FmcMapping/U_Selectio/clk640MHz[*]}]

set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {fmcHpcLaP0}]
set_clock_groups -asynchronous -group [get_clocks {dmaClk}] -group [get_clocks -include_generated_clocks {fmcHpcLaP1}]

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports fmcHpcLaP[10]]
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports fmcHpcLaP[20]]

