// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

interface counter_if #(parameter N=8);
  logic clk;
  logic rst_n;
  logic en;
  logic up_dn;
  logic [N-1:0] count;



  modport DUT (input clk, rst_n, en, up_dn, output count);
  modport DRV (output en, up_dn, rst_n, input clk);
  modport MON (input clk, rst_n, en, up_dn, count);
endinterface


class counter_txn;
  rand bit up_dn;

  function void display();
    $display("[TXN] up_dn=%0b",  up_dn);
  endfunction
endclass

class counter_txn_count;
  int count;
  bit up_dn;
endclass



class counter_gen;
  mailbox #(counter_txn)gen2drv;

  function new(mailbox #(counter_txn) m);
    gen2drv = m;
  endfunction

  task run();
    counter_txn tx;
    repeat (4) begin
      tx = new();
      assert(tx.randomize());
      gen2drv.put(tx);
      tx.display();
      #10;
    end
  endtask
endclass


class counter_driver;
  virtual counter_if.DRV vif;
  mailbox #(counter_txn) gen2drv;

  function new(virtual counter_if vif, mailbox #(counter_txn) m);
    this.vif = vif.DRV;
    gen2drv = m;  
    endfunction

  task reset();
    vif.rst_n = 0;
    vif.en    = 0;
    vif.up_dn = 0;
    #20;
    vif.rst_n = 1;
    vif.en=1;
  endtask

task run();
  counter_txn tx;
  repeat(4) begin
    gen2drv.get(tx);
    vif.up_dn = tx.up_dn;
   
    @(posedge vif.clk);
  end
endtask

endclass


//--------------------------------------
// MONITOR
//--------------------------------------
class counter_monitor;
  virtual counter_if.MON vif;
  mailbox #(counter_txn_count) mon2scb;

  function new(virtual counter_if vif, mailbox #(counter_txn_count) m);
    mon2scb = m;
  this.vif = vif.MON;
endfunction
  task run();
  counter_txn_count tx;
    repeat(4) begin
    
  @(posedge vif.clk);
    tx = new();
    tx.count = vif.count;
     tx.up_dn= vif.up_dn;
    mon2scb.put(tx);
    $display("[MON] count=%0d", tx.count);
    end
endtask

endclass


//--------------------------------------
// SCOREBOARD
//--------------------------------------
class counter_scoreboard;
  mailbox #(counter_txn_count) mon2scb;
  int expected;

  function new(mailbox #(counter_txn_count) m);
    mon2scb = m;
  endfunction
task run();
  counter_txn_count tx;
  expected = 0;  // model reset

  repeat(4) begin
    mon2scb.get(tx);

    // Check first
    if (tx.count !== expected) begin
      $error("[SCB] Mismatch! actual=%0d expected=%0d",
             tx.count, expected);
    end else begin
      $display("[SCB] PASS actual=%0d expected=%0d",
               tx.count, expected);
    end

    // Then update expected for NEXT cycle
    if (tx.up_dn)
      expected--;
    else
      expected++;
  end
endtask



endclass


//--------------------------------------
// ENVIRONMENT
//--------------------------------------
class counter_env;
  counter_gen       gen;
  counter_driver    drv;
  counter_monitor   mon;
  counter_scoreboard scb;

   mailbox #(counter_txn) gen2drv;
  mailbox #(counter_txn_count) mon2scb;

  function new(virtual counter_if vif);
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


//--------------------------------------
// TEST
//--------------------------------------
class counter_test;
  counter_env env;

  function new(virtual counter_if vif);
    env = new(vif);
  endfunction

  task run();
    env.run();
  endtask
endclass


//--------------------------------------
// TB TOP
//--------------------------------------
module tb_top;
  counter_if #(8) cif();

  counter #(8) dut (
    .clk(cif.clk),
    .rst_n(cif.rst_n),
    .en(cif.en),
    .up_dn(cif.up_dn),
    .count(cif.count)
  );

  counter_test test;

  // Clock
  initial cif.clk = 0;
  always #5 cif.clk = ~cif.clk;

  initial begin
    test = new(cif);
    test.run();
    #200 $finish;
  end
endmodule
