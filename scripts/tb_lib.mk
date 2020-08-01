#####################################################################
# tb_lib.mk
# standard testbench library makefile
# Willster419
# 2020-07-31
# A simple testbench library makefile
#####################################################################

# makefile guard
ifndef __TB_LIB_GUARD

#####################################################################
# NAMES AND PATHS
TB_LIB_NAME                  = tb_lib
TB_LIB_PATH                  = $(LIB_DIR)/$(TB_LIB_NAME)
TOP_LIB                      = $(TB_LIB_NAME)
TOP_DESIGN_UNIT             ?= top

# add this lib name to search libs
SEARCH_LIBS                 += $(TB_LIB_NAME)

# add the tb to the compile targets list
COMPILE_TARGETS             += $(TB_LIB_NAME)
#####################################################################

#####################################################################
# TARGETS
$(TB_LIB_NAME): $(TB_LIB_PATH)/depends
$(TB_LIB_PATH)/depends: $(TB_VHDL_SRC) $(TB_VERILOG_SRC)
	@rm -rf $@
	@echo ""
	@echo "-----------------------------------------------"
	@if [ ! -d $(TB_LIB_PATH) ]; \
	then echo "$(TB_LIB_NAME): Creating lib"; $(VLIB) $(TB_LIB_PATH); \
	else echo "$(TB_LIB_NAME): Library already exists"; fi
	@echo "-----------------------------------------------"
	@echo ""
	@echo "-----------------------------------------------"
	@echo "$(TB_LIB_NAME): map to modelsim ini"
	$(VMAP) $(MODELSIM_INI) $(TB_LIB_NAME) $(TB_LIB_PATH)
	@echo "-----------------------------------------------"
	@echo ""
	@echo "-----------------------------------------------"
ifdef TB_VHDL_SRC
	@echo "$(TB_LIB_NAME): Compile VHDL SRC"
	$(VCOM) $(MODELSIM_INI) $(TB_VCOM_ARGS) -work $(TB_LIB_NAME) $(TB_VHDL_SRC)
endif
ifdef TB_VER_SRC
	@echo "$(TB_LIB_NAME): Compile Verilog SRC"
	$(VLOG) $(MODELSIM_INI) $(TB_VLOG_ARGS) -work $(TB_LIB_NAME) $(TB_VER_SRC)
endif
ifdef TB_SV_SRC
	@echo "$(TB_LIB_NAME): Compile Verilog SRC"
	$(VLOG) $(MODELSIM_INI) $(TB_SV_ARGS) -work $(TB_LIB_NAME) $(TB_SV_SRC)
endif
	@echo "-----------------------------------------------"
	@echo ""
	@touch $@

# clean the library path
# phony is set in modelsim_flow.mk
CLEAN_TARGETS += clean_tb
clean_tb:
	@echo ""
	@echo "-----------------------------------------------"
	@echo "$(TB_LIB_NAME): Cleaning..."
	rm -rf $(TB_LIB_PATH)
	@echo "-----------------------------------------------"
	@echo ""
#####################################################################

#####################################################################
# VARIABLE CHECKS
ALL_TB_SRC = $(TB_VHDL_SRC) $(TB_VER_SRC) $(TB_SV_SRC)
nullstring :=
ifeq ($(USE_TB_LIB),ON)
  ifeq ($(nullstring), $(strip $(ALL_TB_SRC)))
    $(warning set to use tb_lib but no src specified!)
    TB_LIB_ABORT = 1
  endif
  ifndef LIB_DIR
    $(warning LIB_DIR not set - please set before including hello_world_lib.mk)
    TB_LIB_ABORT := 1
  endif
endif

ifdef TB_LIB_ABORT
  $(error variable issues in tb_lib.mk, aborting)
endif
#####################################################################

__TB_LIB_GUARD = 1
endif