module finalproject(
    input CLOCK_50,                     //  On Board 50 MHz
    input [3:0] KEY,
    input [9:0] SW,
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
    wire [2:0] w_sprite_id;
    assign w_sprite_id = SW[9:7];

    wire [7:0] w_x;
    assign w_x = {1'b0, SW[6:0]};

    wire [6:0] w_y;
    assign w_y = SW[6:0];

    wire w_begin_draw;
    assign w_begin_draw = KEY[1];
    

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
    
endmodule




