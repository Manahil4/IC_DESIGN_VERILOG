//priority enc ; 8 to 3 encoder
module Task1Q3(input [7:0]in, output reg[2:0]out, output reg valid);

always@(*)begin
casez(in):
8'b00000001: begin out=3'b000; valid=1'b1; end
8'b0000001?: begin out=3'b001; valid=1'b1; end
8'b000001??: begin out=3'b010; valid=1'b1; end
8'b00001???: begin out=3'b011; valid=1'b1;
end
8'b0001????: begin out=3'b100; valid=1'b1;end
8'b001?????: begin out=3'b101; valid=1'b1; end
8'b01??????: begin out=3'b110; valid=1'b1;  
end
8'b1???????: begin out=3'b111; valid=1'b1; end
default: begin out=3'b000; valid=1'b0; end
endcase
end
endmodule