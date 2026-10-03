
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

LIBS = pacorpgengine
LDFLAGS_RAYLIB 	= -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
LDFLAGS = $(CUSTOM_LDFLAGS) $(LDFLAGS_RAYLIB) $(addprefix -l, $(LIBS))

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
all: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $(TARGET)
	@echo "---Built $@ successfully---"

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@

clean:
	@rm -rf $(BUILD_DIR)/* $(BIN_DIR)/*
	@echo "---Removed all generated files.---"

-include $(DEPS)
