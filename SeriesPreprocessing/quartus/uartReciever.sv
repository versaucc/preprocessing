
module uartReciever #(
    parameter CLOCK_FREQ = 50000000,  // 50 MHz system clock
    parameter BAUD_RATE  = 115200
)(
    input  logic clk,
    input  logic reset_n,
    input  logic rx,                  // UART RX line (from PC)

    output logic [7:0] data_out,      // Received byte
    output logic       data_valid     // 1-cycle pulse when byte is ready
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
    logic [7:0]  rx_shift;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data_out <= 0;
            data_valid <= 0;
        end else begin
            data_valid <= 0;  // default

            case (state)
                IDLE: begin
                    if (rx == 0) begin  // Start bit detected
                        state <= START_BIT;
                        clk_count <= 0;
                    end
                end

                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state <= DATA_BITS;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA_BITS: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;
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
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        data_out <= rx_shift;
                        data_valid <= 1;
                        state <= CLEANUP;
                        clk_count <= 0;
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