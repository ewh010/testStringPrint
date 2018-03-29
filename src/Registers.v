// Ryan Pencak
// Registers.v

/* Registers module: reads registers and outputs read data */
module Registers(clk, jal_control, jal_address, readReg1, readReg2, writeReg, writeData, RegWrite_D, RegWrite_W,
                readData1, readData2, v0, a0, ra, sp);

  /* declare inputs */
  input clk, jal_control, RegWrite_D, RegWrite_W;
  input [31:0] jal_address, writeData;
  input [4:0] readReg1, readReg2, writeReg;

  /* declare outputs */
  output reg [31:0] readData1, readData2;
  output wire [31:0] v0, a0, ra, sp;

  /* declare registers and variables */
  reg [31:0] registers[0:31];
  integer i;

  /* initialize registers to 0 */
  initial begin
    for(i=0; i<32; i = i+1)
      registers[i] = 32'b0;
  end

  /* assign registers used in syscalls and JR/JAL for output */
  assign v0 = registers[`v0];
  assign a0 = registers[`a0];
  assign ra = registers[`ra];
  assign sp = registers[`sp];

  /* set register outputs*/
  always @(negedge clk)
  begin
    readData1 = registers[readReg1];
    readData2 = registers[readReg2];
  end

  /* write on negative edge of clock */
  always @(posedge clk)
  begin
    #1
    if ((RegWrite_D == 1) & (jal_control == 1)) // write on control signal
      begin
        // $display($time, " Setting ra to be %08x", jal_address);
        registers[`ra] = jal_address;
      end
  end

  /* write on negative edge of clock */
  always @(posedge clk)
  begin
    #1
    if ((RegWrite_W == 1) & (writeReg != `zero)) // write on control signal
      begin
        // $display($time, " Setting %08x to be %08x", writeReg, writeData);
        registers[writeReg] = writeData;
      end
  end

endmodule
