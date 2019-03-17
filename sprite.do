vlib work

vlog -timescale 1ns/1ns sprite.v

vsim get_sprite_color

log {/*}

add wave {/*}

#force {KEY[0]} 1
#force {SW[9]} 0
#force {SW[3: 0]} 2#1010
#force {SW[7: 5]} 2#000

#clock
force {sprite_id} 1

# fix A values
force {get_x} 2#000 0, 2#001 90, 2#010 180, 2#011 270, 2#100 360, 2#101 450, 2#110 540, 2#111 630 -r 720

force {get_y} 2#000 0, 2#001 720, 2#010 1440


run 2500ns
