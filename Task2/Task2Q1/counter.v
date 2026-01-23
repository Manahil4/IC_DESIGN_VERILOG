module counter#(parameter width = 4)(count,up_dn,en,rst_n,clk);
output reg [width-1:0] count;
input up_dn,rst_n,clk,en;


always @(posedge clk)
begin

if (rst_n==0) count <= {width{1'b0}};
else if (en)
 begin
	if(up_dn)count <= count+1;//up_dn 1 for upcounting
	else count<=count-1;
 end
end
endmodule