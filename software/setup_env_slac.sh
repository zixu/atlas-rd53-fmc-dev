##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Setup environment
source /afs/slac.stanford.edu/g/reseng/rogue/anaconda/rogue_pre-release.sh

# Python Package directories
export SURF_DIR=${PWD}/../firmware/submodules/surf/python

# Setup python path
export PYTHONPATH=${PWD}/python:${SURF_DIR}:${PYTHONPATH}
