module control_unit(
  input  wire [5:0] opcode,
  input  wire [5:0] funct,
  input  wire [31:0] instr,   // raw IF/ID.instr (to detect NOP)
  output reg        reg_dst,
  output reg        alu_src,
  output reg        mem_to_reg,
  output reg        reg_write,
  output reg        mem_read,
  output reg        mem_write,
  output reg        branch,
  output reg        jump,
  output reg        jump_reg,   // <-- new: JR/JALR
  output reg [1:0]  alu_op
);
  always @(*) begin
      // Unconditional safe defaults
      reg_dst    = 0;
      alu_src    = 0;
      mem_to_reg = 0;
      reg_write  = 0;
      mem_read   = 0;
      mem_write  = 0;
      branch     = 0;
      jump       = 0;
      jump_reg   = 0;
      alu_op     = 2'b00;

      // True NOP: leave defaults
      if (instr != 32'h0000_0000) begin
        case (opcode)
          6'b000000: begin
            case (funct)
              6'b001000: begin // JR
                jump_reg = 1;
              end
              6'b001001: begin // JALR
                jump_reg  = 1;
                reg_write = 1;
                reg_dst   = 1; // rd
              end
              default: begin   // R-type ALU
                reg_dst   = 1;
                reg_write = 1;
                alu_op    = 2'b10;
              end
            endcase
          end
          6'b100011: begin // LW
            alu_src   = 1; mem_to_reg = 1; reg_write = 1; mem_read = 1; alu_op = 2'b00;
          end
          6'b101011: begin // SW
            alu_src   = 1; 
            mem_write  = 1;                   
            alu_op = 2'b00;
          end
          6'b000100: begin // BEQ
            branch    = 1;                                   
            alu_op = 2'b01;
          end
          6'b001000: begin // ADDI
            alu_src   = 1; 
            reg_write  = 1;                   
            alu_op = 2'b00;
          end
          6'b001100, 6'b001101, 6'b001010: begin // ANDI/ORI/SLTI
            alu_src   = 1; 
            reg_write  = 1;                   
            alu_op = 2'b11;
          end
          6'b000010: begin // J
            jump = 1;
          end
          6'b000011: begin // JAL
            jump      = 1; 
            reg_write = 1; // link to $31 (handled in datapath)
          end
      endcase
    end
  end

endmodule
