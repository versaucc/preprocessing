
module uartInterface #(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE  = 115200
)(
    input  logic        clk,
    input  logic        reset_n,

    // UART physical lines
    input  logic        rx,           // UART RX from PC
    output logic        tx,           // UART TX to PC

    // RX interface
    output logic [7:0]  data_out,     // Received byte
    output logic        data_valid,   // Pulse when new byte arrives

    // TX interface
    input  logic        send,         // Pulse to send a byte
    input  logic [7:0]  data_in,      // Byte to send
    output logic        tx_ready      // High when TX is ready
);

    // === Instantiate RX ===
    uartReceiver #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    // === Instantiate TX ===
    uartTransmitter #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk(clk),
        .reset_n(reset_n),
        .send(send),
        .data_in(data_in),
        .tx(tx),
        .ready(tx_ready)
    );

endmodule