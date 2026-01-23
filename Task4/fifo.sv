module fifo #(
    parameter DEPTH = 8,
    parameter ADDR_W = $clog2(DEPTH)
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        write_en,
    input  logic        read_en,
    input  logic [15:0] data_in,
    output logic [15:0] data_out,
    output logic        full,
    output logic        empty
);

    logic [15:0] mem [DEPTH];
    logic [ADDR_W-1:0] wr_ptr, rd_ptr;
    logic [ADDR_W:0]   count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            data_out <= 0;
        end
        else begin
            case ({write_en && !full, read_en && !empty})

                2'b10: begin // WRITE only
                    mem[wr_ptr] <= data_in;
                    wr_ptr <= wr_ptr + 1;
                    count  <= count + 1;
                end

                2'b01: begin // READ only
                    data_out <= mem[rd_ptr];
                    rd_ptr <= rd_ptr + 1;
                    count  <= count - 1;
                end

                2'b11: begin // SIMULTANEOUS READ & WRITE
                    mem[wr_ptr] <= data_in;
                    data_out <= mem[rd_ptr];
                    wr_ptr <= wr_ptr + 1;
                    rd_ptr <= rd_ptr + 1;
                    // count unchanged
                end

                default: ; // no operation
            endcase
        end
    end

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

endmodule