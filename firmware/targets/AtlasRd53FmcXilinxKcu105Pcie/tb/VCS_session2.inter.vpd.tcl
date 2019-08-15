# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Wed Aug 14 20:38:12 2019
# Designs open: 1
#   Sim: simv
# Toplevel windows open: 3
# 	TopLevel.1
# 	TopLevel.2
# 	TopLevel.3
#   Source.1: /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/U_DEMUX/GEN_VEC(0)/U_PIPELINE
#   Wave.1: 18 signals
#   Wave.2: 160 signals
#   Group count = 9
#   Group Group1 signal count = 13
#   Group Group3 signal count = 48
#   Group Group4 signal count = 0
#   Group Group5 signal count = 1
#   Group Group6 signal count = 8
#   Group Group7 signal count = 4
#   Group Group8 signal count = 21
#   Group Group9 signal count = 67
#   Group Group10 signal count = 16
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-1_Full64
# DVE build date: Jan 18 2018 21:17:37


#<Session mode="Full" path="/afs/slac.stanford.edu/u/re/ruckman/projects/atlas/atlas-rd53-fmc-dev/software/config/session2.inter.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{1 38} {2560 923}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 545]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
catch { set Stack.1 [gui_share_window -id ${HSPane.1} -type Stack -silent] }
catch { set Class.1 [gui_share_window -id ${HSPane.1} -type Class -silent] }
catch { set Object.1 [gui_share_window -id ${HSPane.1} -type Object -silent] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 545
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 544} {height 638} {dock_state left} {dock_on_new_line true} {child_hier_colhier 496} {child_hier_coltype 61} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 417]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
catch { set Local.1 [gui_share_window -id ${DLPane.1} -type Local -silent] }
catch { set Member.1 [gui_share_window -id ${DLPane.1} -type Member -silent] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 417
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 580
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 416} {height 638} {dock_state left} {dock_on_new_line true} {child_data_colvariable 216} {child_data_colvalue 80} {child_data_coltype 111} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 167]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value -1
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 167
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 2559} {height 166} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{1 38} {2560 923}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 520} {child_wave_right 2034} {child_wave_colname 281} {child_wave_colvalue 237} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings


# Create and position top-level window: TopLevel.3

if {![gui_exist_window -window TopLevel.3]} {
    set TopLevel.3 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.3 TopLevel.3
}
gui_show_window -window ${TopLevel.3} -show_state maximized -rect {{1 38} {2560 923}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.3} -option true

# MDI window settings
set Wave.2 [gui_create_window -type {Wave}  -parent ${TopLevel.3}]
gui_show_window -window ${Wave.2} -show_state maximized
gui_update_layout -id ${Wave.2} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 743} {child_wave_right 1811} {child_wave_colname 276} {child_wave_colvalue 463} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}
gui_update_statusbar_target_frame ${TopLevel.3}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{-ucligui }}
gui_set_env SIMSETUP::SIMEXE {simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {simv}] } {
gui_sim_run Ucli -exe simv -args {-ucligui } -dir ../behav -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 1ps
gui_set_time_units 1us
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus
gui_bus_create -name EXP:bus {/ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(0) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(1) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(2) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(3) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(4) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(5) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(6) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(7) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(8) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(9) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(10) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(11) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(12) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(13) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(14) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(15) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(16) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(17) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(18) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(19) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(20) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(21) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(22) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(23) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(24) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(25) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(26) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(27) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(28) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(29) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(30) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(31) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(32) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(33) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(34) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(35) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(36) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(37) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(38) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(39) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(40) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(41) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(42) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(43) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(44) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(45) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(46) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(47) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(48) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(49) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(50) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(51) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(52) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(53) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(54) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(55) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(56) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(57) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(58) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(59) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(60) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(61) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(62) /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER.TDATA(63)}

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {/ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER}


set _session_group_294 Group1
gui_sg_create "$_session_group_294"
set Group1 "$_session_group_294"

gui_sg_addsignal -group "$_session_group_294" { /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/CLK160MHZ /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RST160MHZ /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/CONFIGMASTER /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/LINKUP /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/CHBOND /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DEBUGSTREAM /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/DATAMASTER /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/AUTOREADREG /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/R /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RXLINKUP /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RXVALID /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RXHEADER /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RXDATA }

set _session_group_295 Group3
gui_sg_create "$_session_group_295"
set Group3 "$_session_group_295"

gui_sg_addsignal -group "$_session_group_295" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/ActiveLanes /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_SEL_SER_CLK /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SER_EN_TAP /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SER_INV_TAP /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SelSerializerType /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SerSelOut0 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SerSelOut1 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SerSelOut2 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SerSelOut3 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_CP_IBIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_EN_GCK2 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_PD_DEL /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_PD_SEL /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_SEL_DEL_CLK /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_VCO_BUFF_BIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_VCO_GAIN /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CDR_VCO_IBIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/GP_LVDS_BIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/GP_LVDS_EN_B /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/GP_LVDS_ROUTE /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/LANE0_LVDS_BIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/LANE0_LVDS_EN_B /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/OutputFormat /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/DataReadDelay /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/GLOBAL_PULSE_ROUTE /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MONITOR_FRAME_SKIP /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MonitorEnable /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoRead /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SkippedTriggerCnt /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MONITOR_FRAME_SKIP /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/WrSkippedTriggerCntRst /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AURORA_INIT_WAIT /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CBSend /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CBWait /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CML_EN_LANE /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CML_TAP0_BIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CML_TAP1_BIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CML_TAP2_BIAS /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SER_EN_TAP /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/SER_INV_TAP /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/OutputFormat /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/ChannelSync/Locked /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/ACB/POR_DIG_B /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/Aurora64b66b_Frame_Multilane_top/SerializerLock }
gui_sg_addsignal -group "$_session_group_295" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CCSend /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CCWait /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CBSend /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CBWait }
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MONITOR_FRAME_SKIP}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MONITOR_FRAME_SKIP}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoRead}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoRead}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MONITOR_FRAME_SKIP}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/MONITOR_FRAME_SKIP}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AURORA_INIT_WAIT}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AURORA_INIT_WAIT}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CML_TAP0_BIAS}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/CML_TAP0_BIAS}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CCSend}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CCSend}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CCWait}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CCWait}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CBSend}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CBSend}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CBWait}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CBWait}

set _session_group_296 Group4
gui_sg_create "$_session_group_296"
set Group4 "$_session_group_296"


set _session_group_297 Group5
gui_sg_create "$_session_group_297"
set Group5 "$_session_group_297"

gui_sg_addsignal -group "$_session_group_297" { /EXP:bus }

set _session_group_298 Group6
gui_sg_create "$_session_group_298"
set Group6 "$_session_group_298"

gui_sg_addsignal -group "$_session_group_298" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRegAddr /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRegData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdWrReg /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRdReg /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/RdReg_mux /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/RdReg /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/RegAddr /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/RegData }
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRegAddr}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRegAddr}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRegData}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/CmdRegData}
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/RegAddr}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/CommandDecoder/RegAddr}

set _session_group_299 Group7
gui_sg_create "$_session_group_299"
set Group7 "$_session_group_299"

gui_sg_addsignal -group "$_session_group_299" { /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_CMD/U_CMD/CMDMASTER.TVALID /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_CMD/U_CMD/CMDSLAVE.TREADY /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_CMD/U_CMD/CMDOUT /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_CMD/U_CMD/R }

set _session_group_300 Group8
gui_sg_create "$_session_group_300"
set Group8 "$_session_group_300"

gui_sg_addsignal -group "$_session_group_300" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdGC /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/WrGC /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdRegCmdDly /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdPixCntFull /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdPixCnt /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero0 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero1 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero2 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero3 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero4 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero5 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero6 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadZero7 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/GC_Reset_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdPixelConf /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdWrPixelConf /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/NewRegData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/LoadDataMaskRst_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RegData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/AutoReadData }
gui_set_radix -radix {decimal} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdPixCnt}
gui_set_radix -radix {unsigned} -signals {Sim:/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/RdPixCnt}

set _session_group_301 Group9
gui_sg_create "$_session_group_301"
set Group9 "$_session_group_301"

gui_sg_addsignal -group "$_session_group_301" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WrWngFifoFullCntRst /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/SkippedTriggerCntErr /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/Reset_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/RegData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ReadClk /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/NumActiveLanes /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/NewRegData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/MonitorRead /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/MonitorEmpty /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/MonData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/LockLoss /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/LoadDataMaskRst_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FrameSkip /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoFullCnt /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ErrWngMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/EnMon /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/CmdErr /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/Clk160 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ChSyncOutOfLock /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/BitFlipWng /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/BitFlipErr /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/AutoReadData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ActiveLanes /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WrFifo /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WrDataDone /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WrDataDly /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WrData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WngFifoFullCnt /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WngFifoFullCntMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/WngFifoFull /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/Status /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/SkippedTriggerCntMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/SendFrame /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ResetFSM_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/RdFifo /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/MonitorReadSync /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/LockLossMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/LoadDefaultData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/LoadData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/LoadDataMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/KWordMM /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/KWordMA /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/KWordEE /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/KWordAM /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/KWordAA /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FrameData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FrameDataDly /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoOut /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoIn }
gui_sg_addsignal -group "$_session_group_301" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoFull /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoFullError /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoEmpty /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FFW_Reset_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/Data /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/DataToBeSent /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/CmpClkCnt /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/CmdErrMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ClkCnt /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/ChSyncOutOfLockMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/CdcSyncReset /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/BitFlipWngMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/BitFlipErrMask /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/AuroraKWord /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/NumActiveLanes /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/MonitorEmpty /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/MonData /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorData/FifoFullCnt }

set _session_group_302 Group10
gui_sg_create "$_session_group_302"
set Group10 "$_session_group_302"

gui_sg_addsignal -group "$_session_group_302" { /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/synch_reset_q1 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/synch_reset_q0 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/synch_reset_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/ch_synch_clk_40 /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/asynch_reset_b_delayed /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/asynch_reset_b_deglitched /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/asynch_reset_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/MonitorEnable /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/Monitor_read /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/Monitor_empty_sync /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/Monitor_empty /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/ResetMonData_b /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/EnMontmp /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/EnMon /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/GlobalConfiguration/GLOBAL_PULSE_ROUTE /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/global_pulse }

# Global: Highlighting
gui_highlight_signals -color #d2b48c {/ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/R.READBACKDET /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/R.AUTODET}
gui_highlight_signals -color #ffff00 {{/ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_CMD/U_CMD/R.TDATA(31 downto 0)}}

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 327.44004



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} /ATLASRD53FMCXILINXKCU105PCIETB}
catch {gui_list_expand -id ${Hier.1} /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)}
catch {gui_list_expand -id ${Hier.1} /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC}
catch {gui_list_expand -id ${Hier.1} /ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut}
catch {gui_list_select -id ${Hier.1} {/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Class 'Class.1'
gui_list_set_filter -id ${Class.1} -list { {OVM 1} {VMM 1} {All 1} {Object 1} {UVM 1} {RVM 1} }
gui_list_set_filter -id ${Class.1} -text {*}
gui_change_design -id ${Class.1} -design Sim

# Member 'Member.1'
gui_list_set_filter -id ${Member.1} -list { {InternalMember 0} {RandMember 1} {All 0} {BaseMember 0} {PrivateMember 1} {LibBaseMember 0} {AutomaticMember 1} {VirtualMember 1} {PublicMember 1} {ProtectedMember 1} {OverRiddenMember 0} {InterfaceClassMember 1} {StaticMember 1} }
gui_list_set_filter -id ${Member.1} -text {*}

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*pulse*}
gui_list_show_data -id ${Data.1} {/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {/ATLASRD53FMCXILINXKCU105PCIETB/GEN_VEC(0)/U_ASIC/dut/DCB/global_pulse }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0
# Warning: Class view not found.

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 327.395772 327.584268
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group4}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group5}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group7}
gui_list_collapse -id ${Wave.1} Group5
gui_list_collapse -id ${Wave.1} Group7
gui_list_expand -id ${Wave.1} /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/CONFIGMASTER
gui_list_expand -id ${Wave.1} /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RXDATA
gui_list_select -id ${Wave.1} {/ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/RXDATA(0) }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group Group1  -item /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/GEN_DP(0)/U_CORE/U_RXPHYLAYER/CHBOND -position below

gui_marker_move -id ${Wave.1} {C1} 327.44004
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false

# View 'Wave.2'
gui_wv_sync -id ${Wave.2} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.2}  C1
gui_wv_zoom_timerange -id ${Wave.2} 0 669.783096
gui_list_add_group -id ${Wave.2} -after {New Group} {Group3}
gui_list_add_group -id ${Wave.2} -after {New Group} {Group6}
gui_list_add_group -id ${Wave.2} -after {New Group} {Group8}
gui_list_add_group -id ${Wave.2} -after {New Group} {Group9}
gui_list_add_group -id ${Wave.2} -after {New Group} {Group10}
gui_list_collapse -id ${Wave.2} Group3
gui_list_collapse -id ${Wave.2} Group6
gui_list_collapse -id ${Wave.2} Group8
gui_list_collapse -id ${Wave.2} Group9
gui_list_collapse -id ${Wave.2} Group10
gui_seek_criteria -id ${Wave.2} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.2}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.2} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.2} -text {*}
gui_list_set_insertion_bar  -id ${Wave.2} -group Group10  -position in

gui_marker_move -id ${Wave.2} {C1} 327.44004
gui_view_scroll -id ${Wave.2} -vertical -set 0
gui_show_grid -id ${Wave.2} -enable false

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active /ATLASRD53FMCXILINXKCU105PCIETB/U_FPGA/U_APP/U_DEMUX/GEN_VEC(0)/U_PIPELINE /u/re/ruckman/projects/atlas/atlas-rd53-fmc-dev/firmware/submodules/surf/axi/axi-stream/rtl/AxiStreamPipeline.vhd
gui_view_scroll -id ${Source.1} -vertical -set 1944
gui_src_set_reusable -id ${Source.1}
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
if {[gui_exist_window -window ${TopLevel.3}]} {
	gui_set_active_window -window ${TopLevel.3}
	gui_set_active_window -window ${Wave.2}
}
#</Session>

