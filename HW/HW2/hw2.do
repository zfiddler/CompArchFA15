vlog -reportprogress 300 -work work multiplexer.v decoder.v adder.v
#vsim -voptargs="+acc" testDecoder
#add wave -position insertpoint \
sim:/testDecoder/addr0 \
#sim:/testDecoder/addr1 \
#sim:/testDecoder/enable \
#sim:/testDecoder/out0 \
#sim:/testDecoder/out1 \
#sim:/testDecoder/out2 \
#sim:/testDecoder/out3


#vsim -voptargs="+acc" testFullAdder
#add wave -position insertpoint \
sim:/testFullAdder/a \
sim:/testFullAdder/b \
sim:/testFullAdder/carryin \
sim:/testFullAdder/sum \
sim:/testFullAdder/carryout

vsim -voptargs="+acc" testMultiplexer
add wave -position insertpoint \
sim:/testMultiplexer/addr0 \
sim:/testMultiplexer/addr1 \
sim:/testMultiplexer/out 

run -all
wave zoom full