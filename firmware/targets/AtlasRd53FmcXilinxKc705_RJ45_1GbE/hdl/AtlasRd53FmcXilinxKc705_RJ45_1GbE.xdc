##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN J4 [get_ports sgmiiTxP]
set_property PACKAGE_PIN J3 [get_ports sgmiiTxN]
set_property PACKAGE_PIN H6 [get_ports sgmiiRxP]
set_property PACKAGE_PIN H5 [get_ports sgmiiRxN]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins IBUFDS_GTE2_Inst/ODIV2]] -group [get_clocks -of_objects [get_pins U_ETH_PHY_MAC/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_ETH_PHY_MAC/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]
