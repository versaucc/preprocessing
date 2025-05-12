vlib work
vlog -sv topLevelTB.sv topLevel.sv uartInterface.sv uartReceiver.sv uartTransmitter.sv smaCalculator.sv emaCalculator.sv

vsim work.topLevelTB

# Waveform setup


add wave -divider "Global"
add wave clk
add wave reset_n

add wave -divider "UART"
add wave uart_rx
add wave uart_tx

add wave -divider "FSM State"
add wave -radix unsigned dut.state
add wave -radix unsigned dut.echo_state
add wave -radix unsigned dut.byte_phase
add wave -radix unsigned dut.byte_count
add wave -radix unsigned dut.payload_received

add wave -divider "Indicators"
add wave -radix unsigned dut.sample_out
add wave dut.sample_valid
add wave -radix unsigned dut.sma_result
add wave dut.sma_valid
add wave -radix unsigned dut.ema_result
add wave dut.ema_valid

add wave -divider "TX Echo"
add wave -radix hex dut.uart_data_in
add wave dut.uart_send
add wave dut.uart_ready

# Run simulation
run 200 us

# Optional: Save waveform
write list simulation_output.wlf