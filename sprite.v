module sprite_draw(
    input clk,
    input resetn,
    input [7:0] x_in,
    input [6:0] y_in,
    input begin_draw,
    input sprite_id_in,

    output          VGA_CLK,                //  VGA Clock
    output          VGA_HS,                 //  VGA H_SYNC
    output          VGA_VS,                 //  VGA V_SYNC
    output          VGA_BLANK,            //  VGA BLANK
    output          VGA_SYNC,             //  VGA SYNC
    output  [9:0]   VGA_R,                  //  VGA Red[9:0]
    output  [9:0]   VGA_G,                  //  VGA Green[9:0]
    output  [9:0]   VGA_B                   //  VGA Blue[9:0]
    );
     

    wire [11:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire writeEn;
    wire w_ld_xys;
    wire [5:0] w_pixel_loc;



    vga_adapter VGA(
        .resetn(resetn),
        .clock(clk),
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
        .VGA_BLANK(VGA_BLANK),
        .VGA_SYNC(VGA_SYNC),
        .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";

    sprite_data s_data (
        .clk(clk),
        .resetn(resetn),
        .ld_xys(w_ld_xys),
        .x_anchor_in(x_in),
        .y_anchor_in(y_in),
        .sprite_id_in(sprite_id_in),
        .pixel_loc(w_pixel_loc),
        .color_out(colour),
        .x_out(x),
        .y_out(y)
        );
    sprite_control s_control (
        .clk(clk),
        .resetn(resetn),
        .go(begin_draw),
        .plot(writeEn),
        .ld_xys(w_ld_xys),
        .pixel_loc(w_pixel_loc)
        );
endmodule

module sprite_data (
    input clk,
    input resetn,
    input ld_xys,
    input [7:0] x_anchor_in,
    input [6:0] y_anchor_in,
    input [2:0] sprite_id_in,
    input [5:0] pixel_loc,
    output [11:0] color_out,
    output [7:0] x_out,
    output [6:0] y_out
    );
    
    // input registers
    reg [7:0] x_anchor;
    reg [6:0] y_anchor;
    reg [2:0] sprite_id;
    wire w_sprite_id;
    assign w_sprite_id = sprite_id;

    assign x_out = x_anchor + pixel_loc[2:0];
    assign y_out = y_anchor + pixel_loc[5:3];
    // Register x with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            x_anchor <= 8'd0;
            y_anchor <= 7'd0;
            sprite_id <= 3'd0;
        end
        else begin
            if (ld_xys) begin
                x_anchor <= x_anchor_in;
                y_anchor <= y_anchor_in;
                sprite_id <= sprite_id_in;
            end
        end
    end
    
    get_sprite_color gsc(
        .get_x(pixel_loc[2:0]),
        .get_y(pixel_loc[5:3]),
        .sprite_id(w_sprite_id),
        .color_data(color_out)
        );
    
endmodule

module sprite_control(
    input clk,
    input resetn,
    input go,

    output reg plot,
    output reg ld_xys,
    output reg [5:0] pixel_loc
    );

    reg [1:0] current_state, next_state; 
    wire finished_counting;
    assign finished_counting = pixel_loc & 6'b111111;

    localparam  S_LOAD        = 2'd0,
                S_LOAD_WAIT   = 2'd1,
                S_DRAW        = 2'd2;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
        case (current_state)
            S_LOAD: next_state = go ? S_LOAD_WAIT : S_LOAD; // Loop in current state until value is input
            S_LOAD_WAIT: next_state = go ? S_LOAD_WAIT : S_DRAW;
            S_DRAW: next_state = finished_counting ? S_LOAD : S_DRAW; // we will be done our two operations, start over after
            default: next_state = S_LOAD;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_xys = 1'b0;
        plot = 1'b0;
        case (current_state)
            S_LOAD_WAIT: begin  
                ld_xys  = 1'b1;
            end
            S_DRAW: begin  
                plot  = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
    
    always@(posedge clk)
    begin: drawing
        if(current_state == S_DRAW && ~finished_counting)
            pixel_loc <= pixel_loc + 1;
        else
            pixel_loc <= 6'b0;
    end // state_FFS

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

// gives out color as RGB, MSB 
module get_sprite_color (
get_x,
get_y, // y input
sprite_id,
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
