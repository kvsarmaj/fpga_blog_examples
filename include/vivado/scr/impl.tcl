#-------------------------------------------------------------------------------
# Integrated script for Vivado synthesis and implementation in batch mode
# ------------------------------------------------------------------------------
# Script is invoked through make from fpga directory
# Script is run by Vivado in batch mode - non-project flow
# The script flow is as such
#  - Set all required variables
#  - Read all verilog code - invokes another script read_rtl.tcl
#  - Create and read ips - invokes another script read_ips.tcl
#  - Read xdc for constrains - xdc should be placed in .../fpga/xdc/
#  - Performs synthesis
#  - Creates post synthesis DCP - global option selectable from Makefile
#  - Reports post synthesis timing
#  - Reports post synthesis utilization
#  - Reports post synthesis power - global option selectable from Makefile
#  - Performs optimization
#     - optimization directives selectable from Makefile
#  - Creates post optimization DCP - global option selectable from Makefile
#  - Reports post optimization timing
#  - Reports post optimization utilization
#  - Reports post optimization power - global option selectable from Makefile
#  - Performs placement
#     - placement directives selectable from Makefile
#  - Creates post place DCP - global option selectable from Makefile
#  - Reports post place timing
#  - Reports post place utilization
#  - Reports post place power - global option selectable from Makefile
#  - Performs route
#     - route directives selectable from Makefile
#  - Creates post route DCP - global option selectable from Makefile
#  - Reports post route timing
#  - Reports post route utilization
#  - Reports post route power - global option selectable from Makefile
#-------------------------------------------------------------------------------

#-----------------------------
# Environment Variables
#-----------------------------

set proj_root $env(PROJ_ROOT)
set proj_ip $env(PROJ_IP)
set proj_bd $env(PROJ_BD)
set proj_rtl $env(PROJ_RTL)
set fpga_dir $env(FPGA_DIR)
set fpga_syn_scr $env(FPGA_SYN_SCR)
set fpga_syn_xdc $env(FPGA_SYN_XDC)
set fpga_dcp $env(FPGA_DCP)
set syn_dcp $env(SYN_DCP)

set work_tag $env(WORK_TAG)
set work_dir $env(WORK_DIR)

set run_pnr $env(RUN_PNR)
set power_run $env(POWER_RUN)
set report_power $env(REPORT_POWER)
set fpga_part_num $env(FPGA_PART_NUM)
set top $env(TOP)

# Control report generation
set dump_timing_reports_at_every_dcp $env(DUMP_TIMING_REPORTS_AT_EVERY_DCP)
set dump_hier_util_reports $env(DUMP_HIER_UTIL_REPORTS)

# Load DCP instead of running synthesis
set load_syn_dcp $env(LOAD_SYN_DCP)

# Post synthesis step control
set no_dcps $env(NO_DCPS)
set no_vivado_directives $env(NO_VIVADO_DIRECTIVES)

# Logic optimization step
set opt_design_directive_sel $env(OPT_DESIGN_DIRECTIVE_SEL)
set opt_design_directive $env(OPT_DESIGN_DIRECTIVE)

# Place step
set place_design_directive_sel $env(PLACE_DESIGN_DIRECTIVE_SEL)
set place_design_directive $env(PLACE_DESIGN_DIRECTIVE)

# Post place physical optimization
set run_post_place_phys_opt $env(RUN_POST_PLACE_PHYS_OPT)
set run_post_place_phys_opt_directive_sel $env(POST_PLACE_PHYS_OPT_DIRECTIVE_SEL)
set run_post_place_phys_opt_directive $env(POST_PLACE_PHYS_OPT_DIRECTIVE)

# Route step
set route_design_directive_sel $env(ROUTE_DESIGN_DIRECTIVE_SEL)
set route_design_directive $env(ROUTE_DESIGN_DIRECTIVE)

# Post route physical optimization
set run_post_route_phys_opt $env(RUN_POST_ROUTE_PHYS_OPT)
set run_post_route_phys_opt_directive_sel $env(POST_ROUTE_PHYS_OPT_DIRECTIVE_SEL)
set run_post_route_phys_opt_directive $env(POST_ROUTE_PHYS_OPT_DIRECTIVE)

set syn_dcp $fpga_dcp/$env(SYN_DCP)

set work_dir $fpga_dir/$env(WORK_DIR)

#set_property board "xilinx.com:vcu118:part0:2.0" [current_project]

set_param general.maxThreads 8

#-----------------------------

#-----------------------------
# Reading RTL
#-----------------------------

if { $load_syn_dcp != "Yes" } {

    source $fpga_syn_scr/read_rtl.tcl
    source $fpga_syn_scr/read_ips.tcl
    source $fpga_syn_scr/read_xdc.tcl

}
#-----------------------------

#-----------------------------
# Perform synthesis, generate reports and create DCP
#-----------------------------

if { $load_syn_dcp == "Yes" } {
    puts "Loading synthesis DCP $syn_dcp"
    open_checkpoint $syn_dcp

	puts "Loading constraints"
    #source $fpga_syn_scr/read_xdc.tcl

} else {
    puts "Commencing synthesis"
    
    # Synthesize
    synth_design -top $top -include_dirs $proj_rtl -part $fpga_part_num
    
    # Create DCP
    if { $no_dcps != "Yes" } {
        write_checkpoint -force $work_dir/post_synth.dcp
    }
    
    # Report utilization
    report_utilization -file $work_dir/post_synth_util.rpt
    
    if { $dump_hier_util_reports == "Yes" } {
        report_utilization -hierarchical -file $work_dir/post_synth_util_hier.rpt
    }
    
    # Report timing
    if { $dump_timing_reports_at_every_dcp == "Yes" } {
        report_timing_summary -file $work_dir/post_synth_timing_report.rpt
    }    
    # dump netlist
    write_verilog -force $work_dir/post_synth_netlist.v
    
    # Report power
    if { $report_power == "Yes" } {
        report_power -file $work_dir/post_synth_power.rpt
    }   
}

#-----------------------------

#-----------------------------
# Perform optimization, generate reports and create DCP
#-----------------------------

puts "PNR option selected is $run_pnr"

if { $run_pnr == "Yes" } { 

    puts "Performing optimization"
    
    # Optimize
    if { $no_vivado_directives == "Yes" } {
        opt_design
    } elseif { $opt_design_directive_sel == "Yes" } {
        opt_design -directive $opt_design_directive
    } else {
        opt_design
    }

    # Power optimization
    if { $power_run == "Yes" } {
        power_opt_design
    }

    if { $no_dcps != "Yes" } {
        write_checkpoint -force $work_dir/post_opt.dcp
    }

    # Report timing
    if { $dump_timing_reports_at_every_dcp == "Yes" } {
        report_timing_summary -file $work_dir/post_opt_timing_report.rpt
    }

    # Report utilization
    report_utilization -file $work_dir/post_opt_util.rpt
    
    if { $dump_hier_util_reports == "Yes" } {
        report_utilization -hierarchical -file $work_dir/post_opt_util_hier.rpt
    }

    # Report power
    if { $report_power == "Yes" } {
        report_power -file $work_dir/post_opt_power.rpt
    }

}

#-----------------------------

#-----------------------------
# Perform placement, generate reports and create DCP
#-----------------------------

if { $run_pnr == "Yes" } { 

    puts "Performing placement"
    
    # Place
    if { $no_vivado_directives == "Yes" } {
        place_design
    } elseif { $place_design_directive_sel == "Yes" } {
        place_design -directive $place_design_directive
    } else {
        place_design
    }

    if { $no_dcps != "Yes" } {
        write_checkpoint -force $work_dir/post_place.dcp
    }

    # Report timing
    if { $dump_timing_reports_at_every_dcp == "Yes" } {
        report_timing_summary -file $work_dir/post_place_timing_report.rpt
    }

    # Report utilization
    report_utilization -file $work_dir/post_place_util.rpt
    
    if { $dump_hier_util_reports == "Yes" } {
        report_utilization -hierarchical -file $work_dir/post_place_util_hier.rpt
    }

    # Report power
    if { $report_power == "Yes" } {
        report_power -file $work_dir/post_place_power.rpt
    }

	# Physical optimization
	if { $run_post_place_phys_opt == "Yes" } {
		if { $no_vivado_directives == "Yes" } { 
			phys_opt_design
		} elseif { $run_post_place_phys_opt_directive_sel == "Yes" } {
			phys_opt_design -directive $run_post_place_phys_opt_directive 
		} else {
			phys_opt_design
		}
	}

    if { $no_dcps != "Yes" } {
        write_checkpoint -force $work_dir/post_place_phys_opt.dcp
    }

    # Report timing
    if { $dump_timing_reports_at_every_dcp == "Yes" } {
        report_timing_summary -file $work_dir/post_place_phys_opt_timing_report.rpt
    }

    # Report utilization
    report_utilization -file $work_dir/post_place_phys_opt_util.rpt
    
    if { $dump_hier_util_reports == "Yes" } {
        report_utilization -hierarchical -file $work_dir/post_place_phys_opt_util_hier.rpt
    }

    # Report power
    if { $report_power == "Yes" } {
        report_power -file $work_dir/post_place_phys_opt_power.rpt
    }

}

#-----------------------------

#-----------------------------
# Perform route, generate reports and create DCP
#-----------------------------

if { $run_pnr == "Yes" } { 

    puts "Performing route"
    
    # Route
    if { $no_vivado_directives == "Yes" } {
        route_design
    } elseif { $route_design_directive_sel == "Yes" } {
        route_design -directive $route_design_directive
    } else {
        route_design
    }

    if { $no_dcps != "Yes" } {
        write_checkpoint -force $work_dir/post_route.dcp
    }

    # Report timing
    if { $dump_timing_reports_at_every_dcp == "Yes" } {
        report_timing_summary -file $work_dir/post_route_timing_report.rpt
    }

    # Report utilization
    report_utilization -file $work_dir/post_route_util.rpt
    
    if { $dump_hier_util_reports == "Yes" } {
        report_utilization -hierarchical -file $work_dir/post_route_util_hier.rpt
    }

    # Report power
    if { $report_power == "Yes" } {
        report_power -file $work_dir/post_route_power.rpt
    }

    report_clock_utilization -file $work_dir/clock_util.rpt
    
 	# Physical optimization
	if { $run_post_route_phys_opt == "Yes" } {
		if { $no_vivado_directives == "Yes" } { 
			phys_opt_design
		} elseif { $run_post_route_phys_opt_directive_sel == "Yes" } {
			phys_opt_design -directive $run_post_route_phys_opt_directive 
		} else {
			phys_opt_design
		}
	}

    if { $no_dcps != "Yes" } {
        write_checkpoint -force $work_dir/post_route_phys_opt.dcp
    }

    # Report timing
    if { $dump_timing_reports_at_every_dcp == "Yes" } {
        report_timing_summary -file $work_dir/post_route_phys_opt_timing_report.rpt
    }

    # Report utilization
    report_utilization -file $work_dir/post_route_phys_opt_util.rpt
    
    if { $dump_hier_util_reports == "Yes" } {
        report_utilization -hierarchical -file $work_dir/post_route_phys_opt_util_hier.rpt
    }

    # Report power
    if { $report_power == "Yes" } {
        report_power -file $work_dir/post_route_phys_opt_power.rpt
    }
}

#-----------------------------

#-----------------------------
# Generate bitstream

write_bitstream -force $work_dir/$top.bit

#-----------------------------

#-----------------------------
# Post run
#  - add any additional scripts for reports
#     or any post PNR optimizations here
#     commands for generating bitstream
#     commands for datasheet etc.
#    mostly it will be specific timing reports
#    but there is a lot more that can be done here

# Report timing
if { $dump_timing_reports_at_every_dcp == "No" } {
    report_timing_summary -file $work_dir/timing_summary.rpt
}

#-----------------------------

puts "Vivado run completed"
puts "Log files are available in $work_dir"
exit
