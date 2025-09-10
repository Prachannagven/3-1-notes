module car (
	input clk,
	input rst,
	input cmd_r,
	input cmd_l,
	output reg [2:0] led_r,
	output reg [2:0] led_l
);
	//Defining a command to ensure that the input signal is not changing
	//during the FSM
	
	reg is_right;
	//Defining all the states for this machine
	reg [1:0] 	state;
	parameter 	INITIAL = 2'b00,
				BLINK_1 = 2'b01,
				BLINK_2 = 2'b10,
				BLINK_3 = 2'b11;

	//Main actual FSM
	always @(posedge clk or posedge rst) begin
		//Resetting on the postive edge of the clock
		if(rst) begin
			state <= INITIAL;
		end
		else begin
			case(state)
				//Initial state, waiting for a command
				//If no command or both commands are given, stay in the initial state
				//If a command is given, go to the first blink state and store the command
				//If a different command is given while blinking, go back to the initial state
				//and store the new command
				INITIAL: begin
					led_r = 3'b000;
					led_l = 3'b000;
					if((!cmd_r && !cmd_l) || (cmd_r && cmd_l)) begin
						state <= INITIAL;
						is_right <= is_right;
					end
					else if(cmd_r) begin
						state <= BLINK_1;
						is_right <= 1'b1;
					end
					else if(cmd_l) begin
						state <= BLINK_1;
						is_right <= 1'b0;
					end
					else begin 
						state <= INITIAL; 
						is_right <= is_right; 
					end
				end
				BLINK_1: begin
					//Blinking the LEDs according to the stored command
					//If the command is the same as the stored command, continue blinking
					//If the command is different, go back to the initial state and store the new command
					//If no command is given, continue blinking
					//The blinking pattern is 001 -> 011 -> 111
					if(is_right == cmd_r && is_right) begin
						led_r = 3'b001;
						led_l = 3'b000;
						state <= BLINK_2;
					end
					else if(is_right == cmd_r && !is_right) begin
						led_r = 3'b000;
						led_l = 3'b001;
						state <= BLINK_2;
					end
					else begin
						state <= INITIAL;
						is_right <= cmd_r ? 1'b1 : 1'b0;
					end
				end
				//Again making sure that the command is the same as the stored
				//command and proceeding through the blinking process
				BLINK_2: begin
					if(is_right == cmd_r && is_right) begin
						led_r = 3'b011;
						led_l = 3'b000;
						state <= BLINK_3;
					end
					else if(is_right == cmd_r && !is_right) begin
						led_r = 3'b000;
						led_l = 3'b011;
						state <= BLINK_3;
					end
					else begin
						state <= INITIAL;
						is_right <= cmd_r ? 1'b1 : 1'b0;
					end
				end
				BLINK_3: begin
					if(is_right == cmd_r && is_right) begin
						led_r = 3'b111;
						led_l = 3'b000;
						state <= INITIAL;
					end
					else if(is_right == cmd_r && !is_right) begin
						led_r = 3'b000;
						led_l = 3'b111;
						state <= INITIAL;
					end
					else begin
						state <= INITIAL;
						is_right <= cmd_r ? 1'b1 : 1'b0;
					end
				end
				default: begin
					state <= INITIAL;
					is_right <= 1'b0;
				end
			endcase
		end
	end
endmodule

