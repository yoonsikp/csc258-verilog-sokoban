
module game_levels(
           input clock,
           input keycode,
           input reset_n,
           input w_level_complete,
           output reg ld_loading,
           output reg [3:0] ld_level_num
       );

reg [3:0] current_state, next_state;

localparam  S_INTRO = 4'd0,
            S_LEVEL_1 = 4'd1,
            S_LEVEL_1_WAIT = 4'd2,
            S_LEVEL_2 = 4'd3,
            S_LEVEL_2_WAIT = 4'd4,
            S_LEVEL_3 = 4'd5,
            S_LEVEL_3_WAIT = 4'd6,
            S_LEVEL_4 = 4'd7,
            S_OUTRO = 4'd8;

wire wkeypressed;
assign wkeypressed = (keycode != 3'b000);

always @(*)
begin: state_table
    case (current_state)
        S_INTRO: next_state = wkeypressed ? S_LEVEL_1 : S_INTRO;
        S_LEVEL_1: next_state = w_level_complete ? S_LEVEL_1_WAIT: S_LEVEL_1;
        S_LEVEL_1_WAIT: next_state = wkeypressed ? S_LEVEL_2 : S_LEVEL_1_WAIT;
        S_LEVEL_2: next_state = w_level_complete ? S_LEVEL_2_WAIT: S_LEVEL_2;
        S_LEVEL_2_WAIT: next_state = wkeypressed ? S_LEVEL_3 : S_LEVEL_2_WAIT;
        S_LEVEL_3: next_state = w_level_complete ? S_LEVEL_3_WAIT: S_LEVEL_3;
        S_LEVEL_3_WAIT: next_state = wkeypressed ? S_LEVEL_4 : S_LEVEL_3_WAIT;
        S_LEVEL_4: next_state = w_level_complete ? S_OUTRO: S_LEVEL_4;
        S_OUTRO: next_state = wkeypressed ? S_LEVEL_1 : S_OUTRO;
    endcase
end
always @(*)
begin
    // default signals are zero
    ld_level_num = 4'b0000;
    ld_loading = 1'b0;
    case (current_state)
        S_INTRO: begin
            ld_level_num = 4'b0000;
            ld_loading = 1'b1;
        end
        S_LEVEL_1: begin
            ld_level_num = 4'b0000;
        end
        S_LEVEL_1_WAIT: begin
            ld_level_num = 4'b0001;
            ld_loading = 1'b1;
        end
        S_LEVEL_2: begin
            ld_level_num = 4'b0001;
        end
        S_LEVEL_2_WAIT: begin
            ld_level_num = 4'b0010;
            ld_loading = 1'b1;
        end
        S_LEVEL_3: begin
            ld_level_num = 4'b0010;
        end
        S_LEVEL_3_WAIT: begin
            ld_level_num = 4'b0011;
            ld_loading = 1'b1;
        end
        S_LEVEL_4: begin
            ld_level_num = 4'b0011;
        end
        S_OUTRO: begin
            ld_level_num = 4'b0000;
            ld_loading = 1'b1;
        end
    endcase
end

always @(posedge clock)
begin: state_FFS
    if (!reset_n)
        current_state = S_INTRO;
    else
        current_state = next_state;
end

endmodule



    module level_handler(
        input clock,
        input ld_loading,
        input [2:0] keycode,
        input [3:0] ld_level_num,
        input reset_n,
        output reg begin_draw,
		  output reg w_level_complete,
        output [7:0] position_x,
        output [6:0] position_y,
        output reg [3:0] sprite_id
    );

// bit [2] crate bit[1:0] wall,floor,goal,black
reg [2:0] level [0:299];

reg [2:0] level1 [0:299];
initial begin
	$readmemb("level1.mem", level1);
end

reg [2:0] level2 [0:299];
initial begin
	$readmemb("level2.mem", level2);
end
reg [2:0] level3 [0:299];
initial begin
	$readmemb("level3.mem", level3);
end

reg [2:0] level4 [0:299];
initial begin
	$readmemb("level4.mem", level4);
end


reg [3:0] player_y;
reg [4:0] player_x;
reg [3:0] cur_y;
reg [4:0] cur_x;

assign position_x = {cur_x, 3'b000};
assign position_y = {cur_y, 3'b000};
wire [2:0] block_above;
wire [2:0] block_below;
wire [2:0] block_right;
wire [2:0] block_left;
assign block_above = level[player_x + 20 * (player_y - 1)];
assign block_below = level[player_x + 20 * (player_y + 1)];
assign block_right = level[player_x + 1 + 20 * (player_y)];
assign block_left = level[player_x - 1 + 20 * (player_y)];

wire [2:0] block_two_above;
wire [2:0] block_two_below;
wire [2:0] block_two_right;
wire [2:0] block_two_left;

assign block_two_above = level[player_x + 20 * (player_y - 2)];
assign block_two_below = level[player_x + 20 * (player_y + 2)];
assign block_two_right = level[player_x + 2 + 20 * (player_y)];
assign block_two_left = level[player_x - 2 + 20 * (player_y)];

reg [6:0] sprite_timer;
reg [8:0] grid_loc;
reg [8:0] copy_helper;
reg level_complete_helper;

always @(posedge clock)
begin //begin always

    if (!reset_n)
    begin
		  level_complete_helper <= 0;
        sprite_id <= 4'd0;
        begin_draw <= 0;
        grid_loc <= 9'b000000000;
        sprite_timer <= 7'b0000000;
        cur_x <= 0;
        cur_y <= 0;
		  player_y <= 4'b0000;
        player_x <= 5'b00000;
		  copy_helper <= 9'b000000000;
		  w_level_complete <= 0;
    end
	 else if (ld_loading)
	 begin
		  w_level_complete <= 0;
		  level_complete_helper <= 0;
	     grid_loc <= 9'b000000000;
        sprite_timer <= 7'b0000000;

		  if (copy_helper == 9'd0) begin
				begin_draw <= 1;
			end
			else if (copy_helper == 9'd1) begin
				begin_draw <= 0;
				sprite_id <= 4'd6;
				cur_x <= 1;
				cur_y <= 0;
			end
			else if (copy_helper == 9'd68) begin
				begin_draw <= 1;
			end
			else if (copy_helper == 9'd69) begin
				begin_draw <= 0;
				sprite_id <= 4'd7;
				cur_x <= 2;
			end
			else if (copy_helper == 9'd140) begin
				begin_draw <= 1;
			end
			else if (copy_helper == 9'd141) begin
				begin_draw <= 0;
				cur_x <= 3;
				sprite_id <= 4'd8 + ld_level_num;
			end
			else if (copy_helper == 9'd260) begin
				cur_x <= 0;
				cur_y <= 0;
			end
			
			
		  if(ld_level_num == 4'b0000) begin
				if (copy_helper < 9'b100101100) begin
					level[copy_helper] <= level1[copy_helper];
					copy_helper <= copy_helper + 1;
				end
				player_y <= 4'b1010;
				player_x <= 5'b01011;
			end
			else if(ld_level_num == 4'b0001) begin
				if (copy_helper < 9'b100101100) begin
					level[copy_helper] <= level2[copy_helper];
					copy_helper <= copy_helper + 1;
				end
				player_y <= 4'b0011;
				player_x <= 5'b01111;
			end
			else if(ld_level_num == 4'b0010) begin
				if (copy_helper < 9'b100101100) begin
					level[copy_helper] <= level3[copy_helper];
					copy_helper <= copy_helper + 1;
				end
				player_y <= 4'b1011;
				player_x <= 5'b01010;
			end
			else if(ld_level_num == 4'b0011) begin
				if (copy_helper < 9'b100101100) begin
					level[copy_helper] <= level4[copy_helper];
					copy_helper <= copy_helper + 1;
				end
				player_y <= 4'b1000;
				player_x <= 5'b01111;
			end
			
//
	 end
	 else if (~ld_loading)
	 begin
			copy_helper <= 9'b000000000;
			 if (grid_loc < 9'b100101100)
			 begin
				  if (sprite_timer == 7'b0000000)
				  begin
						//player model
						if ( (cur_x == player_x) && (cur_y == player_y))
							 sprite_id <= 4'b0010;
						//goal and crate
						else if (level[grid_loc] == 3'b110)
							 sprite_id <= 4'b0101;
						//floor and crate
						else if (level[grid_loc] == 3'b101)
						begin
							level_complete_helper <= 0;
							 sprite_id <= 4'b0001;
						end
						//wall,floor,goal,black
						else if (level[grid_loc][1:0] == 2'b00)
							 sprite_id <= 4'b0000;
						else if (level[grid_loc][1:0] == 2'b01)
							 sprite_id <= 4'b0011;
						else if (level[grid_loc][1:0] == 2'b10)
							 sprite_id <= 4'b0100;
						else if (level[grid_loc][1:0] == 2'b11)
							 sprite_id <= 4'b1100;
						sprite_timer <= sprite_timer + 1;
				  end
				  else if (sprite_timer == 7'b0000001) begin
						sprite_timer <= sprite_timer + 1;
						begin_draw <= 1;
				  end
				  else if (sprite_timer == 7'b0000010) begin
						sprite_timer <= sprite_timer + 1;
						begin_draw <= 0;
				  end
				  else if (sprite_timer == 7'b1000100)
				  begin
						if (cur_x == 8'd19) begin
							 cur_x <= 8'b00000000;
							 cur_y <= cur_y + 1;
						end
						else
							 cur_x <= cur_x + 1;
						sprite_timer <= 7'b0000000;
						grid_loc <= grid_loc + 1;
				  end
				  else
				  begin
						begin_draw <= 0;
						sprite_timer <= sprite_timer + 1;
				  end
					
					if (grid_loc == 9'b100101011)
						w_level_complete <= level_complete_helper;
				  // check if it works
			 end
		
			 else if ((keycode != 3'b000))
			 begin //keypress
	
				  if(keycode == 3'b001) //going up
				  begin
						//check if empty space no crate
						if ((block_above[2] == 0) && (block_above[1:0] != 2'b00))
						begin
							 player_y <= player_y - 1;
						end
						// check if block with pushable space
						else if ((block_above[2] == 1) && (block_two_above[1:0] != 2'b00) && (block_two_above[2] != 1) )
						begin
							 player_y <= player_y - 1;
							 level[player_x + 20 * (player_y - 1)][2] <= 0;
							 level[player_x + 20 * (player_y - 2)][2] <= 1;
						end
				  end //finish up checking
		
		
				  else if(keycode == 3'b010) //right
				  begin
						//check if empty space no crate
						if ((block_right[2] == 0) && (block_right[1:0] != 2'b00))
						begin
							 player_x <= player_x + 1;
						end
						// check if block with pushable space
						else if ((block_right[2] == 1) && (block_two_right[1:0] != 2'b00) && (block_two_right[2] != 1) )
						begin
							 player_x <= player_x + 1;
							 level[player_x + 1 + 20 * (player_y)][2] <= 0;
							 level[player_x + 2 + 20 * (player_y)][2] <= 1;
						end
				  end//finish right checking
		
		
				  else if(keycode == 3'b011) //down
				  begin
						//check if empty space no crate
						if ((block_below[2] == 0) && (block_below[1:0] != 2'b00))
						begin
							 player_y <= player_y + 1;
						end
						// check if block with pushable space
						else if ((block_below[2] == 1) && (block_two_below[1:0] != 2'b00) && (block_two_below[2] != 1) )
						begin
							 player_y <= player_y + 1;
							 level[player_x + 20 * (player_y + 1)][2] <= 0;
							 level[player_x + 20 * (player_y + 2)][2] <= 1;
						end
				  end //finish down checking
		
		
				  else if(keycode == 3'b100) //left
				  begin
						//check if empty space no crate
						if ((block_left[2] == 0) && (block_left[1:0] != 2'b00))
						begin
							 player_x <= player_x - 1;
						end
						// check if block with pushable space
						else if ((block_left[2] == 1) && (block_two_left[1:0] != 2'b00) && (block_two_left[2] != 1) )
						begin
							 player_x <= player_x - 1;
							 level[player_x - 1 + 20 * (player_y)][2] <= 1'b0;
							 level[player_x - 2 + 20 * (player_y)][2] <= 1;
						end
				  end //finish left checking
				  grid_loc <= 9'b000000000;
				  sprite_timer <= 7'b0000000;
				  level_complete_helper <= 1;
				  cur_x <= 0;
				  cur_y <= 0;
		
			 end //keypress


     end

end

endmodule

