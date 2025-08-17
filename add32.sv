module add32 #(parameter XLEN = 32)
  (
    input [XLEN-1:0] a,
    input [XLEN-1:0] b,
    output [XLEN-1:0] y
);
  
  assign y = a + b;  //Y need not be 1 bit higher than a & b, since it wraps around when PC count reaches end value.
  
endmodule
