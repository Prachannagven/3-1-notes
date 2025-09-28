module LFSR(
	input clk,
	input rst,
	output reg [3:0] q
);
	reg feedback = 1'b0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 4'b0001; // Initial state
        end else begin
            // Feedback polynomial x^4 + x + 1, so XOR-ing cells 0 and 3
            feedback <= q[3] ^ q[0]; 
            // Shifting this into the register on the next clock cycle
            q <= {q[2:0], feedback}; 
        end
    end

endmodule
