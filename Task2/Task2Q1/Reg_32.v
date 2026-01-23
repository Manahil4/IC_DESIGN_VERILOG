module reg_32#(parameter width = 4)(q,d,load,rst_n,clk);
output reg [width-1:0] q;
input [width-1:0] d;
input load,rst_n,clk;


always @(posedge clk)
begin
if (rst_n==0)
q <= {width{1'b0}};
else if (load)
q <= d;
end
endmodule