`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2024 11:24:37
// Design Name: 
// Module Name: modNCnt
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


module modNCnt(clk,rst_n,en);
        input clk;
        input rst_n;
        output en;   // enable signal en[0] clk/4, en[1] clk/16 ..
     
        reg [15:0] cnt;    // 16 bit 64k
        reg [7:0] enx;    // 16 bit 64k
        
        // counter action
        always @(posedge clk) begin
            if(!rst_n) begin
                cnt <= 16'b0000_0110_1100_1000; // divider 434 100Mhz 10ns to 230 400 Baud 4.3 us
                                                // 434 = 0x1B2 7us?
                                                // 4.3us 0x1B2 230400  Baud 16'b0000_0001_1011_0010
                                                // 16'b0000_0110_1100_1000
                enx <= 1'b0;
            end else if (clk) begin
                cnt <= cnt - 1;
                if (cnt == 16'b0000_0000_0000_0000) begin    // 4 
                    enx <= 1'b1;
                    cnt <= 16'b0000_0110_1100_1000;
                end else enx <= 1'b0;             
            end     
        end
        
        assign en = enx;
        
endmodule
