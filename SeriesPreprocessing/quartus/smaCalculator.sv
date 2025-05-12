
module smaCalculator #(
    parameter int N = 8  // Window size (must be power of 2 for shift)
)(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        valid,         // Pulse when new sample is ready
    input  logic [15:0] data_in,       // Q8.8 fixed-point input

    output logic [15:0] sma_out,       // Q8.8 average result
    output logic        output_valid   // 1-cycle pulse when output is valid
);

    logic [15:0] window [0:N-1];       // Circular buffer for last N samples
    logic [31:0] sum;                  // Running sum of N samples
    int index;                         // Current write index
    logic initialized;

    logic [15:0] next_sma;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sum <= 0;
            index <= 0;
            sma_out <= 0;
            output_valid <= 0;
            initialized <= 0;
            for (int i = 0; i < N; i++) window[i] <= 0;
        end else begin
            output_valid <= 0;

            if (valid) begin
                if (!initialized) begin
                    // Initialize buffer with first input sample
                    for (int i = 0; i < N; i++) window[i] <= data_in;
                    sum <= data_in * N;
                    index <= 1;
                    sma_out <= data_in;
                    output_valid <= 1;
                    initialized <= 1;
                end else begin
                    // Compute next sum and next average
                    sum <= sum - window[index] + data_in;
                    window[index] <= data_in;
                    index <= (index + 1) % N;

                    next_sma = (sum - window[index] + data_in) >> $clog2(N);
                    sma_out <= next_sma;
                    output_valid <= 1;
                end
            end
        end
    end

endmodule
