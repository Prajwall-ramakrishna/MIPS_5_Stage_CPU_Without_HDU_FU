module pc_reg #(parameter XLEN = 32, parameter RESET_PC = 32'h0000_0000)
  (
  input clk, rst_n, en,
    input [XLEN-1:0] pc_next,
    output reg [XLEN-1:0] pc
);
  
  always@(posedge clk, negedge rst_n)
    begin
      if(!rst_n)
        pc <= RESET_PC;
      else if (en)
        pc <= pc_next;
    end
  
endmodule
