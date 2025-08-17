module mem_wb_reg(
  input  wire        clk, rst_n,

  // controls/data in
  input  wire        mem_to_reg_in, reg_write_in, link_en_in,
  input  wire [31:0] mem_data_in, alu_result_in, link_data_in,
  input  wire [4:0]  dest_reg_in,

  // outs to WB
  output reg         mem_to_reg_out, reg_write_out, link_en_out,
  output reg [31:0]  mem_data_out, alu_result_out, link_data_out,
  output reg [4:0]   dest_reg_out
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_to_reg_out<=0; reg_write_out<=0; link_en_out<=0;
      mem_data_out<=0; alu_result_out<=0; link_data_out<=0; dest_reg_out<=0;
    end else begin
      mem_to_reg_out<= mem_to_reg_in;
      reg_write_out <= reg_write_in;
      link_en_out   <= link_en_in;
      mem_data_out  <= mem_data_in;
      alu_result_out<= alu_result_in;
      link_data_out <= link_data_in;
      dest_reg_out  <= dest_reg_in;
    end
  end
endmodule
