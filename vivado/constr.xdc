set_property PACKAGE_PIN K18 [get_ports reset]
set_property IOSTANDARD LVCMOS25 [get_ports reset]
set_property PULLUP true [get_ports reset]

create_clock -period 100.000 -name clk_gen -waveform {0.000 50.000} -add [get_ports clk]