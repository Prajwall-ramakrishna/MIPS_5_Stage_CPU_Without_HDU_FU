module ex_branch_jump(
  input  wire        branch_ex,
  input  wire        jump_ex,        // J/JAL
  input  wire        jump_reg_ex,    // JR/JALR
  input  wire        alu_zero,       // for BEQ
  input  wire [31:0] pc4_ex,
  input  wire [31:0] rs_val_ex,
  input  wire [31:0] imm_ext_ex,
  input  wire [25:0] instr_index_ex,
  input  wire [4:0]  rd_ex,
  input  wire [5:0]  funct_ex,

  output wire        redirect_valid,
  output wire [31:0] redirect_pc,
  output wire        link_en,
  output wire [4:0]  link_rd_sel,
  output wire [31:0] pc_plus8_ex
);
  wire [31:0] branch_target = pc4_ex + {imm_ext_ex[29:0], 2'b00};
  wire [31:0] jump_target   = {pc4_ex[31:28], instr_index_ex, 2'b00};
  wire        is_jalr       = jump_reg_ex && (funct_ex == 6'b001001);

  assign redirect_valid = jump_reg_ex || jump_ex || (branch_ex && alu_zero);
  assign redirect_pc    = jump_reg_ex ? rs_val_ex
                         : jump_ex    ? jump_target
                                      : branch_target;

  assign link_en     = jump_ex /*JAL*/ || is_jalr;
  assign link_rd_sel = jump_ex ? 5'd31 : (is_jalr ? rd_ex : 5'd0);
  assign pc_plus8_ex = pc4_ex + 32'd4;
endmodule
