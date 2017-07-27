//This file simulates hashing the message "abc", a message of 24 bits.

add wave -position insertpoint  \
sim:/sha_512_core/clk
add wave -position insertpoint  \
sim:/sha_512_core/rst
add wave -position insertpoint  \
sim:/sha_512_core/data_ready
add wave -position insertpoint  \
sim:/sha_512_core/n_blocks
add wave -position insertpoint  \
sim:/sha_512_core/msg_block_in
add wave -position insertpoint  \
sim:/sha_512_core/data_out
add wave -position insertpoint  \
sim:/sha_512_core/finished

add wave -position insertpoint  \
sim:/sha_512_core/CURRENT_STATE
add wave -position insertpoint  \
sim:/sha_512_core/NEXT_STATE
add wave -position insertpoint  \
sim:/sha_512_core/HASH_02_COUNTER

add wave -position insertpoint  \
sim:/sha_512_core/HV
add wave -position insertpoint  \
sim:/sha_512_pkg/W

add wave -position insertpoint  \
sim:/sha_512_core/a
add wave -position insertpoint  \
sim:/sha_512_core/b
add wave -position insertpoint  \
sim:/sha_512_core/c
add wave -position insertpoint  \
sim:/sha_512_core/d
add wave -position insertpoint  \
sim:/sha_512_core/e
add wave -position insertpoint  \
sim:/sha_512_core/f
add wave -position insertpoint  \
sim:/sha_512_core/g
add wave -position insertpoint  \
sim:/sha_512_core/h


force -freeze sim:/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/rst 1
force -freeze sim:/n_blocks 1
run 250
force -freeze sim:/msg_block_in 1024'h6162638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018
force -freeze sim:/sha_512_core/data_ready 1
run 100
force -freeze sim:/sha_512_core/data_ready 0
run 22500