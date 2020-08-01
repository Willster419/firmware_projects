#####################################################################
# hello_world_lib.mk
# hello_world library makefile
# Willster419
# 2020-07-31
# A simple library to add two numbers together with a delay queue
# Used for playing with svunit, UVM and UVMF
#####################################################################

# makefile guard
ifndef __HELLO_WORLD_GUARD

#####################################################################
# NAMES AND PATHS
HELLO_WORLD_LIB_NAME         = hello_world_lib
HELLO_WORLD_LIB_PATH         = $(LIB_DIR)/$(HELLO_WORLD_LIB_NAME)

# add this lib name to search libs
SEARCH_LIBS                 += $(HELLO_WORLD_LIB_NAME)

# define some folders
HELLO_WORLD_SRC_PATH         = $(HELLO_WORLD_ROOT)/src

# define source files here
HELLO_WORLD_VHDL_SRC        += $(HELLO_WORLD_SRC_PATH)/temp.vhd
#HELLO_WORLD_VERILOG_SRC     += $(HELLO_WORLD_SRC_PATH)temp.v
#####################################################################

#####################################################################
# TARGETS
# add the name of the lib to the compile targets list
COMPILE_TARGETS             += $(HELLO_WORLD_LIB_NAME)

# the name is set in modelsim_flow.mk to be an intermediate
# target, so use that to set an actual depends here
$(HELLO_WORLD_LIB_NAME): $(HELLO_WORLD_LIB_PATH)/depends

# set the actual target here. Works in this order:
# 1. remove the depends file
# 2. create libs if they don't already exist
# 3. map to copied modelsim ini
# 4. compile vhdl src
# 5. compile verilog src
# 6. create depends file, using new timestamp
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
$(HELLO_WORLD_LIB_PATH)/depends: $(HELLO_WORLD_VHDL_SRC) $(HELLO_WORLD_VERILOG_SRC)
	rm -rf $@
	@echo ""
	@echo "-----------------------------------------------"
	@if [ ! -d $(HELLO_WORLD_LIB_PATH) ]; \
	then echo "$(HELLO_WORLD_LIB_NAME): Creating lib"; $(VLIB) $(HELLO_WORLD_LIB_PATH); \
	else echo "$(HELLO_WORLD_LIB_NAME): Library already exists"; fi
	@echo "$(HELLO_WORLD_LIB_NAME): map to modelsim ini"
	$(VMAP) $(MODELSIM_INI) $(HELLO_WORLD_LIB_NAME) $(HELLO_WORLD_LIB_PATH)
ifdef HELLO_WORLD_VHDL_SRC
	@echo "$(HELLO_WORLD_LIB_NAME): compile VHDL SRC"
	$(VCOM) $(MODELSIM_INI) $(HELLO_WORLD_VCOM_ARGS) -work $(HELLO_WORLD_LIB_NAME) $(HELLO_WORLD_VHDL_SRC)
endif
ifdef HELLO_WORLD_VERILOG_SRC
	@echo "$(HELLO_WORLD_LIB_NAME): compile Verilog SRC"
	$(VLOG) $(MODELSIM_INI) $(HELLO_WORLD_VLOG_ARGS) -work $(HELLO_WORLD_LIB_NAME) $(HELLO_WORLD_VERILOG_SRC)
endif
	@echo "-----------------------------------------------"
	@echo ""
	touch $@

# clean the library path
# phony is set in modelsim_flow.mk
CLEAN_TARGETS += clean_hello_world
clean_hello_world:
	@echo ""
	@echo "-----------------------------------------------"
	@echo "$(HELLO_WORLD_LIB_NAME): Cleaning..."
	rm -rf $(HELLO_WORLD_LIB_PATH)
	@echo "-----------------------------------------------"
	@echo ""

#####################################################################

#####################################################################
# VARIABLE CHECKS
ifndef HELLO_WORLD_ROOT
  $(warning HELLO_WORLD_ROOT not set - please set before including hello_world_lib.mk)
  HELLO_WORLD_ABORT := 1
endif

ifndef LIB_DIR
  $(warning LIB_DIR not set - please set before including hello_world_lib.mk)
  HELLO_WORLD_ABORT := 1
endif

ifdef HELLO_WORLD_ABORT
  $(error variable issues in hello_world_lib.mk, aborting)
endif
#####################################################################

__HELLO_WORLD_GUARD = 1
endif