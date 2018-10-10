`include "inputconditioner.v"
`include "datamemory.v"
`include "shiftregister.v"
`include "buffer.v"

module spiMemory
  (
   input        clk,
                sclk_pin,
                cs_pin,
   output       miso_pin,
   input        mosi_pin,
   output [3:0] leds
   );

   wire         cs, serial_in, sclk_posedge, sclk_negedge;
   wire         miso, miso_cs;

   inputconditioner mosi_inputcond
     (
      .clk(clk),
      .noisysignal(mosi_pin),
      .conditioned(serial_in),
      );

   inputconditioner sclk_inputcond
     (
      .clk(clk),
      .noisysignal(sclk_pin),
      .positiveedge(sclk_posedge),
      .negativeedge(sclk_negedge)
      );

   inputconditioner cs_inputcond
     (
      .clk(clk),
      .noisysignal(cs_pin),
      .conditioned(cs)
      );

   buffer miso_buffer
     (
      .in(miso),
      .en(miso_cs),
      .out(miso_pin)
      );

endmodule
