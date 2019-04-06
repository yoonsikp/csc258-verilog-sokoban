vlib work

vlog -timescale 1ns/1ns multi_input.v
vlog keyboard_inner_driver.v
vlog keyboard_press_driver.v
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
force {PS2_DAT} 0
force {PS2_CLK} 0 0, 1 500 -r 1000
force {KEY} 2#0010 0, 2#0000 100, 2#0010 200, 2#0000 500, 2#0010 600, 2#0000 1000, 2#0010 1100, 2#0000 10000



run 15000ns
