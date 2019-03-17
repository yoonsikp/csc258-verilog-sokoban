
module spritepath(
    input clk,
    input resetn,
    input [6:0] x_in,
	 input [6:0] y_in,
    input ld_x,
    input [1:0] dx,
	 input [1:0] dy,
    output reg [7:0] x_out,
	 output reg [6:0] y_out
    );
	 

    input storex,
    input go,

    output reg ld_x,
    output reg plot,
    output reg [1:0]  dx, dy

// gives out color as RGB, MSB 
module get_sprite_color (
get_x ,
get_y , // Address input
sprite_id ,
color_data
);
	input [2:0] get_x;
	input [2:0] get_y;
	input [2:0] sprite_id;
	output reg [11:0] color_data; 

	wire [5:0] mem_offset;
	assign mem_offset = {sprite_id, get_y};
	reg [31:0] mem [0:63];  
	
  	wire [31:0] mem_row;
  	assign mem_row = mem[mem_offset];
	wire [7:0] test;
	assign test = get_x * get_y;
	wire [4:0] mem_offset_x;
	assign mem_offset_x = {7-get_x,2'b00};

	wire [3:0] color_id;
	assign color_id = mem_row[mem_offset_x +: 4];



	always @(*)
		begin // describes palette
		  case (color_id)
				4'h0: color_data = 12'b0100_0000_0000;
				4'h1: color_data = 12'b0100_0000_0001;
				4'h2: color_data = 12'b0100_0000_0010;
				4'h3: color_data = 12'b0100_0000_0011;
				4'h4: color_data = 12'b0100_0000_0100;
				4'h5: color_data = 12'b0100_0000_0101;
				4'h6: color_data = 12'b0100_0000_0110;
				4'h7: color_data = 12'b0100_0000_0111;
				4'h8: color_data = 12'b0100_0000_1000;
				4'h9: color_data = 12'b0100_0000_1001;
				4'hA: color_data = 12'b0100_0000_1010;
				4'hB: color_data = 12'b0100_0000_1011;
				4'hC: color_data = 12'b0100_0000_1100;
				4'hD: color_data = 12'b0100_0000_1101;
				4'hE: color_data = 12'b0100_0000_1110;
				4'hF: color_data = 12'b0100_0000_1111;
				default: color_data = 12'b0100_0000_0000;
		  endcase
	end

	initial begin
	  $readmemb("sprites.mem", mem); // sprites are defined as 8x8x(4bit),before a palette conversion
	end

endmodule
