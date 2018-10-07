//------------------------------------------------------------------------
// Input Conditioner
//    1) Synchronizes input to clock domain
//    2) Debounces input
//    3) Creates pulses at edge transitions
//------------------------------------------------------------------------

module inputconditioner
  (
   input      clk, // Clock domain to synchronize input to
   input      noisysignal, // (Potentially) noisy input signal
   output reg conditioned, positiveedge, negativeedge
   // Conditioned output signal
   // 1 clk pulse at rising edge of conditioned
   // 1 clk pulse at falling edge of conditioned
   );
   parameter counterwidth = 3; // Counter size, in bits, >= log2(waittime)
   parameter waittime = 3; // Debounce delay, in clock cycles

   reg [counterwidth - 1:0] counter = 0;
   reg                      synchronizer0 = 0;
   reg                      synchronizer1 = 0;

   always @(posedge clk) begin
     if (conditioned !== 0 && conditioned !== 1) begin
         conditioned <= 0;
         positiveedge <= 0;
         negativeedge <= 0;
       end
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
