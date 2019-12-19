onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_tx_testbench/clk
add wave -noupdate /uart_tx_testbench/async_nreset
add wave -noupdate -radix binary /uart_tx_testbench/data_in
add wave -noupdate /uart_tx_testbench/data_valid
add wave -noupdate -color Blue /uart_tx_testbench/data_out
add wave -noupdate -divider {internal signals}
add wave -noupdate /uart_tx_testbench/uart_tx_inst/state_reg
add wave -noupdate /uart_tx_testbench/uart_tx_inst/timer_tick
add wave -noupdate /uart_tx_testbench/uart_tx_inst/index_reg
add wave -noupdate /uart_tx_testbench/uart_tx_inst/state_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 229
configure wave -valuecolwidth 70
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1408 ns}
