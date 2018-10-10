module dff
  #(parameter width = 1)
   (
    input [width - 1:0]  d,
    input                clk, sclk_edge,
    output [width - 1:0] q
    );

   always @(posedge clk) if (sclk_edge) q <= d;
endmodule
