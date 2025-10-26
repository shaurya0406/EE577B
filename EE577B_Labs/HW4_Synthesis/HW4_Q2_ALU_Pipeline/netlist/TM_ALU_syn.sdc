###################################################################

# Created by write_sdc on Tue Oct 14 20:29:38 2025

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current uA
create_clock [get_ports clk]  -period 40  -waveform {0 20}
set_max_delay 5  -to [get_ports {AvgTxLen_new[7]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[6]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[5]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[4]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[3]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[2]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[1]}]
set_max_delay 5  -to [get_ports {AvgTxLen_new[0]}]
set_max_delay 5  -to [get_ports {InstExed_new[7]}]
set_max_delay 5  -to [get_ports {InstExed_new[6]}]
set_max_delay 5  -to [get_ports {InstExed_new[5]}]
set_max_delay 5  -to [get_ports {InstExed_new[4]}]
set_max_delay 5  -to [get_ports {InstExed_new[3]}]
set_max_delay 5  -to [get_ports {InstExed_new[2]}]
set_max_delay 5  -to [get_ports {InstExed_new[1]}]
set_max_delay 5  -to [get_ports {InstExed_new[0]}]
set_max_delay 5  -from [list [get_ports clk] [get_ports reset] [get_ports {AvgTxLen[7]}]       \
[get_ports {AvgTxLen[6]}] [get_ports {AvgTxLen[5]}] [get_ports {AvgTxLen[4]}]  \
[get_ports {AvgTxLen[3]}] [get_ports {AvgTxLen[2]}] [get_ports {AvgTxLen[1]}]  \
[get_ports {AvgTxLen[0]}] [get_ports {InstExed[7]}] [get_ports {InstExed[6]}]  \
[get_ports {InstExed[5]}] [get_ports {InstExed[4]}] [get_ports {InstExed[3]}]  \
[get_ports {InstExed[2]}] [get_ports {InstExed[1]}] [get_ports {InstExed[0]}]  \
[get_ports {CurTxLen[7]}] [get_ports {CurTxLen[6]}] [get_ports {CurTxLen[5]}]  \
[get_ports {CurTxLen[4]}] [get_ports {CurTxLen[3]}] [get_ports {CurTxLen[2]}]  \
[get_ports {CurTxLen[1]}] [get_ports {CurTxLen[0]}]]
