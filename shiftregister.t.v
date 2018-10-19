`include "shiftregister.v"

module testshiftregister
  #(parameter width = 8)
   ();

   reg clk, peripheralClkEdge, parallelLoad, serialDataIn;
   reg [width-1:0] parallelDataIn;
   wire [width-1:0] parallelDataOut;
   wire             serialDataOut;
   reg [7:0]        i, correct;
   
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

   initial clk=0;
   always #10 clk = !clk;

   initial begin
      $dumpfile("shiftregister.vcd");
      $dumpvars();
      peripheralClkEdge = 0;
      #20 parallelDataIn = 8'b0;
      serialDataIn = 1'b0;
      parallelLoad = 1;
      #20 peripheralClkEdge = 1;
      #20 peripheralClkEdge = 0;

      // Load serial with 1 and make sure that the ones are being shifted in
      for (i = 0; i < 8; i = i + 1)
        begin
           serialDataIn = 1;
           parallelDataIn = 0;
           parallelLoad = 0;
           #20 peripheralClkEdge = 1;
           #20 peripheralClkEdge = 0;
           correct = (1 << (i + 1)) - 1;
           if (parallelDataOut != correct) $display("failed on shifting in 1s, parallelDataOut is %d, should be %d", parallelDataOut, correct);
        end

      // Load serial with 0 and make sure that the 0s are being shifted in.
      for (i = 0; i < 8; i = i + 1)
        begin
           serialDataIn = 0;
           parallelDataIn = 0;
           parallelLoad = 0;
           #20 peripheralClkEdge = 1;
           #20 peripheralClkEdge = 0;
           correct = 256 - (1 << (i + 1));
           if (parallelDataOut != correct) $display("failed on shifting in 0s, parallelDataOut is %d, should be %d", parallelDataOut, correct);
        end
      #20 $finish;
   end

endmodule
