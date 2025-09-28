module moving_average (
    input wire clk,
    input wire rst,
    input wire data_in,
    output reg [2:0] sum_out,
    output reg [3:0] moving_avg
);

    reg [3:0] shift_reg [3:0]; // 4-bit shift register to hold last 4 samples
    integer i;
    reg [2:0] sum; // 3-bit sum of the last 4 samples

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1) begin
                shift_reg[i] <= 4'b0001; //Initializing to 0001 on reset
            end
            sum <= 0;
            sum_out <= 0;
            moving_avg <= 0;
        end 
        else begin
            // Shift in new data
            shift_reg[0] <= data_in;
            for (i = 1; i < 4; i = i + 1) begin
                shift_reg[i] <= shift_reg[i - 1];
            end
            // Calculate sum of the last 4 samples
            sum <= shift_reg[0] + shift_reg[1] + shift_reg[2] + shift_reg[3];
            sum_out <= sum;
            moving_avg <= sum >> 2; // Divide by 4 using right shift
        end
    end
endmodule
