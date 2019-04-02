##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[0] fmcHpc0LaN[0]}]; # PLL_CLK_IN[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[1] fmcHpc0LaN[1]}]; # PLL_CLK_IN[1]
set_property -dict { IOSTANDARD LVDS }                        [get_ports {fmcHpc0LaP[2] fmcHpc0LaN[2]}]; # PLL_CLK_OUT

set_property -dict { IOSTANDARD LVDS }                        [get_ports {fmcHpc0LaP[5] fmcHpc0LaN[5]}];   #  CMD[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[6] fmcHpc0LaN[6]}];   # DATA[0][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[7] fmcHpc0LaN[7]}];   # DATA[0][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[8] fmcHpc0LaN[8]}];   # DATA[0][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[9] fmcHpc0LaN[9]}];   # DATA[0][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports {fmcHpc0LaP[10] fmcHpc0LaN[10]}]; #  CMD[1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[11] fmcHpc0LaN[11]}]; # DATA[1][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[12] fmcHpc0LaN[12]}]; # DATA[1][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[13] fmcHpc0LaN[13]}]; # DATA[1][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[14] fmcHpc0LaN[14]}]; # DATA[1][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports {fmcHpc0LaP[15] fmcHpc0LaN[15]}]; #  CMD[2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[16] fmcHpc0LaN[16]}]; # DATA[2][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[17] fmcHpc0LaN[17]}]; # DATA[2][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[18] fmcHpc0LaN[18]}]; # DATA[2][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[19] fmcHpc0LaN[19]}]; # DATA[2][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports {fmcHpc0LaP[20] fmcHpc0LaN[20]}]; #  CMD[3]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[21] fmcHpc0LaN[21]}]; # DATA[3][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[22] fmcHpc0LaN[22]}]; # DATA[3][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[23] fmcHpc0LaN[23]}]; # DATA[3][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports {fmcHpc0LaP[24] fmcHpc0LaN[24]}]; # DATA[3][3]

##############################################################################

# set_property IODELAY_GROUP xapp_idelay [get_cells U_IDELAYCTRL]
# set_property IODELAY_GROUP xapp_idelay [get_cells U_App/GEN_DP[*].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/xapp1017_serdes.serdes_cmp/loop0[0].idelay_m]
# set_property IODELAY_GROUP xapp_idelay [get_cells U_App/GEN_DP[*].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/xapp1017_serdes.serdes_cmp/loop0[0].idelay_s]

####################
# Timing Constraints
####################

create_clock -name fmcHpc0LaP0 -period 6.237 [get_ports {fmcHpc0LaP[0]}]
create_clock -name fmcHpc0LaP1 -period 6.237 [get_ports {fmcHpc0LaP[1]}]

create_generated_clock -name clk300MHz [get_pins {U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]

create_generated_clock -name clk640MHz [get_pins {U_App/U_FmcMapping/U_FmcMmcm/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk160MHz [get_pins {U_App/U_FmcMapping/U_FmcMmcm/U_Bufg160/O}]

set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP0}]
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP1}]
