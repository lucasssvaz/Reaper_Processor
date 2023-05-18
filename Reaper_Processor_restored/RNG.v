module RNG
(
    input Slow_Clock,
    output reg [31:0] Rand_Out
);

	initial
	begin
		Rand_Out = 32'hFFFFFFFF;
	end

	always_ff @(posedge Slow_Clock)
	begin
		Rand_Out <= {(Rand_Out[31]^Rand_Out[30]^Rand_Out[10]^Rand_Out[0]),Rand_Out[31:1]};
	end

endmodule