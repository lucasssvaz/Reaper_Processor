module IO_Module
(
	input Slow_Clock,
	input Fast_Clock,
	input Reset,
	input Enable,
	input [1:0] IO,
	input Confirm,
	output reg signed [31:0] Data_In,
	input signed [31:0] Data_1,
	input signed [31:0] Data_2,
	input signed [31:0] Data_3,
	output reg signed [31:0] Debug_7Seg,
	input signed [17:0] Raw_Input,
	output reg Interrupt,
	output reg [6:0] Display0,
	output reg [6:0] Display1,
	output reg [6:0] Display2,
	output reg [6:0] Display3,
	output reg [6:0] Display4,
	output reg [6:0] Display5,
	output reg [6:0] Display6,
	output reg [6:0] Display7,
	input [7:0] Kb_Byte,
	output VGA_HS,
	output VGA_VS,
	output [7:0] VGA_Red,
	output [7:0] VGA_Green,
	output [7:0] VGA_Blue,
	output VGA_Blank_N,
	output VGA_Clk,
	output VGA_Sync_N
);

// IO = 0 -> OUTPUT 7 SEG. DISPLAY
// IO = 1 -> INPUT SWITCHES
// IO = 2 -> INPUT PS2 KEYBOARD
// IO = 3 -> OUTPUT VGA

reg State = 0;
wire Out_7Seg;
wire In_Sw_Op;
wire In_Kb_Op;
wire Out_VGA;

assign Out_7Seg = (Enable & (IO == 0));
assign In_Sw_Op = (Enable & (IO == 1));
assign In_Kb_Op = (Enable & (IO == 2));
assign Out_VGA = (Enable & (IO == 3));
assign Debug_7Seg = Data_1;

VGA_Image_Processor VGA_Image_Processor_0
(
	.Fast_Clock(Fast_Clock),
	.Slow_Clock(Slow_Clock),
	.Reset(Reset),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_Clk(VGA_Clk),
	.VGA_Red(VGA_Red),
	.VGA_Green(VGA_Green),
	.VGA_Blue(VGA_Blue),
	.VGA_Blank_N(VGA_Blank_N),
	.VGA_Sync_N(VGA_Sync_N),
	.Enable_Draw(Out_VGA),
	.Draw_X(Data_1),
	.Draw_Y(Data_2),
	.Draw_Color(Data_3)
);

//----------------------------------------------

task To_Display;
	input [3:0] Bin;
	output [6:0] Disp_Hex;

	case (Bin)
		0: Disp_Hex <= 7'b100_0000;
		1: Disp_Hex <= 7'b111_1001;
		2: Disp_Hex <= 7'b010_0100;
		3: Disp_Hex <= 7'b011_0000;
		4: Disp_Hex <= 7'b001_1001;
		5: Disp_Hex <= 7'b001_0010;
		6: Disp_Hex <= 7'b000_0010;
		7: Disp_Hex <= 7'b111_1000;
		8: Disp_Hex <= 7'b000_0000;
		9: Disp_Hex <= 7'b001_0000;
		10: Disp_Hex <= 7'b000_1000;
		11: Disp_Hex <= 7'b000_0011;
		12: Disp_Hex <= 7'b100_0110;
		13: Disp_Hex <= 7'b010_0001;
		14: Disp_Hex <= 7'b000_0110;
		15: Disp_Hex <= 7'b000_1110;
		default: Disp_Hex <= 7'b111_1111;
	endcase
endtask

//----------------------------------------------

always @ (negedge Fast_Clock)
begin
	if (In_Sw_Op && !Confirm)
	begin
		Data_In = {{14{Raw_Input[17]}}, Raw_Input};
	end
	else if (In_Kb_Op)
	begin
		Data_In = {{24{1'b0}}, Kb_Byte};
	end
	else
	begin
		Data_In = Data_In;
	end
end

always @ (negedge Slow_Clock)
begin
	if (Reset)
	begin
		Interrupt = 0;
		State = 0;
	end
	else if (In_Sw_Op)
	begin
		if (!State && !Confirm)
		begin
			Interrupt = 1;
			State = 0;
		end
		else if (!State && Confirm)
		begin
			Interrupt = 1;
			State = 1;
		end
		else if (State && !Confirm)
		begin
			Interrupt = 0;
			State = 0;
		end
		else if (State && Confirm)
		begin
			Interrupt = 1;
			State = 1;
		end
	end
end


always @ (negedge Slow_Clock or posedge Reset)
begin
	if (Reset)
	begin
		Display0 <= 7'b100_0000;
		Display1 <= 7'b100_0000;
		Display2 <= 7'b100_0000;
		Display3 <= 7'b100_0000;
		Display4 <= 7'b100_0000;
		Display5 <= 7'b100_0000;
		Display6 <= 7'b100_0000;
		Display7 <= 7'b100_0000;
	end
	else if (Out_7Seg)	//WRITE OUTPUT
	begin
		To_Display(Data_1[31:28], Display7);
		To_Display(Data_1[27:24], Display6);
		To_Display(Data_1[23:20], Display5);
		To_Display(Data_1[19:16], Display4);
		To_Display(Data_1[15:12], Display3);
		To_Display(Data_1[11:8], Display2);
		To_Display(Data_1[7:4], Display1);
		To_Display(Data_1[3:0], Display0);
	end
end


endmodule