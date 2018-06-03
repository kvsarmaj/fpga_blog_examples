set_part $fpga_part_num

file mkdir $work_dir/ip

set ip_list { \
}

foreach ip_path_el $ip_list {

    set ip_path $proj_rtl/../$ip_path_el
    #puts $ip_path

    # Extract IP name
    set ip_ext $ip_path
    set ip_name [file rootname [file tail $ip_ext]]
    puts "IP name is $ip_name"

    #puts "IP ext is"
    set ip_ext [file extension $ip_ext]
    #puts $ip_ext

    # Set the path to IP hold area
    set ip_hold_path $work_dir/ip/$ip_name/$ip_name$ip_ext
    #puts "IP hold path is "
    #puts $ip_hold_path

    file mkdir $work_dir/ip/$ip_name
    file copy -force $ip_path $ip_hold_path

    # Read ip
    if { $ip_ext eq ".bd" } {
        read_bd $ip_hold_path
    } else {
        read_ip $ip_hold_path
    }

    # Do synthesis of the IP along with top level
    if {$ip_name eq "rap_ddr4"} {
        puts "generating synth dcp for DDR4"
        #upgrade_ip [get_ips ddr4_0]
        #set_property generate_synth_checkpoint true [get_files $ip_hold_path]
    } elseif {$ip_name eq "xdma_0_pcie4_ip"} {
        puts "generating synth dcp for XDMA PCIe IP"
        #upgrade_ip [get_ips xdma_0_pcie4_ip]
        #set_property generate_synth_checkpoint true [get_files $ip_hold_path]
    } elseif {$ip_name eq "xdma_0"} {
        puts "generating synth dcp for XDMA"
        #upgrade_ip [get_ips xdma_0]
        #set_property generate_synth_checkpoint true [get_files $ip_hold_path]
    } elseif {$ip_name eq "xdma_0_pcie4_ip_gt"} {
        puts "generating synth dcp for XDMA"
        #upgrade_ip [get_ips xdma_0_pcie4_ip_gt]
        #set_property generate_synth_checkpoint true [get_files $ip_hold_path]
    } else {
        puts "not generating synth dcp for $ip_name"
        set_property generate_synth_checkpoint false [get_files $ip_hold_path]
        # Disable XDC
        set ip_xdc [get_files -of_objects [get_files $ip_hold_path] -filter {FILE_TYPE == XDC} ]
        #puts "IP XDC files are "
        #puts $ip_xdc
        if {[llength $ip_xdc] != 0} {
            set_property is_enabled false [get_files $ip_xdc]
        }
    }
    # Generate synthesis target
    if { $ip_ext eq ".bd" } {
        generate_target all [get_files $ip_hold_path]
    } else {
        generate_target all [get_ips $ip_name]
    }
}
