# Automatically add newly-declared signals from the entity represented by
# each waveform group's first signal. Existing WCFG objects and their display
# properties are left alone. This script deliberately does not save the WCFG.

proc auto_wave_xml_attribute {tag attribute} {
    set pattern [format {(^|[[:space:]])%s="([^"]*)"} $attribute]
    if {[regexp $pattern $tag whole prefix value]} {
        return $value
    }
    return ""
}

proc auto_wave_read_groups {wcfg_path} {
    if {![file exists $wcfg_path]} {
        return {}
    }

    set channel [open $wcfg_path r]
    set xml [read $channel]
    close $channel

    # Walk only the nested wvobject tags. The WCFG file is read-only here;
    # modifications are made to the in-memory waveform configuration.
    set object_stack {}
    set group_stack {}
    set first_signal [dict create]
    set group_members [dict create]
    set group_labels [dict create]

    set tokens [regexp -all -inline {<wvobject[[:space:]][^>]*>|</wvobject>|<obj_property[[:space:]]+name="label">[^<]*</obj_property>} $xml]
    foreach token $tokens {
        if {[regexp {^<obj_property[[:space:]]+name="label">([^<]*)</obj_property>$} $token whole label]} {
            if {[llength $object_stack] > 0 && [lindex [lindex $object_stack end] 0] eq "group"} {
                set group_name [lindex [lindex $object_stack end] 1]
                dict set group_labels $group_name $label
            }
            continue
        }

        if {$token eq "</wvobject>"} {
            if {[llength $object_stack] == 0} {
                continue
            }
            set object_type [lindex [lindex $object_stack end] 0]
            set object_stack [lrange $object_stack 0 end-1]
            if {$object_type eq "group"} {
                set group_stack [lrange $group_stack 0 end-1]
            }
            continue
        }

        set object_type [auto_wave_xml_attribute $token type]
        set object_name [auto_wave_xml_attribute $token fp_name]

        if {$object_type eq "group"} {
            dict set first_signal $object_name ""
            dict set group_members $object_name {}
            lappend group_stack $object_name
        } elseif {[string match {/*} $object_name]} {
            foreach group_name $group_stack {
                if {[dict get $first_signal $group_name] eq ""} {
                    dict set first_signal $group_name $object_name
                }
                dict lappend group_members $group_name $object_name
            }
        }

        lappend object_stack [list $object_type $object_name]
    }

    return [list $first_signal $group_members $group_labels]
}

proc auto_wave_extend_config {wave_config} {
    set wcfg_path [get_property FILE_PATH $wave_config]
    if {$wcfg_path eq ""} {
        puts "Auto-wave: skipping a waveform configuration without a file path."
        return
    }

    set parsed [auto_wave_read_groups $wcfg_path]
    if {[llength $parsed] != 3} {
        puts "Auto-wave: could not read WCFG: $wcfg_path"
        return
    }
    lassign $parsed first_signal group_members group_labels

    dict for {group_name first_path} $first_signal {
        if {$first_path eq ""} {
            continue
        }

        if {![dict exists $group_labels $group_name]} {
            puts "Auto-wave: group '$group_name' has no label; skipping it."
            continue
        }
        set group_label [dict get $group_labels $group_name]
        if {$group_label eq ""} {
            puts "Auto-wave: group '$group_name' has no label; skipping it."
            continue
        }

        set entity_scope [file dirname $first_path]
        set existing_paths [dict get $group_members $group_name]
        set filter {type == signal || type == in_port || type == out_port || type == inout_port || type == port}
        set entity_signals [get_objects -quiet -filter $filter "${entity_scope}/*"]
        set missing_signals {}

        foreach signal_path $entity_signals {
            if {[lsearch -exact $existing_paths $signal_path] < 0} {
                lappend missing_signals $signal_path
            }
        }

        if {[llength $missing_signals] == 0} {
            continue
        }

        # Use the visible group label (for example "datapath"). WCFG fp_name
        # values such as "group261" are internal IDs and are not valid -into
        # names in XSIM.
        if {[catch {add_wave -into $group_label {*}$missing_signals} message]} {
            puts "Auto-wave: could not extend group '$group_label' from '$entity_scope': $message"
        } else {
            puts "Auto-wave: added [llength $missing_signals] signal(s) to '$group_label' from '$entity_scope'."
        }
    }
}

if {[catch {current_wave_config} original_wave_config] || $original_wave_config eq ""} {
    puts "Auto-wave: no current waveform configuration; nothing to add."
} else {
    set wave_configs [get_wave_configs]
    if {[llength $wave_configs] == 0} {
        set wave_configs [list $original_wave_config]
    }

    foreach wave_config $wave_configs {
        if {[catch {current_wave_config $wave_config} message]} {
            puts "Auto-wave: could not select waveform configuration '$wave_config': $message"
            continue
        }
        auto_wave_extend_config $wave_config
    }

    # Leave the simulator on the waveform configuration that was selected
    # before this script ran.
    catch {current_wave_config $original_wave_config}
}
