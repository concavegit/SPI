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
      $dumpfile("spimemory_2.vcd");
      $dumpvars();

      cs_pin = 1;
      mosi_pin = 0;
      sclk_pin = 0;
      #100 sclk_pin = 1;
      #100 cs_pin = 0;#100;

      //Master Setting Address

      //Writing to Address
      // Writes address 7'b1010101
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
      #100 cs_pin = 0;#100;

      //Master Reading Address

      //Writing to Address
      // Writes address 7'b1010101
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


      // Read from address
      // Should output 8'b10010010
      sclk_pin = 0; #100;
      if (miso_pin !== 1) begin
        $display("Test 1,1 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100;
      if (miso_pin !== 0) begin
        $display("Test 1,2 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100
      if (miso_pin !== 0) begin
        $display("Test 1,3 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100
      if (miso_pin !== 1) begin
        $display("Test 1,4 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100
      if (miso_pin !== 0) begin
        $display("Test 1,5 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100
      if (miso_pin !== 0) begin
        $display("Test 1,6 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100
      if (miso_pin !== 1) begin
        $display("Test 1,7 Failed");
      end
      sclk_pin = 1; #100;
      sclk_pin = 0; #100
      if (miso_pin !== 0) begin
        $display("Test 1,8 Failed");
      end
      sclk_pin = 1; #100;

      //
      // // Read 0xFF
      // for (i = 0; i < 8; i = i + 1) begin
      //    if (i < 7 ) mosi_pin = 0;
      //    else mosi_pin = 1;
      //    sclk_pin = 0;
      //    #100 sclk_pin = 1; #100;
      // end
      //
      // // sr lag
      // sclk_pin = 0;
      // #100 sclk_pin = 1; #100;
      //
      // Check the output of MISO
      // Should Display 8'b10010010
      $display("Reading data at address 0");
      for (i = 0; i < 10; i = i + 1) begin
         sclk_pin = 0;
         #100 sclk_pin = 1; #100;
         $display("%b", miso_pin);
      end
      #100 $finish;
   end
endmodule
