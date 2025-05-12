
module smaCalculator #(
    parameter int N = 8  // Window size (power of 2 recommended)
)(
    input  logic        clk,
    input  logic        valid,         // Pulse when new sample is ready
    input  logic [15:0] data_in,       // Q8.8 fixed-point input

    output logic [15:0] sma_out,       // Q8.8 average result
    output logic        output_valid   // 1-cycle pulse when output is valid
);

    logic [15:0] window [0:N-1];       // Circular buffer
    logic [31:0] sum;                  // Running sum
    int index;                         // Current write index
    logic initialized;

    always_ff @(posedge clk) begin
        output_valid <= 0;

        if (valid) begin
            if (!initialized) begin
                for (int i = 0; i < N; i++) window[i] <= 0;
                sum <= 0;
                index <= 0;
                initialized <= 1;
            end else begin
                // Subtract old value
                sum <= sum - window[index];
                // Add new value
                window[index] <= data_in;
                sum <= sum + data_in;
                // Move index
                index <= (index + 1) % N;
                // Output average (sum >> log2(N) if N is power of 2)
                sma_out <= sum >> $clog2(N);  // Division by N
                output_valid <= 1;
            end
        end
    end

endmodule