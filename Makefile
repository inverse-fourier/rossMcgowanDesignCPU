# --- Toolchain ---
CC      = iverilog
FLAGS   = -g2012
SIM     = vvp
VIEWER  = gtkwave
LINTER  = verilator
LFLAGS  = --lint-only -Wall

# --- Directory Structure ---
RTL_DIR   = rtl
TB_DIR    = tb
WAVE_DIR  = waveforms
BUILD_DIR = build

# --- Selection Logic ---
# MODULE selects the testbench to run, e.g., 'make run MODULE=RAM8Byte'
MODULE ?= memoryCell1Bit

# --- Smart File Discovery ---
# Find ALL SystemVerilog source files in the RTL directory.
ALL_RTL_SRC = $(shell find $(RTL_DIR) -name '*.sv')
# Find the specific testbench for the selected MODULE.
TB_SRC  = $(shell find $(TB_DIR) -name "$(MODULE)TB.sv")

# Output Paths
OUT_FILE = $(BUILD_DIR)/$(MODULE)_sim.out
VCD_FILE = $(WAVE_DIR)/$(MODULE).vcd

# --- Build Rules ---
.PHONY: all setup lint compile run waves clean

# 'make all' or 'make all MODULE=...' will setup, compile, and run a specific testbench.
all: setup compile run

setup:
	@mkdir -p $(WAVE_DIR)
	@mkdir -p $(BUILD_DIR)

# 'make lint' will now lint ALL source files, ignoring the MODULE variable.
lint:
	@echo "--- Linting All RTL Modules ---"
	@echo "Linting files: $(ALL_RTL_SRC)"
	$(LINTER) $(LFLAGS) $(ALL_RTL_SRC)

# 'make compile MODULE=...' compiles the specified testbench against all RTL code.
compile:
	@echo "--- Compiling Testbench for: $(MODULE) ---"
	@if [ -z "$(TB_SRC)" ]; then echo "Error: $(MODULE)TB.sv not found in $(TB_DIR)/ directory!"; exit 1; fi
	$(CC) $(FLAGS) -DVCD_DUMPFILE=\"$(VCD_FILE)\" -o $(OUT_FILE) $(ALL_RTL_SRC) $(TB_SRC)

run:
	@echo "--- Running Simulation for: $(MODULE) ---"
	$(SIM) $(OUT_FILE)

waves:
	@echo "--- Opening Waveform for: $(MODULE) ---"
	$(VIEWER) $(VCD_FILE) &

# Updated clean: ONLY deletes build files, leaves waveforms alone
clean:
	@echo "--- Cleaning Build Binaries (Waveforms Preserved) ---"
	rm -rf $(BUILD_DIR)
	rm -f *.out