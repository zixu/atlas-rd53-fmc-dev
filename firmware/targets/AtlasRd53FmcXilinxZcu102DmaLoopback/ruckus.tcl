# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for version 2020.1 of Vivado (or later)
if { [VersionCheck 2020.1] < 0 } {exit -1}

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/rce-gen3-fw-lib/XilinxZcu102Core

# Load local Source Code and constraints
loadSource -dir       "$::DIR_PATH/hdl"
loadConstraints -dir  "$::DIR_PATH/hdl"
