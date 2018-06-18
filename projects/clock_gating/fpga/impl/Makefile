MOD = $(PROJ)
FPGA_INC = --include $(PROJ_FPGA_INC)/ --include $(PROJ_FPGA_RTL)/ 
MAKE_OPTIONS = impl
FPGA_SYN_SCR = ${BLOG_INC}/vivado/scr
FPGA_SYN_XDC = ${PROJ_FPGA_IMPL}/constraints
FPGA_DCP = ${PROJ_FPGA_IMPL}/dcp
TOP = ${PROJ}

export FPGA_INC
export FPGA_SYN_SCR
export FPGA_SYN_XDC
export FPGA_DCP

include $(PROJ_FPGA_HOME)/rtl/Makefile
include $(BLOG_ROOT)/include/Makefile
