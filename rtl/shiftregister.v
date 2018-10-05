module shiftregister
  #(parameter width=8)
   (
    input               clk, peripheralClkEdge, parallelLoad,
    input [width - 1:0] parallelDataIn,
    input               serialDataIn,
    output [width-1:0]  parallelDataOut,
    output              serialDataOut
    );

   reg [width-1:0]      mem;

   assign parallelDataOut = mem;
   assign serialDataOut = mem[width - 1];

   always @(posedge clk) begin
      if (parallelLoad) mem <= parallelDataIn;
      else if (peripheralClkEdge) mem <= {mem[width-2:0], serialDataIn};
   end
endmodule
