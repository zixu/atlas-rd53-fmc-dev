##############################################################################
## This file is part of 'ATLAS RD53 DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins -hier -filter {name=~*gt0_Pgp3Gtx7Ip6G_i*gtxe2_i*TXOUTCLK}]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins -hier -filter {name=~*gt0_Pgp3Gtx7Ip6G_i*gtxe2_i*RXOUTCLK}]]
    
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins U_PGPv3/REAL_PGP.U_TX_PLL/PllGen.U_Pll/CLKOUT1]]    