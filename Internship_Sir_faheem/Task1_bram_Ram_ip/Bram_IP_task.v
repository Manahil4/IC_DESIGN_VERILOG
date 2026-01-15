

module Bram_IP_task #(parameter N=8)(
    input clk,           // ADDED: Clock signal
    input we, 
    input [2:0] addr, 
    input [7:0] din, 
    output [7:0] dout
);

    // Instantiate the Altera/Intel RAM IP core
    Bram_Ram_ip inst_ram_1 (
        .address(addr),
        .clock(clk),
        .data(din),
        .wren(we),       // Write enable
        .q(dout)         // Output data
    );

endmodule