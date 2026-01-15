// Code your design here

//--------------------------------------
// DUT (example)
//--------------------------------------
module counter #(parameter N=8)(
  input clk,
  input rst_n,
  input en,
  input up_dn,
  output reg [N-1:0] count
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= 0;
    else if (en)
      count <= up_dn ? count - 1 : count + 1;
  end
endmodule

