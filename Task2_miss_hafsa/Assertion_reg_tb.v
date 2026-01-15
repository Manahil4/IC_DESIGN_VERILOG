`timescale 1ns/1ps

module reg32_tb;

    reg clk;
    reg reset;
    reg load;
    reg [31:0] d;
    wire [31:0] q;

    reg [31:0] q_prev;
    reg [31:0] expected_q;

    regN #(32) regA (.clk(clk),.reset(reset), .en(load), .d(d), .q(q));
   
    
    always #5 clk = ~clk;

   
    always @(negedge clk) begin
        q_prev <= q;
    end

   
    always @(*) begin
        if (reset)
            expected_q = 32'b0;
        else if (load)
            expected_q = d;
        else
            expected_q = q_prev; 
    end

    always @(posedge clk) begin
        #1;
        assert (q !== expected_q) $error("FAIL: q=%h, expected=%h, reset=%b, load=%b, d=%h",q, expected_q, reset, load, d);
      else $display("Pass: q=%h, expected=%h, reset=%b, load=%b, d=%h",q, expected_q, reset, load, d);
    end

    initial begin
        clk = 0;
        reset = 0;
        load = 0;
        d = 0;
        q_prev = 0;
        
        
        reset = 1;
        @(negedge clk);
        @(negedge clk);  
        reset = 0;
        
        
        @(negedge clk);
        load = 1;
        d = 32'h1234_ABCD;
        @(negedge clk);
        load = 0;
        
        // Test hold
        @(negedge clk);
        d = 32'hFFFF_0000;  
        @(negedge clk);
        @(negedge clk);
      
        @(negedge clk);
        load = 1;
        d = 32'hDEAD_BEEF;
        @(negedge clk);
        load = 0;
        
        #20 $display("Test completed successfully!");
        $finish;
    end

endmodule