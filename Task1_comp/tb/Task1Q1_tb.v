module Task1Q1_tb;
reg [31:0] a;
reg [31:0] b;
reg cin;
wire [31:0] sum;
wire cout;

Task1Q1 uut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);
integer pass, fail;
reg [32:0] expected;

initial begin
    pass = 0; fail = 0;

    // Directed test
    a = 0; b = 0; cin = 0;
    #1;
    expected = a + b + cin;
    if ({cout,sum} == expected) pass++;
    else fail++;

    // Random tests
    repeat (100) begin
        a = $random;
        b = $random;
        cin = $random;
        #1;
        expected = a + b + cin;
        if ({cout,sum} == expected) pass++;
        else fail++;
    end

    $display("PASS=%0d FAIL=%0d", pass, fail);
    $finish;
end
endmodule
