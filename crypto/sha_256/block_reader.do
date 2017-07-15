
add wave -position insertpoint  \
sim:/block_reader/clk
add wave -position insertpoint  \
sim:/block_reader/rst
add wave -position insertpoint  \
sim:/block_reader/en
add wave -position insertpoint  \
sim:/block_reader/CURRENT_STATE
add wave -position insertpoint  \
sim:/block_reader/NEXT_STATE
add wave -position insertpoint  \
sim:/block_reader/BLOCK_COUNTER
add wave -position insertpoint  \
sim:/block_reader/NUM_BLOCKS
force -freeze sim:/block_reader/clk 1 0, 0 {50 ns} -r 100
run 50
force -freeze sim:/block_reader/rst 1
run 500
force -freeze sim:/block_reader/en 1
run 500

force -freeze sim:/block_reader/clk 1 0, 0 {100 ns} -r 200
run 500

