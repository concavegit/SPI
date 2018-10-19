# Computer Architecture Lab 2: SPI Memory
### By Daniel Connolly, Kawin Nikomborirak, William Fairman, and Sreekanth Sajjala

### Input Conditioning
In bringing an external signal onto an internal clock domain, we needed to utilize a pair of D flip-flops to synchronize the signal with the clock. This effectively brings the signal into phase with the internal domain. Moreover, we implemented a delay between the synchronized output of the second D flip flop and the conditioned output in order to avoid bouncing. As a result, when the second flip flop asserts a 1, the conditioned output only asserts a 1 on the fourth positive edge following this assertion. In other words, it waits for three positive edges of the clock. Finally, though it was not important for the function of the input conditioner, we created positive and negative edge signals that assert the clock edges whenever the conditioned output changes in order to assist other subcircuits of the overall CPU.

#### Gate Schematic
The following diagram shows the structural layout of our input conditioner. The diagram consists of four main functions: meta-stabilizing, counting/debouncing, resetting, and outputting a signal. The noisy signal is sent through a set of d-flip-flops to lower the probability of a meta-stabilized signal: the # of flip flops can be expanded if the probability of meta-stabilizing is too high. The counter consists of a 2-bit adder with a mux resetting the output if the reset flag is triggered. If the counter value reaches 3, the input conditioner outputs a new conditioned signal and could trigger a posedge or negedge flag.  
![Waveforms](/res/InputConditioner.png)

In order to test our input conditioner, we mainly relied on the Gtkwave Analyzer. In analyzing the waveforms output by the analyzer, we looked for instances of bouncing in the noisy input signal. When these occurred, we carefully reviewed the conditioned output of the signal, which told us the circuit was working properly. It is important to note that for our wait-time of three clock cycles, which each cycle lasting twenty nanoseconds on the 50MHz clock, the longest input glitch that the conditioner can suppress is 79 nanoseconds, as this glitch would end just before the fourth clock cycle hit its positive edge. For a wait-time of ten clock cycles, then, the maximum length input glitch the input conditioner will suppress is 209 nanoseconds. To calculate this, simply multiply the wait-time in clock cycles, 10 for our purposes here, by the length of each clock cycle, 20 nanoseconds, and then add just less than one additional clock cycle to the result. The output of our input conditioner, functioning properly, is shown below.
![The waveforms above demonstrate the input conditioner successfully handling bouncing and other errors in the circuitry. The error signals at the beginning will likely be corrected as we add additional parts and functionality to the CPU.](/res/InputConditioner.png#center)


### Shift Register
![Waveforms](/res/shiftregister.png)

The shift register tests by loading 1s into the shift register memory and checking that the loading of 1s from the LSB has successfully occurs.
Then we check that 0 can be loaded into the shift register memory in a similar way, asserting the values of parallelDataOut as we shift 0s into the memory until the memory is just 0.
The initial set to 0 tests the use of parallelDataLoad, as if this step failed the above two steps will have also failed as they assume 0 has been loaded into the memory.
On failed cases, the check classification, actual, and expected values are printed to the console.
Since our tests were passed, nothing was printed to the console.
Of course, we checked that the test bench worked by breaking the parallelDataLoad functionality and making sure the appropriate messages were displayed.

### Zybo FPGA Testing
We set the input conditioner widths to 26 and waittime 50000000 to test debouncing as well.
This gives us 1 second to put in signal glitches and test the debouncer.
The plan is to load 1 into the serial, then pass 0 into the serial until it leaves the memory unit.
Then I will make all values 1 by loading 1 into the serial 8 times with a delay of more than 1 second and then hit reset to test reset.
I will do the same again, but this time loading 0 into the serial instead.
Then I will test debouncing by loading 1 into the serial and double flipping the switch.
The 1 should not shift.

- Cycle 1 through the memory: successfully after 8 shifts.
- Make all values 1: Successful.
- Reset (button): Successfully writes xA5.
- Make all values 0: Successful.
- Reset: Successfully writes xA5.
- Load 1 into LSB: Successful.
- Double Toggle: Successfully does not shift.

# SPI Implementation
We used the schematic below available in the lab prompt.

![](res/schema.png)

The finite state machine we used is outlined by the diagram below.
If CS is high at any point, all enables are low and returned to the initial point.

For the majority of the project, we operated using the following state diagram. This diagram limited the number of states required in our finite state machine, but proved a hassle when it came to debugging.

This design shows the steps necessary for the behavior of an SPI memory unit: CS is asserted low, a 7 bit address is loaded, the RW bit is received, and 8 bits of data is either read or written.
Since there are enables for the data memory write (dm_we), the address write (addr_we), the shiftregister parallel in (sr_we), and the buffer write (miso_buff), it made sense to us to have each state be some combination of these enables.
To begin receiving an address, we must first enable addr_we (the `Begin` state), with everything else set low.
To receive an address from here, simply wait 7 serial clock cycles to load the data into the address (the `LoadAddress` state).
Once this happens, the state machine transitions to a state which handles reading and writing (the `ReadWrite` state).
If the 8th bit is high (read operation), we load the shiftregister with the contents of the datamemory and begin reading by setting sr_we high (the `StartRead` state).
To continue the read operation, we enable miso_buff for 8 serial clock cycles (`EndRead` state) and then return to the beginning state.
To write, we enable dm_we for 8 serial clock cycles and then return to the beginning state.
![](res/fsm.png)

As a result, we transitioned away from the above finite state machine late in the project and tried to employ a machine that had a greater number of states, but in which each state was more clearly defined. In total, this finite state machine, shown below, had twenty-four states, eight of which occurred every time chip select dropped low. These first eight states process the address bits that the shift register receives from the mosi pin and the bit determining whether a read or write operation should take place. After this step, the state machine could proceed down one of two distinct branches, one handling read operation and one handling write operations. In the end, unfortunately, we transitioned back to a slightly altered version of our original finite state machine.

![](res/state_diagram.jpg)

Our new finite state machine is clocked on the positive edge of our global system clock rather than on the serial clock, as it previously had been. Moreover, we added an additional state, which is simply a buffer and termed the "Wait" state in our code. This state delays when we read the read/write pin to allow us to accurately determine whether or not the master is signaling for a read or write operation to take place. By clocking the finite state machine on the system clock, we are able to change the values of our control signals more frequently and respond more quickly to changes in the environment during any given serial clock cycle.

# SPI Test Strategy
Test case 1



![](res/correct.png)

This is our premier test case which shows our SPI momery wokring properly we input 10110001 to the address 1100001 and read the same address and get the same data 1100001. This is the wave form. (note:- miso is being driven when we are writing, we are aware but chose not to do anything as it didn't affect anything and also because its 1:30am and we have been on this for 7 hours)

Test Case 2
![](res/cs=1.png)

This is a test case where the chip select pin has been set to 1 when the fith bit of address is being inputted. This was to check if the FSM would work correctly and if all the write enables would be set to low and the miso pin is not driven.

## Write to all registers
We also wrote 10110001 to all registers and read to verify all registers contain the correct value.
Afterwards, we did the same operation (but this time writing 10000010) with cs high to check for tri-state and read to make sure there was no change in datamemory register values.

# Challenges
We had some issues as we forgot that the Sclk(Serial clock) has a delay of 4 clock cycles as it passed through the input conditioner.
We also forgot that because data is presented on a negative edge, we need to wait a half-sclk cycle after receiving the read-write bit to begin checking the output of miso_pin. Handling so many write enable functions with a 5 state high level FSM also proved to be a hard time for us. We also made some mistakes on our part like forgetting we were putting in decimal values in a program that worked in the hexadecimal and getting confused w.r.t that for an hour

# Work Plan Reflection
The first half of our lab up till the mid term project was well planned and went very smoothly. When we moved on to the SPI implementation, we had a good start with all the modules figured out by monday of the week it was due but we face issues which at that point appeared minor. They looked like timing issues with respect to the mosi pin driven. We clarified a couple of things with Ben and thought we were good to go but the issues still plagued us. We made multiple changes, trying to understand the timings of the different enable pins and writing different FSM structures (one with 5 high level states and another with 23 explicit ones). We were able to fix our errors by adding in delays to make sure all our write enables work in the way they were supposed to. This was accomplished after a 6 hour long marathon meeting.

