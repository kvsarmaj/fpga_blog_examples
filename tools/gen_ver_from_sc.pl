#! /usr/bin/perl

use Env;
use Getopt::Long;
use File::Basename;
use Cwd;
use Switch;
use strict;
use Data::Dumper;
use Storable;

my $proj_root = "${PROJ_SC_HOME}";
my $ws_root = "${WS_ROOT}";
my $short_help;
my $usage;
my $dump_log;
my $log_file;
my $log_fname;
my $ifile;
my $mod;
my $top;
my $ofile;
my $dump_hier;
my $dump_hier_file = 0;
my $hier_file;
my $hier_top;
my $create_sim_file;
my $wr_sim_file = 0;
my $sim_file;
my $sel_depth;
my $inc_list;

my @files;
my @units;
my %mod_list;
my %hier;

my %h;
my %hc;
my $p;
my %full_hier;
my $fh = \%full_hier;
my %sig_list;
my @full_sig_list;

my $bcnt=0;
my $scnt=0;
my $search_inc=0;

GetOptions ("-help"            => \$usage,
            "-h"               => \$short_help,
            "-log"             => \$dump_log,
			"-log_file"        => \$log_fname,
            "-mod=s"           => \$mod,
            "-i=s"             => \$ifile,
            "-top"             => \$top,
            "-o=s"             => \$ofile,
            "-create_sim_file" => \$create_sim_file,
            "-inc_list=s"      => \$inc_list
    );

if(defined $short_help) { short_help(); exit(1); };
if(defined $usage) { short_help(); usage(); exit(1); };
if(defined $dump_log) { $dump_log = 1; };
if(!(defined $log_fname))  { $log_fname = "gen_sim_file.log"; }
if(!(defined $ifile)) {
    if(!(defined $mod)) {
        die "Please specify file list\n";
    } else {
        $ifile = $proj_root."/rtl/".$mod.".rtl.files";
    };
};
if(!(defined $ofile)) {
    $ofile = "sig_list";
};
if(!(defined $top)) {
    if(!(defined $mod)) {
        $top = $ifile;
        $top =~ s/.*\/(.*)$//;
        $top = $1;
        $top =~ s/\..*$//;
    } else {
        $top = $mod;
    }
    $log_file .= $top."\n";
}

if(defined $dump_hier){
    $dump_hier_file = 1;
    if(!(defined $hier_file)) {
        $hier_file = $mod."_hier";
    };
}

if(defined $create_sim_file) {
    $wr_sim_file = 1;
    if(!(defined $sim_file)) {
        $sim_file = "sim.cpp";
    }
}

if(!(defined $sel_depth)) {
    $sel_depth = 0;
}

if(defined $inc_list) {
    $search_inc = 1;
}

#-------------------------------------------------------------------------------
#Build file list and hierarchy
#-------------------------------------------------------------------------------

build_file_list();
build_hier_tree();
build_sig_list();
if($wr_sim_file) {
    write_sim_file();
}
if($dump_log) {
	print "Writing log file...\n";
    open FWP, ">", $log_fname or die "Could not open $log_fname for reading : $!\n";
    print FWP $log_file;
	print "...done\n";
    close(FWP);	
}

#-------------------------------------------------------------------------------
#Build signal list
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#Functions
#-------------------------------------------------------------------------------


#----------
#Help

sub short_help() {
    print " gen_sim_file.pl -help|-h|-mod=|-i= [-log] [-top] [-o=] [-sel_depth=] \n";
    print "                 [-dump_hier] [-hier_file=] [-create_sim_file] [-sim_file=] [-inc_list=] \n";
}

sub usage() {
    print "\n";
    print "   -h                    short usage\n";
    print "   -help                 detailed help\n";
    print "   -log                  dumps log file from the script\n";
	print "   -log_file             specify name of the log file\n";
	print "                         defaults to gen_sim_file.log\n";
    print "   -mod=                 specify module name for building file list\n";
    print "   -i=                   specify you own file list - must be complete list to generate sim file correctly\n";
    print "   -top                  specify top of the hierarchy instantiated in sim.cpp\n";
    print "                           script is generally capable of figuring this out\n";
    print "                           where it fails to do so, specify the top module name\n";
    print "   -o                    specify output file name to dump the signale list\n";
    print "                           when not provided, defaults to sig_list\n";
    print "   -sel_depth            specify hierarchy depth as +ve integer for signal list to be traced\n";
    print "                           when not specified, defaults to 0 i.e., full depth\n";
    print "   -dump_hier            specify if hierarchy file has to be dumped\n";
    print "                           filename specified by -hier_file option\n";
    print "   -hier_file            specify file where hierarchy has to be dumped\n";
    print "                           when not specified, <mod>_hier will be used\n";
    print "                           where <mod> is not specified, top_hier will be used\n";
    print "   -create_sim_file      creates simulation top which initiates simulation\n";
    print "   -sim_file=            specify file name for simulation top which initiates simulation\n";
    print "                           when not specified, defaults to sim.cpp\n";
    print "   -inc_list=            specify included directories \n";
    print "                           preferable when component includes other components/projects\n";
    print "\n";

}

#----------
#build file list

sub build_file_list {
    my $fname;

	$inc_list =~ s/-I//g;
	$log_file .= "Looking in included directories for hierarchy parsing \n";

	my @dirs = split(/\s/,$inc_list);
	foreach my $t (@dirs) {
		$log_file .= "\t".$t."\n";
		opendir my $dir, $t or die "Cannot open directory : $!";
		my @flist = readdir $dir;
		closedir $dir;
		$log_file .= "\t\tFiles found for hierarchy parsing:\n";
		foreach my $f (@flist) {
			if($f =~ m/.cpp$/) {
				my $fn = $t."/".$f;
				$log_file .= "\t\t".$fn."\n";
				push(@files, $fn);
			}
		}
	}
}

