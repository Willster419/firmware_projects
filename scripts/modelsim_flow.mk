#####################################################################
# modelsim_flow.mk
# Modelsim compile and run makefile
# Willster419
# Makefile for defining the modelsim simulation flow as outlined in
# the modelsim users manual
#####################################################################

#####################################################################
# As the manual describes, there's a few key steps for setting up a
# sim from start to finish. They are:
# 1. Create libraries to store compiled design
# 2. Map the libraries into the modelsim ini
# 3. Compile the src into the libraries
# 4. (Dependant on modelsim/questa version) optimize the design
# 5. Run the simulator
#
# This makefile attempts to facilitiate these steps into a single
# makefile to help with running simulations quickly and from the
# command line
#####################################################################

#####################################################################
# The first step is to define some vars that could be overriden if
# requested by the user, before loading this makefile. For example:
# - The root Makefile of the target lib could specify a custom
#   location for VSIM *before* this script is loaded
#####################################################################

#####################################################################
# This makefile requires the following variables preset:
# - LIB_DIR    -> location of compiled libraries
# - RUN_DIR    -> location of run directory of simulation
#####################################################################

#####################################################################
# Some good sites for makefile refrence of what goes on here:
# - https://stackoverflow.com/a/448939/3128017
#####################################################################

# makefile guard
ifndef __MODELSIM_FLOW_GUARD

# set default locations for modelsim commands
# if you have a custom path, you could put
# the absolute path here
VLIB                           ?= vlib
VMAP                           ?= vmap
VCOM                           ?= vcom
VLOG                           ?= vlog
VOPT                           ?= vopt
VSIM                           ?= vsim

#####################################################################
# makefile options
# control if using the vopt step
# some older versions of modelsim don't come with it
USE_VOPT                       ?= OFF
#####################################################################

#####################################################################
# set some commonly used args
# location of modelsim ini to use and arg creation
MODELSIM_INI_PATH              ?= $(LIB_DIR)/modelsim.ini
MODELSIM_INI                    = -modelsimini "$(MODELSIM_INI_PATH)"

# set mode to run the simulator in
# options:
# - command line mode (-c)
# - gui/interactive mode (-gui / -i)
# - batch mode (TODO)
SIM_RUN_MODE                   ?= -c

# create search libs
# https://stackoverflow.com/a/11515360/3128017
VSIM_SEARCH_LIBS                = $(addprefix -L , $(SEARCH_LIBS))

# add ability for user to run do files before running sim
VSIM_DO_FILES                   = $(addprefix -do , $(DO_FILES))

# add ability for user to run wave do fiels before running sim
# only add these to vsim if it's in gui mode
ifeq ($(strip $(SIM_RUN_MODE)),-i)
  VSIM_WAVE_DO_FILES            = $(addprefix -do , $(WAVE_DO_FILES))
endif
ifeq ($(strip $(SIM_RUN_MODE)),-gui)
  VSIM_WAVE_DO_FILES            = $(addprefix -do , $(WAVE_DO_FILES))
endif

# create the name of the logfile to make
# https://www.computerhope.com/unix/udate.htm
LOG_TIMESTAMP                   = $(shell date +%F_%H-%M-%S)
LOG_NAME                       ?= log_$(LOG_TIMESTAMP).log

# if not uvm, allow a default test name for that parameter
ifdef TESTNAME
  LOG_NAME                      = $(TESTNAME)_$(LOG_TIMESTAMP).log
endif

# add uvm test name arg
ifdef UVM_TESTNAME
  VSIM_ARGS                    += "+UVM_TESTNAME=$(UVM_TESTNAME)"
  LOG_NAME                      = $(UVM_TESTNAME)_$(LOG_TIMESTAMP).log
endif

# add acc to vopt during optimization
VOPT_ARGS                      += +acc
#####################################################################

#####################################################################
# create lib and run directories
.PHONY: create_runs create_libs
create_libs:
	@mkdir -p $(LIB_DIR)

create_runs:
	@mkdir -p $(RUN_DIR)

# create run targets
# target to copy the modelsim ini to the lib location if it doesn't
# already exist
# from modelsim manual:
# "Copies the default modelsim.ini file from the ModelSim installation directory to the current directory.This argument is intended only for making a copy of the default modelsim.ini file to the current directory."
# https://stackoverflow.com/a/17203203/3128017
# https://www.intel.com/content/www/us/en/programmable/support/support-resources/knowledge-base/solutions/rd05172000_4425.html
.PHONY: copy_modelsim_ini
copy_modelsim_ini: create_libs
	@echo ""
	@echo "-----------------------------------------------"
	@if [ ! -f $(MODELSIM_INI_PATH) ]; \
	then echo "Copying modelsim ini to $(MODELSIM_INI_PATH)"; \
	cd $(LIB_DIR); \
	$(VMAP) -c; \
	else echo "modelsim ini already exists"; \
	fi
	@echo "-----------------------------------------------"
	@echo ""

# compile targets
.INTERMEDIATE: compile_all $(COMPILE_TARGETS)
compile_all: create_runs create_libs copy_modelsim_ini $(COMPILE_TARGETS)

# map the top library to modelsim's "work" lib
.PHONY: map_top_lib
map_top_lib:
	@echo ""
	@echo "-----------------------------------------------"
	@echo "Mapping work to top lib"
	$(VMAP) $(MODELSIM_INI) work $(TOP_LIB_PATH)
	@echo "-----------------------------------------------"
	@echo ""

# configure usage of optimize
VOPT_TARGET   :=
VSIM_TOP       = $(TOP_LIB).$(TOP_DESIGN_UNIT)
ifeq ($(strip $(USE_VOPT)),ON)
  VOPT_TARGET  = optimize
  VSIM_TOP     = optimized
endif

# optimize targets
.INTERMEDIATE: optimize
optimize: $(TOP_LIB_PATH)/optimized/depends

$(TOP_LIB_PATH)/optimized/depends: $(COMPILE_TARGETS)
	@rm -rf $@
	@echo ""
	@echo "-----------------------------------------------"
	@echo "Running optimization"
	$(VOPT) $(MODELSIM_INI) $(VSIM_SEARCH_LIBS) $(VOPT_ARGS) $(VSIM_SEARCH_LIBS) $(TOP_LIB).$(TOP_DESIGN_UNIT) -o optimized
	@echo "-----------------------------------------------"
	@echo ""
	@touch $@

# complete run target
.PHONY: simit
simit: create_runs create_libs copy_modelsim_ini $(COMPILE_TARGETS) map_top_lib $(VOPT_TARGET) sim_only

# sim target
.PHONY: sim_only
sim_only:
	@echo ""
	@echo "-----------------------------------------------"
	@echo "Running sim"
	cd $(RUN_DIR); $(VSIM) $(MODELSIM_INI) $(SIM_RUN_MODE) $(VSIM_SEARCH_LIBS) $(VSIM_ARGS) -logfile $(LOG_NAME) $(VSIM_DO_FILES) $(VSIM_WAVE_DO_FILES) -do "run 0" -do "run -all" $(VSIM_TOP)
	@echo "-----------------------------------------------"
	@echo ""

# clean targets
.PHONY: clean_all $(CLEAN_TARGETS) clean_libs clean_runs
clean_all: $(CLEAN_TARGETS) clean_libs clean_runs

clean_libs:
	@echo ""
	@echo "-----------------------------------------------"
	@echo "Cleaning lib folder..."
	rm -rf $(LIB_DIR)
	@echo "-----------------------------------------------"
	@echo ""

clean_runs:
	@echo ""
	@echo "-----------------------------------------------"
	@echo "Cleaning run folder..."
	rm -rf $(RUN_DIR)
	@echo "-----------------------------------------------"
	@echo ""

#####################################################################

#####################################################################
# variable checks
ifndef TOP_LIB
  $(warning TOP_LIB not set - please set before including modelsim_flow.mk)
  MODELSIM_FLOW_ABORT := 1
endif

ifndef TOP_DESIGN_UNIT
  $(warning TOP_DESIGN_UNIT not set - please set before including modelsim_flow.mk)
  MODELSIM_FLOW_ABORT := 1
endif

ifndef TOP_LIB_PATH
  $(warning TOP_LIB_PATH not set - please set before including modelsim_flow.mk)
  MODELSIM_FLOW_ABORT := 1
endif

ifndef LIB_DIR
  $(warning LIB_DIR not set - please set before including modelsim_flow.mk)
  MODELSIM_FLOW_ABORT := 1
endif

ifndef RUN_DIR
  $(warning RUN_DIR not set - please set before including modelsim_flow.mk)
  MODELSIM_FLOW_ABORT := 1
endif

ifdef MODELSIM_FLOW_ABORT
  $(error variable issues in modelsim_flow.mk, aborting)
endif
#####################################################################

__MODELSIM_FLOW_GUARD := 1
endif
