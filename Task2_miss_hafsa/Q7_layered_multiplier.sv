// Code your testbench here
// or browse Examples
interface mult_if (input logic clk);
    logic EA, EB, EP;
    logic [7:0] A_in, B_in;
    logic [15:0] P;
endinterface


class mult_txn;
    rand bit [7:0] A;
    rand bit [7:0] B;

    bit [15:0] expected;

    function void calculate();
        expected = A * B;
    endfunction
endclass


class generator;
    mailbox gen2drv;

    function new(mailbox mb);
        gen2drv = mb;
    endfunction

    task run();
        mult_txn t;
        repeat (10) begin
            t = new();
            assert(t.randomize());
            t.calculate();
            gen2drv.put(t);
        end
    endtask
endclass



class driver;
    virtual mult_if vif;
    mailbox gen2drv;

    function new(virtual mult_if vif, mailbox mb);
        this.vif = vif;
        gen2drv = mb;
    endfunction

    task run();
        mult_txn t;
        repeat(10) begin
            gen2drv.get(t);

            vif.EA <= 1;
            vif.EB <= 1;
            vif.A_in <= t.A;
            vif.B_in <= t.B;

            @(posedge vif.clk);
            vif.EA <= 0;
            vif.EB <= 0;

            vif.EP <= 1;
            @(posedge vif.clk);
            vif.EP <= 0;
        end
    endtask
endclass




class monitor;
    virtual mult_if vif;
    mailbox mon2scb;

    function new(virtual mult_if vif, mailbox mb);
        this.vif = vif;
        mon2scb = mb;
    endfunction

    task run();
        mult_txn t;
        forever begin
            @(posedge vif.clk);
            t = new();
            t.expected = vif.P;
            mon2scb.put(t);
        end
    endtask
endclass




class scoreboard;
    mailbox mon2scb;

    function new(mailbox mb);
        mon2scb = mb;
    endfunction

    task run();
        mult_txn t;
        forever begin
            mon2scb.get(t);
            $display("Output = %0d", t.expected);
        end
    endtask
endclass







class env;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;

    mailbox gen2drv;
    mailbox mon2scb;

    function new(virtual mult_if vif);
        gen2drv = new();
        mon2scb = new();

        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);
    endfunction

    task run();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join
    endtask
endclass



module tb;
    logic clk = 0;
    always #5 clk = ~clk;

    mult_if vif(clk);

    adder_tree_multiplier_8x8 dut (
        .clk(clk),
        .EA(vif.EA),
        .EB(vif.EB),
        .EP(vif.EP),
        .A_in(vif.A_in),
        .B_in(vif.B_in),
        .P(vif.P)
    );

    env e;

    initial begin
        e = new(vif);
        e.run();
        #500 $finish;
    end
endmodule
