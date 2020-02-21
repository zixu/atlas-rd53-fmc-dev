# Define target output
target: prom

# Define target part
export PRJ_PART = XC7K160TFBG484-2

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../..)

# Use top level makefile
include ../shared_config.mk
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
