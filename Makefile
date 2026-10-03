
BUILD_MODE 	?= DEBUG
OUT			?= pacorpg

SRC_DIR		= $(CURDIR)/src
LIB_DIR 	= $(CURDIR)/lib
BUILD_DIR	= $(CURDIR)/build
BIN_DIR 	= $(CURDIR)/bin

# OUT -----------------------------------------------------------------------------------------
TARGET	= $(BIN_DIR)/$(OUT)

# Set up compiler and flags
#----------------------------------------------------------------------------------------------
CC			= gcc
CFLAGS 		= -std=c23 -Wall -Wextra
ifeq ($(PACO_ERPG_BUILD_MODE), DEBUG)
	CFLAGS += -g
endif

CFLAGS += $(CUSTOM_CFLAGS)

INCLUDE_PATHS 	= -Iinclude $(EXTRA_INCLUDE_PATHS)

# External
#----------------------------------------------------------------------------------------------
LIB_BUILD_DIR	=  $(BUILD_DIR)/lib

# Paco RPG Engine
LIB_ENGINE_NAME = pacorpgengine
LIB_ENGINE_OUT	= $(LIB_BUILD_DIR)/lib$(LIB_ENGINE_NAME).so
LIB_ENGINE_DIR	= $(LIB_DIR)/Paco-RPG-Engine
LIB_ENGINE_INCLUDE_PATHS = $(LIB_ENGINE_DIR)/include

LIBS = $(LIB_ENGINE_OUT)

LDFLAGS_RAYLIB 	= -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
LDFLAGS = $(CUSTOM_LDFLAGS) $(LDFLAGS_RAYLIB) -L$(LIB_BUILD_DIR) -l$(LIB_ENGINE_NAME)

INCLUDE_PATHS += -I$(LIB_ENGINE_INCLUDE_PATHS)

# Sources and output
#----------------------------------------------------------------------------------------------
SOURCES	= $(shell find $(SRC_DIR) -name '*.c')
OBJECTS	= $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SOURCES))

# Dependency generation
CFLAGS 	+= -MMD -MP
DEPS 	:= $(OBJECTS:.o=.d)

# Define processes to execute
#------------------------------------------------------------------------------------------------
.PHONY: all run clean
all: $(TARGET) $(LIBS)

$(TARGET): $(OBJECTS) $(LIBS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $(TARGET)
	@echo "---Built $@ successfully---"

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@

$(LIB_ENGINE_OUT):
	@echo "Building Paco RPG Engine..."
	@mkdir -p $(LIB_BUILD_DIR)
	$(MAKE) -C $(LIB_ENGINE_DIR) PACO_ERPG_LIBTYPE=SHARED PACO_ERPG_LIB_NAME=$(LIB_ENGINE_NAME) PACO_ERPG_BUILD_MODE=$(BUILD_MODE) PACO_ERPG_RELEASE_PATH=$(LIB_BUILD_DIR)
	@echo "Done"

clean:
	@rm -rf $(BUILD_DIR)/* $(BIN_DIR)/*
	@echo "---Removed all generated files.---"

-include $(DEPS)
