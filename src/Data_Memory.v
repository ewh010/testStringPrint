// Ryan Pencak
// dataMemory.v

/* dataMemory module: handles write and read data*/
module Data_Memory(clk, memWrite, memRead, address, writeData, Byte_Warning,
                  readData, stringAdr);

  /* declare inputs */
  input clk;
  input memWrite;
  input memRead;
  input [31:0] address;
  input [31:0] writeData;
  //input [31:0] SyscallRead;
  input [2:0] Byte_Warning;
  input [31:0] stringAdr;
  /* declare outputs */
  output reg [31:0] readData;

  /* declare registers */
  reg [31:0] memory[32'h7ffffffc>>2: (32'h7ffffffc>>2)-2048]; // define memory from stack pointer shift right 2 to 256 less than that to make room
  reg [29:0] characterWordAddress;
  reg [1:0] accessInstruction;
  reg [7:0] currentByte;



  always @(posedge clk)
  begin
    #1
    if (memRead == 1)
    begin
      // $display($time, " Read out %08x", memory[address >> 2]);
      readData = memory[address >> 2]; // at read, set readData to memory at address shifted right 2
    end
  end

///////// Write ////////
  always @(posedge clk)
  begin
    ///if (((address) <= [32'h7ffffffc>>2])) && ((address) >= ((32'h7ffffffc>>2)-2048)) 
    if(memWrite == 1) begin
      // $display($time, " MEM: Writing data %08x to address %08x", writeData, address);
      //memory[address >> 2] = writeData; // at write, set memory at address shifted right 2 to writeData

      if(mem[address[31:2]] == 32'bX) begin
        mem[address[31:2]] = 32'b0;
      end

      if(Byte_Warning == `SIZE_WORD) begin
        mem[address[31:2]] = writeData;
  
      end
  
      if(Byte_Warning == `SIZE_HALF) begin
        if(address[1] == 1) begin
          mem[address[31:2]] = ((writeData << 16) & 32'hFFFF0000) | ((mem[address[31:2]) & 32'h0000FFFF);
        end
        if(address[1] == 0) begin
          mem[address[31:2]] = ((writeData) & 32'h0000FFFF) | ((mem[address[31:2]) & 32'hFFFF0000);
        end
      end
  
      if(Byte_Warning == `SIZE_BYTE) begin
        if(address[1:0] == 3)begin
          mem[address[31:2]] = ((writeData << 24) & 32'hFF000000) | ((mem[address[31:2]]) & 32'h00FFFFFF);
        end
        if(address[1:0] == 2) begin
          mem[address[31:2]] = ((writeData << 16) & 32'h00FF0000) | ((mem[address[31:2]]) & 32'hFF00FFFF);
        end
        if(address[1:0] == 1) begin
          mem[address[31:2]] = ((writeData << 8) & 32'h0000FF00) | ((mem[address[31:2]]) & 32'hFFFF00FF);
        end
        if(address[1:0] == 0) begin
          mem[address[31:2]] = ((writeData) & 32'h000000FF) | ((mem[address[31:2]]) & 32'hFFFFFF00);
        end
      end
  end
  
  
  
  
  always @(negedge clk) begin
    if (Byte_Warning == `SIZE_WORD)begin
      readData = mem[address[31:2]];
    end
  
    if (Byte_Warning == `SIZE_HALF) begin
      if (address[1] == 1)
        readData = (mem[address[31:2]] & 32'hFFFF0000) >> 16;
      if (address[1] ==0)
        readData = (mem[address[31:2]] & 32'h0000FFFF);
    end
  
    if (Byte_Warning == `SIZE_BYTE) begin
      if (address[1:0] == 3)
        readData = (mem[address[31:2]] & 32'hFF000000) >> 24;
      if (address[1:0] == 2)
        readData = (mem[address[31:2]] & 32'h00FF0000) >> 16;
      if (address[1:0] == 1)
        readData = (mem[address[31:2]] & 32'h0000FF00) >> 8;
      if (address[1:0] == 0)
        readData = (mem[address[31:2]] & 32'h000000FF);
    end
    else begin
      readData = 0;
    end

  end

  always @(stringAdr) begin
    accessInstruction = stringAdr[1:0];
    characterWordAddress = stringAdr [31:2];

    case(accessInstruction)
      2'h0: currentByte = 32'h000000FF & mem[characterWordAddress];
      2'h1: currentByte = (32'h0000FF00 & mem[characterWordAddress]) >> 8;
      2'h2: currentByte = (32'h00FF0000 & mem[characterWordAddress]) >> 16;
      2'h3: currentByte = (32'hFF000000 & mem[characterWordAddress]) >> 24;
    endcase

    while (currentByte !=0 ) begin
      case(accessInstruction)
        2'h0: currentByte = 32'h000000FF & mem[characterWordAddress];
        2'h1: currentByte = 32'h000000FF & mem[characterWordAddress] >> 8;
        2'h2: currentByte = 32'h000000FF & mem[characterWordAddress] >> 16;
        2'h3: currentByte = 32'h000000FF & mem[characterWordAddress] >>24;
    end

    $write( "%c", currentByte);
    if (accessInstruction == 2'h3) begin
      characterWordAddress = characterWordAddress + 4;
    end 
    accessInstruction = accessInstruction + 1;
  end


  


endmodule
