onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rmodule_prediction/clk
add wave -noupdate /rmodule_prediction/async_nreset
add wave -noupdate /rmodule_prediction/data_in
add wave -noupdate /rmodule_prediction/valid
add wave -noupdate -radix binary /rmodule_prediction/data_out
add wave -noupdate /rmodule_prediction/parity
add wave -noupdate -color White /rmodule_prediction/more
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix binary /rmodule_prediction/expected_output
add wave -noupdate /rmodule_prediction/expected_parity
add wave -noupdate -color White /rmodule_prediction/expected_more
add wave -noupdate /rmodule_prediction/entered
add wave -noupdate /rmodule_prediction/do_prediction
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {61529 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 224
configure wave -valuecolwidth 73
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {93006 ps}
