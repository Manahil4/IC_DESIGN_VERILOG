//  Output controller
module vFSM(
    output logic [7:0] rgb,
    input clk,
    input rst,
    input [7:0] pixel_data,
    input display_on
);
    logic [1:0] state, next;
    
    always_comb begin
        rgb = 0;  // Default value
        case(state)
            2'b00: begin
                next = display_on ? 2'b01 : 2'b00;
            end
            2'b01: begin
                next = 2'b10;
            end
            2'b10: begin
                rgb = pixel_data;  
                next = 2'b00;
            end
            default: next = 2'b00;
        endcase
    end
    
    always_ff @(posedge clk or negedge rst) begin
        if(!rst)
            state <= 2'b00;
        else
            state <= next;
    end
endmodule
//addresses and display_on signal generator
module vga(
    output logic [18:0] address,
    output logic display_on,
    input clk,
    input rst
);
    logic [9:0] h_count;
    logic [9:0] v_count;
    
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            h_count <= 0;
            v_count <= 0;
        end
        else if(h_count == 10'd799) begin
            h_count <= 0;
            if(v_count == 10'd524)
                v_count <= 0;
            else 
                v_count <= v_count + 1;
        end
        else begin
            h_count <= h_count + 1;
        end
    end
    
    assign address = h_count + (v_count * 20'd640);
    assign display_on = (h_count < 10'd640) && (v_count < 10'd480);
endmodule


module sram(
    input [18:0] address,
    input clk,
    output reg [7:0] data
);
    reg [7:0] memory [0:307199];
    
     initial begin
        for (int i = 0; i < 307200; i++)
            memory[i] = i[7:0];   // each location holds its address LSBs
    end
    
     always_ff @(posedge clk) begin
        data <= memory[address];
    end
endmodule

// DUT
module top(
    input clk,
    input rst,
    output [7:0] rgb
);
    logic [18:0] address;
    logic display_on;
    logic [7:0] pixel_data;
    
    // Instantiate submodules
    sram sram_inst(
        .address(address),
        .clk(clk),
        .data(pixel_data)
    );
    
    vga vga_inst(
        .address(address),
        .display_on(display_on),
        .clk(clk),
        .rst(rst)
    );
    
    vFSM vFSM_inst(
        .rgb(rgb),
        .clk(clk),
        .rst(rst),
        .pixel_data(pixel_data),
        .display_on(display_on)
    );
endmodule