module tb_moving_average_filter;
reg CLK;
reg RESET;
reg DATA_IN;
wire [2:0] SUM_OUT;
wire [31:0] MOVING_AVG;
// Instantiate the DUT (Design Under Test)
moving_average_filter DUT (
.CLK(CLK),
.RESET(RESET),
.DATA_IN(DATA_IN),
.SUM_OUT(SUM_OUT),
.MOVING_AVG(MOVING_AVG)
);
// Clock generation (50 MHz clock, period = 20ns)
always begin
#10 CLK = ~CLK; // Toggle clock every 10ns
end
// Stimulus generation
initial begin
// Initialize signals
CLK = 0;
RESET = 0;
DATA_IN = 0;
#10;
// Apply reset
$display("Applying reset...");
RESET = 1; // Assert reset
#20;
RESET = 0; // Deassert reset
$display("Reset deasserted. Starting test.");
// Test data inputs (single bit at a time)
#20 DATA_IN = 1; // Input 1
#20 DATA_IN = 1; // Input 1
#20 DATA_IN = 1; // Input 1
#20 DATA_IN = 1; // Input 1
// At this point, the shift register contains: 1111 (all ones)
// Continue
// Sending 0's to the shift register
#20 DATA_IN = 0; // Input 0
#20 DATA_IN = 0; // Input 0
#20 DATA_IN = 0; // Input 0
#20 DATA_IN = 0; // Input 0
// At this point, the shift register is all zeros: 0000
// Sending a pattern
#20 DATA_IN = 1; // Input 1
#20 DATA_IN = 0; // Input 0
#20 DATA_IN = 1; // Input 1
#20 DATA_IN = 0; // Input 0
// Observe results for 40ns
#40;
$finish;
end
// Monitor outputs
initial begin
$monitor("Time = %0t | DATA_IN = %b | SUM_OUT = %b | MOVING_AVG = %d", $time, DATA_IN,
SUM_OUT, MOVING_AVG);
end
endmodule
