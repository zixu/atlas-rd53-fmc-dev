export GEN_BIN_IMAGE = 1
export TIG_PULSE = 1

# Use the PGPv4 6G core
export INCLUDE_PGP4_6G = 1

# ZCU106 builds use .BIN files
export GEN_BIN_IMAGE = 1

# Define target output
target: bit

# Define target part
export PRJ_PART = XCZU7EV-FFVC1156-2-E

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../..)

# Use top level makefile
include ../shared_config.mk
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
