// Part 2 skeleton

module finalproject
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	assign colour = SW[9:7];
	
	//
	wire [1:0] w_dx;
	wire [1:0] w_dy;
	wire w_ld_x;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	datapath d0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.x_in(SW[6:0]),
		.y_in(SW[6:0]),
		.ld_x(w_ld_x),
		.dx(w_dx),
		.dy(w_dy),
		.x_out(x),
		.y_out(y)
	);

    // Instansiate FSM control
    control c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.storex(~KEY[3]),
		.go(~KEY[1]),
		.ld_x(w_ld_x),
		.plot(writeEn),
		.dx(w_dx),
		.dy(w_dy)
	);
    
endmodule


module control(
    input clk,
    input resetn,
    input storex,
    input go,

    output reg ld_x,
    output reg plot,
    output reg [1:0]  dx, dy
    );

    reg [4:0] current_state, next_state; 
    
    localparam  S_LOAD_X        = 5'd0,
                S_LOAD_X_WAIT   = 5'd1,
                S_LOAD_Y        = 5'd2,
                S_LOAD_Y_WAIT   = 5'd3,
                S_CYCLE_0       = 5'd4,
                S_CYCLE_1       = 5'd5,
                S_CYCLE_2       = 5'd6,
                S_CYCLE_3       = 5'd7,
                S_CYCLE_4       = 5'd8,
                S_CYCLE_5       = 5'd9,
                S_CYCLE_6       = 5'd10,
                S_CYCLE_7       = 5'd11,
                S_CYCLE_8       = 5'd12,
                S_CYCLE_9       = 5'd13,
                S_CYCLE_10      = 5'd14,
                S_CYCLE_11      = 5'd15,
                S_CYCLE_12      = 5'd16,
                S_CYCLE_13      = 5'd17,
                S_CYCLE_14      = 5'd18,
                S_CYCLE_15      = 5'd19,
                S_DRAW          = 5'd20;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = storex ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = storex ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = S_CYCLE_1;
                S_CYCLE_1: next_state = S_CYCLE_2;
                S_CYCLE_2 : next_state = S_CYCLE_3;
                S_CYCLE_3 : next_state = S_CYCLE_4;
                S_CYCLE_4 : next_state = S_CYCLE_5;
                S_CYCLE_5 : next_state = S_CYCLE_6;
                S_CYCLE_6 : next_state = S_CYCLE_7;
                S_CYCLE_7 : next_state = S_CYCLE_8;
                S_CYCLE_8 : next_state = S_CYCLE_9;
                S_CYCLE_9 : next_state = S_CYCLE_10;
                S_CYCLE_10: next_state = S_CYCLE_11;
                S_CYCLE_11: next_state = S_CYCLE_12;
                S_CYCLE_12: next_state = S_CYCLE_13;
                S_CYCLE_13: next_state = S_CYCLE_14;
                S_CYCLE_14: next_state = S_CYCLE_15;
		S_CYCLE_15: next_state = S_DRAW;
                S_DRAW: next_state = S_LOAD_X; // we will be done our two operations, start over after
            default:     next_state = S_LOAD_X;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;

        dx = 2'b00;
        dy = 2'b00;
		  
		  plot = 1'b0;

        case (current_state)
            S_LOAD_X_WAIT: begin
                ld_x = 1'b1;
                end
            S_CYCLE_0: begin  
                dx = 2'b00;
                dy = 2'b00;
					 plot = 1'b1;
            end
            S_CYCLE_1: begin  
                dx = 2'b01;
                dy = 2'b00;
					 plot = 1'b1;
            end
            S_CYCLE_2: begin  
                dx = 2'b10;
                dy = 2'b00;
					 plot = 1'b1;
            end
            S_CYCLE_3: begin  
                dx = 2'b11;
                dy = 2'b00;
					 plot = 1'b1;
            end
            S_CYCLE_4: begin  
                dx = 2'b00;
                dy = 2'b01;
					 plot = 1'b1;
            end
            S_CYCLE_5: begin  
                dx = 2'b01;
                dy = 2'b01;
					 plot = 1'b1;
            end
            S_CYCLE_6: begin  
                dx = 2'b10;
                dy = 2'b01;
					 plot = 1'b1;
            end
            S_CYCLE_7: begin  
                dx = 2'b11;
                dy = 2'b01;
					 plot = 1'b1;
            end
            S_CYCLE_8: begin  
                dx = 2'b00;
                dy = 2'b10;
					 plot = 1'b1;
            end
            S_CYCLE_9: begin  
                dx = 2'b01;
                dy = 2'b10;
					 plot = 1'b1;
            end
            S_CYCLE_10: begin  
                dx = 2'b10;
                dy = 2'b10;
					 plot = 1'b1;
            end
            S_CYCLE_11: begin  
                dx = 2'b11;
                dy = 2'b10;
					 plot = 1'b1;
            end
            S_CYCLE_12: begin  
                dx = 2'b00;
                dy = 2'b11;
					 plot = 1'b1;
            end
            S_CYCLE_13: begin  
                dx = 2'b01;
                dy = 2'b11;
					 plot = 1'b1;
            end
            S_CYCLE_14: begin  
                dx = 2'b10;
                dy = 2'b11;
					 plot = 1'b1;
            end
            S_CYCLE_15: begin  
                dx = 2'b11;
                dy = 2'b11;
					 plot = 1'b1;
            end
            S_DRAW: begin  
                plot  = 1'b0;
            end


        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module datapath(
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
    
    // input registers
    reg [7:0] x;

    // Register x with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            x <= 8'd0;
        end
		  else begin
            if (ld_x)
					x <= {1'b0, x_in};
        end
    end
 
    always @(*)
    begin
        case (dx)
            2'd0:
                x_out = x + 8'd0;
            2'd1:
                x_out = x + 8'd1;
            2'd2:
                x_out = x + 8'd2;
            2'd3:
                x_out = x + 8'd3;
            default: x_out = 8'd0;
        endcase

        case (dy)
            2'd0:
                y_out = y_in + 7'd0;
            2'd1:
                y_out = y_in + 7'd1;
            2'd2:
                y_out = y_in + 7'd2;
            2'd3:
                y_out = y_in + 7'd3;
            default: y_out = y_in + 7'd0;
        endcase
    end
    
endmodule