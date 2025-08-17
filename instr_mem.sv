module instr_mem #(
  parameter XLEN = 32,
  parameter DEPTH = 1024  // number of 32b words, power of two recommended
)(
  input  wire [XLEN-1:0] addr,   // byte address; will index by addr[...:2]
  output wire [31:0]     instr
);
  // ---------- helpers ----------
  function integer CLOG2;
    input integer value;
    integer v;
    begin
      v = value - 1;
      for (CLOG2 = 0; v > 0; CLOG2 = CLOG2 + 1) v = v >> 1;
    end
  endfunction
  localparam IDXW = CLOG2(DEPTH);

  // ---------- memory ----------
  reg [31:0] mem [0:DEPTH-1];
  wire [IDXW-1:0] idx = addr[IDXW+1:2];  // word index (ignore byte lanes)

  assign instr = mem[idx];

  integer i;
  initial begin
    // Default everything to NOP
    for (i = 0; i < DEPTH; i = i + 1) mem[i] = 32'h0000_0000;
    // Optionally preload from a hex file named "prog.hex" (one 32b word per line)
     $readmemh("prog.hex", mem);
  end
endmodule
