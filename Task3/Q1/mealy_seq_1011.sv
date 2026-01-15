module mealy_seq_detect(input d, input clk, input rst, output res);
logic [1:0] state, next_state;
parameter S0=2'b00, S1=2'b01, S2=2'b10, S3=2'b11;
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
    S0: next_state = (d) ? S1 : S0;
    S1: next_state = (d) ? S1 : S2;
    S2: next_state = (d) ? S3 : S0;
    S3: begin next_state = (d) ? S1 : S2; res=d?1'b1:1'b0; end
    endcase
end


endmodule