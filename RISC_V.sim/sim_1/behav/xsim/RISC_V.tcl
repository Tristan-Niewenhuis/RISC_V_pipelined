set CLEAR_EXISTING_WAVES 1

set DUT_SCOPE        "/RISC_V_tb/uut/RISC_V_block_i/RISC_V_0/U0"
set DATAPATH_SCOPE   "${DUT_SCOPE}/datapath"
set FETCH_SCOPE      "${DUT_SCOPE}/Fetch"
set LOAD_STORE_SCOPE "${DUT_SCOPE}/Load_Store"

if {$CLEAR_EXISTING_WAVES} {
    set existing_waves [get_waves -quiet *]
    if {[llength $existing_waves] > 0} {
        remove_wave $existing_waves
    }
}

proc add_scope_signals_to_group {group_name scope_path} {
    set group [add_wave_group $group_name]
    add_wave -into $group [get_objects ${scope_path}/*]
}

set tb_group [add_wave_group "testbench"]
add_wave -into $tb_group /RISC_V_tb/sys_clock
add_wave -into $tb_group /RISC_V_tb/resetn
add_wave -into $tb_group /RISC_V_tb/led_16bits_tri_o
add_wave -into $tb_group /RISC_V_tb/dip_switches_16bits_tri_i

add_scope_signals_to_group "DUT"        $DUT_SCOPE
add_scope_signals_to_group "datapath"   $DATAPATH_SCOPE
add_scope_signals_to_group "fetch"      $FETCH_SCOPE
add_scope_signals_to_group "load_store" $LOAD_STORE_SCOPE

run 15us
