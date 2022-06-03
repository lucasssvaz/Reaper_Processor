//REQUIRES 25MHZ CLOCK INPUT TO GENERATE 640x480@60Hz
module VGA_Clock_Generator
(
	input Fast_Clock,
	input Reset,
	output reg VGA_HS,
	output reg VGA_VS,
	output reg VGA_Clk,
	output reg [9:0] Counter_Horz, //X
	output reg [9:0] Counter_Vert, //Y
	output reg VGA_Blank_N,
	output reg VGA_Sync_N
);

//Horizontal Parameter: 16 + 96 + 48 + 640 = 800
localparam H_FRONT = 16;
localparam H_SYNC = 96;
localparam H_BACK = 48;
localparam H_ACT = 640;
localparam H_BLANK = H_FRONT + H_SYNC + H_BACK;
localparam H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

//Vertical Parameter: 10 + 2 + 33 + 480 = 525
localparam V_FRONT = 10;
localparam V_SYNC = 2;
localparam V_BACK = 33;
localparam V_ACT = 480;
localparam V_BLANK = V_FRONT + V_SYNC + V_BACK;
localparam V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

initial
begin
	Counter_Horz <= 10'b0;
	Counter_Vert <= 10'b0;
	VGA_Clk <= 0;
end

assign VGA_Sync_N = 1'b0; //If not SOG, Sync input should be tied to 0
assign VGA_Blank_N = ~((Counter_Horz < H_BLANK) || (Counter_Vert < V_BLANK));

always @(posedge Fast_Clock or posedge Reset)
begin
	if (Reset)
		VGA_Clk <= 0;
	else
		VGA_Clk <= ~VGA_Clk;
end

always @ (posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
		Counter_Horz <= 10'd0; //Start of row count
	else if (Counter_Horz == 800)
		Counter_Horz <= 10'd0;
	else
		Counter_Horz <= Counter_Horz + 10'b1;
end

always @ (posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
		Counter_Vert <= 10'd0; //Start of row count
	else if (Counter_Vert == 525)
		Counter_Vert <= 10'd0;
	else if (Counter_Horz == 800)
		Counter_Vert <= Counter_Vert + 10'b1;
end

always @(posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
		VGA_HS <= 1; //The sync signal is pulled high
	else if(Counter_Horz == 0)
		VGA_HS <= 0; //Line count starts, line sync signal is pulled low
	else if(Counter_Horz == H_SYNC)
		VGA_HS <= 1; //Line count starts, line sync signal is pulled high
end

always @ (posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
		VGA_VS <= 1; //The sync signal is pulled high
	else if(Counter_Vert == 0)
		VGA_VS <= 0; //Line count starts, line sync signal is pulled low
	else if(Counter_Vert == V_SYNC)
		VGA_VS <= 1; //Line count starts, line sync signal is pulled high
end

endmodule

//==========================================================================

module VGA_Out
(
	input Fast_Clock,
	input Reset,
	output reg VGA_HS,
	output reg VGA_VS,
	output reg VGA_Clk,
	output reg [7:0] VGA_Red,
	output reg [7:0] VGA_Green,
	output reg [7:0] VGA_Blue,
	output reg VGA_Blank_N,
	output reg VGA_Sync_N
);

wire [9:0] VGA_Counter_Horz;
wire [9:0] VGA_Counter_Vert;

VGA_Clock_Generator VGA_Clock_Generator_0
(
	.Fast_Clock(Fast_Clock),
	.Reset(Reset),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_Clk(VGA_Clk),
	.Counter_Horz(VGA_Counter_Horz),
	.Counter_Vert(VGA_Counter_Vert),
	.VGA_Blank_N(VGA_Blank_N),
	.VGA_Sync_N(VGA_Sync_N)
);

always @(posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
	begin
		VGA_Red = 8'h0;
		VGA_Green = 8'h0;
		VGA_Blue = 8'h0;
	end
	else if(144 <= VGA_Counter_Horz && VGA_Counter_Horz <= 223)
	begin
		VGA_Red = 8'hFF;
		VGA_Green = 8'h0;
		VGA_Blue = 8'h0;
	end
	else if(224 <= VGA_Counter_Horz && VGA_Counter_Horz <= 303)
	begin
		VGA_Red = 8'hFF;
		VGA_Green = 8'hFF;
		VGA_Blue = 8'h0;
	end
	else if(304 <= VGA_Counter_Horz && VGA_Counter_Horz <= 383)
	begin
		VGA_Red = 8'h0;
		VGA_Green = 8'hFF;
		VGA_Blue = 8'h0;
	end
	else if(384 <= VGA_Counter_Horz && VGA_Counter_Horz <= 463)
	begin
		VGA_Red = 8'h0;
		VGA_Green = 8'hFF;
		VGA_Blue = 8'hFF;
	end
	else if(464 <= VGA_Counter_Horz && VGA_Counter_Horz <= 543)
	begin
		VGA_Red = 8'hFF;
		VGA_Green = 8'h0;
		VGA_Blue = 8'hFF;
	end
	else if(544 <= VGA_Counter_Horz && VGA_Counter_Horz <= 623)
	begin
		VGA_Red = 8'h0;
		VGA_Green = 8'h0;
		VGA_Blue = 8'hFF;
	end
	else if(624 <= VGA_Counter_Horz && VGA_Counter_Horz <= 703)
	begin
		VGA_Red = 8'h0;
		VGA_Green = 8'h0;
		VGA_Blue = 8'h0;
	end
	else if(704 <= VGA_Counter_Horz && VGA_Counter_Horz <= 783)
	begin
		VGA_Red = 8'hFF;
		VGA_Green = 8'hFF;
		VGA_Blue = 8'hFF;
	end
	else
	begin
		VGA_Red = 8'hFF;
		VGA_Green = 8'hFF;
		VGA_Blue = 8'hFF;
	end
end

endmodule