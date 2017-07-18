add wave -position insertpoint  \
sim:/block_reader/clk
add wave -position insertpoint  \
sim:/block_reader/rst
add wave -position insertpoint  \
sim:/block_reader/en
add wave -position insertpoint  \
sim:/block_reader/data_in
add wave -position insertpoint  \
sim:/block_reader/data
add wave -position insertpoint  \
sim:/block_reader/data_out
add wave -position insertpoint  \
sim:/block_reader/CURRENT_STATE
add wave -position insertpoint  \
sim:/block_reader/NEXT_STATE
add wave -position insertpoint  \
sim:/block_reader/BLOCK_COUNTER
add wave -position insertpoint  \
sim:/block_reader/NUM_BLOCKS
add wave -position insertpoint  \
sim:/block_reader/valid
force -freeze sim:/block_reader/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/block_reader/rst 1
run 50
force -freeze sim:/block_reader/en 1
force -freeze sim:/block_reader/data_in 32'hDEADFACE
run 200
force -freeze sim:/block_reader/data_in 32'h00000ACE
run 100
force -freeze sim:/block_reader/data_in 32'h0000000A
run 100
force -freeze sim:/block_reader/data_in 32'h000000FF
run 100
force -freeze sim:/block_reader/data_in 32'h00000800
run 100
force -freeze sim:/block_reader/data_in 32'h000E0000
run 100
force -freeze sim:/block_reader/data_in 32'h11111111
run 100
run 1700

