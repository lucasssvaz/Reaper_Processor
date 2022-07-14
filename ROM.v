module ROM
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=13)
(
	input [(ADDR_WIDTH-1):0] PC,
	input Fast_Clock, 
	output reg [(DATA_WIDTH-1):0] Instruction
);

	reg [DATA_WIDTH-1:0] rom[4095:0]; //1024 per process

	initial
	begin
		$readmemb("OS.txt", rom, 0, 1023);
		$readmemb("Proc1.txt", rom, 1024, 2047);
		$readmemb("Proc2.txt", rom, 2048, 3071);
		$readmemb("Proc3.txt", rom, 3072, 4095);
	end

	always @ (posedge Fast_Clock)
	begin
		Instruction <= rom[PC];
	end

endmodule
