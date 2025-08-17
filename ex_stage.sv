module ex_stage(
  // Control from ID/EX
  input  wire        reg_dst_ex, alu_src_ex, mem_to_reg_ex, reg_write_ex,
                     mem_read_ex, mem_write_ex, branch_ex, jump_ex, jump_reg_ex,
  input  wire [1:0]  alu_op_ex,
  // Data from ID/EX
  input  wire [31:0] pc4_ex, rdata1_ex, rdata2_ex, imm_ext_ex,
  input  wire [25:0] instr_index_ex,
  input  wire [4:0]  rs_ex, rt_ex, rd_ex,
  input  wire [5:0]  funct_ex,
  input  wire [5:0]  opcode_ex,

  // Redirect to IF
  output wire        redirect_valid,
  output wire [31:0] redirect_pc,
  output wire        ifid_flush,
  output wire        idex_flush,

  // ALU outputs (for later stages)
  output wire [31:0] alu_result_ex,
  output wire [31:0] write_data_ex, // to data memory (comes from rdata2_ex)
  output wire [4:0]  dest_reg_ex,
  output wire        link_en_ex,
  output wire [31:0] link_data_ex   // PC+8
);
  // Operand B mux
  wire [31:0] src_a = rdata1_ex;
  wire [31:0] src_b = alu_src_ex ? imm_ext_ex : rdata2_ex;

  // ALU control
  wire [3:0] alu_ctrl;
  alu_control ALUCTRL(
    .alu_op(alu_op_ex), .funct(funct_ex), .opcode(opcode_ex), .alu_ctrl(alu_ctrl)
  );

  // ALU
  wire zero;
  alu ALU(.a(src_a), .b(src_b), .alu_ctrl(alu_ctrl), .y(alu_result_ex), .zero(zero));

  // Branch / Jump resolution
  wire [4:0] link_rd_sel;
  wire [31:0] pc_plus8_ex;
  ex_branch_jump BJ(
    .branch_ex(branch_ex), .jump_ex(jump_ex), .jump_reg_ex(jump_reg_ex),
    .alu_zero(zero), .pc4_ex(pc4_ex), .rs_val_ex(src_a), .imm_ext_ex(imm_ext_ex),
    .instr_index_ex(instr_index_ex), .rd_ex(rd_ex), .funct_ex(funct_ex),
    .redirect_valid(redirect_valid), .redirect_pc(redirect_pc),
    .link_en(link_en_ex), .link_rd_sel(link_rd_sel), .pc_plus8_ex(pc_plus8_ex)
  );

  // Destination register (normal)
  wire [4:0] dest_normal = reg_dst_ex ? rd_ex : rt_ex;
  assign dest_reg_ex = link_en_ex ? link_rd_sel : dest_normal;
  assign write_data_ex = rdata2_ex;
  assign link_data_ex  = pc_plus8_ex;

  // Flush policy: when redirecting, flush IF/ID and ID/EX
  assign ifid_flush = redirect_valid;
  assign idex_flush = redirect_valid;
endmodule
