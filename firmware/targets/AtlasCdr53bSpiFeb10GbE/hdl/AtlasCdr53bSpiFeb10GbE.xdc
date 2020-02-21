##############################################################################
## This file is part of 'ATLAS RD53 DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_10GigE/TenGigEthGtx7Clk_Inst/IBUFDS_GTE2_Inst/ODIV2]] -group [get_clocks {U_10GigE/GEN_LANE[0].TenGigEthGtx7_Inst/U_TenGigEthGtx7Core/U0/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK}]

set_property DIFF_TERM false [get_ports { dPortDataP[0] dPortDataN[0] dPortDataP[1] dPortDataN[1] dPortDataP[2] dPortDataN[2] dPortCmdP dPortCmdN }]
set_property DIFF_TERM true  [get_ports { dPortDataP[3} dPortDataN[3} ]
