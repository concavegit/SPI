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

   wire [7:0]   shift_reg_parallel_out, datamemout;
   wire         sr_we, serial_out;

   shiftregister sr
     (
      .clk(clk),
      .peripheralClkEdge(sclk_posedge),
      .parallelLoad(sr_we),
      .parallelDataIn(datamemout),
      .serialDataIn(serial_in),
      .parallelDataOut(shift_reg_parallel_out),
      .serialDataOut(serial_out)
      );

   wire [6:0]   address;
   wire         dm_we;

   datamemory dm
     (
      .clk(clk),
      .dataOut(datamemout),
      .address(address),
      .writeEnable(dm_we),
      .dataIn(shift_reg_parallel_out)
      );

   wire         addr_we;

   addressLatch al
     (
      .d(shift_reg_parallel_out[6:0]),
      .clk(clk),
      .ce(addr_we),
      .q(address)
      );

   wire         miso_buff;

   fsm fsm0
     (
      .clk(clk),
      .cs(cs),
      .rw(shift_reg_parallel_out[0]),
      .s_pos(sclk_posedge),
      .miso_buff(miso_buff),
      .dm_we(dm_we),
      .addr_we(addr_we),
      .sr_we(sr_we)
      );


  wire serial_out_delayed;

  dff miso_dff
    (
      .d(serial_out),
      .clk(clk),
      .ce(sclk_negedge),
      .q(serial_out_delayed)
      );

   bufif1 b(miso_pin, serial_out_delayed, miso_buff);
endmodule
