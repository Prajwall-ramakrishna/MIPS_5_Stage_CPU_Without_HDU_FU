module if_id_reg #(
  parameter XLEN = 32
)(
  input  wire             clk,
  input  wire             rst_n,
  input  wire             write_en,     // ifid_write from HDU
  input  wire             flush,        // ifid_flush on taken branch/jump
  input  wire [XLEN-1:0]  pc4_in,
  input  wire [31:0]      instr_in,
  output reg  [XLEN-1:0]  pc4_out,
  output reg  [31:0]      instr_out
);
  localparam [31:0] NOP = 32'h0000_0000;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc4_out   <= {XLEN{1'b0}};
      instr_out <= NOP;
    end else if (flush) begin
      pc4_out   <= {XLEN{1'b0}};
      instr_out <= NOP;
    end else if (write_en) begin
      pc4_out   <= pc4_in;
      instr_out <= instr_in;
    end
    // else hold (stall)
  end
endmodule
