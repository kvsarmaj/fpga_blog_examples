############################################################################
# SystemC variables
############################################################################
CC = gcc
CXX = g++
SC_INCLUDE = -I. -I$(SYSTEMC_HOME)/include $(SC_INC)
SC_FLAGS = -g -Wall
SC_CFLAGS = 
SC_LDFLAGS = -L. -L$(SYSTEMC_HOME)/lib-linux64 -Wl,-rpath=$(SYSTEMC_HOME)/lib-linux64 
SC_EXTRA_FLAGS = -lsystemc -lm
SC_LINK_FLAGS = -L /lib64 
SC_SRC_FILES = $(SC_RTL_FILES) $(SC_TB_FILES) $(SC_SIM_FILES)
SC_SIM_FILE = $(SC_SIM_FILES)
SC_EXE = sim
SC_VCD_VIEW = gtkwave
SC_GTK_OPTS = -S $(WS_ROOT)/include/add_all_sig.tcl
GEN_SIM = $(WS_TOOL_ROOT)/gen_sim_file.pl
GEN_SIM_OPTS = -dump_hier -log -create_sim_file -inc_list "$(SC_INC)"
############################################################################

############################################################################
# HDL variables
############################################################################
SIMULATOR = vivado
WORK_LIB = work_lib
GEN_HDL =
TEST = test_code_download
PARSE_VERBOSITY = 0
############################################################################

############################################################################
# Xilinx implementation variables
############################################################################

XST_OPT_MODE = Speed
XST_OPT_LEVEL = 1
ARCH = spartan6
PART = xc6slx9l-csg324 

XST=$(XILINX_BIN)/xst
NGDBUILD=$(XILINX_BIN)/ngdbuild
MAP=$(XILINX_BIN)/map
PAR=$(XILINX_BIN)/par
TRCE=$(XILINX_BIN)/trce
BITGEN=$(XILINX_BIN)/bitgen
PROMGEN=$(XILINX_BIN)/promgen
FLOORPLAN=$(XILINX_BIN)/floorplanner

XSTWORK=$(PROJ).work
XSTSCRIPT=$(PROJ).xst

IMPACT_OPTIONS_FILE ?= _impact.cmd    
############################################################################

############################################################################
# Vivado implementation variables
############################################################################

WORK_TAG = $(shell date +%Y_%m_%d_%H_%M_%S)
WORK_PRE = run
WORK_DIR = $(WORK_PRE)_$(WORK_TAG)
VIVADO_PATH = /opt/Xilinx/Vivado/2017.3/bin

RUN_PNR = Yes
POWER_RUN = No
REPORT_POWER = No
FPGA_PART_NUM = xcvu9p-flga2104-2L-e
TOP = rap_top
SYN_DCP = $(TOP).syn.dcp

# Control report generation
DUMP_TIMING_REPORTS_AT_EVERY_DCP = Yes
DUMP_HIER_UTIL_REPORTS = Yes

# Load DCP instead of running synthesis
LOAD_SYN_DCP = No

# Post synthesis step control
NO_DCPS = No
NO_VIVADO_DIRECTIVES = Yes

# Logic optimization step
OPT_DESIGN_DIRECTIVE_SEL = Yes
OPT_DESIGN_DIRECTIVE = ExploreArea

# Place step
PLACE_DESIGN_DIRECTIVE_SEL = No
PLACE_DESIGN_DIRECTIVE = Explore

# Post place physical optimization
RUN_POST_PLACE_PHYS_OPT = No
POST_PLACE_PHYS_OPT_DIRECTIVE_SEL = Yes
POST_PLACE_PHYS_OPT_DIRECTIVE = AggressiveExplore

# Route step
ROUTE_DESIGN_DIRECTIVE_SEL = Yes
ROUTE_DESIGN_DIRECTIVE = Explore

# Post route physical optimization
RUN_POST_PLACE_PHYS_OPT = No
POST_PLACE_PHYS_OPT_DIRECTIVE_SEL = Yes
POST_PLACE_PHYS_OPT_DIRECTIVE = Explore

export WORK_TAG
export WORK_DIR
export VIVADO_PATH

export RUN_PNR
export POWER_RUN
export REPORT_POWER
export FPGA_PART_NUM
export TOP
export SYN_DCP

# Control report generation
export DUMP_TIMING_REPORTS_AT_EVERY_DCP
export DUMP_HIER_UTIL_REPORTS

# Load DCP instead of running synthesis
export LOAD_SYN_DCP

# Post synthesis step control
export NO_DCPS
export NO_VIVADO_DIRECTIVES

# Logic optimization step
export OPT_DESIGN_DIRECTIVE_SEL
export OPT_DESIGN_DIRECTIVE

# Place step
export PLACE_DESIGN_DIRECTIVE_SEL
export PLACE_DESIGN_DIRECTIVE

# Post place physical optimization
export RUN_POST_PLACE_PHYS_OPT
export POST_PLACE_PHYS_OPT_DIRECTIVE_SEL
export POST_PLACE_PHYS_OPT_DIRECTIVE

# Route step
export ROUTE_DESIGN_DIRECTIVE_SEL
export ROUTE_DESIGN_DIRECTIVE

# Post route physical optimization
export RUN_POST_ROUTE_PHYS_OPT
export POST_ROUTE_PHYS_OPT_DIRECTIVE_SEL
export POST_ROUTE_PHYS_OPT_DIRECTIVE

############################################################################

.PHONY: clean

all: $(MAKE_OPTIONS)

sc_sim_all: sc_clean sc_comp_run

hdl_sim_all: hdl_clean hdl_comp_run

############################################################################
# SC run options
############################################################################
sc_comp_run: sc_gen_sim sc_comp sc_run sc_vcd  

sc_gen_sim:
	@echo "-----------------------------------------------------"
	@echo "Generating sim.cpp                                   "
	@echo "-----------------------------------------------------"
	perl $(GEN_SIM) -mod $(MOD) $(GEN_SIM_OPTS) -sim_file=$(SC_EXE).cpp
	@echo "-----------------------------------------------------"
ifeq ("$(wildcard sim.cpp)","")
	@echo "sim.cpp generation failed"
else
	@echo "sim.cpp generation successful"
endif
	@echo "-----------------------------------------------------"

sc_comp: $(SC_EXE) 

$(SC_EXE): $(SC_SRC_FILES)
	@echo "-----------------------------------------------------" | tee -a build.log
	@echo " Building SystemC simulation for $(MOD)              " | tee -a build.log
	@echo "-----------------------------------------------------" | tee -a build.log
	$(CXX) $(SC_INCLUDE) $(SC_FLAGS) $(SC_CFLAGS) $(SC_LDFLAGS) $(SC_EXTRA_FLAGS) $(SC_SIM_MAIN) -o $@ 2>&1 | tee -a build.log

sc_run: $(SC_EXE)
	@echo "-----------------------------------------------------" | tee -a sim.log
	@echo " Running SystemC sumulation for $(MOD)               " | tee -a sim.log
	@echo "-----------------------------------------------------" | tee -a sim.log
	./$(SC_EXE) | tee -a sim.log

sc_vcd: $(SC_EXE)
	$(SC_VCD_VIEW) $(SC_GTK_OPTS) $(SC_EXE).vcd &

sc_clean: 
	rm -f $(SC_EXE).cpp $(SC_EXE) $(SC_EXE).vcd *.log *.o
############################################################################

############################################################################
# HDL simulation options
############################################################################

hdl_comp_run: hdl_parse hdl_elab hdl_sim

hdl_parse:
	xvlog -work $(WORK_LIB) --sv $(HDL_INC) -f $(HDL_SIM_FILES) --log $(HDL_COMPILE_LOG) --verbose $(PARSE_VERBOSITY)

hdl_elab:
	xelab $(WORK_LIB).$(MOD)_tb --debug all --log $(HDL_ELAB_LOG)

hdl_sim:
	perl write_run_script.pl -test $(TEST) -ofile $(TEST).run
	xsim --wdb $(TEST).wbd --R --f $(TEST).run --log $(HDL_SIM_LOG)

hdl_wave:

hdl_ip_sim_files:

############################################################################

############################################################################
# Xilinx image options using Vivado
############################################################################

# Makeflow for synthesis and implementation

.PHONY: clean impl

all: impl

impl: 
	@echo "---------------------------------------------------------------------"
	@echo "-Running Vivado Synthesis and implementation                         "
	@echo "---------------------------------------------------------------------"
	@echo "Creating work directory $(WORK_DIR)"
	mkdir -p $(WORK_DIR)
	export RUN_PNR=Yes; export LOAD_SYN_DCP=No; $(VIVADO_PATH)/vivado -mode tcl -source $(FPGA_SYN_SCR)/impl.tcl -log $(WORK_DIR)/impl.log 

syn: 
	@echo "---------------------------------------------------------------------"
	@echo "-Running Vivado synthesis                                            "
	@echo "---------------------------------------------------------------------"
	@echo "Creating work directory $(WORK_DIR)"
	mkdir -p $(WORK_DIR)
	export RUN_PNR=No; export LOAD_SYN_DCP=No; $(VIVADO_PATH)/vivado -mode tcl -source $(FPGA_SYN_SCR)/impl.tcl -log $(WORK_DIR)/syn.log

pnr:
	@echo "---------------------------------------------------------------------"
	@echo "-Running Vivado implementation                                       "
	@echo "---------------------------------------------------------------------"
	@echo "---------------------------------------------------------------------"
	@echo "-Synthesis DCP $(TOP).syn.dcp                                        "
	@echo "---------------------------------------------------------------------"
	mkdir -p $(WORK_DIR)
	export RUN_PNR=Yes; export LOAD_SYN_DCP=Yes; $(VIVADO_PATH)/vivado -mode tcl -source $(FPGA_SYN_SCR)/impl.tcl -log $(WORK_DIR)/pnr.log

clean:
	@echo "---------------------------------------------------------------------"
	@echo "-Cleaning up                                                         "
	@echo "---------------------------------------------------------------------"
	\rm -rf ./.srcs/

clean_runs:
	@echo "---------------------------------------------------------------------"
	@echo "-Cleaning old run directory                                          "
	@echo "---------------------------------------------------------------------"
	\rm -rf ./run_*

############################################################################


############################################################################
# Xilinx image options using XST
############################################################################
#image: $(PROJ).bit
#
#$(XSTWORK): $(SOURCES)
#	> $@
#	for a in $(SOURCES); do echo "vhdl work $$a" >> $@; done   
#
#$(XSTSCRIPT): $(XSTWORK)
#	> $@
#	echo -n "run -ifn $(XSTWORK) -ifmt mixed -top $(TOP) -ofn $(PROJ).ngc" >> $@
#	echo " -ofmt NGC -p $(PART) -iobuf yes -opt_mode $(XST_OPT_MODE) -opt_level $(XST_OPT_LEVEL)" >> $@
#
#$(PROJ).bit: $(XSTSCRIPT)
#	$(XST) -intstyle ise -ifn $(PROJ).xst -ofn $(PROJ).syr
#	$(NGDBUILD) -intstyle ise -dd _ngo -nt timestamp -uc $(PROJ).ucf -p $(PART) $(PROJ).ngc $(PROJ).ngd
#	$(MAP) -intstyle ise -p $(PART) -w -ol high -t 1 -global_opt off -o $(PROJ).map.ncd $(PROJ).ngd $(PROJ).pcf
#	$(PAR) -w -intstyle ise -ol high $(PROJ).map.ncd $(PROJ).ncd $(PROJ).pcf
#	$(TRCE) -intstyle ise -v 4 -s 4 -n 4 -fastpaths -xml $(PROJ).twx $(PROJ).ncd -o $(PROJ).twr $(PROJ).pcf
#	$(BITGEN) -intstyle ise $(PROJ).ncd
#
#$(PROJ).bin: $(PROJ).bit
#	$(PROMGEN) -w -p bin -o $(PROJ).bin -u 0 $(PROJ).bin
#
#floorplan: $(PROJ).ngd $(PROJ).par.ncd
#	$(FLOORPLAN) $^
#
#report:
#	cat *.srp
#
#fpga_clean::
#	rm -f *.work *.xst
#	rm -f *.ngc *.ngd *.bld *.srp *.lso *.prj
#	rm -f *.map.mrp *.map.ncd *.map.ngm *.mcs *.par.ncd *.par.pad
#	rm -f *.pcf *.prm *.bgn *.drc
#	rm -f *.par_pad.csv *.par_pad.txt *.par.par *.par.xpi
#	rm -f *.bit
#	rm -f *.vcd *.vvp
#	rm -f verilog.dump verilog.log
#	rm -rf _ngo/
#	rm -rf xst/

