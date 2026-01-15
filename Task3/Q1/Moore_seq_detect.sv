//Moore Machine for sequence detection of 1011

module Moore_seq_detect(input d, input clk,input rst, output logic res);
logic [2:0] state, next_state;
parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100;
// State Transition
always_ff @(posedge clk or negedge rst) begin
    if (!rst)
        state <= S0;
    else
        state <= next_state;
end
// Next State Logic
always_comb begin
    case(state)
    3'b000:next_state = (d) ? S1 : S0;
    3'b001:next_state = (d) ? S1 : S2;
    3'b010:next_state = (d) ? S3 : S0;
    3'b011:next_state = (d) ? S4 : S2;
    3'b100:next_state = (d) ? S1 : S2;
    endcase
end
always_comb res=(state==S4)?1'b1:1'b0;
endmodule