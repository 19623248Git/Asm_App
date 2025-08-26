# -- MODIFIED: Use gcc as the linker for easier C library linking
CC = gcc
ASM = nasm

# -- MODIFIED: Added -nostartfiles to prevent linking conflicts with C runtime.
CFLAGS = -no-pie -nostartfiles
ASMFLAGS = -f elf64 -g -F dwarf

TARGET = server
BIN_DIR = bin
OBJ_DIR = $(BIN_DIR)/obj
EXECUTABLE = $(BIN_DIR)/$(TARGET)

# -- MODIFIED: Define all source and object files
SRCS = server.asm utils.asm parser.asm
OBJS = $(patsubst %.asm,$(OBJ_DIR)/%.o,$(SRCS))

# Phony targets are special rules that don't represent actual files
.PHONY: all build run clean

# -- ADDED: 'all' is a standard default target
all: build

# The main build target
build: $(EXECUTABLE)

# Rule to run the executable
run: build
	@echo "Running Server (Press Ctrl+C to stop)"
	./$(EXECUTABLE)

# -- MODIFIED: Rule to link the executable from ALL object files
$(EXECUTABLE): $(OBJS)
	@mkdir -p $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $^
	@echo "Linked executable: $(EXECUTABLE)"

# -- MODIFIED: Pattern rule to assemble any .asm file into an object file
$(OBJ_DIR)/%.o: %.asm
	@mkdir -p $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<
	@echo "Assembled object file: $@"

# Target to clean up all generated files and directories
clean:
	@echo "Cleaning up generated files"
	rm -rf $(BIN_DIR)
