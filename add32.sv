module add32 #(parameter XLEN = 32)
  (
    input [XLEN-1:0] a,
    input [XLEN-1:0] b,
    output [XLEN-1:0] y
);
  
  assign y = a + b;
  
endmodule
