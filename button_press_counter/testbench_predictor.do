onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /testbench_predictor/clk
add wave -noupdate -label rst /testbench_predictor/rst
add wave -noupdate -label activator /testbench_predictor/activator
add wave -noupdate -label buttons /testbench_predictor/buttons
add wave -noupdate -label equalizer /testbench_predictor/equalizer
add wave -noupdate -label display -radix hexadecimal /testbench_predictor/display
add wave -noupdate -label display_predicted -radix hexadecimal /testbench_predictor/display_predicted
add wave -noupdate -label indicator /testbench_predictor/indicator
add wave -noupdate -label indicator_predicted /testbench_predictor/indicator_predicted
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 1000
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1 ns}
