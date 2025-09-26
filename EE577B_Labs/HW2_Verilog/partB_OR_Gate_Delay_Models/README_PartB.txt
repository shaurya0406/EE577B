# Part B — Delay Modeling of an OR Gate (Verilog-2001)

This folder contains five Verilog implementations of `y = a | b`, each modeling delay differently:

1. **or_df** — `assign #DLY y = a | b;` (inertial)
2. **or_gate** — `or #(DLY) (y, a, b);` (inertial)
3. **or_nb** — `y <= #DLY (a | b);` using nonblocking intra-assignment delay (transport-like)
4. **or_blk** — two-step blocking: `y = 1'bx; #DLY y = a | b;` (shows a brief X window)
5. **or_buf** — `wire t = a | b; buf #(DLY) (y, t);` (inertial on output net)

## How to Run (Icarus Verilog)

```bash
make        # or 'make sim'
```

Outputs:
- `delay.out` — text log of all signals over time
- `waves.vcd` — waveform for viewing in GTKWave (`make waves`)

## What to Observe

With `DLY = 2 ns`:
- Short 1 ns pulses on inputs get **filtered** by inertial models (`or_df`, `or_gate`, `or_buf`).
- The nonblocking intra-assignment delay (`or_nb`) tends to **propagate** even narrow pulses (transport-like scheduling).
- `or_blk` shows a brief `X` hazard window then settles after `DLY`.

All files use **Verilog-2001** only (no SystemVerilog).