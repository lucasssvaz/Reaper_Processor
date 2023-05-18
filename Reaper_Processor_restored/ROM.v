module ROM
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=13)
(
	input [(ADDR_WIDTH-1):0] PC,
	input Fast_Clock,
	output reg [(DATA_WIDTH-1):0] Instruction
);

	reg [DATA_WIDTH-1:0] rom[512:0]; //1024 per process

	initial
	begin
		$readmemb("PONG.txt", rom, 0, 512);
	end

	always @ (posedge Fast_Clock)
	begin
		Instruction <= rom[PC];
	end

endmodule
