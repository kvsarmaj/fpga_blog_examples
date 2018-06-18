#Constraints for clock_gating module
create_clock -name "sys_clk_i" -period 10 [get_ports sys_clk_i]

create_generated_clock -name "gated_clk_o" -source [get_clocks sys_clk_i] [get_nets gated_clk_o[0]]
