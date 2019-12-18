onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /testbench_waveform/clk
add wave -noupdate -label rst /testbench_waveform/rst
add wave -noupdate -label activator /testbench_waveform/activator
add wave -noupdate -label buttons /testbench_waveform/buttons
add wave -noupdate -label equalizer /testbench_waveform/equalizer
add wave -noupdate -label display -radix hexadecimal /testbench_waveform/display
add wave -noupdate -label indicator /testbench_waveform/indicator
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
WaveRestoreZoom {0 ps} {225750 ps}
