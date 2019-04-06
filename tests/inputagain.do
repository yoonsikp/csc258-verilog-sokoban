vlib work

vlog -timescale 1ns/1ns multi_input.v
vlog -timescale 1ns/1ns keyboard_inner_driver.v
vlog -timescale 1ns/1ns keyboard_press_driver.v
vsim multi_input

log {/*}

add wave {/*}

#force {KEY[0]} 1
#force {SW[9]} 0
#force {SW[3: 0]} 2#1010
#force {SW[7: 5]} 2#000

#clock
force {clk} 0 0, 1 5 -r 10
force {resetn} 1 0, 0 10, 1 40
force {KEY[3: 0]} 2#1111 0, 2#1110 50, 2#1111 867, 2#1011 1450, 2#1111 2467




run 3500ns
