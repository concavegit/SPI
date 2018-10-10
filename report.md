# Midpoint
## Zybo FPGA Testing
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

## Input Conditioning
In bringing an external signal onto an internal clock domain, we needed to utilize a pair of D flip-flops to synchronize the signal with the clock. This effectively brings the signal into phase with the internal domain. Moreover, we implemented a delay between the synchronized output of the second D flip flop and the conditioned output in order to avoid bouncing. As a result, when the second flip flop asserts a 1, the conditioned output only asserts a 1 on the fourth positive edge following this assertion. In other words, it waits for three positive edges of the clock. Finally, though it was not important for the function of the input conditioner, we created positive and negative edge signals that assert of the clock edges whenever the conditioned output changes in order to assist other subcircuits of the overall CPU in functioning properly. 

In order to test our input conditioner, we mainly relied on the Gtkwave Analyzer. In analyzing the waveforms output by the analyzer, we looked for instances of bouncing in the noisy input signal. When these occurred, we carefully reviewed the conditioned output of the signal, which told us the circuit was working properly. It is important to note that for our wait-time of three clock cycles, which each cycle lasting twenty nanoseconds on the 50MHz clock, the longest input glitch that the conditioner can suppress is 79 nanoseconds, as this glitch would end just before the fourth clock cycle hit its positive edge. For a wait-time of ten clock cycles, then, the maximum length input glitch the input conditioner will suppress is 209 nanoseconds. To calculate this, simply multiply the wait-time in clock cycles, 10 for our purposes here, by the length of each clock cycle, 20 nanoseconds, and then add just less than one additional clock cycle to the result. The output of our input conditioner, functioning properly, is shown below.
![The waveforms above demonstrate the input conditioner successfully handling bouncing and other errors in the circuitry. The error signals at the beginning will likely be corrected as we add additional parts and functionality to the CPU.](/res/InputConditioner.png#center)


## Shift Register
![Waveforms]()
