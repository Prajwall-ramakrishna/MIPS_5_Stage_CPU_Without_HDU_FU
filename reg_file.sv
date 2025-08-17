module reg_file #(
  parameter XLEN = 32,
  parameter REG_COUNT = 32
)(
  input  wire             clk,
  input  wire             rst_n,
  input  wire             we,
  input  wire [4:0]       raddr1, raddr2,  // 32 regs
  input  wire [4:0]       waddr,
  input  wire [XLEN-1:0]  wdata,
  output wire [XLEN-1:0]  rdata1,
  output wire [XLEN-1:0]  rdata2
);
  reg [XLEN-1:0] regs [0:REG_COUNT-1];

  // write-first read (same-cycle RAW bypass inside regfile)
  wire same_w_r1 = we && (waddr != 5'd0) && (waddr == raddr1);
  wire same_w_r2 = we && (waddr != 5'd0) && (waddr == raddr2);

  wire [XLEN-1:0] rf1 = (raddr1 != 5'd0) ? regs[raddr1] : {XLEN{1'b0}};
  wire [XLEN-1:0] rf2 = (raddr2 != 5'd0) ? regs[raddr2] : {XLEN{1'b0}};

  assign rdata1 = (raddr1 == 5'd0) ? {XLEN{1'b0}} :
                  same_w_r1        ? wdata         : rf1;
  assign rdata2 = (raddr2 == 5'd0) ? {XLEN{1'b0}} :
                  same_w_r2        ? wdata         : rf2;

  // optional: guard unknown addr
  function is_unknown_addr;
    input [4:0] a;
    begin is_unknown_addr = (^a === 1'bx); end
  endfunction

  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i=0; i<REG_COUNT; i=i+1) regs[i] <= '0;
    end else if (we && (waddr != 5'd0) && !is_unknown_addr(waddr)) begin
      regs[waddr] <= wdata;
    end
  end
endmodule
