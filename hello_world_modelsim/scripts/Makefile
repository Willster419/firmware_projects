#####################################################################
# Makefile
# device main makefile
# Willster419
# 2020-07-31
# Compiles all listed devices and includes modelsim flow makefile
#####################################################################

# define root paths
REPO_ROOT                       = $(abspath ../../)
PROJECT_PATH                    = $(abspath ../)
SCRIPTS_DIR                     = $(REPO_ROOT)/scripts
LIB_DIR                         = $(PROJECT_PATH)/build
RUN_DIR                         = $(PROJECT_PATH)/run
SRC_DIR                         = $(PROJECT_PATH)/src
TB_DIR                          = $(PROJECT_PATH)/tb

# set shell to be bash
# https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html
SHELL = /bin/bash

# provide it with a root path
HELLO_WORLD_ROOT = $(PROJECT_PATH)

# add a do file
WAVE_DO_FILES += $(PROJECT_PATH)/scripts/tb_waves.do

# include module makefiles here
include hello_world_lib.mk

# define tb top
#TOP_DESIGN_UNIT                 = hello_world_tb
TOP_DESIGN_UNIT                 = pipeline_tb

# define tb src
TB_SV_SRC                      += $(TB_DIR)/pipeline_tb.sv

# include tb makefile
USE_TB_LIB                      = ON
include $(SCRIPTS_DIR)/tb_lib.mk

# include modelsim flow makefile
include $(SCRIPTS_DIR)/modelsim_flow.mk
