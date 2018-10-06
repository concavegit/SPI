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
   
   always #10 clk = !clk;

   initial begin
      $dumpfile("inputconditioner.vcd");
      $dumpvars();
      clk = 0;
      pin <= 1;
      #10 pin <= 0;
      #10 pin <= 1;
      #50 pin <= 0;
      #100 pin <= 0;
      #900 $finish;
   end
endmodule
