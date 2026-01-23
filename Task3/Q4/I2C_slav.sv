module i2c_slav (
    inout wire SDA,
    input wire SCL
);
    // Always ACK by pulling SDA low during SCL high
    assign SDA = (SCL) ? 1'b0 : 1'bz;
endmodule
