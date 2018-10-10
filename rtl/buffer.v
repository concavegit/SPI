module buffer
  #(parameter width = 1)
   (
    input [width - 1:0]  in,
    input                en,
    output [width - 1:0] out
    );

   assign out = en ? in : {width{1'bz}};
endmodule
