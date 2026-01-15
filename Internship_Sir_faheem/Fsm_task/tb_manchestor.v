`timescale 1ns/1ps

module manchester_tb();
    reg clk, rst_n, w;
    wire z_mealy;
 
    manchester_mealy mealy_inst (
        .z(z_mealy), .w(w), .clk(clk), .rst_n(rst_n)
    );

     initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, simple_tb);
    end

    always #5 clk = ~clk;


initial begin
    clk = 0;
    rst_n = 0;
    w = 0;
    
    #10 rst_n = 1;
    
    // Test sequence:  1 1 0 1
    #20 w = 1;  
    #20 w = 1;  
    #20 w = 0;  
    #20 w = 1; 
    
    #40 $finish;
end
endmodule