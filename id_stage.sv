module id_stage(
  input  wire        clk,
  input  wire        rst_n,

  // From IF/ID
  input  wire [31:0] if_id_pc4,
  input  wire [31:0] if_id_instr,

  // WB port to reg file (will be used later; keep for completeness)
  input  wire        wb_we,
  input  wire [4:0]  wb_rd,
  input  wire [31:0] wb_wdata,

  // ID/EX flush (on redirects)
  input  wire        idex_flush,

  // To EX via ID/EX
  output wire        branch_ex,
  output wire        jump_ex,
  output wire        jump_reg_ex,
  output wire        reg_dst_ex,
  output wire        alu_src_ex,
  output wire [1:0]  alu_op_ex,
  output wire        mem_read_ex,
  output wire        mem_write_ex,
  output wire        mem_to_reg_ex,
  output wire        reg_write_ex,

  output wire [31:0] pc4_ex,
  output wire [31:0] rdata1_ex,
  output wire [31:0] rdata2_ex,
  output wire [31:0] imm_ext_ex,
  output wire [25:0] instr_index_ex,
  output wire [4:0]  rs_ex, rt_ex, rd_ex,
  output wire [5:0]  funct_ex,
  output wire [5:0] opcode_ex
);
  // Fields
  wire [5:0]  opcode = if_id_instr[31:26];
  wire [4:0]  rs     = if_id_instr[25:21];
  wire [4:0]  rt     = if_id_instr[20:16];
  wire [4:0]  rd     = if_id_instr[15:11];
  wire [5:0]  funct  = if_id_instr[5:0];
  wire [15:0] imm    = if_id_instr[15:0];
  wire [25:0] idx    = if_id_instr[25:0];

  // Control
  wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump, jump_reg;
  wire [1:0] alu_op;

  control_unit CU(
    .opcode(opcode), .funct(funct), .instr(if_id_instr),
    .reg_dst(reg_dst), .alu_src(alu_src), .mem_to_reg(mem_to_reg), .reg_write(reg_write),
    .mem_read(mem_read), .mem_write(mem_write), .branch(branch),
    .jump(jump), .jump_reg(jump_reg), .alu_op(alu_op)
  );

  // Regfile
  wire [31:0] rf_rdata1, rf_rdata2;
  reg_file RF(
    .clk(clk), .rst_n(rst_n),
    .we(wb_we), .raddr1(rs), .raddr2(rt), .waddr(wb_rd), .wdata(wb_wdata),
    .rdata1(rf_rdata1), .rdata2(rf_rdata2)
  );

  // Sign extend
  wire [31:0] imm_ext;
  sign_extend SE(.imm(imm), .imm_ext(imm_ext));

  // ID/EX register
  id_ex_reg IDEX(
    .clk(clk), .rst_n(rst_n), .flush(idex_flush), .opcode_in(opcode), 
    .opcode_out(opcode_ex),
    .reg_dst_in(reg_dst), .alu_src_in(alu_src), .mem_to_reg_in(mem_to_reg),
    .reg_write_in(reg_write), .mem_read_in(mem_read), .mem_write_in(mem_write),
    .branch_in(branch), .jump_in(jump), .jump_reg_in(jump_reg), .alu_op_in(alu_op),

    .pc4_in(if_id_pc4), .rdata1_in(rf_rdata1), .rdata2_in(rf_rdata2), .imm_ext_in(imm_ext),
    .instr_index_in(idx), .rs_in(rs), .rt_in(rt), .rd_in(rd), .funct_in(funct),

    .reg_dst_out(reg_dst_ex), .alu_src_out(alu_src_ex), .mem_to_reg_out(mem_to_reg_ex),
    .reg_write_out(reg_write_ex), .mem_read_out(mem_read_ex), .mem_write_out(mem_write_ex),
    .branch_out(branch_ex), .jump_out(jump_ex), .jump_reg_out(jump_reg_ex), .alu_op_out(alu_op_ex),

    .pc4_out(pc4_ex), .rdata1_out(rdata1_ex), .rdata2_out(rdata2_ex), .imm_ext_out(imm_ext_ex),
    .instr_index_out(instr_index_ex), .rs_out(rs_ex), .rt_out(rt_ex), .rd_out(rd_ex), .funct_out(funct_ex)
  );
endmodule
