module i2c_master (
    input  logic        clk,        // system clock
    input  logic        rst,
    input  logic        start,
    input  logic [6:0]  slave_addr,
    input  logic [11:0] data_in,

    output logic        busy,
    output logic        done,
    output logic        ack_error,

    inout  wire         SDA,
    output logic        SCL
);

    // Open-drain SDA
    logic sda_drive;   // 0 = pull low, 1 = release
    assign SDA = (sda_drive == 0) ? 1'b0 : 1'bz;

    typedef enum logic [3:0] {
        IDLE,
        START,
        SEND_ADDR,
        ADDR_ACK,
        SEND_DATA1,
        DATA1_ACK,
        SEND_DATA2,
        DATA2_ACK,
        STOP,
        DONE
    } state_t;

    state_t state;

    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;

    // Simple SCL generator (divide-by-2)
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            SCL <= 1;
        else if (busy)
            SCL <= ~SCL;
        else
            SCL <= 1;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            sda_drive  <= 1;
            busy       <= 0;
            done       <= 0;
            ack_error  <= 0;
            bit_cnt    <= 0;
        end else begin
            done <= 0;

            case (state)

            IDLE: begin
                sda_drive <= 1;
                busy      <= 0;
                ack_error <= 0;
                if (start) begin
                    busy  <= 1;
                    state <= START;
                end
            end

            START: begin
                if (SCL) begin
                    sda_drive <= 0; // SDA low while SCL high
                    shift_reg <= {slave_addr, 1'b0}; // write = 0
                    bit_cnt   <= 3'd7;
                    state     <= SEND_ADDR;
                end
            end

            SEND_ADDR: begin
                if (!SCL) begin
                    sda_drive <= shift_reg[bit_cnt];
                end else if (SCL) begin
                    if (bit_cnt == 0)
                        state <= ADDR_ACK;
                    else
                        bit_cnt <= bit_cnt - 1;
                end
            end

            ADDR_ACK: begin
                if (!SCL) begin
                    sda_drive <= 1; // release SDA
                end else begin
                    if (SDA) begin
                        ack_error <= 1;
                        state <= STOP;
                    end else begin
                        shift_reg <= data_in[11:4];
                        bit_cnt   <= 3'd7;
                        state     <= SEND_DATA1;
                    end
                end
            end

            SEND_DATA1: begin
                if (!SCL) begin
                    sda_drive <= shift_reg[bit_cnt];
                end else if (SCL) begin
                    if (bit_cnt == 0)
                        state <= DATA1_ACK;
                    else
                        bit_cnt <= bit_cnt - 1;
                end
            end

            DATA1_ACK: begin
                if (!SCL) begin
                    sda_drive <= 1;
                end else begin
                    if (SDA) begin
                        ack_error <= 1;
                        state <= STOP;
                    end else begin
                        shift_reg <= {data_in[3:0], 4'b0000};
                        bit_cnt   <= 3'd7;
                        state     <= SEND_DATA2;
                    end
                end
            end

            SEND_DATA2: begin
                if (!SCL) begin
                    sda_drive <= shift_reg[bit_cnt];
                end else if (SCL) begin
                    if (bit_cnt == 0)
                        state <= DATA2_ACK;
                    else
                        bit_cnt <= bit_cnt - 1;
                end
            end

            DATA2_ACK: begin
                if (!SCL) begin
                    sda_drive <= 1;
                end else begin
                    if (SDA)
                        ack_error <= 1;
                    state <= STOP;
                end
            end

            STOP: begin
                if (SCL) begin
                    sda_drive <= 1; // SDA rises while SCL high
                    state <= DONE;
                end
            end

            DONE: begin
                busy <= 0;
                done <= 1;
                state <= IDLE;
            end

            endcase
        end
    end

endmodule
