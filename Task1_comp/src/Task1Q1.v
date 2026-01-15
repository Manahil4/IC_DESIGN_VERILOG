module Task1Q1(output [31:0] sum,output cout,
             input  [31:0] a,
             input  [31:0] b, input cin);

  assign {cout,sum} = a + b+cin;
endmodule
