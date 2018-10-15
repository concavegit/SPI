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
 * - 1: Load the first 7 bits of data into the adress and then proceed
 *   to state 2.
 * - 2: Branch for the value of RW.
 * - 3: Read: Enable the miso_pin and close parallel load (sr) of the
 *   shift register and then proceed tho state 4.
 * - 4: Disable miso_pin and revert to state 0.
 * - 5: Write MOSI to the selected address and then revert to state 0.
 */

module fsm
  (
   input      sclk_edge,
              cs,
              rw,
   output reg miso_buff,
   dm_we,
   addr_we,
   sr_we
   );

   // Keep track of the amount of bits of data loaded.
   reg [3:0]  counter = 0;

   // Keep track of the current state.
   reg [2:0]  state = 0;

   always @(posedge sclk_edge) begin
      // If cs is high, do nothing.
      if (cs) begin
         state <= 0;
         miso_buff <= 0;
         dm_we <= 0;
         addr_we <= 0;
         sr_we <= 0;
         counter <= 0;
      end
      else begin
         case (state)

           // Begin the transaction
           0: begin
              addr_we <= 1;
              state <= 1;
           end

           // Load the first 7 bits of data for the address.
           1: begin
              counter <= counter + 1;
              if (counter == 6) begin
                 state <= 2;
                 counter <= 0;
                 addr_we <= 0;
              end
           end

           // Handle RW
           2: begin
              if (rw) begin
                 sr_we <= 1;
                 state <= 3;
              end
              else begin
                 dm_we <= 1;
                 state <= 5;
              end
           end

           // Read operation:
           3: begin
              sr_we <= 0;
              miso_buff <= 1;
              state <= 4;
           end

           // Stop writing to miso
           4: begin
              if (counter == 7) begin
                 state <= 0;
                 counter <= 0;
                 miso_buff <= 0;
              end
              else begin
                 counter <= counter + 1;
              end
           end

           // Write to datamemory for 8 bits.
           5: begin
              if (counter == 8) begin
                 dm_we <= 0;
                 state <= 0;
                 counter <= 0;
              end
              else begin
                 counter <= counter + 1;
              end
           end
         endcase
      end
   end

endmodule
