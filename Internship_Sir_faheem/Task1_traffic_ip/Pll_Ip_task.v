module Pll_Ip_task (
    input  clk_50,
    input  rst_n,
    output reg r,
    output reg g,
    output reg y
);

reg  [2:0] cs, ns;
wire clk, pll_locked;//locked = 1 → PLL stable , locked = 0 → PLL unstable

/* NEXT STATE LOGIC */
always @(*) begin
    ns = cs + 1;
end

/* STATE REGISTER */
always @(posedge clk) begin
    if (!rst_n || !pll_locked)//Hold the FSM in reset when reset is active OR PLL is not locked
        cs <= 3'b000;
    else
        cs <= ns;
end

/* OUTPUT LOGIC */
always @(*) begin
    r = 0;
    g = 0;
    y = 0;

    case(cs)
        3'b000, 3'b001, 3'b010: begin r = 1;y=0;end
        3'b011: begin r = 1; y = 1; end
        3'b100, 3'b101, 3'b110: begin r=0;g=1;y = 0; end
        3'b111: begin y = 1;g=0;end
    endcase
end

/* Using PLL Ip*/
pll_traffic_ip u_pll (
    .refclk   (clk_50),
    .rst      (~rst_n),//pll's rst is active high while rst_n is considered as low here
    .outclk_0 (clk),
    .locked   (pll_locked)
);

endmodule
