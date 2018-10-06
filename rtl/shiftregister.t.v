`include "shiftregister.v"

module testshiftregister
  #(parameter width = 8)
   ();

   reg clk, peripheralClkEdge, parallelLoad, serialDataIn;
   reg [width-1:0] parallelDataIn;
   wire [width-1:0] parallelDataOut;
   wire             serialDataOut;

   shiftregister dut
     (
      .clk(clk),
      .peripheralClkEdge(peripheralClkEdge),
      .parallelLoad(parallelLoad),
      .parallelDataIn(parallelDataIn),
      .serialDataIn(serialDataIn),
      .parallelDataOut(parallelDataOut),
      .serialDataOut(serialDataOut)
      );

   always #10 clk = !clk;

   initial begin
      $dumpfile("shiftregister.vcd");
      $dumpvars();
      clk = 0;
      peripheralClkEdge
   end

endmodule
