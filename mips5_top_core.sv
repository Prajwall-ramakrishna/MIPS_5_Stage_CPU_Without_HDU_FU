module mips5_top_core(
  input  wire clk,
  input  wire rst_n
);
  // === IF controls (no HDU yet) ===
  wire pc_write = 1'b1;
  wire ifid_write = 1'b1;

  // === Redirect from EX ===
  wire        pc_src;
  wire [31:0] redirect_pc;
  wire        ifid_flush_ex, idex_flush_ex;

  // === IF ===
  wire [31:0] if_id_pc4, if_id_instr, pc_curr, pc_plus4;
  if_stage IFSTG(
    .clk(clk), .rst_n(rst_n),
    .pc_write(pc_write), .ifid_write(ifid_write), .ifid_flush(ifid_flush_ex),
    .pc_src(pc_src), .redirect_pc(redirect_pc),
    .if_id_pc4(if_id_pc4), .if_id_instr(if_id_instr),
    .pc_curr(pc_curr), .pc_plus4(pc_plus4)
  );

  // === ID ===
  wire branch_ex, jump_ex, jump_reg_ex, reg_dst_ex, alu_src_ex, mem_read_ex, mem_write_ex, mem_to_reg_ex, reg_write_ex;
  wire [1:0] alu_op_ex;
  wire [31:0] pc4_ex, rdata1_ex, rdata2_ex, imm_ext_ex;
  wire [25:0] instr_index_ex;
  wire [4:0]  rs_ex, rt_ex, rd_ex;
  wire [5:0]  funct_ex, opcode_ex;

  // WB bus back to regfile
  wire        wb_we;
  wire [4:0]  wb_rd;
  wire [31:0] wb_wdata;

  id_stage IDSTG(
    .clk(clk), .rst_n(rst_n),
    .if_id_pc4(if_id_pc4), .if_id_instr(if_id_instr),
    .wb_we(wb_we), .wb_rd(wb_rd), .wb_wdata(wb_wdata),
    .idex_flush(idex_flush_ex),

    .branch_ex(branch_ex), .jump_ex(jump_ex), .jump_reg_ex(jump_reg_ex),
    .reg_dst_ex(reg_dst_ex), .alu_src_ex(alu_src_ex), .alu_op_ex(alu_op_ex),
    .mem_read_ex(mem_read_ex), .mem_write_ex(mem_write_ex),
    .mem_to_reg_ex(mem_to_reg_ex), .reg_write_ex(reg_write_ex),

    .pc4_ex(pc4_ex), .rdata1_ex(rdata1_ex), .rdata2_ex(rdata2_ex), .imm_ext_ex(imm_ext_ex),
    .instr_index_ex(instr_index_ex), .rs_ex(rs_ex), .rt_ex(rt_ex), .rd_ex(rd_ex),
    .funct_ex(funct_ex), .opcode_ex(opcode_ex)
  );

  // === EX ===
  wire redirect_valid;
  wire [31:0] alu_result_ex, write_data_ex, link_data_ex;
  wire [4:0]  dest_reg_ex;
  wire link_en_ex;
  ex_stage EXSTG(
    .reg_dst_ex(reg_dst_ex), .alu_src_ex(alu_src_ex), .mem_to_reg_ex(mem_to_reg_ex),
    .reg_write_ex(reg_write_ex), .mem_read_ex(mem_read_ex), .mem_write_ex(mem_write_ex),
    .branch_ex(branch_ex), .jump_ex(jump_ex), .jump_reg_ex(jump_reg_ex),
    .alu_op_ex(alu_op_ex),
    .pc4_ex(pc4_ex), .rdata1_ex(rdata1_ex), .rdata2_ex(rdata2_ex), .imm_ext_ex(imm_ext_ex),
    .instr_index_ex(instr_index_ex), .rs_ex(rs_ex), .rt_ex(rt_ex), .rd_ex(rd_ex),
    .funct_ex(funct_ex), .opcode_ex(opcode_ex),

    .redirect_valid(redirect_valid), .redirect_pc(redirect_pc),
    .ifid_flush(ifid_flush_ex), .idex_flush(idex_flush_ex),

    .alu_result_ex(alu_result_ex), .write_data_ex(write_data_ex),
    .dest_reg_ex(dest_reg_ex), .link_en_ex(link_en_ex), .link_data_ex(link_data_ex)
  );

  assign pc_src = redirect_valid;

  // === EX/MEM ===
  wire mem_read_m, mem_write_m, mem_to_reg_m, reg_write_m, link_en_m;
  wire [31:0] alu_result_m, write_data_m, link_data_m;
  wire [4:0]  dest_reg_m;

  ex_mem_reg EXMEM(
    .clk(clk), .rst_n(rst_n), .flush(1'b0), // no mispredict recovery beyond EX here
    .mem_read_in(mem_read_ex), .mem_write_in(mem_write_ex),
    .mem_to_reg_in(mem_to_reg_ex), .reg_write_in(reg_write_ex),
    .link_en_in(link_en_ex),
    .alu_result_in(alu_result_ex), .write_data_in(write_data_ex),
    .dest_reg_in(dest_reg_ex), .link_data_in(link_data_ex),

    .mem_read_out(mem_read_m), .mem_write_out(mem_write_m),
    .mem_to_reg_out(mem_to_reg_m), .reg_write_out(reg_write_m),
    .link_en_out(link_en_m),
    .alu_result_out(alu_result_m), .write_data_out(write_data_m),
    .dest_reg_out(dest_reg_m), .link_data_out(link_data_m)
  );

  // === MEM ===
  wire        mem_to_reg_w, reg_write_w, link_en_w;
  wire [31:0] mem_data_w, alu_result_w, link_data_w;
  wire [4:0]  dest_reg_w;

  mem_stage MEMSTG(
    .clk(clk), .rst_n(rst_n),
    .mem_read_m(mem_read_m), .mem_write_m(mem_write_m),
    .mem_to_reg_m(mem_to_reg_m), .reg_write_m(reg_write_m), .link_en_m(link_en_m),
    .alu_result_m(alu_result_m), .write_data_m(write_data_m),
    .dest_reg_m(dest_reg_m), .link_data_m(link_data_m),

    .mem_to_reg_w(mem_to_reg_w), .reg_write_w(reg_write_w), .link_en_w(link_en_w),
    .mem_data_w(mem_data_w), .alu_result_w(alu_result_w),
    .dest_reg_w(dest_reg_w), .link_data_w(link_data_w)
  );

  // === MEM/WB ===
  wire        mem_to_reg_wb, reg_write_wb, link_en_wb;
  wire [31:0] mem_data_wb, alu_result_wb, link_data_wb;
  wire [4:0]  dest_reg_wb;

  mem_wb_reg MEMWB(
    .clk(clk), .rst_n(rst_n),
    .mem_to_reg_in(mem_to_reg_w), .reg_write_in(reg_write_w), .link_en_in(link_en_w),
    .mem_data_in(mem_data_w), .alu_result_in(alu_result_w), .link_data_in(link_data_w),
    .dest_reg_in(dest_reg_w),

    .mem_to_reg_out(mem_to_reg_wb), .reg_write_out(reg_write_wb), .link_en_out(link_en_wb),
    .mem_data_out(mem_data_wb), .alu_result_out(alu_result_wb), .link_data_out(link_data_wb),
    .dest_reg_out(dest_reg_wb)
  );

  // === Writeback ===
  wire [31:0] wb_data_normal = mem_to_reg_wb ? mem_data_wb : alu_result_wb;
  wire [31:0] wb_data_final  = link_en_wb ? link_data_wb : wb_data_normal;

  assign wb_we    = reg_write_wb;
  assign wb_rd    = dest_reg_wb;
  assign wb_wdata = wb_data_final;

endmodule
