/*
 * Module fsm
 *
 * Inputs: sclk_edge, cs, rw
 * Outputs: miso_buff, dm_we, addr_we, sr_we
 * Function: miso_buff enables output to master, use dm_we to write to
 * memory, addr_we to select an address of data memory, and sr_we to
 * parallel load the shift register.
 *
 * The states which control these outputs are:
 * - 0: Begin the transaction by allowing the address of the data
 *     memory to be selected and proceed to state 1.
 * - 1: Load the first 7 bits of data into the address and then proceed
 *   to state 2.
 * - 2: Branch for the value of RW.
 * - 3: Read: Enable the miso_pin and close parallel load (sr) of the
 *   shift register and then proceed tho state 4.
 * - 4: Disable miso_pin and revert to state 0.
 * - 5: Write MOSI to the selected address and then revert to state 0.
 */

`define BEGIN 3'd0
`define LOAD_ADDRESS 3'd1
`define HANDLE_READ_WRITE 3'd2
`define START_READ 3'd3
`define END_READ 3'd4
`define WRITE 3'd5

module fsm
  (
   input      sclk_edge, // Positive edge of the serial clock
              cs, // Chip Select
              rw, // Bit determining whether a read or write operation is occurring, equivalent to ShiftRegOutP[0]
   output reg miso_buff,
   dm_we, // Date Memory Write Enable
   addr_we, // Address Write enable
   sr_we    // Shift Register Write Enable
   );

   // Keep track of the amount of bits of data loaded.
   reg [3:0]  counter = 0;

   // Keep track of the current state.
   reg [2:0]  state = `BEGIN;

   always @(posedge sclk_edge) begin
      // If cs is high, do nothing.
      if (cs) begin
         state <= `BEGIN;
         miso_buff <= 0;
         dm_we <= 0;
         addr_we <= 0;
         sr_we <= 0;
         counter <= 0;
      end
      else begin
         case (state)

           // Begin the transaction
           `BEGIN: begin
              addr_we <= 1;
              state <= `LOAD_ADDRESS;
              dm_we <= 0;
              sr_we <= 0;
              miso_buff <= 0;
              counter <= 1;
           end

           // Load the first 7 bits of data for the address.
           `LOAD_ADDRESS: begin
              counter <= counter + 1;
              sr_we <= 0;
              dm_we <= 0;
              miso_buff <= 0;

              // 6 because counting starts at 0
              if (counter == 6) begin
                 state <= `HANDLE_READ_WRITE;
                 counter <= 0;
                 addr_we <= 0;
                 //sr_we <= 1;
              end
           end

           // Handle RW
           `HANDLE_READ_WRITE: begin
              // Read when rw high, write when rw low
              miso_buff <= 0;
              //sr_we <= 0;
              if (rw) begin
                 sr_we <= 1;
                 dm_we <= 0;
                 state <= `START_READ;
              end
              else begin
                 dm_we <= 1;
                 // sr_we <= 0;
                 state <= `WRITE;
              end
           end

           // Read operation:
           `START_READ: begin
              sr_we <= 0;
              dm_we <= 0;
              miso_buff <= 1;
              state <= `END_READ;
           end

           // Stop writing to miso
           `END_READ: begin
              if (counter == 7) begin
                 state <= `BEGIN;
                 dm_we <= 0;
                 sr_we <= 0;
                 counter <= 0;
                 miso_buff <= 0;
              end
              else begin
                 counter <= counter + 1;
              end
           end

           // Write to datamemory for 8 bits.
           `WRITE: begin
              if (counter == 7) begin
                 dm_we <= 0;
                 sr_we <= 0;
                 dm_we <= 1;
                 state <= `BEGIN;
                 counter <= 0;
              end
              else
                counter <= counter + 1;
           end
         endcase
      end
   end

endmodule
