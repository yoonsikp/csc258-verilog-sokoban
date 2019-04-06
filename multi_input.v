
module keyboard_input (
           input [3:0] KEY,
           input clk,
           input PS2_DAT,
           input PS2_CLK,
           input resetn,
           output reg [2:0] keycode
       );

wire wvalid;
wire wmakeBreak;
wire [7:0] woutcode;

keyboard_press_driver kpd(
                          .CLOCK_50(clk),
                          .valid(wvalid),
                          .makeBreak(wmakeBreak),
                          .outCode(woutcode),
                          .PS2_DAT(PS2_DAT), // PS2 data line
                          .PS2_CLK(PS2_CLK), // PS2 clock line
                          .reset(~resetn)
                      );

wire wtrulyvalid;
assign wtrulyvalid = wvalid && wmakeBreak;

always @(posedge clk)
begin
    if (!resetn) keycode <= 3'b000;
    else if ( wtrulyvalid && woutcode == 8'h74 )
        keycode <= 3'b010;
    else if ( wtrulyvalid && woutcode == 8'h6B ) 
        keycode <= 3'b100;
    else if (wtrulyvalid && woutcode == 8'h72 ) 
        keycode <= 3'b011;
    else if (wtrulyvalid && woutcode == 8'h75)
        keycode <= 3'b001;
	 else
       keycode <= 3'b000;
end
endmodule


