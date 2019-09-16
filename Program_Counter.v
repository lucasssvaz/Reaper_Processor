module Program_Counter (input Interrupt, input Reset, input Sys_Clock, input Halt, input [7:0] NextPC, output reg [7:0] PC);

reg Lock = 0;

always @ (Halt)
begin
	if (Halt)
		Lock = 1;
	else
		Lock = 0;
end

always @(posedge Sys_Clock) begin
	if (Reset)
	begin
		PC = 0;
	end
	else if (!Lock && !Interrupt) 
	begin
		PC = NextPC[7:0];
	end
end


endmodule