onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_conv_alu/input
add wave -noupdate /tb_conv_alu/UUT/conv_opr
add wave -noupdate /tb_conv_alu/UUT/input_img
add wave -noupdate /tb_conv_alu/UUT/input_kn
add wave -noupdate /tb_conv_alu/UUT/output
add wave -noupdate /tb_conv_alu/UUT/conv_img
add wave -noupdate /tb_conv_alu/UUT/conv_kn
add wave -noupdate /tb_conv_alu/UUT/mult
add wave -noupdate /tb_conv_alu/UUT/added
add wave -noupdate /tb_conv_alu/output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 212
configure wave -valuecolwidth 256
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {99 ns}
