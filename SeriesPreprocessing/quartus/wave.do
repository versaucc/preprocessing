onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Global
add wave -noupdate /topLevelTB/clk
add wave -noupdate /topLevelTB/reset_n
add wave -noupdate -divider UART
add wave -noupdate /topLevelTB/uart_rx
add wave -noupdate /topLevelTB/uart_tx
add wave -noupdate -divider {FSM State}
add wave -noupdate -radix unsigned /topLevelTB/dut/state
add wave -noupdate -radix unsigned /topLevelTB/dut/echo_state
add wave -noupdate -radix unsigned /topLevelTB/dut/byte_phase
add wave -noupdate -radix unsigned /topLevelTB/dut/byte_count
add wave -noupdate -radix unsigned /topLevelTB/dut/payload_received
add wave -noupdate -divider Indicators
add wave -noupdate -radix unsigned /topLevelTB/dut/sample_out
add wave -noupdate /topLevelTB/dut/sample_valid
add wave -noupdate -radix unsigned /topLevelTB/dut/sma_result
add wave -noupdate /topLevelTB/dut/sma_valid
add wave -noupdate -radix unsigned /topLevelTB/dut/ema_result
add wave -noupdate /topLevelTB/dut/ema_valid
add wave -noupdate -divider {TX Echo}
add wave -noupdate -radix hexadecimal /topLevelTB/dut/uart_data_in
add wave -noupdate /topLevelTB/dut/uart_send
add wave -noupdate /topLevelTB/dut/uart_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83766579 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 232
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {230458292 ps}
