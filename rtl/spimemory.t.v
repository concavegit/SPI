`include "spimemory.v"

module spitest();
   reg clk;
   reg sclk_pin;
   reg cs_pin;
   wire miso_pin;
   reg  mosi_pin;
   wire [3:0] leds;

   integer    i;
   reg [7:0]        test_case, test_case_result;
   reg [6:0]        test_case_addr;

   initial clk=0;
   always #1 clk= ~clk;


   spiMemory dut(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds[3:0]);

   initial begin
      $dumpfile("spimemory.vcd");
      $dumpvars();

      test_case = 8'b10110001;
      test_case_addr = 7'b1100001;
      cs_pin = 1;
      mosi_pin = 0;
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;

      // Write 8'b11001110 to address 0x00;
      for (i = 0; i < 16; i = i + 1) begin
         if (i < 7) mosi_pin = 1;
         else if (i == 7) mosi_pin = 0;
         else mosi_pin = test_case[i - 8];

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
         mosi_pin = 1;
         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
      end

      // Check the output of MISO
      $display("Reading data at address 0, should write ");
      for (i = 0; i < 10; i = i + 1) begin
         sclk_pin = 1;
         if (i > 7) cs_pin = 1;
         #100 sclk_pin = 0; #100;
         $display("%b", miso_pin);
      end
      #100 $finish;

      if (test_case_result != test_case) $display ("Failed to read %d from %d", test_case, test_case_addr);

      // Get back to

      // Write 010101 to address 0x11001100110
   end
endmodule
