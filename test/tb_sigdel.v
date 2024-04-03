`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UA Kempten
// Engineer: Joerg Vollrath
// 
// Create Date: 03/20245
// Design Name: sig del
// Module Name: tb_sigdel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Run time for sync2 filter: 400 us
//   All submodules are tested
// pwm: cycle run time 1.3ms
// syn2:
//    sampling every 4th clock cycle 
//    OSR 16
//    New possible output value change: 20ns * 4 * 16 1.28 us
//////////////////////////////////////////////////////////////////////////////////


module tb_sigdel();

reg clk = 1;
reg rst_n = 1;
reg [7:0] inp ;
wire [7:0] out;
wire [7:0] outx;
wire [7:0] outXa;
wire [15:0] outs0;
wire [15:0] outs1;
wire [15:0] outs2;
wire [7:0] en;
wire pwmX;
integer i;
reg ncyc = 0;

  // Clock divider
  clkdiv clkdiv1(.clk(clk),
               .rst_n(rst_n),
               .en(en));     
  // SINC1 test
  sinc1 sinc10(.clk(clk),
               .rst_n(rst_n),
               .din(inp[0]),    
               .fsclk(en[0]),
               .fbwclk(en[2]),
               .out(outs0));
  // SINC2 test
  sinc2 sinc20(.clk(clk),
               .rst_n(rst_n),
               .din(inp[0]),    
               .fsclk(en[0]),
               .fbwclk(en[2]),
               .out(outs1));
  // SINC3 test
  sinc3 sinc30(.clk(clk),
               .rst_n(rst_n),
               .din(inp[0]),    
               .fsclk(en[0]),
               .fbwclk(en[2]),
               .out(outs2));
  
  // PWM out[6]
  // 65k*20ns = 1.30ms per pulse ca. 780 Hz 
  pwm pwm1(.clk(clk),
           .rst_n(rst_n),
           .width(10'b01_0000_0000),
           .out(pwmX));

sigdel sigdelX(.clk(clk),
               .rst_n(rst_n),
               .inp(inp),
               .out(out),
               .outXa(outXa));
tt_um_jv_sigdel sigdelY(.clk(clk),
                       .rst_n(rst_n),
                       .ui_in(inp),
                       .uo_out(outx));

always
 #10 clk = ~clk;  // setup Tclk = 20ns 50 MHz CLK

// 
initial begin
 #0 inp = 8'b00000000;
 #15 rst_n = 0;
 #10 rst_n = 1;
 // Typical pattern sampling every 4th clock cycle
 // 01010101  #80 #80
 // 001001001 #160 #80
 // 00010001  #240 #80
 // 011011011 #80 #160
 // 011101110 #80 #240
 #0 ncyc = !ncyc;   // first high time
 for(i=0;i<256;i=i+1) begin // 65k * 40ns = 2.6 ms
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;    
 for(i=0;i<256;i=i+1) begin // 65k * 40ns = 2.6 ms
   #80 inp[0] = !inp[0];
   #160 inp[0] = !inp[0];
 end 
 #0 ncyc = !ncyc;  // 2nd high
  for(i=0;i<256;i=i+1) begin // 65k * 40ns = 2.6 ms
   #160 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 for(i=0;i<256;i=i+1) begin // 65k * 40ns = 2.6 ms
   #80 inp[0] = !inp[0];
   #240 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;  // 3rd high
  for(i=0;i<256;i=i+1) begin // 65k * 40ns = 2.6 ms
   #240 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;  
 // measurement of enx and eny for inp[4:1]
 #0 inp = 8'b00000010;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;  // 4th high
 #0 inp = 8'b00000100;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00000110;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc; // 5th high
 #0 inp = 8'b00001000;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00001010;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc; // 6th high
  #0 inp = 8'b00001100;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00001110;
 for(i=0;i<256;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;  // 7th high
 #0 inp = 8'b00010000; 
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00010010;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc; // 8th high
 #0 inp = 8'b00010100;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00010110;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;  // 9th high
 #0 inp = 8'b00011000;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00011010;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;  // 10th high
 #0 inp = 8'b00011100;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc;
 #0 inp = 8'b00011110;
 for(i=0;i<256*16;i=i+1) begin // 
   #80 inp[0] = !inp[0];
   #80 inp[0] = !inp[0];
 end  
 #0 ncyc = !ncyc; // 11th high end

end



endmodule
