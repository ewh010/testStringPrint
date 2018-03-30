// Ryan Pencak
// control.v

`include "../include/mips.h"

/* control module: determines control signal values */
module Control(instr,
               EX_D, MEM_D, WB_D, Jump, Branch, syscall_control, jr_control, jal_control, BranchOp, Byte_Warning);

  /* declare inputs */
  input [31:0] instr;

  /* declare outputs */
  output reg [2:0] BranchOp;
  output reg [6:0] EX_D;
  output reg [1:0] MEM_D;
  output reg [1:0] WB_D;
  output reg Jump;
  output reg Branch;
  output reg syscall_control;
  output reg jr_control;
  output reg jal_control;
  output reg [1:0] Byte_Warning;

  /* declare control signals */
  reg RegDst;
  reg MemRead;
  reg MemToReg;
  reg [4:0] ALUop;
  reg RegWrite;
  reg ALUsrc;
  reg MemWrite;

  initial begin
    RegDst = 0;
    Jump = 0;
    Branch = 0;
    MemRead = 0;
    MemToReg = 0;
    ALUop = 5'b00000;
    BranchOp = 3'b000;
    RegWrite = 0;
    ALUsrc = 0;
    MemWrite = 0;
    syscall_control = 0;
    jr_control = 0;
    jal_control = 0;
    EX_D = 0;
    MEM_D = 0;
    WB_D = 0;
    Byte_Warning = 2'h0;
  end

  always @(instr) // case on instruction
  begin

    /* initialize control signals to 0 */
    RegDst = 0;
    Jump = 0;
    Branch = 0;
    MemRead = 0;
    MemToReg = 0;
    ALUop = 5'b00000;
    BranchOp = 3'b000;
    RegWrite = 0;
    ALUsrc = 0;
    MemWrite = 0;
    syscall_control = 0;
    jr_control = 0;
    jal_control = 0;

    case (instr[`op]) // case on opcode

      `LUI: // Load Upper Immediate
        begin
          RegWrite = 1;
          ALUsrc = 1;
          ALUop = 5'b011;
          $display("LUI Instruction");
        end

      `J: // Jump
        begin
          Jump = 1;
          $display("J Instruction");
        end

      `JAL: // Jump and Link
        begin
          Jump = 1;
          RegWrite = 1;
          jal_control = 1;
          $display("JAL Instruction");
        end

      `ADDI , `ADDIU: // ADD Immediate
        begin
          RegWrite = 1;
          ALUop = 5'b00010;
          ALUsrc = 1;
          $display("ADDI Instruction");
        end

      `ANDI:
        begin
          ALUop = 5'b00000;
          $display("ANDI Instruction");
        end

      `ORI: // OR Immediate
        begin
          RegWrite = 1;
          ALUop = 5'b00001;
          ALUsrc = 1;
          $display("ORI Instruction");
        end

      `BEQ: // Branch on Equal
        begin
          Branch = 1;
          BranchOp = 5'b00001;
          $display("BEQ Instruction");
        end

      `BNE: // Branch on Not Equal
        begin
          Branch = 1;
          BranchOp = 5'b00100;
          $display("BNE Instruction");
        end

      6'b000001: // BLTZ- Branch Less than  Zero
        begin
          Branch = 1;
          BranchOp = 5'b00110;
          $display("BLTZ Instruction");
        end

      `LW: // Load Word
        begin
          MemRead = 1;
          MemToReg = 1;
          RegWrite = 1;
          ALUsrc = 1;
          ALUop = 5'b00010;
          Byte_Warning = `SIZE_BYTE;
          $display("LW Instruction");
        end

      `LH: // Load half Word
        begin
          MemRead = 1;
          MemToReg = 1;
          RegWrite = 1;
          ALUsrc = 1;
          ALUop = 5'b00010;
          Byte_Warning = `SIZE_HALF;
          $display("LW Instruction");
        end
      
      `LB:
        begin
          MemRead = 1;
          MemToReg = 1;
          RegWrite = 1;
          ALUsrc = 1;
          ALUop = 5'b00010;
          Byte_Warning = `SIZE_BYTE;
          $display("LW Instruction");
        end


      `SW: // Store Word
        begin
          ALUop = 5'b00010;
          ALUsrc = 1;
          MemWrite = 1;
          Byte_Warning = `SIZE_WORD;
          $display("SW Instruction");
        end
      `SH: // Store half Word
        begin
          ALUop = 5'b00010;
          ALUsrc = 1;
          MemWrite = 1;
          Byte_Warning = `SIZE_HALF;
          $display("SW Instruction");
        end

      `SB: // Store Byte
        begin
          ALUop = 5'b00010;
          ALUsrc = 1;
          MemWrite = 1;
          Byte_Warning = `SIZE_BYTE;
          $display("SB Instruction");
        end

      `SPECIAL: // R-type Instruction
        begin
          RegDst=1;
          RegWrite = 1;

          case (instr[`function])

            `AND:
              begin
                ALUop = 5'b00000;
                $display("AND Instruction");
              end

            `OR:
              begin
                ALUop = 5'b00001;
                $display("OR Instruction");
              end

            `ADD , `ADDU:
              begin
                ALUop = 5'b00010;
                $display("ADD Instruction");
              end

            `SUB , `SUBU:
              begin
                ALUop = 5'b00110;
                $display("SUB Instruction");
              end

            `DIV:
              begin
                ALUop = 5'b01010;
                $display("DIV Instruction");
              end

            `MOVZ:
              begin
                ALUop = 5'b01101;
                $display("MOVZ Instruction");
              end

            `MFLO:
              begin
                ALUop = 5'b00100;
                $display("MFLO Instruction");
              end

            `MFHI:
              begin
                ALUop = 5'b00101;
                $display("MFHI Instruction");
              end

            `SLT:
              begin
                ALUop = 5'b00111;
                $display("SLT Instruction");
              end

            `SLL:
              begin
                ALUop = 5'b01000;
                $display("SLL Instruction");
              end

            `SRA:
              begin
                ALUop = 5'b01001;
                $display("SRA Instruction");
              end

            `JR:
              begin
                Jump = 1;
                RegWrite = 1;
                jr_control = 1;
                $display("JR Instruction");
              end

            `SYSCALL:
              begin
                syscall_control = 1;
                RegWrite = 1;
                $display("SYSCALL Instruction");
              end

            `BREAK:
               begin
                $display("Break Instruction -- Finish Execution");
                $finish;
              end

            6'b000000: //NOP
              begin
                ALUop = 5'bxxxxx;
                $display("NOP Instruction");
              end

            default:
              $display("R Instruction Not Listed\n");

          endcase
        end

      default:
        $display("Instruction Not Found\n");

    endcase

    // controlSignals = {RegDst, Jump, Branch, MemRead, MemToReg, ALUop, RegWrite, ALUsrc, MemWrite};
    EX_D = {RegDst, ALUsrc, ALUop};
    MEM_D = {MemWrite, MemRead};
    WB_D = {RegWrite, MemToReg};

    // $display("ALUop = %05x\nRegDst = %01x | Jump = %01x | Branch = %01x | MemRead = %01x | MemToReg = %01x | RegWrite = %01x | ALUsrc = %01x | MemWrite = %01x\n", ALUop, RegDst, Jump, Branch, MemRead, MemToReg, RegWrite, ALUsrc, MemWrite);

  end //end always

endmodule

// `BEQZ: // Branch on Equal to Zero
//   begin
//     Branch = 1;
//     BranchOp = 3'b010;
//   end

// `BLEZ: // Branch Less than Equal to Zero
//   begin
//     Branch = 1;
//     BranchOp = 3'b011;
//   end
// `BNEZ: // Branch Not Equal to Zero
//   begin
//     Branch = 1;
//     BranchOp = 3'b101;
//   end
