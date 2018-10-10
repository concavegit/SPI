`timescale 1 ns / 1 ps
`include "inputconditioner.v"

module testconditioner();
   reg clk, pin;
   wire conditioned, rising, falling;

   inputconditioner dut(
                        .clk(clk),
                        .noisysignal(pin),
                        .conditioned(conditioned),
                        .positiveedge(rising),
                        .negativeedge(falling)
                        );
   // Generate clock (50MHz)
   initial clk=0;
   always #10 clk = !clk; // 50MHz Clock

   // Should suppress glitches up to 79 ns
   initial begin
      $dumpfile("inputconditioner.vcd");
      $dumpvars();
      clk = 0;
      pin <= 0;
      #80 pin <= 0;
      #80 pin <= 1;
      #80 pin <= 0;
      #79 pin <= 1;
      #80 pin <= 0;
      #20 pin <= 1;
      #80 pin <= 1;
      #30 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #10 pin <= 0;
      #80 pin <= 1;
      #80 pin <= 0;
      #20 pin <= 1;
      #80 pin <= 0;
      #80 pin <= 1;
      #30 pin <= 0;
      #80 pin <= 1;
      #100 $finish;
   end
endmodule
