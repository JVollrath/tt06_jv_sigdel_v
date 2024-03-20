

    // module clock divider clkdiv.v
    module clkdiv(clk,rst_n,en);
        input clk;
        input rst_n;
        output [7:0] en;   // enable signal en[0] clk/4, en[1] clk/16 ..
     
        reg [15:0] cnt;    // 16 bit 64k
        reg [7:0] enx;    // 16 bit 64k
        
        // counter action
        always @(posedge clk) begin
            if(!rst_n) begin
                cnt <= 16'b0000_0000_0000_0000;
                enx <= 8'b00000000;
            end else if (clk) begin
                cnt <= cnt + 1;
                if (cnt[1:0] == 00) begin    // 4 
                    enx[0] <= 1'b1;
                end else enx[0] <= 1'b0;             
                if (cnt[3:0] == 4'b0000) begin // 16
                    enx[1] <= 1'b1;
                end else enx[1] <= 1'b0;             
                if (cnt[5:0] == 6'b000000) begin // 64
                    enx[2] <= 1'b1;
                end else enx[2] <= 1'b0;             
                if (cnt[7:0] == 8'b00000000) begin  // 256
                    enx[3] <= 1'b1;
                end else enx[3] <= 1'b0;    // 1024          
                if (cnt[9:0] == 10'b0000000000) begin
                    enx[4] <= 1'b1;
                end else enx[4] <= 1'b0;             
                if (cnt[11:0] == 12'b0000_0000_0000) begin // 4096
                    enx[5] <= 1'b1;
                end else enx[5] <= 1'b0;             
                if (cnt[13:0] == 14'b00_0000_0000_0000) begin  // 16k
                    enx[6] <= 1'b1;
                end else enx[6] <= 1'b0;             
                if (cnt[15:0] == 16'b0000_0000_0000_0000) begin   // 64k
                    enx[7] <= 1'b1;
                end else enx[7] <= 1'b0;             
            end     
        end
        
        assign en = enx;
        
    endmodule

