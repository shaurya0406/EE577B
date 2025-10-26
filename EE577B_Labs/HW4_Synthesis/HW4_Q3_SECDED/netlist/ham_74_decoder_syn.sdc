###################################################################

# Created by write_sdc on Tue Oct 14 16:18:25 2025

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_max_delay 5  -to [get_ports {qc[7]}]
set_max_delay 5  -to [get_ports {qc[6]}]
set_max_delay 5  -to [get_ports {qc[5]}]
set_max_delay 5  -to [get_ports {qc[4]}]
set_max_delay 5  -to [get_ports {qc[3]}]
set_max_delay 5  -to [get_ports {qc[2]}]
set_max_delay 5  -to [get_ports {qc[1]}]
set_max_delay 5  -to [get_ports {qc[0]}]
set_max_delay 5  -to [get_ports {qd[3]}]
set_max_delay 5  -to [get_ports {qd[2]}]
set_max_delay 5  -to [get_ports {qd[1]}]
set_max_delay 5  -to [get_ports {qd[0]}]
set_max_delay 5  -to [get_ports x]
set_max_delay 5  -from [list [get_ports {c[7]}] [get_ports {c[6]}] [get_ports {c[5]}]          \
[get_ports {c[4]}] [get_ports {c[3]}] [get_ports {c[2]}] [get_ports {c[1]}]    \
[get_ports {c[0]}]]
