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
   reg [7:0]        test_case_read;
   reg [7:0]        j;

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

      // Write 8'10110001 to address 1100001.
      for (i = 0; i < 16; i = i + 1) begin
         if (i < 7) mosi_pin = test_case_addr[i];
         else if (i == 7) mosi_pin = 0;
         else mosi_pin = test_case[15 - i];

         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
      end

      // Lie dormant for a bit
      cs_pin = 1;
      #1000;
      
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;


      // Read from 1100001
      for (i = 0; i < 8; i = i + 1) begin
         if (i == 7) mosi_pin = 1;
         else  mosi_pin = test_case_addr[i];
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

      // Test Case 2: Write a test case to all addresses
      test_case = 8'b10110011;
      for (j = 0; j < 128; j = j + 1) begin
         cs_pin = 1;
         sclk_pin = 0;
         #100 sclk_pin = 1;
         #100 cs_pin = 0;#100;
         test_case_addr = j[6:0];
         for (i = 0; i < 16; i = i + 1) begin
            if (i < 7) mosi_pin = test_case_addr[i];
            else if (i == 7) mosi_pin = 0;
            else mosi_pin = test_case[15 - i];

            sclk_pin = 0;
            #100 sclk_pin = 1; #100;
         end
      end

      // Read all registers, they should all be 1011011
      for (j = 0; j < 128; j = j + 1) begin

      // Lie dormant for a bit
      cs_pin = 1;
      #1000;
      
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;
         test_case_addr = j[6:0];
         for (i = 0; i < 8; i = i + 1) begin
            if (i == 7) mosi_pin = 1;
            else  mosi_pin = test_case_addr[i];
            sclk_pin = 0;
            #100 sclk_pin = 1; #100;
         end

         // Check the output of MISO
         for (i = 0; i < 10; i = i + 1) begin
            sclk_pin = 1;
            if (i > 7) cs_pin = 1;
            #100 sclk_pin = 0; #100;
            // test_case_read[i] = miso_pin;
            if (test_case_read != 8'b1011011) $display("Failed to read 1011011 from register %b", test_case_addr);
            
            // $display("%b", miso_pin);

         end
      end

      // Test Case 3: Write 10000010 to all addresses, but with CS HIGH
      test_case = 8'b10000010;
      for (j = 0; j < 128; j = j + 1) begin
         cs_pin = 1;
         sclk_pin = 0;
         #100 sclk_pin = 1;
         #100 cs_pin = 1;#100;
         test_case_addr = j[6:0];
         for (i = 0; i < 16; i = i + 1) begin
            if (i < 7) mosi_pin = test_case_addr[i];
            else if (i == 7) mosi_pin = 0;
            else mosi_pin = test_case[15 - i];

            sclk_pin = 0;
            #100 sclk_pin = 1; #100;
         end
      end

      // Read all registers, they should all still be 1011011
      for (j = 0; j < 128; j = j + 1) begin

         // Lie dormant for a bit
         cs_pin = 1;
         #1000;
         
         sclk_pin = 0;
         #100 sclk_pin = 1;
         #100 cs_pin = 0;#100;
         test_case_addr = j[6:0];
         for (i = 0; i < 8; i = i + 1) begin
            if (i == 7) mosi_pin = 1;
            else  mosi_pin = test_case_addr[i];
            sclk_pin = 0;
            #100 sclk_pin = 1; #100;
         end

         // Check the output of MISO
         for (i = 0; i < 10; i = i + 1) begin
            sclk_pin = 1;
            if (i > 7) cs_pin = 1;
            #100 sclk_pin = 0; #100;
            // test_case_read[i] = miso_pin;
            if (test_case_read != 8'b1011011) $display("Failed to read 1011011 from register %b", test_case_addr);
         end
      end
      $finish;

   end
endmodule
