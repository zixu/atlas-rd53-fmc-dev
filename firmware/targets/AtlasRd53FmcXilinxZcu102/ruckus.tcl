# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/rce-gen3-fw-lib/XilinxZcu102Core
loadRuckusTcl $::env(TOP_DIR)/common

# Load local Source Code and constraints
loadConstraints -dir "$::DIR_PATH/hdl"
# loadSource -dir "$::DIR_PATH/hdl"
# loadIpCore -dir "$::DIR_PATH/ip"
loadSource -path "$::DIR_PATH/hdl/AtlasRd53FmcXilinxZcu102.vhd"
loadSource -path "$::DIR_PATH/../AtlasRd53FmcXilinxKcu105/hdl/AtlasRd53HsSelectio.vhd"

# Load the simulation testbed
loadSource -sim_only -dir "$::DIR_PATH/tb"
set_property top {AtlasRd53FmcXilinxZcu102Tb} [get_filesets sim_1]
