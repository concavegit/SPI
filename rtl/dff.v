module dff
  #(parameter width = 7)
   (
    input [width-1:0]      d,
    input                  clk, ce,
    output reg [width-1:0] q
    );

   always @(posedge clk) if (ce) q[6:0] <= d[6:0];
endmodule
