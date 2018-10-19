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
      cs_pin = 1;
      mosi_pin = 0;
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;

      // Write 8'b11001110 to address 7'b1111111
      for (i = 0; i < 16; i = i + 1) begin
         if (i < 7) mosi_pin = 1;
         else if (i == 7) mosi_pin = 0; // Signal that this is a write operation
         else mosi_pin = test_case[i - 8]; // Inverts the test case

         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
      end

      // Lie dormant for a bit
      cs_pin = 1;
      #1000;

      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;


      // Read 0xFF
      for (i = 0; i < 8; i = i + 1) begin
         if (i < 7) mosi_pin = 1;
         if (i == 7) mosi_pin = 1;
         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
      end

      // Check the output of MISO
      $display("Reading data for test 1, should write 10001101:");
      for (i = 0; i < 8; i = i + 1) begin
         sclk_pin = 1;
         #100 sclk_pin = 0; #100;
         $display("%b", miso_pin);
      end
      #100;



      // Test Case 2
      cs_pin = 1;
      mosi_pin = 0;
      sclk_pin = 0;
      #2000 sclk_pin = 1;
      #100 cs_pin = 0;sclk_pin=0;

      //Master Setting Address

      //Writing to Address
      // Writes to address 7'b1010101
      for (i = 0; i < 7; i = i + 1) begin
          if (i%2 == 0) mosi_pin = 1;
          else mosi_pin = 0;
          sclk_pin = 0;
          #100 sclk_pin = 1; #100;
      end

      //Read or Write Bit
      // Set to Write Here
      sclk_pin = 0;
      mosi_pin = 0;
      #100; sclk_pin = 1; #100;


      //Writing Data
      //Writing 8'b10010010
      for (i = 0; i < 8; i = i + 1) begin
          if (i%3 == 0) mosi_pin = 1;
          else mosi_pin = 0;
          sclk_pin = 0;
          #100 sclk_pin = 1; #100;
      end

      // Lie dormant for a bit
      cs_pin = 1;
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;sclk_pin=0;

      //Master Reading Address

      //Read from Address
      // Reads address 7'b1010101
      for (i = 0; i < 7; i = i + 1) begin
          if (i%2 == 0) mosi_pin = 1;
          else mosi_pin = 0;
          sclk_pin = 0;
          #100 sclk_pin = 1; #100;
      end

      //Read or Write Bit
      // Set to Read Here
      sclk_pin = 0;
      mosi_pin = 1;
      #100; sclk_pin = 1; #100;

      // Check the output of MISO
      $display("Reading data for test 2, should write 10010010:");
      for (i = 0; i < 8; i = i + 1) begin
         sclk_pin = 1;
         #100 sclk_pin = 0; #100;
         $display("%b", miso_pin);
      end
      #100;


      $finish();
   end
endmodule
