module seq_detector_moore(z, w, clk, rst_n);
    output reg z;
    input w, clk, rst_n;

    reg [1:0] state, nextstate;

    parameter S0 = 2'b00, 
              S1 = 2'b01, 
              S2 = 2'b10; 

    always @(*) begin
        case(state)
            S0: begin
                if (w == 1'b1) nextstate = S1;
                else           nextstate = S0;
            end
            S1: begin
                if (w == 1'b1) nextstate = S2;
                else           nextstate = S0;
            end
            S2: begin
                if (w == 1'b1) nextstate = S2;
                else           nextstate = S0;
            end
            default: nextstate = S0;
        endcase
    end

    
    always @(*) begin
        case(state)
            S2:      z = 1'b1;
            default: z = 1'b0;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= nextstate;
    end
endmodule