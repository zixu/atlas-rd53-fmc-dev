##############################################################################
## This file is part of 'ATLAS RD53 DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -name pgpClkP       -period 3.200 [get_ports {pgpClkP}]
create_clock -name refClk160MHz  -period 6.237 [get_ports {refClk160MHzP}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_PLL/PllGen.U_Pll/CLKOUT1]] -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]
