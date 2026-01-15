interface top_if;
    logic clk;
    logic rst;
    logic [7:0] rgb;
    logic display_on;
endinterface

class vga_txn;
    int cycles;

    function new(int cycles = 1000);
        this.cycles = cycles;
    endfunction
endclass

class driver;
    virtual top_if vif;

    function new(virtual top_if vif);
        this.vif = vif;
    endfunction

    task run(vga_txn t);
        // Apply reset
        vif.rst <= 0;
        repeat (5) @(posedge vif.clk);
        vif.rst <= 1;

        // Run for requested cycles
        repeat (t.cycles) @(posedge vif.clk);
    endtask
endclass


class monitor;
    virtual top_if vif;
    mailbox #(byte) mon_mb;

    function new(virtual top_if vif, mailbox #(byte) mb);
        this.vif    = vif;
        this.mon_mb = mb;
    endfunction

    task run();
        forever @(posedge vif.clk) begin
            if (vif.display_on)
                mon_mb.put(vif.rgb);
        end
    endtask
endclass


class scoreboard;
    mailbox #(byte) mon_mb;
    int rx_count = 0;
    int expected_cycles;

    function new(mailbox #(byte) mb, int cycles);
        this.mon_mb = mb;
        this.expected_cycles = cycles;
    endfunction

    task run();
        byte rgb;
        forever begin
            mon_mb.get(rgb);
            rx_count++;

            if (rx_count % expected_cycles == 0)
                $display("Scoreboard: received %0d RGB samples", rx_count);
        end
    endtask
endclass


class env;
    driver     drv;
    monitor    mon;
    scoreboard sb;
    mailbox #(byte) mb;

    function new(virtual top_if vif, vga_txn t);
        mb  = new();
        drv = new(vif);
        mon = new(vif, mb);
        sb  = new(mb, t.cycles);
    endfunction

    task run(vga_txn t);
        fork
            drv.run(t);
            mon.run();
            sb.run();
        join_none
    endtask
endclass


module tb;

    top_if tif();

    // Clock generation
    initial tif.clk = 0;
    always #5 tif.clk = ~tif.clk;

    // DUT
    top dut (
        .clk(tif.clk),
        .rst(tif.rst),
        .rgb(tif.rgb)
    );

    assign tif.display_on = dut.display_on;

    // Coverage
    covergroup fsm_cg @(posedge tif.clk);
        coverpoint dut.vFSM_inst.state;
        coverpoint dut.display_on;
        cross dut.vFSM_inst.state, dut.display_on;
    endgroup

    fsm_cg cg = new();

    // Environment
    env e;
    vga_txn t;

    initial begin
        t = new(2000);     // you can change this freely
        e = new(tif, t);
        e.run(t);

        #3000;
        $display("Simulation finished");
        $finish;
    end

endmodule
