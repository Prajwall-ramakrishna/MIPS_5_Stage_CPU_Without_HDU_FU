// ALUOp mapping:
// 00 -> add (LW, SW, ADDI)
// 01 -> sub (BEQ)
// 10 -> funct-based (R-type)
// 11 -> immediate logical/SLTI (we'll use opcode decode upstream to choose ALUOp=11 and pass a small hint via funct bits if desired; here keep simple)
module alu_control(
  input  wire [1:0] alu_op,
  input  wire [5:0] funct,
  input  wire [5:0] opcode,   // to help 11-case
  output reg  [3:0] alu_ctrl
);
  localparam ADD=4'b0010, SUB=4'b0110, AND=4'b0000, OR=4'b0001, SLT=4'b0111;

  always @(*) begin
    case (alu_op)
      2'b00: alu_ctrl = ADD; // add
      2'b01: alu_ctrl = SUB; // beq: subtract
      2'b10: begin           // R-type funct
        case (funct)
          6'b100000, 6'b100001: alu_ctrl = ADD; // ADD/ADDU
          6'b100010, 6'b100011: alu_ctrl = SUB; // SUB/SUBU
          6'b100100: alu_ctrl = AND;
          6'b100101: alu_ctrl = OR;
          6'b101010: alu_ctrl = SLT;
          default:               alu_ctrl = ADD;
        endcase
      end
      2'b11: begin // ANDI/ORI/SLTI
        case (opcode)
          6'b001100: alu_ctrl = AND; // ANDI
          6'b001101: alu_ctrl = OR;  // ORI
          6'b001010: alu_ctrl = SLT; // SLTI (signed)
          default:    alu_ctrl = ADD;
        endcase
      end
      default: alu_ctrl = ADD;
    endcase
  end
endmodule
