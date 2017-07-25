add wave -position insertpoint  \
sim:/sha_256_read_and_hash/clk
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/rst
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/n_blocks
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/data_in
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/data_out
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/finished
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/CURRENT_STATE
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/NEXT_STATE

add wave -position insertpoint  \
sim:/sha_256_read_and_hash/input_block_reader_INST/CURRENT_STATE
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/input_block_reader_INST/NEXT_STATE
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/CURRENT_STATE
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/NEXT_STATE
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/HASH_02_COUNTER
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/msg_block_in

add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/HV
add wave -position insertpoint  \
sim:/sha_256_pkg/W

add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/a
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/b
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/c
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/d
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/e
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/f
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/g
add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/h

add wave -position insertpoint  \
sim:/sha_256_read_and_hash/sha_256_core_INST/data_out


force -freeze sim:/sha_256_read_and_hash/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/sha_256_read_and_hash/rst 1
force -freeze sim:/sha_256_read_and_hash/n_blocks 1
run 50
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000018
run 300
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100

force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100

force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100

force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h00000000
run 100
force -freeze sim:/sha_256_read_and_hash/data_in 32'h61626380
run 100


run 22500
