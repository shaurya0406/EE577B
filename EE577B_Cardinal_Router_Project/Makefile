# Top-level Makefile — orchestrates sim and synth
.PHONY: all sim synth lint clean reports tree

all: sim synth

sim:
	$(MAKE) -C sim

synth:
	$(MAKE) -C synth/dc

lint:
	@echo "[lint] (placeholder) — add your linter here"

reports:
	@echo "Reports live in synth/dc/reports and results/synthesis"

tree:
	@find . -maxdepth 3 -type d | sort

clean:
	$(MAKE) -C sim clean || true
	$(MAKE) -C synth/dc clean || true
	rm -rf results/logs/* results/vcd/* results/simv/* results/netlist/* results/synthesis/*
