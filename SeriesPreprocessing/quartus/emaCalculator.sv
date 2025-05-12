
module emaCalculator #(
    parameter logic [15:0] ALPHA = 16'd64  // Q8.8 for alpha = 0.25
)(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        valid,         // Pulse when new sample is ready
    input  logic [15:0] data_in,       // Q8.8 fixed-point

    output logic [15:0] ema_out,       // Q8.8 EMA output
    output logic        output_valid   // 1-cycle pulse
);

    logic [15:0] ema_reg;
    logic initialized;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ema_reg <= 0;
            ema_out <= 0;
            output_valid <= 0;
            initialized <= 0;
        end else begin
            output_valid <= 0;

            if (valid) begin
                if (!initialized) begin
                    ema_reg <= data_in;
                    ema_out <= data_in;
                    initialized <= 1;
                    output_valid <= 1;
                end else begin
                    logic signed [16:0] diff;
                    logic signed [31:0] temp;
                    logic signed [15:0] ema_next;

                    diff = $signed(data_in) - $signed(ema_reg);
                    temp = diff * $signed(ALPHA);
                    ema_next = $signed(ema_reg) + (temp >>> 8);  // Q8.8

                    ema_reg <= ema_next;
                    ema_out <= ema_next;
                    output_valid <= 1;
                end
            end
        end
    end

endmodule