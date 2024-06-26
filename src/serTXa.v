`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2024 08:46:12
// Design Name: 
// Module Name: serTXa
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
// 
//////////////////////////////////////////////////////////////////////////////////


module serTXa(clk, rst_n, enx, data,tx);
    input clk;
    input rst_n;
    input enx;
    input [11:0] data;
    output tx;
  
    reg txI;
    reg [5:0] cntT;    // counter 0..64
    reg [2:0] cntC;    // counter 0..8
    wire [9:0] dataW;  // Data word to send 
    reg [7:0] dataXA;  // ASCII value
    reg [4:0] nib;     // 4 Bit numeric
    reg [11:0] dataI;     // 4 Bit numeric
    wire P;             // parity
    
    // transfer to ASCII
   always @(nib)   
      case (nib)	
	    5'b00000 : dataXA = 8'b0011_0000;    // ASC 0 0x30
	    5'b00001 : dataXA = 8'b0011_0001;    // ASC 1
	    5'b00010 : dataXA = 8'b0011_0010;    // ASC 2
	    5'b00011 : dataXA = 8'b0011_0011;    // ASC 3
	    5'b00100 : dataXA = 8'b0011_0100;    // ASC 4
	    5'b00101 : dataXA = 8'b0011_0101;    // ASC 5
	    5'b00110 : dataXA = 8'b0011_0110;    // ASC 6
	    5'b00111 : dataXA = 8'b0011_0111;    // ASC 7
	    5'b01000 : dataXA = 8'b0011_1000;    // ASC 8
	    5'b01001 : dataXA = 8'b0011_1001;    // ASC 9
	    5'b01010 : dataXA = 8'b0100_0001;    // ASC A 0x41
	    5'b01011 : dataXA = 8'b0100_0010;    // ASC B
	    5'b01100 : dataXA = 8'b0100_0011;    // ASC C
	    5'b01101 : dataXA = 8'b0100_0100;    // ASC D
	    5'b01110 : dataXA = 8'b0100_0101;    // ASC E
	    5'b01111 : dataXA = 8'b0100_0110;    // ASC F
     	5'b10000 : dataXA = 8'b0111_1000;    // ASC x 0x78 8'b0111_1000
     	5'b10001 : dataXA = 8'b0000_1101;    // ASC CR 0x0D 8'b0000_1101
     	5'b10010 : dataXA = 8'b0000_1010;    // ASC LF 0x0A 8'b0000_1010
     	5'b10011 : dataXA = 8'b0010_0000;    // ASC Space 0x20 8'b0010_0000
     	default: dataXA = 8'b0010_0000;      // ASC x
	  endcase	
    // transfer to ASCII
   always @(cntC, data)
          case (cntC[2:0])	
		    3'b001 : nib = 5'b10000;   // "x"
	        3'b010 : nib = {1'b0,dataI[11:8]};   // MSB
	        3'b011 : nib = {1'b0,dataI[7:4]};    // ..
	        3'b100 : nib = {1'b0,dataI[3:0]};    // LSB
            3'b101 : nib = 5'b10001;   // CR
	        3'b110 : nib = 5'b10010;   // LF
	      default: nib = 5'b10011;     // space
	      endcase	
                   
     assign dataW = {1'b1,dataXA,1'b0}; // 4'b011
     // assign dataW = {10'b1_0111_1011_0}; // gives { successfull with baud 56200  

    // counter action       
    always @(posedge clk) begin
       if(!rst_n) begin
          cntT <= 6'b00_0000;
          cntC <= 3'b000;
          txI <= 1'b1;
       end else if (clk & enx) begin
          txI <= dataW[cntT[3:0]];
          cntT <= cntT + 1;
          if (cntT == 6'b001001) begin
            cntT <= 6'b00_0000;
            cntC <= cntC + 1;
          end
          if (cntC == 3'b000 ) begin
             dataI = data;
          end
       end
    end   
    assign tx = txI;
endmodule
