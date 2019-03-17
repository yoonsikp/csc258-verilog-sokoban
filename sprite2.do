vlib work

vlog -timescale 1ns/1ns sprite.v

vsim sprite_control

log {/*}

add wave {/*}

#force {KEY[0]} 1
#force {SW[9]} 0
#force {SW[3: 0]} 2#1010
#force {SW[7: 5]} 2#000

#clock
force {clk} 0 0, 1 5 -r 10
force {resetn} 1 0, 0 10, 1 40

force {go} 0 0, 1 60, 0 70 



run 1500ns
