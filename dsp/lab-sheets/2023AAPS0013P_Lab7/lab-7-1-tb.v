module tb_LFSR;
    reg CLOCK; // Clock signal
    reg RESET; // Reset signal
    wire [3:0] Q; // Output of the LFSR
    // Instantiate the LFSR module
    LFSR uut (
    .CLOCK(CLOCK),
    .RESET(RESET),
    .Q(Q)
    );
    // Clock generation (period of 10 time units)
    always begin
        #5 CLOCK = ~CLOCK; // Toggle clock every 5 time units
    end
    // Test sequence
    initial begin
    // Initialize signals
    CLOCK = 0;
    RESET = 0;
    // Apply reset
    RESET = 1; #10;
    RESET = 0; #10;
    #5;
    // Wait for some cycles to see the output pattern
    #125;
    // Finish the simulation
    $finish;
    end
    // Display output on each clock cycle
    initial begin
    $monitor("Time = %0t, RESET = %b, Q = %b", $time, RESET, Q);
    end
endmodule
