module manchester_mealy (
    output reg z,
    input w,
    input clk,
    input rst_n
);

    reg state, next_state;
    parameter S0 = 1'b0, S1 = 1'b1;

    
    always @(*) begin
        case (state)
            S0: begin
                
                z = w ? 0 : 1; 
                next_state = S1;
            end
            S1: begin
                z = w ? 1 : 0;
                next_state = S0;
            end
            default: begin
                z = 0;
                next_state = S0;
            end
        endcase
    end

    // State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

endmodule