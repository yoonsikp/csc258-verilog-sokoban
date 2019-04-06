module finalproject(
           input CLOCK_50,                     //  On Board 50 MHz
           input [3:0] KEY,
           input [9:0] SW,
           input PS2_CLK,
           input PS2_DAT,
           output [6:0] HEX0,
           output [6:0] HEX1,
           // The ports below are for the VGA output.  Do not change.
           output VGA_CLK,                         //  VGA Clock
           output VGA_HS,                          //  VGA H_SYNC
           output VGA_VS,                          //  VGA V_SYNC
           output VGA_BLANK_N,                 //  VGA BLANK
           output VGA_SYNC_N,                      //  VGA SYNC
           output [9:0] VGA_R,                         //  VGA Red[9:0]
           output [9:0] VGA_G,                         //  VGA Green[9:0]
           output [9:0] VGA_B                          //  VGA Blue[9:0]
       );

wire resetn;
assign resetn = KEY[0];

// Create the colour, x, y and writeEn wires that are inputs to the controller.
wire [3:0] w_sprite_id;
wire [7:0] w_x;
wire [6:0] w_y;
wire w_begin_draw;


sprite_draw spriteD(
                .resetn(resetn),
                .clk(CLOCK_50),
                .x_in(w_x),
                .y_in(w_y),
                .begin_draw(w_begin_draw),
                .sprite_id_in(w_sprite_id),
                /* Signals for the DAC to drive the monitor. */
                .VGA_R(VGA_R),
                .VGA_G(VGA_G),
                .VGA_B(VGA_B),
                .VGA_HS(VGA_HS),
                .VGA_VS(VGA_VS),
                .VGA_BLANK(VGA_BLANK_N),
                .VGA_SYNC(VGA_SYNC_N),
                .VGA_CLK(VGA_CLK));

wire [2:0] wkeycode;
keyboard_input kinp(
                   .KEY(KEY),
                   .clk(CLOCK_50),
                   .PS2_DAT(PS2_DAT),
                   .PS2_CLK(PS2_CLK),
                   .resetn(resetn),
                   .keycode(wkeycode),
               );


wire w_ld_loading;
wire [3:0] w_ld_level_num;
wire w_level_complete;

hex_decoder hone(
                .hex_digit({2'b00, w_ld_level_num[1:0]} + 1),
                .segments(HEX0)

            );

hex_decoder htwo(
                .hex_digit({2'b00, w_ld_level_num[3:2]} + 1),
                .segments(HEX1)

            );

wire w_level_complete_enh;
assign w_level_complete_enh = ~KEY[2] || w_level_complete;
wire w_ld_loading_enh;
assign w_ld_loading_enh = ~KEY[1] || w_ld_loading;

game_levels game(
                .clock(CLOCK_50),
                .keycode(wkeycode),
                .reset_n(resetn),
                .ld_loading(w_ld_loading),
                .ld_level_num(w_ld_level_num),
                .w_level_complete(w_level_complete_enh)
            );


level_handler lhp(
                    .clock(CLOCK_50),
                    .ld_loading(w_ld_loading_enh),
                    .keycode(wkeycode),
                    .ld_level_num(w_ld_level_num),
                    .w_level_complete(w_level_complete),
                    .reset_n(resetn),
                    .begin_draw(w_begin_draw),
                    .position_x(w_x),
                    .position_y(w_y),
                    .sprite_id(w_sprite_id)
                );
endmodule


    module hex_decoder(hex_digit, segments);
input [3:0] hex_digit;
output reg [6:0] segments;

always @(*)
case (hex_digit)
    4'h0: segments = 7'b100_0000;
    4'h1: segments = 7'b111_1001;
    4'h2: segments = 7'b010_0100;
    4'h3: segments = 7'b011_0000;
    4'h4: segments = 7'b001_1001;
    4'h5: segments = 7'b001_0010;
    4'h6: segments = 7'b000_0010;
    4'h7: segments = 7'b111_1000;
    4'h8: segments = 7'b000_0000;
    4'h9: segments = 7'b001_1000;
    4'hA: segments = 7'b000_1000;
    4'hB: segments = 7'b000_0011;
    4'hC: segments = 7'b100_0110;
    4'hD: segments = 7'b010_0001;
    4'hE: segments = 7'b000_0110;
    4'hF: segments = 7'b000_1110;
    default: segments = 7'h7f;
endcase
endmodule
