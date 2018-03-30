// Ryan Pencak
// Syscall.v

/* Sycscall module: determine and execute syscall */
module Syscall(syscall_control, sysstall, v0, a0,
              stat_control, stringAdr);

  /* declare inputs */
  input syscall_control, sysstall;
  input [31:0] v0, a0;

  /* declare outputs */
  output reg stat_control;
  output reg [31:0] stringAdr;

  initial begin
    stat_control = 0;
  end

  always @(syscall_control, sysstall)
  begin

    if((syscall_control == 1) && (sysstall == 0)) // on syscall control signal
    begin
      // v0 as 1 indicates a print integer syscall
      if(v0 == 1)
        $display("\n\nSYCALL OUTPUT = %d\n\n", a0);

      else if (v0 == 4)
        $display("\n\nSYCALL STRING PRINT NOT ENABLED\n\n");
        stringAdr = a0;

      // v0 as 10 indicates an execution kill
      else if(v0 == 10)
      begin
        $display("Syscall received 10, kill execution.\n\n");
        stat_control = 1;
        #1; $finish;
      end

      i
    end
  end





endmodule
