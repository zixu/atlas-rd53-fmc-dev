##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ATLAS RD53 FMC DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -name sysClk300P -period 3.333 [get_ports {sysClk300P}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_Bufg160/O]] -group [get_clocks sfpClk156P]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthGthUltraScaleCore/U0/TenGigEthGthUltraScale156p25MHzCore_local_clock_reset_block/rxusrclk2_bufg_gt_i/O}]] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthRst/CLK156_BUFG_GT/O}]]
set_clock_groups -asynchronous -group [get_clocks sfpClk156P] -group [get_clocks -of_objects [get_pins {U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthRst/CLK156_BUFG_GT/O}]]
