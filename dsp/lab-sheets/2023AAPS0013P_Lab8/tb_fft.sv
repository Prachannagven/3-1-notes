`timescale 1ns/1ps

module fft_tb;
    reg clk;
    reg rst_n;
    reg start;
    real real_in[0:7];
    wire real real_out[0:7];
    wire real imag_out[0:7];
    wire done;

    // Instantiate DUT
    fft_8_pt dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .real_in(real_in),
        .real_out(real_out),
        .imag_out(imag_out),
        .done(done)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    initial begin
        // Init
        rst_n = 0;
        start = 0;
        #20;
        rst_n = 1;

        // Provide some simple input
        real_in[0] = 1.0;
        real_in[1] = 0.0;
        real_in[2] = 0.0;
        real_in[3] = 0.0;
        real_in[4] = 0.0;
        real_in[5] = 0.0;
        real_in[6] = 0.0;
        real_in[7] = 0.0;

        // Pulse start
        #10 start = 1;
        #10 start = 0;

        // Wait for either done OR 100 clocks
        fork
            begin
                wait(done == 1);
                $display("✅ FFT completed (done=1).");
            end
            begin
                repeat(100) @(posedge clk);
                $display("⚠️ Timeout: 100 cycles elapsed, done not asserted.");
            end
        join_any
        disable fork;

        // Display results (whatever we have)
        $display("FFT Results:");
        for (integer i=0; i<8; i=i+1) begin
            $display("X[%0d] = %f + j%f", i, real_out[i], imag_out[i]);
        end

        $finish;
    end
endmodule

