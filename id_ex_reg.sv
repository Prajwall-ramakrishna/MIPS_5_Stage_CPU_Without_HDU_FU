module id_ex_reg(
  input  wire        clk,
  input  wire        rst_n,
  input  wire        flush,    // squash to NOP

  // control
  input  wire        reg_dst_in, alu_src_in, mem_to_reg_in, reg_write_in,
                      mem_read_in, mem_write_in, branch_in, jump_in, jump_reg_in,
  input  wire [1:0]  alu_op_in,

  // data / fields
  input  wire [31:0] pc4_in, rdata1_in, rdata2_in, imm_ext_in,
  input  wire [25:0] instr_index_in,
  input  wire [4:0]  rs_in, rt_in, rd_in,
  input  wire [5:0]  funct_in,

  // outs
  output reg         reg_dst_out, alu_src_out, mem_to_reg_out, reg_write_out,
                     mem_read_out, mem_write_out, branch_out, jump_out, jump_reg_out,
  output reg [1:0]   alu_op_out,

  output reg [31:0]  pc4_out, rdata1_out, rdata2_out, imm_ext_out,
  output reg [25:0]  instr_index_out,
  output reg [4:0]   rs_out, rt_out, rd_out,
  output reg [5:0]   funct_out,
  
    // add to port list:
  input  wire [5:0]  opcode_in,
  output reg  [5:0]  opcode_out

);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || flush) begin
      {reg_dst_out, alu_src_out, mem_to_reg_out, reg_write_out,
       mem_read_out, mem_write_out, branch_out, jump_out, jump_reg_out} <= '0;
      alu_op_out    <= 2'b00;
      pc4_out       <= '0; 
      rdata1_out <= '0; 
      rdata2_out <= '0; 
      imm_ext_out <= '0;
      instr_index_out <= '0; 
      rs_out <= '0; 
      rt_out <= '0; 
      rd_out <= '0; 
      funct_out <= '0;
      opcode_out <= '0;
    end else begin
      reg_dst_out   <= reg_dst_in;
      alu_src_out   <= alu_src_in;
      mem_to_reg_out<= mem_to_reg_in;
      reg_write_out <= reg_write_in;
      mem_read_out  <= mem_read_in;
      mem_write_out <= mem_write_in;
      branch_out    <= branch_in;
      jump_out      <= jump_in;
      jump_reg_out  <= jump_reg_in;
      alu_op_out    <= alu_op_in;
      opcode_out    <= opcode_in;

      pc4_out       <= pc4_in;
      rdata1_out    <= rdata1_in;
      rdata2_out    <= rdata2_in;
      imm_ext_out   <= imm_ext_in;
      instr_index_out <= instr_index_in;
      rs_out        <= rs_in;
      rt_out        <= rt_in;
      rd_out        <= rd_in;
      funct_out     <= funct_in;
    end
  end
endmodule
