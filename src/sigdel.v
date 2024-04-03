//////////////////////////////////////////////////////////////////////////////////
// Company: UA Kempten
// Engineer: Joerg Vollrath
// 
// Create Date: 03/2024
// Design Name: sigdel
// Module Name: sigdel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A 1st order passive 4-Bit sigma delta ADC
//               Attach an input signal via 20k resistor to inp[0]
//               Attach a 20k resistor between inp[0] and out[5]
//               Attach a 22 pF capacitor between inp[0] and gnd
//        select sample rate, oversampling, ans sync filter inp[6:1]
//               out[4:0] shows a 4-bit ADC output value
//               out[7:6] show 10 Bit ADC output value as PWM signal
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sigdel(clk,rst_n,inp,out,outXa);
    input clk;
    input rst_n;
    input [7:0] inp;
    output [7:0] out;
	output [7:0] outXa;
    
    wire [7:0] en;     // clock divider enable signal
    wire [15:0] outs0; // output avg
    wire [15:0] outs1; // output sinc1
    wire [15:0] outs2; // output sinc2
    wire [15:0] outs3; // output sinc3
    wire [15:0] outa;   // output multiplexer
    wire [15:0] outb;
    wire [15:0] outx;
    reg [15:0] outy;
    reg [3:0] outB;
    reg inx;
    wire enx1;
    wire enx2;
    wire enx;
    wire eny1;
    wire eny2;
    wire eny;
    wire ent;
	
  // Buffered input signal inx
    always @(posedge clk) begin
        if(!rst_n)
            inx <= 0;
        else
            if (enx) begin
              inx <= inp[0];
           end 
    end
    assign out[4] = inx;
    assign out[5] = !inx;
    
  // inp{2:1]  flck, 1/4, 1/16, 1/256
  // inp[4:3]  oversampling 16,256,1024,4096
  // inp[6:5]  filtering AVG(reset),SINC1,2,3
  // inp[7]    output pwm yes/no
  assign enx1 = inp[1] ? en[1] : en[0];
  assign enx2 = inp[1] ? en[3] : en[2];
  assign enx = inp[2] ? enx2: enx1;
 
  assign eny1 = inp[3] ? en[5] : en[4];
  assign eny2 = inp[3] ? en[7] : en[6];
  assign eny = inp[4] ? eny2: eny1;
 
 
  // Clock divider
  clkdiv clkdiv1(.clk(clk),
               .rst_n(rst_n),
               .en(en));     
  // AVG
  sinc2 sinc20(.clk(clk),
               .rst_n(rst_n),
               .din(inx),    
               .fsclk(en[0]),
               .fbwclk(eny),
               .out(outs0));
 
  // SINC1
  sinc1 sinc11(.clk(clk),
               .rst_n(rst_n),
               .din(inx),
               .fsclk(enx),
               .fbwclk(eny),
               .out(outs1));
  
  // SINC2
  sinc2 sinc21(.clk(clk),
               .rst_n(rst_n),
               .din(inx),
               .fsclk(enx),
               .fbwclk(eny),
               .out(outs2));
  // SINC3
  sinc3 sinc31(.clk(clk),
               .rst_n(rst_n),
               .din(inx),
               .fsclk(enx),
               .fbwclk(eny),
               .out(outs3));
  
  // MUX AVG, SINC1, SINC2, SINC3 to 
  // out[0..3]
  assign outa = inp[5] ? outs1 : outs0;
  assign outb = inp[5] ? outs3 : outs2;
  assign outx = inp[6] ? outb : outa;
  //assign out[3:0] = outx[5:3];

 always @(inp[6:1])    
      case (inp[6:1])	
	    6'b110011 : outB = outx[5:2];   // 6 Bit
	    6'b011011 : outB = outx[5:2]; 
	    6'b010110 : outB = outx[5:2]; 
	    6'b010001 : outB = outx[5:2]; 
	    6'b100111 : outB = outx[7:4];   // 8 Bit
	    6'b100010 : outB = outx[7:4];
	    6'b011111 : outB = outx[7:4];
	    6'b011010 : outB = outx[7:4];
	    6'b010101 : outB = outx[7:4];
	    6'b010000 : outB = outx[7:4];
	    6'b011110 : outB = outx[9:6];   // 10 Bit
	    6'b011001 : outB = outx[9:6];
	    6'b010100 : outB = outx[9:6];
	    6'b110111 : outB = outx[11:8];  // 12 bit
	    6'b110010 : outB = outx[11:8];
	    6'b101011 : outB = outx[11:8];
	    6'b100001 : outB = outx[11:8];
	    6'b011000 : outB = outx[11:8];
	    6'b011100 : outB = outx[13:10]; // 14 bit
		default: outB = outx[11:8];     // 12 bit
	  endcase	
  assign out[3:0] = outB;
	assign outXa = outy[7:0];

  // Buffered output outy
    always @(posedge clk) begin
        if(!rst_n)
            outy <= 16'b0000_0000_0000_0000;
        else
          if (en[4]) begin
            outy <= outx;
          end  
    end
  
  // PWM out[6]
  pwm pwm1(.clk(clk),
           .rst_n(rst_n),
           .width(outy[15:6]),
           .out(out[6]));
  
  // PWM out[7]
   pwm pwm2(.clk(clk),
           .rst_n(rst_n),
           .width(outy[9:0]),
           .out(out[7]));
  
  // UART too much area ?!
  // modNCnt modNCnt1(
  //       .clk(clk),
  //      .rst_n(rst_n),
  //      .en(ent));

  // serTXa serTXAa(.clk(clk), 
  //              .rst_n(rst_n), 
  //              .enx(ent), 
  //              .data(outy[11:0]),
  //		 .tx(out[7]));
  
endmodule
