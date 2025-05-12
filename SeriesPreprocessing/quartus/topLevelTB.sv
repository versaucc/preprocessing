// Minimal working SystemVerilog testbench for topLevel.sv
// Simulates sending UART header + 2 samples for SMA

`timescale 1ns/1ps

module topLevelTB;

    logic clk = 0;
    logic reset_n = 0;
    logic uart_rx;
    wire  uart_tx;

    // Clock generation (50 MHz)
    always #10 clk = ~clk;

    // Instantiate DUT
    topLevel dut (
        .clk(clk),
        .reset_n(reset_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // UART simulation constants
    localparam int BAUD_PERIOD = 8680; // 1 bit @ 115200 baud (in ns)

    // Sample stream (header + 2 samples)
    logic [7:0] stream [0:15];
    integer i;

    initial begin
        // Set idle line
        uart_rx = 1;

        // Wait then reset
        #100;
        reset_n = 1;
        #100;

        // === HEADER ===
        stream[0]  = 8'h44; // release_id = 0x11223344
        stream[1]  = 8'h33;
        stream[2]  = 8'h22;
        stream[3]  = 8'h11;

        stream[4]  = 8'hDD; // series_id = 0xAABBCCDD
        stream[5]  = 8'hCC;
        stream[6]  = 8'hBB;
        stream[7]  = 8'hAA;

        stream[8]  = 8'h02; // length = 2 samples (LSB first)
        stream[9]  = 8'h00;
        stream[10] = 8'h00;
        stream[11] = 8'h00;

        // === Data (Q8.8 fixed-point) ===
        stream[12] = 8'h00; // Sample 1 = 25.0 = 0x1900
        stream[13] = 8'h19;
        stream[14] = 8'h00; // Sample 2 = 26.0 = 0x1A00
        stream[15] = 8'h1A;

        for (i = 0; i < 16; i++) begin
            send_uart_byte(stream[i]);
        end

        // Wait and end
        #200000;
        $finish;
    end

    // UART transmit simulation
	task send_uart_byte(input [7:0] data);
		 integer i;
		 begin
			  uart_rx = 0;  // Start bit
			  #(8680);

			  for (i = 0; i < 8; i++) begin
					uart_rx = data[i];
					#(8680);
			  end

			  uart_rx = 1;  // Stop bit
			  #(8680);
		 end
	endtask

endmodule
