//******************************************************************************
// Examples for fpgadesignjournal.wordpress.com
// These examples are provided for discussion and analysis of certain scenarios
//  discussed in the blog
// Design is targeted to specific device from Xilinx products. Device used
//  in the design is specified in each examples
// Design is targeted to specific version of Vivado. Version of the Vivado software
//  is specified in each example
//******************************************************************************
//
// Author: K V Sarma Jonnavithula
// Descrption: This example illustrates clock gating in ASIC prototyping using
//             Xilinx 7 series architecture. The discussion applies to architectures
//             where configure logic block design has remained more or less similar
//             in terms of the available resources in the FPGA
// Target device: Artix 32T
// Vivado version: Vivado v2016.3
//
//******************************************************************************

module clock_gating
    #(
      localparam NUM_OF_CLKS = 1
      )
    (
     input                    sys_clk_i,
     input                    sys_reset_i,
     output [NUM_OF_CLKS-1:0] gated_clk_o
     );

    (* keep = "true" *) reg [NUM_OF_CLKS-1:0]     enable_shift_reg;
    
    genvar                   i;
    generate
        for(i=0;i<NUM_OF_CLKS;i=i+1)
        begin: gen_clk_gates
            clock_gate
              #(
                .BEHAVIORAL_LATCH (0)
                )
            U_clock_gate
              (
               .clk_i (sys_clk_i),
               .enable_i (enable_shift_reg[i]),
               .gated_clk_o (gated_clk_o[i])
               );
        end
    endgenerate

    always@(posedge sys_clk_i or posedge sys_reset_i)
    begin
        if(sys_reset_i)
            enable_shift_reg <= 'd0;
        else
            enable_shift_reg <= enable_shift_reg + 1;
    end

endmodule // clock_gate
