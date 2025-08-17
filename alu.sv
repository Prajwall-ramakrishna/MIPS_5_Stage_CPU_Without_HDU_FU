module alu(
  input  wire [31:0] a, b,
  input  wire [3:0]  alu_ctrl,     // op select
  output reg  [31:0] y,
  output wire        zero
);
  localparam ADD=4'b0010, SUB=4'b0110, AND=4'b0000, OR=4'b0001, SLT=4'b0111;
  always @(*) begin
    case (alu_ctrl)
      ADD: y = a + b;   //In MIPS, the sum size is 32 bits if a & b are greater numbers, resulting in 33 bits, then the numbers are divided into multiple registers
      SUB: y = a - b;
      AND: y = a & b;
      OR : y = a | b;
      SLT: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
      default: y = 32'd0;
    endcase
  end
  assign zero = (y == 32'd0);
endmodule
