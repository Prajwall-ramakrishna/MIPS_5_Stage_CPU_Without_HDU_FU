module ex_mem_reg(
  input  wire        clk, rst_n, flush,

  // control
  input  wire        mem_read_in, mem_write_in, mem_to_reg_in, reg_write_in,
  input  wire        link_en_in,

  // data
  input  wire [31:0] alu_result_in,
  input  wire [31:0] write_data_in,   // store data
  input  wire [4:0]  dest_reg_in,
  input  wire [31:0] link_data_in,    // PC+8 for JAL/JALR

  // outs
  output reg         mem_read_out, mem_write_out, mem_to_reg_out, reg_write_out,
                     link_en_out,
  output reg [31:0]  alu_result_out,
  output reg [31:0]  write_data_out,
  output reg [4:0]   dest_reg_out,
  output reg [31:0]  link_data_out
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || flush) begin
      {mem_read_out, mem_write_out, mem_to_reg_out, reg_write_out, link_en_out} <= '0;
      alu_result_out <= '0; write_data_out <= '0; dest_reg_out <= '0; link_data_out <= '0;
    end else begin
      mem_read_out  <= mem_read_in;
      mem_write_out <= mem_write_in;
      mem_to_reg_out<= mem_to_reg_in;
      reg_write_out <= reg_write_in;
      link_en_out   <= link_en_in;

      alu_result_out<= alu_result_in;
      write_data_out<= write_data_in;
      dest_reg_out  <= dest_reg_in;
      link_data_out <= link_data_in;
    end
  end
endmodule
