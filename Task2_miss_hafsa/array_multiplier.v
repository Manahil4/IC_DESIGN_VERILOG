
module array_multiplier_8bit_core (
    input [7:0] A,
    input [7:0] B,
    output [15:0] P
);

    wire [15:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;
    wire [15:0] s1, s2, s3, s4, s5, s6, s7;

    assign pp0 = B[0] ? (A << 0) : 16'b0;
    assign pp1 = B[1] ? (A << 1) : 16'b0;
    assign pp2 = B[2] ? (A << 2) : 16'b0;
    assign pp3 = B[3] ? (A << 3) : 16'b0;
    assign pp4 = B[4] ? (A << 4) : 16'b0;
    assign pp5 = B[5] ? (A << 5) : 16'b0;
    assign pp6 = B[6] ? (A << 6) : 16'b0;
    assign pp7 = B[7] ? (A << 7) : 16'b0;

    assign s1 = pp0 + pp1;
    assign s2 = s1  + pp2;
    assign s3 = s2  + pp3;
    assign s4 = s3  + pp4;
    assign s5 = s4  + pp5;
    assign s6 = s5  + pp6;
    assign s7 = s6  + pp7;

    assign P = s7;
endmodule

module array_multiplier (
    input clk,
    input EA,     // enable for A register
    input EB,     // enable for B register
    input EP,     // enable for output register
    input [7:0] A_in,
    input [7:0] B_in,
    output [15:0] P
);

    wire [7:0] A_reg, B_reg;
    wire [15:0] P_comb;
	 
	 regN #(8) regA (
    .clk(clk),
    .reset(1'b0),
    .en(EA),
    .d(A_in),
    .q(A_reg)
);

regN #(8) regB (
    .clk(clk),
    .reset(1'b0),
    .en(EB),
    .d(B_in),
    .q(B_reg)
);

regN #(16) regP (
    .clk(clk),
    .reset(1'b0),
    .en(EP),
    .d(P_comb),
    .q(P)
);


    // Combinational array multiplier
    array_multiplier_8bit_core mul_core (
        .A(A_reg),
        .B(B_reg),
        .P(P_comb)
    );


endmodule
