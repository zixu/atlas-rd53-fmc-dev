# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Load the source code
loadSource -dir "$::DIR_PATH/rtl"

if { ${family} eq {artix7}  ||
     ${family} eq {kintex7} ||
     ${family} eq {virtex7} ||
     ${family} eq {zynq} } {
   loadSource -dir  "$::DIR_PATH/rtl/7Series"
}

if { ${family} eq {kintexu} ||
     ${family} eq {kintexuplus} ||
     ${family} eq {virtexuplus} ||
     ${family} eq {zynquplus} } {
   loadSource -dir  "$::DIR_PATH/rtl/UltraScale"
}
