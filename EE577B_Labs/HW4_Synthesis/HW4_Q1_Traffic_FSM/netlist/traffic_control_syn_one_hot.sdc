###################################################################

# Created by write_sdc on Tue Oct 14 23:05:00 2025

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_max_delay 5  -to [get_ports {L_A[2]}]
set_max_delay 5  -to [get_ports {L_A[1]}]
set_max_delay 5  -to [get_ports {L_A[0]}]
set_max_delay 5  -to [get_ports {L_B[2]}]
set_max_delay 5  -to [get_ports {L_B[1]}]
set_max_delay 5  -to [get_ports {L_B[0]}]
set_max_delay 5  -to [get_ports RA]
set_max_delay 5  -to [get_ports RB]
set_max_delay 5  -from [list [get_ports CLK] [get_ports reset] [get_ports ERR] [get_ports PA]  \
[get_ports PB]]
