# constraints.sdc — minimal
create_clock -period 10.000 [get_ports clk]
set_clock_uncertainty 0.1 [get_clocks clk]
set_input_delay  1.0 -clock clk [all_inputs]
set_output_delay 1.0 -clock clk [all_outputs]
set_driving_cell -lib_cell INVX1 [all_inputs]
set_load 0.05 [all_outputs]
