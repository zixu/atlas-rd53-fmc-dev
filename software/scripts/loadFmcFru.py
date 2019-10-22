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
import time

from array import array

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

# Get the arguments
args = parser.parse_args()

#################################################################

myRoot = FmcDev.FmcDev(
    dev      = args.dev,
    hwType   = args.hwType,
    ip       = args.ip,
    pollEn   = False,
    initRead = False,
    fmcFru   = True,
)

#################################################################

# Create a pointer to FMC FRU device
fmcFru = myRoot.Fmc.Fru

# Load the FRU binary file into python array
data = array('B')
with open('config/fmc-fru/PC_256_101_00_C03_FRU.bin', 'rb') as f:
    data.fromfile(f, 256)

# Load the FRU into the PROM
for i in range(len(data)):
    fmcFru.MEM[i].post(data[i])
    time.sleep(0.01)

for i in range(len(data)):
    msg = str(i) + '\t' + str(fmcFru.MEM[i].get()) + '\t' + str(data[i]) + '\t'
    msg = msg + str(fmcFru.MEM[i].get())
    print (msg)

# Stop Root
myRoot.stop()
