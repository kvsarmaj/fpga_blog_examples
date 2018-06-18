# Hardcoding for now
# This should be a procedure to read all the RTL
# Requires a script to create a tcl commands to read RTL
#  from the file list provided

set proj_home $env(PROJ_HOME)
set proj_fpga_home $env(PROJ_FPGA_HOME)
set proj_fpga_ip $env(PROJ_FPGA_IP)
set proj_fpga_bd $env(PROJ_FPGA_BD)
set proj_fpga_rtl $env(PROJ_FPGA_RTL)
set proj_fpga_inc $env(PROJ_FPGA_INC)
set proj_fpga_xdc $env(PROJ_FPGA_XDC)
set fpga_impl_dir $env(PROJ_FPGA_IMPL)
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

source $proj_fpga_xdc/$top.tcl
