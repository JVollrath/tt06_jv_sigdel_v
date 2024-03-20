
    // module sinc1.v    sinc2 filter
    module sinc1(clk,rst_n,din,fsclk,fbwclk,out);
        input clk;
        input rst_n;
        input din;         // 1 bit data input
        input fsclk;       // enable signal for fast sampling clock
        input fbwclk;      // enable signal for low oversampled clock
        output [15:0] out; // final filter output
     
       // integrator signals
        wire [15:0] c0; 
        reg [15:0] c1; 
        
        reg [15:0] d0; 
        reg [15:0] d1; 
        
        wire [15:0] cx;
        wire [14:0] cx1;
     
        // 2 integrators: add accumulate Din C0,C1,C2,C3
        always @(posedge clk) begin
            if(!rst_n) begin
                c1 <= 16'b0000_0000_0000_0000;
            end else if (fsclk) begin
                c1 <= c0;
            end     
        end
        assign cx1 = 0;
        assign cx = {cx1,din};
        assign c0 = cx + c1;
     
        // 2 differentiators: sub accumulate D0,D1,C2,C3
        always @(posedge clk) begin
            if(!rst_n) begin
                d0 <= 16'b0000_0000_0000_0000;
                d1 <= 16'b0000_0000_0000_0000;
            end else if (fbwclk) begin
                d0 <= c1;
                d1 <= d0;
            end     
        end
        assign out = d0 - d1;
        
    endmodule