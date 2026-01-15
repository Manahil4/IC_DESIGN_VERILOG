`timescale 1ns/1ps

module tb_BRAM_IP_task;
    reg clk;
    reg we;
    reg [2:0] addr;
    reg [7:0] din;
    wire [7:0] dout;
    
    // Instantiate DUT
    Bram_IP_task dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        we = 0;
        addr = 0;
        din = 0;
        
        // Wait a bit
        #10;
        
        // Test 1: Write to address 0
        @(negedge clk);
        we = 1;
        addr = 3'b000;
        din = 8'hAA;
        @(negedge clk);
        we = 0;
        
        // Read back from address 0
        #10;
        $display("Read from addr 0: %h (should be AA)", dout);
        
        // Test 2: Write to address 5
        @(negedge clk);
        we = 1;
        addr = 3'b101;
        din = 8'h55;
        @(negedge clk);
        we = 0;
        
        // Read back from address 5
        #10;
        $display("Read from addr 5: %h (should be 55)", dout);
        
        // Test 3: Simultaneous read from another address
        addr = 3'b000;
        #10;
        $display("Read from addr 0: %h (should still be AA)", dout);
        
        #50 $finish;
    end
    
    // Monitor changes
    always @(posedge clk) begin
        $display("Time=%t: addr=%d, we=%b, din=%h, dout=%h", 
                 $time, addr, we, din, dout);
    end
endmodule