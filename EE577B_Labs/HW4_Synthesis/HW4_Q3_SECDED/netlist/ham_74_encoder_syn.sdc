###################################################################

# Created by write_sdc on Tue Oct 14 16:19:45 2025

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
set_max_delay 5  -to [get_ports {c[7]}]
set_max_delay 5  -to [get_ports {c[6]}]
set_max_delay 5  -to [get_ports {c[5]}]
set_max_delay 5  -to [get_ports {c[4]}]
set_max_delay 5  -to [get_ports {c[3]}]
set_max_delay 5  -to [get_ports {c[2]}]
set_max_delay 5  -to [get_ports {c[1]}]
set_max_delay 5  -to [get_ports {c[0]}]
set_max_delay 5  -from [list [get_ports {d[3]}] [get_ports {d[2]}] [get_ports {d[1]}]          \
[get_ports {d[0]}]]
