//------------------------------------------------------------------------
// Input Conditioner
//    1) Synchronizes input to clock domain
//    2) Debounces input
//    3) Creates pulses at edge transitions
//------------------------------------------------------------------------

module inputconditioner
  (
   input      clk,
   input      noisysignal,
   output reg conditioned, positiveedge, negativeedge
   );
   parameter counterwidth = 3;
   parameter waittime = 3;

   reg [counterwidth - 1:0] counter = 0;
   reg                      synchronizer0 = 0;
   reg                      synchronizer1 = 0;

   always @(posedge clk) begin
      if (conditioned == synchronizer1) counter <= 0;
      else begin
         if (counter == waittime) begin
            counter <= 0;
            conditioned <= synchronizer1;
            if (synchronizer1 == 1) positiveedge <= 1;
            else negativeedge <= 1;
         end
         else counter <= counter + 1;
      end
      if (positiveedge) positiveedge <= 0;
      if (negativeedge) negativeedge <= 0;
      synchronizer0 <= noisysignal;
      synchronizer1 <= synchronizer0;
   end
endmodule 
