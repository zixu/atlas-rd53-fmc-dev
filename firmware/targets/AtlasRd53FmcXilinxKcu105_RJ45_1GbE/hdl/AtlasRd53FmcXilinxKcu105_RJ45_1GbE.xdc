##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################


# MDIO/Ext. PHY
set_property PACKAGE_PIN K25     [get_ports "phyIrqN"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyIrqN"]
set_property PACKAGE_PIN L25     [get_ports "phyMdc"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyMdc"]
set_property PACKAGE_PIN H26     [get_ports "phyMdio"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyMdio"]
set_property PACKAGE_PIN J23     [get_ports "phyRstN"]
set_property IOSTANDARD LVCMOS18 [get_ports "phyRstN"]

# On-Board System clock
set_property ODT RTT_48 [get_ports "sysClk300N"]
set_property PACKAGE_PIN AK16 [get_ports "sysClk300N"]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports "sysClk300N"]
set_property PACKAGE_PIN AK17 [get_ports "sysClk300P"]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports "sysClk300P"]
set_property ODT RTT_48 [get_ports "sysClk300P"]

# SGMII/Ext. PHY
set_property PACKAGE_PIN P25 [get_ports ethRxN]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports ethRxN]
set_property PACKAGE_PIN P24 [get_ports ethRxP]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports ethRxP]
set_property PACKAGE_PIN M24 [get_ports ethTxN]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports ethTxN]
set_property PACKAGE_PIN N24 [get_ports ethTxP]
set_property IOSTANDARD DIFF_HSTL_I_18 [get_ports ethTxP]
set_property PACKAGE_PIN N26 [get_ports ethClkN]
set_property IOSTANDARD LVDS_25 [get_ports ethClkN]
set_property PACKAGE_PIN P26 [get_ports ethClkP]
set_property IOSTANDARD LVDS_25 [get_ports ethClkP]

# Placement - put SGMII ETH close in clock region of the 625MHz clock;
#             otherwise it is difficult to meet timing.
create_pblock SGMII_ETH_BLK
add_cells_to_pblock [get_pblocks SGMII_ETH_BLK] [get_cells U_MarvelWrap/U_1GigE]
resize_pblock       [get_pblocks SGMII_ETH_BLK] -add {CLOCKREGION_X2Y1:CLOCKREGION_X2Y1}

set_property LOC PLL_X1Y3 [get_cells {U_MarvelWrap/U_1GigE/U_PLL}]

# Timing Constraints 
create_clock -name lvdsClkP   -period 1.600 [get_ports {ethClkP}]
create_clock -name sysClk300P -period 3.333 [get_ports {sysClk300P}]

create_generated_clock -name ethClk625MHz [get_pins {U_MarvelWrap/U_1GigE/U_PLL/CLKOUT0}] 
create_generated_clock -name ethClk312MHz [get_pins {U_MarvelWrap/U_1GigE/U_PLL/CLKOUT1}] 
create_generated_clock -name ethClk125MHz [get_pins {U_MarvelWrap/U_1GigE/U_sysClk125/O}]

set_property CLOCK_DELAY_GROUP ETH_CLK_GRP [get_nets {U_MarvelWrap/U_1GigE/sysClk312}] [get_nets {U_MarvelWrap/U_1GigE/sysClk625}]

set_clock_groups -asynchronous -group [get_clocks {ethClk312MHz}] -group [get_clocks {ethClk125MHz}]

set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {lvdsClkP}] -group [get_clocks -include_generated_clocks {sysClk300P}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_MarvelWrap/U_1GigE/U_sysClk125/O]] -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_Bufg160/O]]
