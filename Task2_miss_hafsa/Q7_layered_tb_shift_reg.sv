// Code your testbench here
// or browse Examples
interface shift_if #(parameter N=8);
  logic clk;
  logic rst_n;
  logic shift_en;
  logic dir;
  logic d_in;
  logic [N-1:0] q_out;

  modport DUT (input clk, rst_n, shift_en, dir, d_in,
               output q_out);

  modport DRV (output shift_en, dir, d_in, rst_n,
               input clk);

  modport MON (input clk, rst_n, shift_en, dir, d_in, q_out);
endinterface

// Driver transaction
class shift_txn;
  rand bit shift_en;
  rand bit dir;
  rand bit d_in;

  function void display();
    $display("[TXN] shift_en=%0b dir=%0b d_in=%0b",
              shift_en, dir, d_in);
  endfunction
endclass

// Monitor → Scoreboard transaction
class shift_txn_out;
  bit dir;
  bit d_in;
  bit shift_en;
  logic [7:0] q_out;
endclass

//gen
class shift_gen;
  mailbox #(shift_txn) gen2drv;

  function new(mailbox #(shift_txn) m);
    gen2drv = m;
  endfunction

  task run();
    shift_txn tx;
    repeat (6) begin
      tx = new();
      assert(tx.randomize());
      gen2drv.put(tx);
      tx.display();
      #10;
    end
  endtask
endclass

// Drv
class shift_driver;
  virtual shift_if.DRV vif;
  mailbox #(shift_txn) gen2drv;

  function new(virtual shift_if vif,mailbox #(shift_txn) m);
    this.vif = vif.DRV;
    gen2drv = m;
  endfunction

  task reset();
    vif.rst_n = 0;
    vif.shift_en = 0;
    vif.dir = 0;
    vif.d_in = 0;
    #20;
    vif.rst_n = 1;
  endtask

  task run();
    shift_txn tx;
    repeat (6) begin
      gen2drv.get(tx);
      vif.shift_en = tx.shift_en;
      vif.dir      = tx.dir;
      vif.d_in     = tx.d_in;
      @(posedge vif.clk);
    end
  endtask
endclass


// MON
class shift_monitor;
  virtual shift_if.MON vif;
  mailbox #(shift_txn_out) mon2scb;

  function new(virtual shift_if vif,
               mailbox #(shift_txn_out) m);
    this.vif = vif.MON;
    mon2scb = m;
  endfunction

  task run();
    shift_txn_out tx;
    repeat (6) begin
      @(posedge vif.clk);
      tx = new();
      tx.shift_en = vif.shift_en;
      tx.dir      = vif.dir;
      tx.d_in     = vif.d_in;
      tx.q_out    = vif.q_out;
      mon2scb.put(tx);
      $display("[MON] q_out=%b", tx.q_out);
    end
  endtask
endclass

// SCR
class shift_scoreboard;
  mailbox #(shift_txn_out) mon2scb;
  logic [7:0] expected;

  function new(mailbox #(shift_txn_out) m);
    mon2scb = m;
    expected = 0;
  endfunction

  task run();
    shift_txn_out tx;
    repeat (6) begin
      mon2scb.get(tx);

      // CHECK
      if (tx.q_out !== expected)
        $error("[SCB] Mismatch! actual=%b expected=%b",
               tx.q_out, expected);
      else
        $display("[SCB] PASS actual=%b expected=%b",
                 tx.q_out, expected);

      // UPDATE MODEL
      if (tx.shift_en) begin
        if (tx.dir == 0)
          expected = {expected[6:0], tx.d_in};
        else
          expected = {tx.d_in, expected[7:1]};
      end
    end
  endtask
endclass


// ENV
class shift_env;
  shift_gen gen;
  shift_driver drv;
  shift_monitor mon;
  shift_scoreboard scb;

  mailbox #(shift_txn) gen2drv;
  mailbox #(shift_txn_out) mon2scb;

  function new(virtual shift_if vif);
    gen2drv = new();
    mon2scb = new();

    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);
  endfunction

  task run();
    drv.reset();
    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none
  endtask
endclass


// Test
class shift_test;
  shift_env env;

  function new(virtual shift_if vif);
    env = new(vif);
  endfunction

  task run();
    env.run();
  endtask
endclass


//Tb_top
module tb_top;
  shift_if #(8) sif();

  shift_reg #(8) dut (
    .clk(sif.clk),
    .rst_n(sif.rst_n),
    .shift_en(sif.shift_en),
    .dir(sif.dir),
    .d_in(sif.d_in),
    .q_out(sif.q_out)
  );

  shift_test test;

  initial sif.clk = 0;
  always #5 sif.clk = ~sif.clk;

  initial begin
    test = new(sif);
    test.run();
    #300 $finish;
  end
endmodule
