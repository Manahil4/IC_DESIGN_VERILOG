module tb;

    logic clk, rst, start;
    logic [6:0] slave_addr;
    logic [11:0] data_in;
    logic busy, done, ack_error;
    wire SDA;
    logic SCL;

    i2c_master dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .slave_addr(slave_addr),
        .data_in(data_in),
        .busy(busy),
        .done(done),
        .ack_error(ack_error),
        .SDA(SDA),
        .SCL(SCL)
    );

    i2c_slav slave (
        .SDA(SDA),
        .SCL(SCL)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        slave_addr = 7'h42;
        data_in = 12'hABC;

        #20 rst = 0;
        #20 start = 1;
        #10 start = 0;

        wait(done);
        $display("DONE, ack_error=%0d", ack_error);

        #50 $finish;
    end
endmodule
