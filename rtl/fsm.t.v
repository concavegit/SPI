`include "fsm.v"
module testfsm();
   reg shift_reg_out_p = 0;
   reg cs = 1;
   reg sclk = 0;

   wire miso_buff, dm_we, addr_we, sr_we;

   fsm f
     (
      .sclk_edge(sclk),
      .cs(cs),
      .rw(shift_reg_out_p),
      .miso_buff(miso_buff),
      .dm_we(dm_we),
      .addr_we(addr_we),
      .sr_we(sr_we)
      );

   always #1 sclk = !sclk;
   initial begin
      $dumpfile("fsm.vcd");
      $dumpvars();
      #2 cs = 0;
      shift_reg_out_p = 0;
      #18 shift_reg_out_p = 1;
      #16 $finish;
   end
endmodule
