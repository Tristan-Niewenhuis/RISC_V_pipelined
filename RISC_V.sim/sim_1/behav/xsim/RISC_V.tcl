set SKIP 0

set DUT_SCOPE        "/RISC_V_tb/uut/RISC_V_block_i/RISC_V_0/U0"
set DATAPATH_SCOPE   "${DUT_SCOPE}/datapath"
set FETCH_SCOPE      "${DUT_SCOPE}/Fetch"
set LOAD_STORE_SCOPE "${DUT_SCOPE}/Load_Store"

# Path to your existing WCFG file
set OLD_WCFG "C:/RISC_V_research/RISC_V/RISC_V_tb_behav.wcfg"


# Parse a WCFG file and return every wvobject fp_name that is NOT a group.
proc get_wcfg_signal_paths {wcfg_file} {
    set paths {}

    if {![file exists $wcfg_file]} {
        puts "WARNING: WCFG file not found: $wcfg_file"
        return $paths
    }

    set fh [open $wcfg_file r]
    set data [read $fh]
    close $fh

    # Match every  <wvobject fp_name="..." type="...">
    foreach {full fp_name type} \
        [regexp -all -inline \
            {<wvobject\s+fp_name="([^"]+)"\s+type="([^"]+)"} \
            $data] {

        # Skip groups / dividers, keep real signals only
        if {$type ne "group" && $type ne "divider"} {
            lappend paths $fp_name
        }
    }

    return [lsort -unique $paths]
}


# Add a design object only if its full path is not already in the WCFG.
proc add_wave_if_missing {group design_object existing_paths_var} {
    upvar 1 $existing_paths_var existing_paths

    set object_path [get_property -quiet NAME $design_object]

    if {$object_path eq ""} {
        set object_path $design_object
    }

    if {[lsearch -exact $existing_paths $object_path] < 0} {
        puts "ADDING:   $object_path"
        add_wave -into $group $design_object
        lappend existing_paths $object_path
    }
}


# Find an existing waveform group or create it.
proc get_or_create_wave_group {group_name} {
    set group [get_waves -quiet $group_name]

    if {[llength $group] == 0} {
        set group [add_wave_group $group_name]
    } else {
        set group [lindex $group 0]
    }

    return $group
}


# Add all objects immediately beneath a scope.
proc add_scope_signals_to_group {group_name scope_path existing_paths_var} {
    upvar 1 $existing_paths_var existing_paths

    set group [get_or_create_wave_group $group_name]

    foreach design_object [get_objects -quiet ${scope_path}/*] {
        add_wave_if_missing $group $design_object existing_paths
    }
}


if {!$SKIP} {

    # Build the "already present" list from the old WCFG file on disk.
    set existing_wave_paths [get_wcfg_signal_paths $OLD_WCFG]

    # Testbench signals
    set tb_group [get_or_create_wave_group "testbench"]

    foreach signal {
        /RISC_V_tb/sys_clock
        /RISC_V_tb/resetn
        /RISC_V_tb/led_16bits_tri_o
        /RISC_V_tb/dip_switches_16bits_tri_i
    } {
        set design_object [get_objects -quiet $signal]

        if {[llength $design_object] > 0} {
            add_wave_if_missing \
                $tb_group [lindex $design_object 0] existing_wave_paths
        } else {
            puts "WARNING: Simulation object not found: $signal"
        }
    }

    # DUT hierarchy
    add_scope_signals_to_group "DUT"        $DUT_SCOPE       existing_wave_paths
    add_scope_signals_to_group "datapath"   $DATAPATH_SCOPE  existing_wave_paths
    add_scope_signals_to_group "fetch"      $FETCH_SCOPE     existing_wave_paths
    add_scope_signals_to_group "load_store" $LOAD_STORE_SCOPE existing_wave_paths

} else {
    puts "SKIP = 1: skipping waveform setup, using existing WCFG."
}


# Runs in both cases
run 15us