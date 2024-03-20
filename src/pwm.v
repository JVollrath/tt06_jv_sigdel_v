    // module pwm pwm.v
    module pwm(clk,rst_n,width,out);
        input clk;
        input rst_n;
        input [9:0] width;   // pwm width
        output out;
     
        reg [9:0] cnt;    // 16 bit 64k
        reg outx;
        
        // counter action
        always @(posedge clk) begin
            if(!rst_n) begin
                cnt <= 10'b00_0000_0000;
            end else if (clk) begin
                cnt <= cnt + 1;
                if (cnt < width) begin // 4 
                    outx <= 1'b1;
                end else outx <= 1'b0;           
            end     
        end
     
        assign out = outx;
     
    endmodule

