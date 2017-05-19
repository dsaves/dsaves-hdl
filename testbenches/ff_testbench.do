
add wave -position insertpoint  \
sim:/ff/clk
add wave -position insertpoint  \
sim:/ff/i
add wave -position insertpoint  \
sim:/ff/o
force -freeze sim:/ff/clk 1 0, 0 {50 ns} -r 100
run 50
force -freeze sim:/ff/i 1 0, 0 {100 ns} -r 200
run 500

force -freeze sim:/ff/clk 1 0, 0 {100 ns} -r 200
force -freeze sim:/ff/i 1 0, 0 {50 ns} -r 100
run 500

