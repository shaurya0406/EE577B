# Makefile for Part B (Icarus Verilog)
# Usage:
#   make sim    # compile and run
#   make waves  # open GTKWave (if installed)
#   make clean

TOP=tb
SRC=$(wildcard src/*.v) tb/tb.v

all: sim

sim: $(SRC)
	iverilog -g2001 -o tb.vvp $(SRC)
	vvp tb.vvp

waves: sim
	gtkwave tb.vcd &

clean:
	rm -f tb.vvp tb.vcd delay.out
