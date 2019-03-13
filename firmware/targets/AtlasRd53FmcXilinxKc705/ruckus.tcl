# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/axi-pcie-core/hardware/XilinxKc705
loadRuckusTcl $::env(TOP_DIR)/common

# Load Timon's source code
loadSource -dir "$::env(PROJ_DIR)/../../submodules/HomebrewAurora/RX"
loadSource -dir "$::env(PROJ_DIR)/../../submodules/HomebrewAurora/RX/xapp1017"

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"
