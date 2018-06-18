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

module clock_gate
    #(
      parameter BEHAVIORAL_LATCH = 1
      )
    (
     input clk_i,
     input enable_i,
     output gated_clk_o
     );
    
    wire    inv_clk;
    reg     enable_latched;
    wire    enable_latch;

    assign inv_clk = ~clk_i;

    generate
        if(BEHAVIORAL_LATCH == 1)
        begin
            always@(inv_clk)
            begin
                enable_latched = enable_i;
            end

            assign enable_latch  = enable_latched;
        end // if (BEHAVIORAL_LATCH == 1)
        else
        begin
            LD_1 U_latch (.Q(enable_latch), .G(clk_i), .D(enable_i));
        end // else: !if(BEHAVIORAL_LATCH == 1)
    endgenerate

    assign gated_clk_o = enable_latch & clk_i;

endmodule // clock_gate
