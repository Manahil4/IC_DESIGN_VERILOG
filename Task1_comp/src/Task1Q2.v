//Barrel Shifter module
module Task1Q2(output reg [31:0] data_out,
             input  [31:0] data_in,
             input  [4:0] shift_amt, //shift amount =5 bits for 32 bits input 
             input  dir); //direction: 0 for left, 1 for right

  always @(*) begin
    if(shift_amt == 0) begin
      data_out = data_in; //no shift
    end else if (dir == 0) begin
      data_out = (data_in << shift_amt) | (data_in >> (32 - shift_amt)); //rotate left shift
    end else begin
      data_out = (data_in >> shift_amt)|(data_in << (32 - shift_amt)); //rotate right shift
    end
  end
  endmodule