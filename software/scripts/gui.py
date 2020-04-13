#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'Camera link gateway'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'Camera link gateway', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import setupLibPaths
import sys
import argparse
import FmcDev
import pyrogue.gui

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--dev",
    type     = str,
    required = False,
    default  = '/dev/datadev_0',
    help     = "path to device",
)

parser.add_argument(
    "--hwType",
    type     = str,
    required = False,
    default  = 'eth',
    help     = "Define whether sim/rce/pcie/eth HW config",
)

parser.add_argument(
    "--ip",
    type     = str,
    required = False,
    default  = '192.168.2.10',
    help     = "IP address for hwType=eth",
)

parser.add_argument(
    "--pollEn",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable auto-polling",
)

parser.add_argument(
    "--initRead",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable read all variables at start",
)

# Get the arguments
args = parser.parse_args()

#################################################################

cl = FmcDev.FmcDev(
    dev      = args.dev,
    hwType   = args.hwType,
    ip       = args.ip,
    pollEn   = args.pollEn,
    initRead = args.initRead,
)

#################################################################

# # Dump the address map
# pr.generateAddressMap(cl,'addressMapDummp.txt')

# Create GUI
appTop = pyrogue.gui.application(sys.argv)
guiTop = pyrogue.gui.GuiTop()
guiTop.addTree(cl)
guiTop.resize(800, 1000)

# Run gui
appTop.exec_()
cl.stop()

