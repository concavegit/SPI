`include "spimemory.v"

module spimemorytestbenchharness();

  wire clk;
  wire sclk_pin;
  wire cs_pin;
  wire mosi_pin;
  wire[3:0] leds;
  wire miso_pin;

  reg begintest; // Set High to begin testing memory file
  wire endtest; // Set High to signal test completion
  wire dutpassed; // Indicates whether memory file passed tests

  // Instantiate the memory file being tested
  spiMemory DUT
  (
    .clk(clk),
    .sclk_pin(sclk_pin),
    .cs_pin(cs_pin),
    .mosi_pin(mosi_pin),
    .miso_pin(miso_pin),
    .leds(leds)
    );

  // Instantiate test bench to test the DUT
  spimemorytestbench tester
  (
    .begintest(begintest),
    .endtest(endtest),
    .dutpassed(dutpassed),
    .clk(clk),
    .sclk_pin(sclk_pin),
    .cs_pin(cs_pin),
    .mosi_pin(mosi_pin),
    .miso_pin(miso_pin),
    .leds(leds)
    );

    initial begin
      begintest=0;
      #10;
      begintest=1;
      #1000;
    end

    always @(posedge endtest) begin
      $display("DUT passed?: %b", dutpassed);
    end

  endmodule


module spimemorytestbench
(
  // Test bench driver signal connections
  input	   		begintest,	// Triggers start of testing
  output reg 		endtest,	// Raise once test completes
  output reg 		dutpassed,	// Signal test result

  input miso_pin,
  input[3:0] leds,
  output reg sclk_pin,
  output reg cs_pin,
  output reg mosi_pin,
  output reg clk
  );

    integer data_length;

    initial begin
      cs_pin = 1;
      sclk_pin = 0;
      mosi_pin = 0;
      clk = 0;
    end

    always #10 clk = !clk; // 50MHz Clock
    always #40 sclk_pin = !sclk_pin; // Serial clock on 80 nanosecond cycles


    task reset_pins; begin
      cs_pin = 1;
      sclk_pin = 0;
      mosi_pin = 0;
      #5 clk=1; #5 clk=0; #5 clk=1; #5 clk=0;
      end
    endtask

    always @(posedge begintest) begin
      endtest = 0;
      dutpassed = 1;
      #10;


      // Add test cases

      // Test Case 1:
      //
      reset_pins();
      cs_pin = 0;

      // Write to register 7'b0011101
      mosi_pin <= 0;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0; // Write when 8th bit is low

      // Write 8'b10101010 to the register
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0;

      #80
      // Read from register 7'b0011101
      mosi_pin <= 0;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 0;
      #80 mosi_pin <= 1;
      #80 mosi_pin <= 1; // Read when 8th bit is high

      // With 50 MHz clock, should take 160 nanoseconds total to read from serial

      for (data_length = 0; data_length < 8; data_length = data_length + 1) begin
        #20; // Cycle through and check the bits from the miso pin
      end

      #5
      endtest = 1;
    end

endmodule
