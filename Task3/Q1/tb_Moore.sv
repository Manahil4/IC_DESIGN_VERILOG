// Code your testbench here
// or browse Examples
module seq_detector_tb;

  logic clk;
  logic rst;
  logic d;
  logic res;

   Moore_seq_detect dut (.d(d), .clk(clk), .rst(rst), .res(res));

  initial clk = 0;
  always #5 clk = ~clk;

  logic [3:0] history;
  logic exp_res;

  covergroup state_cg @(posedge clk);
    coverpoint dut.state {
      bins S0 = {0};
      bins S1 = {1};
      bins S2 = {2};
      bins S3 = {3};
      bins S4 = {4}; 
    }
  endgroup
  state_cg scg = new();

 covergroup fsm_cg @(posedge clk);

  // Current state from DUT
  coverpoint dut.state {
    bins S0 = {0};
    bins S1 = {1};
    bins S2 = {2};
    bins S3 = {3};
    bins S4 = {4};
  }

  // Next state from DUT
  coverpoint dut.next_state {
    bins S0 = {0};
    bins S1 = {1};
    bins S2 = {2};
    bins S3 = {3};
    bins S4 = {4};
  }

  // Transition coverage
  cross dut.state, dut.next_state;

endgroup

fsm_cg tcg = new();


  covergroup sequence_cg @(posedge clk);
    coverpoint history {
      bins one      = {4'b0001};
      bins ten      = {4'b0010};
      bins seq101  = {4'b0101};
      bins seq1011 = {4'b1011};
    }
  endgroup
  sequence_cg seqcg = new();

  task drive_bit(input logic bit_in);
    begin
      d = bit_in;
      @(posedge clk);

      history = {history[2:0], bit_in};
     exp_res = (dut.state == dut.S4);


      if (res !== exp_res)
        $display(" FAIL d=%b hist=%b exp=%b got=%b",
                  bit_in, history, exp_res, res);
      else
        $display(" PASS d=%b hist=%b res=%b",
                  bit_in, history, res);
    end
  endtask

  // ==========================
  // TEST
  // ==========================
  initial begin
    d = 0;
    history = 0;
    exp_res = 0;

    // RESET
    rst = 0;
    repeat(2) @(posedge clk);
    rst = 1;

    $display("\n--- Non-overlapping ---");
    drive_bit(0);
    drive_bit(0);
    drive_bit(1);
    drive_bit(0);
    drive_bit(1);
    drive_bit(1);

    $display("\n--- Overlapping ---");
    drive_bit(1);
    drive_bit(0);
    drive_bit(1);
    drive_bit(1);
    drive_bit(0);
    drive_bit(1);
    drive_bit(1);

    $display("\n--- Random ---");
    repeat(20)
      drive_bit($urandom_range(0,1));

    // REPORT
    $display("\nCoverage Summary:");
    $display("State coverage     = %0.2f %%", scg.get_coverage());
    $display("Transition coverage= %0.2f %%", tcg.get_coverage());
    $display("Sequence coverage  = %0.2f %%", seqcg.get_coverage());
#200;
    $finish;
  end
  initial begin
  $display("=== ENTERING TEST ===");
end


endmodule
