`include "spimemory.v"

module spitest();
   reg clk;
   reg sclk_pin;
   reg cs_pin;
   wire miso_pin;
   reg  mosi_pin;
   wire [3:0] leds;

   integer    i;

   initial clk=0;
   always #1 clk= ~clk;


   spiMemory dut(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds[3:0]);
   initial begin
      $dumpfile("spimemory.vcd");
      $dumpvars();

      cs_pin = 1;
      mosi_pin = 0;
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;

      // Write 0xFF to address 0x00;

      for (i = 0; i < 16; i = i + 1) begin
         if (i < 8) mosi_pin = 0;
         else mosi_pin = 1;
         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
      end

      // Lie dormant for a bit
      cs_pin = 1;
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;


      // Read 0xFF
      for (i = 0; i < 8; i = i + 1) begin
         if (i < 7 ) mosi_pin = 0;
         else mosi_pin = 1;
         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
      end

      // sr lag
      sclk_pin = 0;
      #100 sclk_pin = 1; #100;

      // Check the output of MISO
      $display("Reading data at address 0");
      for (i = 0; i < 8; i = i + 1) begin
         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
         $display("%b", miso_pin);
      end
      #100 $finish;
   end
endmodule
