# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/common

# Load local source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -path "$::DIR_PATH/../../submodules/axi-pcie-core/hardware/XilinxKc705/xdc/XilinxKc705App.xdc"
loadConstraints -dir  "$::DIR_PATH/../AtlasRd53FmcXilinxKc705Pcie/hdl"
loadConstraints -dir  "$::DIR_PATH/hdl"
