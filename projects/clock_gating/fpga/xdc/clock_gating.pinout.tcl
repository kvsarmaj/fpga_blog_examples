#Pin constraints for clock_gating
set_property PACKAGE_PIN W5 [get_ports sys_clk_i]
set_property IOSTANDARD LVCMOS18 [get_ports sys_clk_i]

set_property PACKAGE_PIN W19 [get_ports sys_reset_i]
set_property IOSTANDARD LVCMOS18 [get_ports sys_reset_i]

set_property PACKAGE_PIN U16 [get_ports gated_clk_o[0]]
set_property IOSTANDARD LVCMOS18 [get_ports gated_clk_o[0]]
