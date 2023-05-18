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

//Using 9-bit RGB color depth
//Frame Resolution = 160x120x9
module VGA_Image_Processor
(
	input Fast_Clock,
	input Slow_Clock,
	input Reset,
	output reg VGA_HS,
	output reg VGA_VS,
	output reg VGA_Clk,
	output reg [7:0] VGA_Red,
	output reg [7:0] VGA_Green,
	output reg [7:0] VGA_Blue,
	output reg VGA_Blank_N,
	output reg VGA_Sync_N,
	input Enable_Draw,
	input [31:0] Draw_X,
	input [31:0] Draw_Y,
	input [31:0] Draw_Color
);

localparam FB_WIDTH = 160;
localparam FB_HEIGHT = 120;
localparam FB_SCALE = 640/FB_WIDTH;
localparam FB_SCALE_BITS = FB_SCALE/2;
localparam FB_WORDS = 19200;
localparam FB_ADDRW = 15;
localparam FB_COLOR_BITS = 9;
localparam COLOR_FB_TO_VGA_FACTOR = 36;

wire Inv_Slow_Clock = ~Slow_Clock;
wire [9:0] VGA_X;
wire [9:0] VGA_Y; //Bit 9 is unused

/* The basic formula is address = y*WIDTH + x;
* For 160x120 resolution we can write 160 as (128 + 32). Memory address becomes
* (y*128) + (y*32) + x;
* This simplifies the multiplication to a simple shift and add operation.
* A leading 0 bit is added to each operand to ensure that they are treated as unsigned
* inputs. By default the use of a '+' operator will generate a signed adder.
*/
wire [$clog2(FB_WIDTH)-1:0] FB_Write_X = Draw_X[$clog2(FB_WIDTH)-1:0];
wire [$clog2(FB_HEIGHT)-1:0] FB_Write_Y = Draw_Y[$clog2(FB_HEIGHT)-1:0];
wire [FB_ADDRW:0] FB_Write_Calc_Address = ({1'b0, FB_Write_Y, 7'd0} + {1'b0, FB_Write_Y, 5'd0} + {1'b0, FB_Write_X});
wire [FB_ADDRW-1:0] FB_Write_Address = FB_Write_Calc_Address[FB_ADDRW-1:0];
wire FB_Write_Valid = (({1'b0, FB_Write_X} >= 0) & ({1'b0, FB_Write_X} < FB_WIDTH) & ({1'b0, FB_Write_Y} >= 0) & ({1'b0, FB_Write_Y} < FB_HEIGHT));
wire FB_Write_Enable = (Enable_Draw & FB_Write_Valid);
wire [FB_COLOR_BITS-1:0] FB_Write_Data = Draw_Color[FB_COLOR_BITS-1:0];

wire [$clog2(FB_WIDTH)-1:0] FB_Read_X = VGA_X[9:FB_SCALE_BITS];
wire [$clog2(FB_HEIGHT)-1:0] FB_Read_Y = VGA_Y[8:FB_SCALE_BITS];
wire [FB_ADDRW:0] FB_Read_Calc_Address = ({1'b0, FB_Read_Y, 7'd0} + {1'b0, FB_Read_Y, 5'd0} + {1'b0, FB_Read_X});
wire [FB_ADDRW-1:0] FB_Read_Address = FB_Read_Calc_Address[FB_ADDRW-1:0];
wire [FB_COLOR_BITS-1:0] FB_Read_Data;

VGA_Signal_Generator VGA_Signal_Generator_0
(
	.Fast_Clock(Fast_Clock),
	.Reset(Reset),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_Clk(VGA_Clk),
	.Counter_X(VGA_X),
	.Counter_Y(VGA_Y),
	.VGA_Blank_N(VGA_Blank_N),
	.VGA_Sync_N(VGA_Sync_N)
);

//TODO: VSync

VGA_Frame_Buffer Frame_Buffer_160_120_9
(
	.data(FB_Write_Data),
	.rdaddress(FB_Read_Address),
	.rdclock(VGA_Clk),
	.wraddress(FB_Write_Address),
	.wrclock(Inv_Slow_Clock),
	.wren(FB_Write_Enable),
	.q(FB_Read_Data)
);

//------------------------------------------------------

always_ff @ (negedge VGA_Clk)
begin
	VGA_Red <= Reset ? 8'b0 : ({1'b0, FB_Read_Data[8:6], 5'd0} + {1'b0, FB_Read_Data[8:6], 2'd0});
	VGA_Green <= Reset ? 8'b0 : ({1'b0, FB_Read_Data[5:3], 5'd0} + {1'b0, FB_Read_Data[5:3], 2'd0});
	VGA_Blue <= Reset ? 8'b0 : ({1'b0, FB_Read_Data[2:0], 5'd0} + {1'b0, FB_Read_Data[2:0], 2'd0});
end

endmodule