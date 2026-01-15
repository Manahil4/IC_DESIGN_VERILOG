`timescale 1ps/
module Task1Q2_tb;
reg [31:0] data_in;
reg shift_amt;
reg dir; 
wire [31:0] data_out;
integer pass=0, fail=0;
reg [31:0] expected;

Task1Q2 uut( .data_in(data_in), .data_out(data_out), .shift_amt(shift_amt), .dir(dir), );

task check();
if (data_out==expected) $display("PASS=%0d FAIL=%0d", pass++, fail);
else $display("PASS=%0d FAIL=%0d", pass, fail++);
endtask

initial begin
    #10;
shift_amt =0;
dir=$random(0,1);
data_in = $random;
expected = data_in; //no shift
check();
#10;
dir = 0;    //left shift
shift_amt = $random(1,31);
data_in = $random;
expected= (data_in << shift_amt) | (data_in >> (32 - shift_amt)); //rotate left shift
check();
#10;
dir=1; //right shift
shift_amt = $random(1,31);
data_in = $random;
expected= (data_in >> shift_amt)|(data_in << (32 - shift_amt)); //rotate right shift
check();
#10;
$display("PASS=%0d FAIL=%0d", pass, fail);
$finish;
end
endmodule
