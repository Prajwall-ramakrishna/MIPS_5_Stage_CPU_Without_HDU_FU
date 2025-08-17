module mem_stage(
  input  wire        clk, rst_n,

  // from EX/MEM
  input  wire        mem_read_m, mem_write_m, mem_to_reg_m, reg_write_m, link_en_m,
  input  wire [31:0] alu_result_m,
  input  wire [31:0] write_data_m,
  input  wire [4:0]  dest_reg_m,
  input  wire [31:0] link_data_m,

  // to MEM/WB
  output wire        mem_to_reg_w,
  output wire        reg_write_w,
  output wire        link_en_w,
  output wire [31:0] mem_data_w,
  output wire [31:0] alu_result_w,
  output wire [4:0]  dest_reg_w,
  output wire [31:0] link_data_w
);
  wire [31:0] rdata;
  data_mem DMEM(
    .clk(clk),
    .mem_read(mem_read_m),
    .mem_write(mem_write_m),
    .addr(alu_result_m),     // address from ALU
    .wdata(write_data_m),
    .rdata(rdata)
  );

  // Pass-throughs (registered in MEM/WB later)
  assign mem_to_reg_w = mem_to_reg_m;
  assign reg_write_w  = reg_write_m;
  assign link_en_w    = link_en_m;
  assign mem_data_w   = rdata;
  assign alu_result_w = alu_result_m;
  assign dest_reg_w   = dest_reg_m;
  assign link_data_w  = link_data_m;
endmodule
