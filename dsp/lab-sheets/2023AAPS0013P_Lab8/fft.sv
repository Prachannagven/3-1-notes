module fft_8_pt(
    input clk,
    input rst_n,
    input start,
    input  real real_in  [0:7],
    output real real_out [0:7],
    output real imag_out [0:7],
    output reg done
);
   //Temporary Variables for butterfly stages
   signed real inputs     [7:0];
   real butter_s1  [7:0];
   real butter_s2_r[7:0];
   real butter_s2_i[7:0];
   real butter_s3_r[7:0];
   real butter_s3_i[7:0];
   
   // Temporary variables for twiddle products
   real tw_re;
   real tw_im;

   // State machine variables
   reg [2:0] state = 3'b000;


   always @(posedge clk or negedge rst_n) begin
       if(!rst_n) begin
           done <= 0;
           state <= 3'b000;
           for (int i=0; i<8; i=i+1) begin
               real_out[i] <= 0;
               imag_out[i] <= 0;
           end
       end
       else if(start) begin
           case(state)
               3'b000: begin
                   //Stage 1 - Bit Reversal
                   inputs[0] <= real_in[0];
                   inputs[1] <= real_in[4];
                   inputs[2] <= real_in[2];
                   inputs[3] <= real_in[6];
                   inputs[4] <= real_in[1];
                   inputs[5] <= real_in[5];
                   inputs[6] <= real_in[3];
                   inputs[7] <= real_in[7];
                   state <= 3'b001;
               end

               3'b001: begin
                   //Stage 2 - First stage of Butterfly
                   butter_s1[0] <= inputs[0] + inputs[1];
                   butter_s1[1] <= inputs[0] - inputs[1];
                   butter_s1[2] <= inputs[2] + inputs[3];
                   butter_s1[3] <= inputs[2] - inputs[3];
                   butter_s1[4] <= inputs[4] + inputs[5];
                   butter_s1[5] <= inputs[4] - inputs[5];
                   butter_s1[6] <= inputs[6] + inputs[7];
                   butter_s1[7] <= inputs[6] - inputs[7];
                   state <= 3'b010;
               end

               3'b010: begin
                   //Stage 3 - Second stage of Butterfly
                   butter_s2_r[0] <= butter_s1[0] + butter_s1[2];
                   butter_s2_i[0] <= 0;
                   butter_s2_r[1] <= butter_s1[1];
                   butter_s2_i[1] <= -butter_s1[3];
                   butter_s2_r[2] <= butter_s1[0] - butter_s1[2];
                   butter_s2_i[2] <= 0;
                   butter_s2_r[3] <= butter_s1[1];
                   butter_s2_i[3] <= butter_s1[3];
                   butter_s2_r[4] <= butter_s1[4] + butter_s1[6];
                   butter_s2_i[4] <= 0;
                   butter_s2_r[5] <= butter_s1[5];
                   butter_s2_i[5] <= -butter_s1[7];
                   butter_s2_r[6] <= butter_s1[4] - butter_s1[6];
                   butter_s2_i[6] <= 0;
                   butter_s2_r[7] <= butter_s1[7];
                   butter_s2_i[7] <= butter_s1[5];
                   state <= 3'b011;
               end

               3'b011: begin
                   //Stage 4 - Final stage of butterfly
                   // X[0] = even0 + even1
                   butter_s3_r[0] <= butter_s2_r[0] + butter_s2_r[4];
                   butter_s3_i[0] <= butter_s2_i[0] + butter_s2_i[4];
                   // X[1] = even1 + odd1 * W8^1  (0.707 - j0.707)
                   tw_re = 0.707 * butter_s2_r[5] - 0.707 * butter_s2_i[5];
                   tw_im = -0.707 * butter_s2_r[5] - 0.707 * butter_s2_i[5];
                   butter_s3_r[1] <= butter_s2_r[1] + tw_re;
                   butter_s3_i[1] <= butter_s2_i[1] + tw_im;
                   // X[2] = even2 + odd2 * W8^2  (W8^2 = -j)
                   butter_s3_r[2] <= butter_s2_r[2] + butter_s2_i[6];
                   butter_s3_i[2] <= butter_s2_i[2] - butter_s2_r[6];
                   // X[3] = even3 + odd3 * W8^3  (-0.707 - j0.707)
                   tw_re = -0.707 * butter_s2_r[7] - 0.707 * butter_s2_i[7];
                   tw_im = -0.707 * butter_s2_r[7] + -0.707 * butter_s2_i[7];
                   butter_s3_r[3] <= butter_s2_r[3] + tw_re;
                   butter_s3_i[3] <= butter_s2_i[3] + tw_im;
                   // X[4] = even0 - even1
                   butter_s3_r[4] <= butter_s2_r[0] - butter_s2_r[4];
                   butter_s3_i[4] <= butter_s2_i[0] - butter_s2_i[4];
                   // X[5] = even1 - odd1 * W8^1
                   butter_s3_r[5] <= butter_s2_r[1] - tw_re;
                   butter_s3_i[5] <= butter_s2_i[1] - tw_im;
                   // X[6] = even2 - odd2 * W8^2
                   butter_s3_r[6] <= butter_s2_r[2] - butter_s2_i[6];
                   butter_s3_i[6] <= butter_s2_i[2] + butter_s2_r[6];
                   // X[7] = even3 - odd3 * W8^3
                   butter_s3_r[7] <= butter_s2_r[3] - tw_re;
                   butter_s3_i[7] <= butter_s2_i[3] - tw_im;
                   state <= 3'b100;
               end


               3'b100: begin
                  // Final outputs
                  for (int i=0; i<8; i=i+1) begin
                      real_out[i] <= butter_s3_r[i];
                      imag_out[i] <= butter_s3_i[i];
                  end
                  done <= 1;
                  state <= 3'b000; // Reset state for next operation
               end
           endcase
       end
   end
endmodule
