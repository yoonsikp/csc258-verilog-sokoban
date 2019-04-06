vlib work

vlog -timescale 1ns/1ns multi_input.v
vsim keyencoder

log {/*}

add wave {/*}

#force {KEY[0]} 1
#force {SW[9]} 0
#force {SW[3: 0]} 2#1010
#force {SW[7: 5]} 2#000

#clock
force {clk} 0 0, 1 5 -r 10
force {resetn} 1 0, 0 10, 1 40

force {KEY} 2#010 0, 2#000 100, 2#010 200, 2#000 500, 2#010 600, 2#000 1000, 2#010 1100, 2#000 10000



run 15000ns
