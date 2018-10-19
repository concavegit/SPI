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
`define WAIT 3'd6

module fsm
  (
   input      clk, // Positive edge of the serial clock
              cs,        // Chip Select
              rw,        // Bit determining whether a read or write operation is occurring, equivalent to ShiftRegOutP[0]
              s_pos,  //pos edge of serial clock

   output reg miso_buff,
              dm_we,   // Date Memory Write Enable
              addr_we, // Address Write enable
              sr_we   // Shift Register Write Enable
              //stateOut //Testing Variable
   );

   // Keep track of the amount of bits of data loaded.
   reg [3:0]  counter = 0;

   // Keep track of the current state.
   reg [6:0]  state = 0;

   always @(posedge clk) begin
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
//        stateOut <= state;
         case (state)
            0: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
<<<<<<< HEAD:rtl/fsm_system.v
              miso_buff <= 0;
           end

           // Load the first 7 bits of data for the address.
           `LOAD_ADDRESS: begin
              dm_we <= 0;
              addr_we <= 1;
              if(s_pos) counter <= counter + 1;
=======
              state <= 1;
            end
            1: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 2;
            end
            2: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 3;
            end
            3: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 4;
            end
            4: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 5;
            end
            5: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 6;
            end
            6: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 1;
>>>>>>> 142bb42a51f06421403c80387a239f582eb449e9:rtl/fsm.v
              sr_we <= 0;
              state <= 7;
            end
            7: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 1;
              if (rw) state <= 8;
              else state <= 16;
            end

<<<<<<< HEAD:rtl/fsm_system.v
              // 6 because counting starts at 0
              if (counter == 7) begin
                 state <= `HANDLE_READ_WRITE;
                 counter <= 0;
                 addr_we <= 0;
              end

           end


           // Handle RW
           `HANDLE_READ_WRITE: begin
              // Read when rw high, write when rw low
              miso_buff <= 1;
              if(s_pos) begin
                state <= `WAIT;
              end
           end

           `WAIT: begin
           if (rw) begin
              sr_we <= 1;
              dm_we <= 0;
              state <= `START_READ;
           end
           else begin
              dm_we <= 1;
              sr_we <= 0;
              state <= `WRITE;
            end
            end

           // Read operation:
           `START_READ: begin
=======


            8: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
>>>>>>> 142bb42a51f06421403c80387a239f582eb449e9:rtl/fsm.v
              sr_we <= 0;
              state <= 9;
            end
            9: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 10;
            end
            10: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 11;
            end
            11: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 12;
            end
            12: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 13;
            end
            13: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 14;
            end
            14: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 15;
            end
            15: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 0;
            end

<<<<<<< HEAD:rtl/fsm_system.v
           // Stop writing to miso
           `END_READ: begin
           if(s_pos) counter <= counter + 1;
              if (counter == 8) begin
                 state <= `BEGIN;
                 dm_we <= 0;
                 sr_we <= 0;
                 counter <= 0;
                 miso_buff <= 0;
              end
           end


           // Write to datamemory for 8 bits.
           `WRITE: begin
              // if (counter == 6) begin
              //   dm_we <= 1;
              // end
              if(s_pos) counter <= counter + 1;
              if (counter == 8) begin
                 dm_we <= 0;
                 sr_we <= 0;
                 dm_we <= 1;
                 state <= `BEGIN;
                 counter <= 0;
              end
           end
=======

            16: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 17;
            end
            17: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 18;
            end
            18: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 19;
            end
            19: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 20;
            end
            20: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 21;
            end
            21: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 22;
            end
            22: begin
              miso_buff <= 1;
              dm_we <= 0;
              addr_we <= 0;
              sr_we <= 0;
              state <= 23;
            end
            23: begin
              miso_buff <= 1;
              dm_we <= 1;
              addr_we <= 0;
              sr_we <= 0;
              state <= 0;
            end

           // Begin the transaction
           // `BEGIN: begin
           //    addr_we <= 0;
           //    state <= `LOAD_ADDRESS;
           //    dm_we <= 0;
           //    sr_we <= 0;
           //    miso_buff <= 1;
           // end
           //
           // // Load the first 7 bits of data for the address.
           // `LOAD_ADDRESS: begin
           //    addr_we <= 1;
           //    counter <= counter + 1;
           //    sr_we <= 0;
           //    dm_we <= 0;
           //    miso_buff <= 1;
           //
           //    // 6 because counting starts at 0
           //    if (counter == 6) begin
           //       counter <= 0;
           //       addr_we <= 0;
           //       state <= `HANDLE_READ_WRITE;
           //    end
           // end
           //
           // // Handle RW
           // `HANDLE_READ_WRITE: begin
           //    // Read when rw high, write when rw low
           //    miso_buff <= 1;
           //    if (rw) begin
           //       sr_we <= 1;
           //       dm_we <= 0;
           //       state <= `START_READ;
           //    end
           //    else begin
           //       dm_we <= 1;
           //       sr_we <= 0;
           //       state <= `WRITE;
           //    end
           // end
           //
           // // Read operation:
           // `START_READ: begin
           //    sr_we <= 0;
           //    dm_we <= 0;
           //    miso_buff <= 1;
           //    state <= `END_READ;
           // end
           //
           // // Stop writing to miso
           // `END_READ: begin
           //    if (counter == 7) begin
           //       state <= `BEGIN;
           //       dm_we <= 0;
           //       sr_we <= 0;
           //       counter <= 0;
           //       miso_buff <= 1;
           //    end
           //    else begin
           //       counter <= counter + 1;
           //    end
           // end
           //
           // // Write to datamemory for 8 bits.
           // `WRITE: begin
           //    if (counter == 7) begin
           //       dm_we <= 0;
           //       sr_we <= 0;
           //       dm_we <= 1;
           //       state <= `BEGIN;
           //       counter <= 0;
           //    end
           //    else
           //      counter <= counter + 1;
           // end
>>>>>>> 142bb42a51f06421403c80387a239f582eb449e9:rtl/fsm.v
         endcase
      end
   end

endmodule
