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



# create run targets
# target to copy the modelsim ini to the lib location
# from modelsim manual:
# "Copies the default modelsim.ini file from the ModelSim installation directory to the current directory.This argument is intended only for making a copy of the default modelsim.ini file to the current directory."
# https://stackoverflow.com/a/17203203/3128017
.PHONY: copy_modelsim_ini
copy_modelsim_ini:
	@mkdir -p $(LIB_DIR)
	@mkdir -p $(RUN_DIR)
	@if [ ! -f $(MODELSIM_INI_PATH) ]; then echo "Copying modelsim ini to $(MODELSIM_INI_PATH)"; cd $(LIB_DIR); $(VMAP) -c; else echo "modelsim ini already exists"; fi

# variable checks
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

__MODELSIM_FLOW_GUARD := 1
endif
