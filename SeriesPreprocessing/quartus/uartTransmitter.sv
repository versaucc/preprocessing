
module uartTransmitter #(
    parameter CLOCK_FREQ = 50000000,   // 50 MHz system clock
    parameter BAUD_RATE  = 115200
)(
    input  logic       clk,
    input  logic       reset_n,

    input  logic       send,           // Pulse to start sending data
    input  logic [7:0] data_in,        // Byte to send

    output logic       tx,             // UART TX line
    output logic       ready           // 1 when transmitter is idle
);

    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        CLEANUP
    } state_t;

    state_t state;
    logic [15:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  tx_data;

    assign ready = (state == IDLE);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            tx <= 1;  // idle is high
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    if (send) begin
                        tx_data <= data_in;
                        state <= START_BIT;
                        clk_count <= 0;
                    end
                end

                START_BIT: begin
                    tx <= 0;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                        bit_index <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA_BITS: begin
                    tx <= tx_data[bit_index];
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        if (bit_index == 7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP_BIT: begin
                    tx <= 1;
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= CLEANUP;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                CLEANUP: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
	