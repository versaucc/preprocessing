# UART TX (FPGA → PC)
set_location_assignment PIN_AF14 -to uart_tx
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to uart_tx

# UART RX (PC → FPGA)
set_location_assignment PIN_AE14 -to uart_rx
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to uart_rx

module topLevel (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        uart_rx,
    output logic        uart_tx
);

    // === FSM States ===
    typedef enum logic [2:0] {
        IDLE, HEADER, PAYLOAD, DONE
    } state_t;

    state_t state;

    logic [7:0]  byte_buf[0:11];
    logic [31:0] release_id, series_id, length;
    logic [15:0] sample_word;
    logic [15:0] sample_out;
    logic        sample_valid;
    logic        byte_phase;

    int byte_count;
    int payload_received;

    // === SMA & EMA ===
    logic [15:0] sma_result, ema_result;
    logic sma_valid, ema_valid;

    smaCalculator sma (
        .clk(clk),
        .valid(sample_valid),
        .data_in(sample_out),
        .sma_out(sma_result),
        .output_valid(sma_valid)
    );

    emaCalculator ema (
        .clk(clk),
		  .reset_n(reset_n), 
        .valid(sample_valid),
        .data_in(sample_out),
        .ema_out(ema_result),
        .output_valid(ema_valid)
    );

    // === UART Interface ===
    logic [7:0] uart_data_out;
    logic       uart_valid;
    logic [7:0] uart_data_in;
    logic       uart_send;
    logic       uart_ready;

    uartInterface uart (
        .clk(clk),
        .reset_n(reset_n),
        .rx(uart_rx),
        .tx(uart_tx),
        .data_out(uart_data_out),
        .data_valid(uart_valid),
        .send(uart_send),
        .data_in(uart_data_in),
        .tx_ready(uart_ready)
    );

    // === Echo FSM ===
    typedef enum logic [1:0] {
        ECHO_IDLE, ECHO_LSB, ECHO_MSB
    } echo_state_t;

    echo_state_t echo_state;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            byte_count <= 0;
            payload_received <= 0;
            sample_valid <= 0;
            byte_phase <= 0;
            echo_state <= ECHO_IDLE;
            uart_send <= 0;
        end else begin
            sample_valid <= 0;
            uart_send <= 0;

            // === Frame Receive FSM ===
            case (state)
                IDLE: begin
                    if (uart_valid) begin
                        byte_buf[0] <= uart_data_out;
                        byte_count <= 1;
                        state <= HEADER;
                    end
                end

                HEADER: begin
                    if (uart_valid) begin
                        byte_buf[byte_count] <= uart_data_out;
                        byte_count++;

                        if (byte_count == 11) begin
                            release_id <= {byte_buf[3], byte_buf[2], byte_buf[1], byte_buf[0]};
                            series_id  <= {byte_buf[7], byte_buf[6], byte_buf[5], byte_buf[4]};
                            length     <= {byte_buf[11], byte_buf[10], byte_buf[9], byte_buf[8]};
                            payload_received <= 0;
                            byte_phase <= 0;
                            state <= PAYLOAD;
                        end
                    end
                end

                PAYLOAD: begin
                    if (uart_valid) begin
                        if (byte_phase == 0) begin
                            sample_word[7:0] <= uart_data_out;
                            byte_phase <= 1;
                        end else begin
                            sample_word[15:8] <= uart_data_out;
                            byte_phase <= 0;
                            payload_received++;

                            sample_out <= sample_word;
                            sample_valid <= 1;

                            if (payload_received + 1 == length) begin
                                state <= DONE;
                            end
                        end
                    end
                end

                DONE: begin
                    state <= IDLE;
                    byte_count <= 0;
                end
            endcase

            // === Echo FSM for SMA ===
            case (echo_state)
                ECHO_IDLE: begin
                    if (sma_valid && uart_ready) begin
                        uart_data_in <= sma_result[7:0];  // LSB first
                        uart_send <= 1;
                        echo_state <= ECHO_LSB;
                    end
                end

                ECHO_LSB: begin
                    if (uart_ready) begin
                        uart_data_in <= sma_result[15:8];  // MSB
                        uart_send <= 1;
                        echo_state <= ECHO_MSB;
                    end
                end

                ECHO_MSB: begin
                    if (uart_ready) begin
                        echo_state <= ECHO_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
			