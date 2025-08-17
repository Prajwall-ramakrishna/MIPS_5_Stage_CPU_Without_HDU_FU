module if_stage #(
  parameter XLEN = 32,
  parameter RESET_PC = 32'h0000_0000,
  parameter IMEM_DEPTH = 1024
)(
  input  wire             clk,
  input  wire             rst_n,

  // Hazard control
  input  wire             pc_write,     // 1 = update PC, 0 = stall PC
  input  wire             ifid_write,   // 1 = latch IF/ID, 0 = hold IF/ID
  input  wire             ifid_flush,   // 1-cycle pulse to squash into NOP

  // Redirect from EX (branch/jump resolved there)
  input  wire             pc_src,       // 0: PC+4, 1: branch/jump target
  input  wire [XLEN-1:0]  redirect_pc,  // target address when pc_src=1

  // Outputs to ID through IF/ID
  output wire [XLEN-1:0]  if_id_pc4,
  output wire [31:0]      if_id_instr,

  // (optional) expose current PC and PC+4 for debug
  output wire [XLEN-1:0]  pc_curr,
  output wire [XLEN-1:0]  pc_plus4
);
  // PC register
  wire [XLEN-1:0] pc_next;
  pc_reg #(.XLEN(XLEN), .RESET_PC(RESET_PC)) u_pc (
    .clk    (clk),
    .rst_n  (rst_n),
    .en     (pc_write),
    .pc_next(pc_next),
    .pc     (pc_curr)
  );

  // PC + 4
  add32 #(.XLEN(32)) u_add4 (.a(pc_curr), .b(32'd4), .y(pc_plus4));

  // Next PC mux
  assign pc_next = (pc_src) ? redirect_pc : pc_plus4;

  // Instruction memory (combinational read)
  wire [31:0] instr;
  instr_mem #(.XLEN(XLEN), .DEPTH(IMEM_DEPTH)) u_imem (
    .addr  (pc_curr),
    .instr (instr)
  );

  // IF/ID register
  if_id_reg #(.XLEN(XLEN)) u_ifid (
    .clk       (clk),
    .rst_n     (rst_n),
    .write_en  (ifid_write),
    .flush     (ifid_flush),
    .pc4_in    (pc_plus4),
    .instr_in  (instr),
    .pc4_out   (if_id_pc4),
    .instr_out (if_id_instr)
  );

endmodule
