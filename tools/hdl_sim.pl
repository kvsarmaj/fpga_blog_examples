#! /usr/bin/perl

use Env;
use Getopt::Long;
use Switch;
use strict;

my $proj_root = "${PROJ_SC_HOME}";
my $ws_root = "${WS_ROOT}";
my $vivado_bin = "${VIVADO_BIN}";
my $short_help;
my $usage;
my $dump_log;
my $log_fname;
my $ver_flist;
my $vhdl_flist;
my $top;
my $mod;
my $work_lib;
my $simulator;
my $cmd;
my $sim_path;
my $hdl_sel;
my $sim_step;
my $test_name;

GetOptions ("-help"              => \$usage,
            "-h"                 => \$short_help,
            "-log"               => \$dump_log,
            "-log_file=s"        => \$log_fname,
			"-hdl_lang=s"        => \$hdl_sel,
            "-ver_flist=s"       => \$ver_flist,
			"-vhdl_flist=s"      => \$vhdl_flist,
            "-test=s"            => \$test_name,
            "-mod=s"             => \$mod,
            "-top=s"             => \$top,
			"-step=s"            => \$sim_step,
            "-work_lib=s"        => \$work_lib,
            "-simulator=s"       => \$simulator
    );

if(defined $short_help) { short_help(); exit(1); };
if(defined $usage) { short_help(); usage(); exit(1); };
if(defined $dump_log) { 
    $dump_log = 1;
} else {
    $dump_log = 0;
}
if(!(defined $sim_step)) {
	$sim_step = "build";
}
if($dump_log == 1) {
    if(!(defined $log_fname)) {
		if($sim_step eq "build") {
			$log_fname = $mod.".build.log";
		} elsif($sim_step eq "sim") {
			$log_fname = $mod.".sim.log";
		}
    }
}
if(!(defined $hdl_sel)) {
	$hdl_sel = "verilog";
}
if(!((defined $ver_flist && ($hdl_sel eq "verilog" or $hdl_sel eq "mixed" )))
   && (!(defined $vhdl_flist && ($hdl_sel eq "vhdl" or $hdl_sel eq "mixed")))){
    print "File list missing. Please provide a file list\n";
    short_help();
}
if(!(defined $simulator)) {
    $simulator = "vivado";
}
if(!(defined $work_lib)) {
	$work_lib = "work_lib"
}

exec_cmd();

#----------------------------------------------------------------------------
# Functions
#----------------------------------------------------------------------------

#--------
# Help
#--------

sub short_help () {
    print "hdl_sim.pl [-h|-help] [-log] [-log_file] -f <opts-in-a-file> -test <test-name> -mod <module> -top <top-name> [-work_lib <lib>] [-simulator] \n";
}

sub usage () {
    print "build_hdl_sim.pl\n";
    print "\t -h				: short help\n";
    print "\t -help				: long help\n";
    print "\t -log				: generate a build log\n";
    print "\t -log_file <>		: name of the log file\n";
    print "\t                     when not provided, log file name will be mod.rtl.comp.log\n";
    print "\t -ver_flist <>		: file containing list of verilog files for build\n";
	print "\t                     necessary field to get list of files for build\n";
	print "\t -vhdl_flist <>	: file containing list of vhdl files for build\n";
	print "\t                     necessary field to get list of files for build\n";
	print "\t -test				: name of the testcase\n";
	print "\t                     required field when simulator is Vivado\n";
	print "\t -mod <>			: module name\n";
	print "\t -top <>			: top of the simulation\n";
	print "\t                     generally should be top tb\n";
	print "\t -work_lib <>		: work library\n";
	print "\t                     when unspecified, mod_work will be used\n";
	print "\t -simulator <>		: target simulation\n";
	print "\t                     when unspecified, Vivado\n";
	print "\t -hdl <>			: hdl language used in design\n";
	print "\t                     must be verilog or vhdl or mixed\n";
	print "\t                     when unspecified, verilog is assumed\n";
	print "\n";
	print "\n";
	print "hdl_sim.pl -log -ver_flist <mod>.sim.files -test <test_name> -mod <mod> -top <top>\n"
}

#--------

sub exec_cmd() {

	if($simulator eq "vivado") {
		if($sim_step eq "build") {
			if($hdl_sel eq "verilog" || $hdl_sel eq "mixed") {
				$cmd = $vivado_bin."/xvlog ";
				$cmd .= "-work ".$work_lib." ";
				$cmd .= "-f ".$ver_flist." ";
				$cmd .= "-log ".$log_fname." ";
				print $cmd."\n";
				system($cmd);
			} 
			if($hdl_sel eq "vhdl" || $hdl_sel eq "mixed") {
				$cmd = $vivado_bin."/xvhdl ";
				$cmd .= "-work ".$work_lib;
				$cmd .= "-f ".$vhdl_flist;
				$cmd .= "-log ".$log_fname;
				print $cmd."\n";
				system($cmd);			
			}
		} elsif($sim_step eq "build") {
			$cmd = $vivado_bin."/xelab ";
			$cmd .= "-work.".$top;
			$cmd .= "-s ".$test_name;
			$cmd .= "-log ".$log_fname;
			print $cmd."\n";
			system($cmd);
			$cmd = $vivado_bin."/xsim ";
			$cmd .= "-R "
		}
	}
	
}

#--------
