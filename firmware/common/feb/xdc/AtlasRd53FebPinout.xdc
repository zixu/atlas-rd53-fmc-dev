##############################################################################
## This file is part of 'ATLAS RD53 DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN AA6  [get_ports {dPortDataP[0][0]} ]
set_property PACKAGE_PIN AB6  [get_ports {dPortDataN[0][0]} ]

set_property PACKAGE_PIN AA9  [get_ports {dPortDataP[0][1]} ]
set_property PACKAGE_PIN AA8  [get_ports {dPortDataN[0][1]} ]

set_property PACKAGE_PIN U8   [get_ports {dPortDataP[0][2]} ]
set_property PACKAGE_PIN V8   [get_ports {dPortDataN[0][2]} ]

set_property PACKAGE_PIN V7   [get_ports {dPortDataP[0][3]} ]
set_property PACKAGE_PIN W7   [get_ports {dPortDataN[0][3]} ]

set_property PACKAGE_PIN U10  [get_ports {dPortDataP[1][0]} ]
set_property PACKAGE_PIN V9   [get_ports {dPortDataN[1][0]} ]

set_property PACKAGE_PIN T11  [get_ports {dPortDataP[1][1]} ]
set_property PACKAGE_PIN T10  [get_ports {dPortDataN[1][1]} ]

set_property PACKAGE_PIN AA11 [get_ports {dPortDataP[1][2]} ]
set_property PACKAGE_PIN AB11 [get_ports {dPortDataN[1][2]} ]

set_property PACKAGE_PIN AB13 [get_ports {dPortDataP[1][3]} ]
set_property PACKAGE_PIN AB12 [get_ports {dPortDataN[1][3]} ]

set_property PACKAGE_PIN M2   [get_ports {dPortDataP[2][0]} ]
set_property PACKAGE_PIN M1   [get_ports {dPortDataN[2][0]} ]

set_property PACKAGE_PIN N3   [get_ports {dPortDataP[2][1]} ]
set_property PACKAGE_PIN N2   [get_ports {dPortDataN[2][1]} ]

set_property PACKAGE_PIN M5   [get_ports {dPortDataP[2][2]} ]
set_property PACKAGE_PIN N4   [get_ports {dPortDataN[2][2]} ]

set_property PACKAGE_PIN P4   [get_ports {dPortDataP[2][3]} ]
set_property PACKAGE_PIN R4   [get_ports {dPortDataN[2][3]} ]

set_property PACKAGE_PIN V4   [get_ports {dPortDataP[3][0]} ]
set_property PACKAGE_PIN W4   [get_ports {dPortDataN[3][0]} ]

set_property PACKAGE_PIN T5   [get_ports {dPortDataP[3][1]} ]
set_property PACKAGE_PIN U5   [get_ports {dPortDataN[3][1]} ]

set_property PACKAGE_PIN W1   [get_ports {dPortDataP[3][2]} ]
set_property PACKAGE_PIN Y1   [get_ports {dPortDataN[3][2]} ]

set_property PACKAGE_PIN AA1  [get_ports {dPortDataP[3][3]} ]
set_property PACKAGE_PIN AB1  [get_ports {dPortDataN[3][3]} ]

set_property IOSTANDARD LVDS [get_ports {dPortDataP[*} ]
set_property IOSTANDARD LVDS [get_ports {dPortDataN[*} ]
set_property DIFF_TERM true  [get_ports {dPortDataP[*} ]
set_property DIFF_TERM true  [get_ports {dPortDataN[*} ]

##############################################################################

# set_property PACKAGE_PIN G15  [get_ports {dPortHitP[0][0]} ]
# set_property PACKAGE_PIN G16  [get_ports {dPortHitN[0][0]} ]

# set_property PACKAGE_PIN C12  [get_ports {dPortHitP[0][1]} ]
# set_property PACKAGE_PIN B12  [get_ports {dPortHitN[0][1]} ]

# set_property PACKAGE_PIN A13  [get_ports {dPortHitP[0][2]} ]
# set_property PACKAGE_PIN A14  [get_ports {dPortHitN[0][2]} ]

# set_property PACKAGE_PIN C13  [get_ports {dPortHitP[0][3]} ]
# set_property PACKAGE_PIN B13  [get_ports {dPortHitN[0][3]} ]

# set_property PACKAGE_PIN E14  [get_ports {dPortHitP[1][0]} ]
# set_property PACKAGE_PIN D14  [get_ports {dPortHitN[1][0]} ]

# set_property PACKAGE_PIN C14  [get_ports {dPortHitP[1][1]} ]
# set_property PACKAGE_PIN C15  [get_ports {dPortHitN[1][1]} ]

# set_property PACKAGE_PIN B15  [get_ports {dPortHitP[1][2]} ]
# set_property PACKAGE_PIN A15  [get_ports {dPortHitN[1][2]} ]

# set_property PACKAGE_PIN B17  [get_ports {dPortHitP[1][3]} ]
# set_property PACKAGE_PIN A18  [get_ports {dPortHitN[1][3]} ]

# set_property PACKAGE_PIN H17  [get_ports {dPortHitP[2][0]} ]
# set_property PACKAGE_PIN G17  [get_ports {dPortHitN[2][0]} ]

# set_property PACKAGE_PIN J16  [get_ports {dPortHitP[2][1]} ]
# set_property PACKAGE_PIN J17  [get_ports {dPortHitN[2][1]} ]

# set_property PACKAGE_PIN D19  [get_ports {dPortHitP[2][2]} ]
# set_property PACKAGE_PIN D20  [get_ports {dPortHitN[2][2]} ]

# set_property PACKAGE_PIN C19  [get_ports {dPortHitP[2][3]} ]
# set_property PACKAGE_PIN C20  [get_ports {dPortHitN[2][3]} ]

# set_property PACKAGE_PIN B18  [get_ports {dPortHitP[3][0]} ]
# set_property PACKAGE_PIN A19  [get_ports {dPortHitN[3][0]} ]

# set_property PACKAGE_PIN C22  [get_ports {dPortHitP[3][1]} ]
# set_property PACKAGE_PIN B22  [get_ports {dPortHitN[3][1]} ]

# set_property PACKAGE_PIN D21  [get_ports {dPortHitP[3][2]} ]
# set_property PACKAGE_PIN D22  [get_ports {dPortHitN[3][2]} ]

# set_property PACKAGE_PIN B20  [get_ports {dPortHitP[3][3]} ]
# set_property PACKAGE_PIN B21  [get_ports {dPortHitN[3][3]} ]

# set_property IOSTANDARD LVDS_25  [get_ports {dPortHitP[*} ]
# set_property IOSTANDARD LVDS_25  [get_ports {dPortHitN[*} ]
# set_property DIFF_TERM true      [get_ports {dPortHitP[*} ]
# set_property DIFF_TERM true      [get_ports {dPortHitN[*} ]

##############################################################################

set_property PACKAGE_PIN F15  [get_ports {dPortCmdP[0]} ]
set_property PACKAGE_PIN F16  [get_ports {dPortCmdN[0]} ]

set_property PACKAGE_PIN B16  [get_ports {dPortCmdP[1]} ]
set_property PACKAGE_PIN A16  [get_ports {dPortCmdN[1]} ]

set_property PACKAGE_PIN F18  [get_ports {dPortCmdP[2]} ]
set_property PACKAGE_PIN E19  [get_ports {dPortCmdN[2]} ]

set_property PACKAGE_PIN A20  [get_ports {dPortCmdP[3]} ]
set_property PACKAGE_PIN A21  [get_ports {dPortCmdN[3]} ]

set_property IOSTANDARD LVDS_25 [get_ports {dPortCmdP[*} ]
set_property IOSTANDARD LVDS_25 [get_ports {dPortCmdN[*} ]

##############################################################################

# set_property PACKAGE_PIN W6   [get_ports {dPortAuxP[0]} ]
# set_property PACKAGE_PIN Y6   [get_ports {dPortAuxN[0]} ]

# set_property PACKAGE_PIN T9   [get_ports {dPortAuxP[1]} ]
# set_property PACKAGE_PIN T8   [get_ports {dPortAuxN[1]} ]

# set_property PACKAGE_PIN P2   [get_ports {dPortAuxP[2]} ]
# set_property PACKAGE_PIN R2   [get_ports {dPortAuxN[2]} ]

# set_property PACKAGE_PIN N5   [get_ports {dPortAuxP[3]} ]
# set_property PACKAGE_PIN P5   [get_ports {dPortAuxN[3]} ]

# set_property IOSTANDARD LVDS [get_ports {dPortAuxP[*} ]
# set_property IOSTANDARD LVDS [get_ports {dPortAuxN[*} ]

##############################################################################

# set_property PACKAGE_PIN W22 [get_ports {dPortRst[0]} ]
# set_property PACKAGE_PIN U17 [get_ports {dPortRst[1]} ]
# set_property PACKAGE_PIN V18 [get_ports {dPortRst[2]} ]
# set_property PACKAGE_PIN T20 [get_ports {dPortRst[3]} ]

# set_property IOSTANDARD LVCMOS33 [get_ports {dPortRst[*} ]

##############################################################################

# set_property PACKAGE_PIN T19 [get_ports {dPortNtcCsL[0]} ]
# set_property PACKAGE_PIN T21 [get_ports {dPortNtcCsL[1]} ]
# set_property PACKAGE_PIN U21 [get_ports {dPortNtcCsL[2]} ]
# set_property PACKAGE_PIN U22 [get_ports {dPortNtcCsL[3]} ]

# set_property IOSTANDARD LVCMOS33 [get_ports {dPortNtcCsL[*} ]

##############################################################################

# set_property PACKAGE_PIN V22 [get_ports {dPortNtcSck[0]} ]
# set_property PACKAGE_PIN T18 [get_ports {dPortNtcSck[1]} ]
# set_property PACKAGE_PIN U18 [get_ports {dPortNtcSck[2]} ]
# set_property PACKAGE_PIN W21 [get_ports {dPortNtcSck[3]} ]

# set_property IOSTANDARD LVCMOS33 [get_ports {dPortNtcSck[*} ]

##############################################################################

# set_property PACKAGE_PIN U20  [get_ports {dPortNtcSdo[0]} ]
# set_property PACKAGE_PIN Y21  [get_ports {dPortNtcSdo[1]} ]
# set_property PACKAGE_PIN Y22  [get_ports {dPortNtcSdo[2]} ]
# set_property PACKAGE_PIN AA20 [get_ports {dPortNtcSdo[3]} ]

# set_property IOSTANDARD LVCMOS33 [get_ports {dPortNtcSdo[*} ]

##############################################################################

# set_property -dict { PACKAGE_PIN N18 IOSTANDARD LVCMOS33           } [get_ports { trigInL }];
# set_property -dict { PACKAGE_PIN L19 IOSTANDARD LVCMOS33           } [get_ports { hitInL  }];
# set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { hitOut  }];

##############################################################################

# set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVDS_25 } [get_ports { tluTrgClkP }];
# set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVDS_25 } [get_ports { tluTrgClkN }];

# set_property -dict { PACKAGE_PIN C8 IOSTANDARD LVDS_25 } [get_ports { tluBsyP }];
# set_property -dict { PACKAGE_PIN B8 IOSTANDARD LVDS_25 } [get_ports { tluBsyN }];

# set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { tluIntP }];
# set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { tluIntN }];

# set_property -dict { PACKAGE_PIN A9 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { tluRstP }];
# set_property -dict { PACKAGE_PIN A8 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { tluRstN }];

##############################################################################

set_property -dict { PACKAGE_PIN G11 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { refClk160MHzP }];
set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { refClk160MHzN }];

# set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { extClk160MHzP[0] }];
# set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { extClk160MHzN[0] }];

# set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { extClk160MHzP[1] }];
# set_property -dict { PACKAGE_PIN C18 IOSTANDARD LVDS_25 DIFF_TERM true } [get_ports { extClk160MHzN[1] }];

##############################################################################

# set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { qsfpScl }];
# set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports { qsfpSda }];
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { qsfpRst }];
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports { qsfpSel }];
# set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { qsfpIntL }];
# set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports { qsfpPrstL }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { qsfpLpMode }];

##############################################################################

set_property PACKAGE_PIN D6  [get_ports { pgpClkP } ]
set_property PACKAGE_PIN D5  [get_ports { pgpClkN } ]

set_property PACKAGE_PIN F2 [get_ports { pgpTxP[0] } ]
set_property PACKAGE_PIN F1 [get_ports { pgpTxN[0] } ]
set_property PACKAGE_PIN G4 [get_ports { pgpRxP[0] } ]
set_property PACKAGE_PIN G3 [get_ports { pgpRxN[0] } ]

set_property PACKAGE_PIN D2 [get_ports { pgpTxP[1] } ]
set_property PACKAGE_PIN D1 [get_ports { pgpTxN[1] } ]
set_property PACKAGE_PIN E4 [get_ports { pgpRxP[1] } ]
set_property PACKAGE_PIN E3 [get_ports { pgpRxN[1] } ]

set_property PACKAGE_PIN B2  [get_ports { pgpTxP[2] } ]
set_property PACKAGE_PIN B1  [get_ports { pgpTxN[2] } ]
set_property PACKAGE_PIN C4  [get_ports { pgpRxP[2] } ]
set_property PACKAGE_PIN C3  [get_ports { pgpRxN[2] } ]

set_property PACKAGE_PIN A4  [get_ports { pgpTxP[3] } ]
set_property PACKAGE_PIN A3  [get_ports { pgpTxN[3] } ]
set_property PACKAGE_PIN B6  [get_ports { pgpRxP[3] } ]
set_property PACKAGE_PIN B5  [get_ports { pgpRxN[3] } ]

##############################################################################

# set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { bootCsL }];
# set_property -dict { PACKAGE_PIN H18 IOSTANDARD LVCMOS33 } [get_ports { bootMosi }];
# set_property -dict { PACKAGE_PIN H19 IOSTANDARD LVCMOS33 } [get_ports { bootMiso }];

##############################################################################

set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN R22 IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN M16 IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

##############################################################################

# set_property -dict { PACKAGE_PIN J19 IOSTANDARD LVCMOS33 } [get_ports { pwrSyncSclk }];
# set_property -dict { PACKAGE_PIN G20 IOSTANDARD LVCMOS33 } [get_ports { pwrSyncFclk }];
# set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports { pwrScl }];
# set_property -dict { PACKAGE_PIN F19 IOSTANDARD LVCMOS33 } [get_ports { pwrSda }];
# set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { tempAlertL }];

# set_property PACKAGE_PIN L12 [get_ports { vPIn } ]
# set_property PACKAGE_PIN M11 [get_ports { vNIn } ]

##############################################################################

set_property CFGBVS VCCO         [current_design]
set_property CONFIG_VOLTAGE 3.3  [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design] 

##############################################################################
