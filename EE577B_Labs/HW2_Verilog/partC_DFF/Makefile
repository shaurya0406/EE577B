# Makefile for Part B (Icarus Verilog)
# Usage:
#   make sim     # compile and run
#   make waves   # open GTKWave (if installed)
#   make clean   # remove build artifacts
#   make setup   # create project skeleton (src/ + tb/ with tb.v)

TOP=tb
SRC=$(wildcard src/*.v) tb/tb.v

all: sim

sim: $(SRC)
	iverilog -g2001 -o tb.vvp $(SRC)
	vvp tb.vvp

waves: sim
	gtkwave tb.vcd &

clean:
	rm -f tb.vvp tb.vcd delay.out dff_*.out

setup:
	mkdir -p src tb
	@if [ ! -f tb/tb.v ]; then \
	  echo '`timescale 1ns/1ps'             > tb/tb.v; \
	  echo 'module tb;'                     >> tb/tb.v; \
	  echo '  initial begin'                >> tb/tb.v; \
	  echo '    $$display("Default testbench");' >> tb/tb.v; \
	  echo '    $$finish;'                  >> tb/tb.v; \
	  echo '  end'                          >> tb/tb.v; \
	  echo 'endmodule'                      >> tb/tb.v; \
	  echo "Created tb/tb.v (default)"; \
	else \
	  echo "tb/tb.v already exists, not overwritten."; \
	fi
