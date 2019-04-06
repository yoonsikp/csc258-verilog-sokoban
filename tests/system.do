vlib work

vlog -timescale 1ns/1ns system.v
vsim levelhodgepodge

log {/*}

add wave {/*}

#force {KEY[0]} 1
#force {SW[9]} 0
#force {SW[3: 0]} 2#1010
#force {SW[7: 5]} 2#000

#clock
force {clock} 0 0, 1 5 -r 10
force {ld_level_accept} 1
force {ld_loading} 0

force {reset_n} 1 0, 0 10, 1 40
force {w_level_complete} 0
run 3500ns
