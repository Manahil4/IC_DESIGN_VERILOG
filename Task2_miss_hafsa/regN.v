module regN #(parameter N=8)(
    input clk,
    input reset,
    input en,
    input [N-1:0] d,
    output reg [N-1:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= {N{1'b0}};
        else if (en)
            q <= d;
    end
endmodule
