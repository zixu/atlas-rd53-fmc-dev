# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Load the source code
loadSource           -dir  "$::DIR_PATH/rtl"
loadSource -sim_only -dir  "$::DIR_PATH/tb"

set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
