// Code your design here
`timescale 1ns/1ps

module shift_reg #(parameter N = 8)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        shift_en,
    input  logic        dir,     // 0 = left, 1 = right
    input  logic        d_in,
    output logic [N-1:0] q_out
);

    always @(posedge clk) begin
        if (!rst_n)
            q_out <= '0;
        else if (shift_en) begin
            if (dir == 0)          // LEFT SHIFT
                q_out <= {q_out[N-2:0], d_in};
            else                   // RIGHT SHIFT
                q_out <= {d_in, q_out[N-1:1]};
        end
    end

endmodule
