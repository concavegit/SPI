`include "shiftregister.v"
`include "inputconditioner.v"

module midpoint
  (
   input        clk,
                btn0,
                btn1,
                btn2,
                sw0,
                sw1,

   output [3:0] parallelDataOut
   );

   wire         peripheralClkEdge, parallelLoad, serialDataIn;

   shiftregister shiftreg
     (
      .clk(clk),
      .peripheralClkEdge(peripheralClkEdge),
      .parallelLoad(parallelLoad),
      .parallelDataIn(8'hA5),
      .serialDataIn(serialDataIn),
      .parallelDataOut({parallelDataOut, parallelDataOut})
      );

   inputconditioner #(.counterwidth(26), .waittime(50000000)) btn0inputcond
     (
      .clk(clk),
      .noisysignal(btn0),
      .negativeedge(parallelLoad)
      );

   inputconditioner #(.counterwidth(26), .waittime(50000000)) sw0inputcond
     (
      .clk(clk),
      .noisysignal(sw0),
      .conditioned(serialDataIn)
      );

   inputconditioner #(.counterwidth(26), .waittime(50000000)) sw1inputcond
     (
      .clk(clk),
      .noisysignal(sw1),
      .positiveedge(peripheralClkEdge)
      );

endmodule
