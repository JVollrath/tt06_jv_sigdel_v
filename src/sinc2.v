

    // module sinc2.v    sinc2 filter
    module sinc2(clk,rst_n,din,fsclk,fbwclk,out);
        input clk;
        input rst_n;
        input din;         // 1 bit data input
        input fsclk;       // enable signal for fast sampling clock
        input fbwclk;      // enable signal for low oversampled clock
        output [15:0] out; // final filter output
     
       // integrator signals
        wire [15:0] c0; 
        reg [15:0] c1; 
        wire [15:0] c2; 
        reg [15:0] c3; 
        
        reg [15:0] d0; 
        reg [15:0] d1; 
        wire [15:0] d2; 
        reg [15:0] d3;
        
        wire [15:0] cx;
        wire [14:0] cx1;
     
        // 2 integrators: add accumulate Din C0,C1,C2,C3
        always @(posedge clk) begin
            if(!rst_n) begin
                c1 <= 16'b0000_0000_0000_0000;
                c3 <= 16'b0000_0000_0000_0000;
            end else if (fsclk) begin
                c1 <= c0;
                c3 <= c2;
            end     
        end
        assign cx1 = 0;
        assign cx = {cx1,din};
        assign c0 = cx + c1;
        assign c2 = c1 + c3;
     
        // 2 differentiators: sub accumulate D0,D1,C2,C3
        always @(posedge clk) begin
            if(!rst_n) begin
                d0 <= 16'b0000_0000_0000_0000;
                d1 <= 16'b0000_0000_0000_0000;
                d3 <= 16'b0000_0000_0000_0000;
            end else if (fbwclk) begin
                d0 <= c3;
                d1 <= d0;
                d3 <= d2;
            end     
        end
        assign d2 = d0 - d1;
        assign out = d2 - d3;
        
    endmodule