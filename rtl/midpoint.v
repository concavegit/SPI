`include "shiftregister.v"
`include "inputconditioner.v"

module midpoint
  (
   input        clk,
                button0,
                switch0,
                switch1,
                [7:0] parallelDataIn,
   output [7:0] parallelDataOut
   );

   wire         peripheralClkEdge, parallelLoad, serialDataIn;

   shiftregister shiftreg
     (
      .clk(clk),
      .peripheralClkEdge(peripheralClkEdge),
      .serialDataIn(serialDataIn),
      .parallelDataOut(parallelDataOut)
      );

   inputconditioner button0inputcond
     (
      .clk(clk),
      .noisysignal(button0),
      .negativeedge(parallelLoad)
      );

   inputconditioner switch0inputcond
     (
      .clk(clk),
      .noisysignal(switch0),
      .conditioned(serialDataIn)
      );

   inputconditioner switch1inputcond
     (
      .clk(clk),
      .noisysignal(switch1),
      .positiveedge(peripheralClkEdge)
      );

endmodule
