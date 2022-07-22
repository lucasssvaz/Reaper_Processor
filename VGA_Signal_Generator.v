// REQUIRES 25.175MHZ CLOCK TO GENERATE 640x480@60Hz
//
// Based on:
// https://www.fpga4fun.com/PongGame.html
// https://projectf.io/posts/fpga-pong/
// http://tinyvga.com/vga-timing/640x480@60Hz
// https://www.analog.com/media/en/technical-documentation/data-sheets/adv7123.pdf
// https://www.796t.com/content/1549104121.html
// https://projectf.io/posts/framebuffers/
// https://projectf.io/posts/hardware-sprites/
// https://opengameart.org/content/8x8-ascii-bitmap-font-with-c-source
// https://en.wikipedia.org/wiki/List_of_monochrome_and_RGB_color_formats
// https://github.com/junzhengca/space-enemies

module VGA_Signal_Generator
(
	input Fast_Clock,
	input Reset,
	output reg VGA_HS,
	output reg VGA_VS,
	output reg VGA_Clk,
	output reg [9:0] Counter_X, //Horizontal
	output reg [9:0] Counter_Y,	//Vertical
	output reg VGA_Blank_N,
	output reg VGA_Sync_N
);

localparam VERT_VISIBLE_PIXELS = 10'd480;
localparam VERT_SYNC_START = 10'd493;
localparam VERT_SYNC_END = 10'd494; //(VERT_SYNC_START + 2 - 1);
localparam VERT_TOTAL_PIXELS = 10'd525;

localparam HORZ_VISIBLE_PIXELS = 10'd640;
localparam HORZ_SYNC_START = 10'd659;
localparam HORZ_SYNC_END = 10'd754; //(HORZ_SYNC_START + 96 - 1);
localparam HORZ_TOTAL_PIXELS = 10'd800;

reg VGA_HS_D1;
reg VGA_VS_D1;
reg VGA_Blank_D1;
wire Counter_X_Clear;
wire Counter_Y_Clear;

initial
begin
	Counter_X <= 10'b0;
	Counter_Y <= 10'b0;
	VGA_Clk <= 0;
end

VGA_PLL VGA_Clk_Generator_0
(
	.inclk0(Fast_Clock),
	.c0(VGA_Clk)
);

assign VGA_Sync_N = 1'b1; //Should be tied to 1
assign Counter_X_Clear = (Counter_X == (HORZ_TOTAL_PIXELS-1));
assign Counter_Y_Clear = (Counter_Y == (VERT_TOTAL_PIXELS-1));

//--------------------------------------------------------

always @(posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
		Counter_X <= 10'd0;
	else if (Counter_X_Clear)
		Counter_X <= 10'd0;
	else
	begin
		Counter_X <= Counter_X + 1'b1;
	end
end

always @(posedge VGA_Clk or posedge Reset)
begin
	if (Reset)
		Counter_Y <= 10'd0;
	else if (Counter_X_Clear && Counter_Y_Clear)
		Counter_Y <= 10'd0;
	else if (Counter_X_Clear) //Increment when x counter resets
		Counter_Y <= Counter_Y + 1'b1;
end

always @(posedge VGA_Clk)
begin
	//- Sync Generator (ACTIVE LOW)
	VGA_HS_D1 <= ~((Counter_X >= HORZ_SYNC_START) && (Counter_X <= HORZ_SYNC_END));
	VGA_VS_D1 <= ~((Counter_Y >= VERT_SYNC_START) && (Counter_Y <= VERT_SYNC_END));

	//- Current X and Y is valid pixel range
	VGA_Blank_D1 <= ((Counter_X < HORZ_VISIBLE_PIXELS) && (Counter_Y < VERT_VISIBLE_PIXELS));

	//- Add 1 cycle delay
	VGA_HS <= VGA_HS_D1;
	VGA_VS <= VGA_VS_D1;
	VGA_Blank_N <= VGA_Blank_D1;
end

endmodule