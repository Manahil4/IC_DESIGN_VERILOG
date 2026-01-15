`timescale 1ns/1ps

module Task1Q3_tb;

    reg  [7:0] in;
    wire [2:0] out;
    wire       valid;

    reg  [2:0] expected_out;
    reg        expected_valid;
    integer    pass, fail;
    integer    i;

    Task1Q3 uut (
        .in(in),
        .out(out),
        .valid(valid)
    );

    task check;
        begin
            if (out === expected_out && valid === expected_valid) 
                pass = pass + 1;
           else
                fail = fail + 1;
                  
        end
    endtask

    initial begin
        pass = 0;
        fail = 0;

        // Valid one-hot tests
        for (i = 0; i < 8; i = i + 1) begin
            in = 8'b1 << i;
            #1;
            expected_out   = i[2:0];
            expected_valid = 1'b1;
            check();
        end

        //  Invalid: no bits high
        in = 8'b00000000;
        #1;
        expected_out   = 3'b000;
        expected_valid = 1'b0;
        check();

        //  Invalid: multiple bits high 
        in = 8'b00101000; // multiple 1s
        #1;
        expected_out   = 3'd5;   // highest bit position
        expected_valid = 1'b1;
        check();

        $display("FINAL RESULT: PASS=%0d FAIL=%0d", pass, fail);
        $finish;
    end

endmodule
