module fsm
  #(parameter width = 1)
   (
    input                sclk_edge, cs, rw,
    output [width - 1:0] miso_buff,
    output               dm_we, addr_we, sr_we
    );

   always @(posedge sclk_edge)
     begin
     end

endmodule
