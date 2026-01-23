module shift_reg #(
    parameter N = 8
)(
    input  logic        clk,
    input  logic        rst_n,     
    input  logic        shift_en,  
    input  logic        dir,       
	 input  logic        d_in,      
    output logic [N-1:0] q_out
);

    always @(posedge clk) begin
        if (!rst_n)
            q_out <= '0;
        else if (shift_en) begin
            if (dir == 1'b0)
                q_out <= {q_out[N-2:0], d_in};   
            else
                q_out <= {d_in, q_out[N-1:1]};   
        end
        else q_out<=q_out;
    end

endmodule
