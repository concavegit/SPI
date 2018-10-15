/*
* D-Flip Flop modules
* In SPI, used for controlling miso pin and for address latch
*/
module addressLatch
  #(parameter width = 7) // Address is 7 bits long
   (
    input [width - 1:0] d,
    input                  clk, ce,
    output reg [width - 1:0] q
    );

   always @(posedge clk) begin
      if (ce) begin
        q <= d;
      end
    end
endmodule

module dff
   (
    input d,
    input  clk, ce,
    output reg q
    );

   always @(posedge clk) begin
      if (ce) begin
        q <= d;
      end
    end
endmodule
