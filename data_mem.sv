module data_mem #(
  parameter XLEN=32, DEPTH=1024
)(
  input  wire             clk,
  input  wire             mem_read,
  input  wire             mem_write,
  input  wire [XLEN-1:0]  addr,       // byte address; word-aligned
  input  wire [31:0]      wdata,
  output wire [31:0]      rdata
);
  function integer CLOG2; input integer v; integer x; begin
    x=v-1; for (CLOG2=0;x>0;CLOG2=CLOG2+1) x=x>>1; end
  endfunction
  localparam IDXW = CLOG2(DEPTH);

  reg [31:0] mem [0:DEPTH-1];
  wire [IDXW-1:0] idx = addr[IDXW+1:2];

  // combo read (OK for simple sim)
  assign rdata = mem_read ? mem[idx] : 32'h0000_0000;

      // helper: detect unknown
  function is_unknown_addr;
    input [4:0] a;
    begin
      is_unknown_addr = (^a === 1'bx); // XOR-reduce returns x if any bit is x
    end
  endfunction
  
  // sync write
  always @(posedge clk) begin
    if (mem_write && (^idx !== 1'bx)) mem[idx] <= wdata;
  end

  integer i;
  initial begin
    for (i=0;i<DEPTH;i=i+1) mem[i] = 32'h0;
    // Optionally preload data with $readmemh("data.hex", mem);
  end
endmodule
