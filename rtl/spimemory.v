`include "inputconditioner.v"
`include "datamemory.v"
`include "shiftregister.v"
`include "fsm.v"
`include "dff.v"

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

   // Condition inputs
   inputconditioner mosi_inputcond
     (
      .clk(clk),
      .noisysignal(mosi_pin),
      .conditioned(serial_in)
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

   wire [7:0]   shift_reg_parallel_out, dout;
   wire         sr_we, d;

   shiftregister sr
     (
      .clk(clk),
      .peripheralClkEdge(sclk_posedge),
      .parallelLoad(sr_we),
      .parallelDataIn(dout),
      .serialDataIn(serial_in),
      .parallelDataOut(shift_reg_parallel_out),
      .serialDataOut(d)
      );

   wire [6:0]   address;
   wire         dm_we;

   datamemory dm
     (
      .clk(clk),
      .dataOut(dout),
      .address(address),
      .writeEnable(dm_we),
      .dataIn(shift_reg_parallel_out)
      );

   wire         addr_we;

   dff al
     (
      .d(shift_reg_parallel_out[6:0]),
      .clk(clk),
      .ce(addr_we),
      .q(address)
      );

   wire         miso_buff;

   fsm fsm0
     (
      .sclk_edge(sclk_posedge),
      .cs(cs),
      .rw(shift_reg_parallel_out[0]),
      .miso_buff(miso_buff),
      .dm_we(dm_we),
      .addr_we(addr_we),
      .sr_we(sr_we)
      );

   bufif1 b(miso_pin, d, miso_buff);
endmodule
