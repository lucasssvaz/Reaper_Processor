module Reaper_Processor
(
	input Raw_Button_I,
	input signed [17:0] Raw_Input,
	input Fast_Clock,
	output Slow_Clock,
	input Raw_Reset_I,
	output [6:0] Display0,
	output [6:0] Display1,
	output [6:0] Display2,
	output [6:0] Display3,
	output [6:0] Display4,
	output [6:0] Display5,
	output [6:0] Display6,
	output [6:0] Display7,
	output Err_Out,
	output signed [31:0] DebugZERO,
    output signed [31:0] DebugT0,
    output signed [31:0] DebugT1,
    output signed [31:0] DebugT2,
    output signed [31:0] DebugT3,
    output signed [31:0] DebugT4,
    output signed [31:0] DebugT5,
    output signed [31:0] DebugT6,
    output signed [31:0] DebugT7,
    output signed [31:0] DebugT8,
    output signed [31:0] DebugT9,
    output signed [31:0] DebugT10,
    output signed [31:0] DebugT11,
    output signed [31:0] DebugT12,
    output signed [31:0] DebugT13,
    output signed [31:0] DebugT14,
    output signed [31:0] DebugT15,
    output signed [31:0] DebugT16,
    output signed [31:0] DebugT17,
    output signed [31:0] DebugT18,
    output signed [31:0] DebugT19,
    output signed [31:0] DebugT20,
    output signed [31:0] DebugT21,
    output signed [31:0] DebugT22,
    output signed [31:0] DebugT23,
    output signed [31:0] DebugT24,
    output signed [31:0] DebugT25,
    output signed [31:0] DebugT26,
    output signed [31:0] DebugT27,
    output signed [31:0] DebugT28,
    output signed [31:0] DebugT29,
    output signed [31:0] DebugT30,
    output signed [31:0] DebugT31,
    output signed [31:0] DebugT32,
    output signed [31:0] DebugT33,
    output signed [31:0] DebugT34,
    output signed [31:0] DebugT35,
    output signed [31:0] DebugT36,
    output signed [31:0] DebugT37,
    output signed [31:0] DebugT38,
    output signed [31:0] DebugT39,
    output signed [31:0] DebugR0,
    output signed [31:0] DebugR1,
    output signed [31:0] DebugR2,
    output signed [31:0] DebugR3,
    output signed [31:0] DebugR4,
    output signed [31:0] DebugR5,
    output signed [31:0] DebugR6,
    output signed [31:0] DebugR7,
    output signed [31:0] DebugR8,
    output signed [31:0] DebugR9,
    output signed [31:0] DebugSP,
    output signed [31:0] DebugGP,
    output signed [31:0] DebugJMP,
    output signed [31:0] DebugRA,
    output signed [31:0] DebugRET,
    output signed [31:0] DebugBR,
    output signed [31:0] DebugCTX,
    output signed [31:0] DebugK7,
    output signed [31:0] DebugAX0,
    output signed [31:0] DebugAX1,
    output signed [31:0] DebugAX2,
    output signed [31:0] DebugAX3,
    output signed [31:0] DebugCRT,
	output signed [31:0] Debug_7Seg,
	output [7:0] Debug_Kb_Byte,
	output [12:0] PC,
	output [31:0] Instruction,
	output Change_Context,
	output reg [1:0] Proc_ID,
	output [12:0] Context_PC,
	output [12:0] Mux_Stack_Out,
	output Halt,
	input PS2_KB_Clk,
	input PS2_KB_Data,
	output VGA_HS,
	output VGA_VS,
	output [7:0] VGA_Red,
	output [7:0] VGA_Green,
	output [7:0] VGA_Blue,
	output VGA_Blank_N,
	output VGA_Clk,
	output VGA_Sync_N
);


//==============================================================

reg [12:0] NPPC;
reg [12:0] Proc_PC[3:0];
reg [7:0] Kb_Byte;
reg OR_Branch;
reg Stack_Mux_Control;
wire [1:0] IO_Selection;
wire [12:0] Branch_Out;
wire [12:0] Jump_Out;
wire [12:0] NextPC;
wire [12:0] Ret_Add;
wire [4:0] ALU_Op;
wire ALU_Src;
wire ALU_True;
wire Branch;
wire Button;
wire Interrupt;
wire IO_Enable;
wire Jump_I;
wire Jump_R;
wire Long_Imm;
wire Mem_To_Reg;
wire Mem_Write;
wire Raw_Button;
wire Raw_Reset;
wire Reg_Write;
wire Reset;
wire [1:0] Draw_Select;
wire [31:0] Draw_Text_Color;
wire signed [31:0] ALU_Data_3;
wire signed [31:0] ALU_Result;
wire signed [31:0] Data_1;
wire signed [31:0] Data_2;
wire signed [31:0] Data_3;
wire signed [31:0] Data_From_Mem;
wire signed [31:0] Data_In;
wire signed [31:0] Data_To_Reg;
wire signed [31:0] Mem_Out;
wire signed [31:0] Out_Imm;
wire signed [31:0] Reg_Write_Data;
wire Stack_Enable;
wire Stack_Write;


//======================================================================================

assign Debug_Kb_Byte = Kb_Byte;
assign Reset = ~Raw_Reset_I;
assign Button = ~Raw_Button_I;

initial
begin
	Proc_PC[0] <= 13'd0;
	Proc_PC[1] <= 13'd1024;
	Proc_PC[2] <= 13'd2048;
	Proc_PC[3] <= 13'd3072;
	Proc_ID <= 2'b0;
end

always @ (negedge Slow_Clock)
begin
	if (Change_Context)
	begin
		Proc_PC[Proc_ID] = Mux_Stack_Out;
		Proc_ID = $unsigned(Data_1[1:0]);
		Context_PC = Proc_PC[Proc_ID];
	end
end

always @ (PC)
begin
	NPPC <= PC + 13'b1;
end

always @ (Branch or Jump_R or ALU_True)
begin
	OR_Branch <= (Branch & ALU_True) | Jump_R;
end

always @ (Stack_Enable or Stack_Write)
begin
	Stack_Mux_Control <= Stack_Enable & !(Stack_Write);
end


//======================================================================================

Program_Counter Program_Counter_0
(
	.Interrupt(Interrupt),
	.Reset(Reset),
	.Slow_Clock(Slow_Clock),
	.Halt(Halt),
	.NextPC(NextPC),
	.PC(PC)
);

ROM ROM_0
(
	.PC(PC),
	.Fast_Clock(Fast_Clock),
	.Instruction(Instruction)
);

Clock_Manager Clock_Manager_0
(
	.Reset(Reset),
	.Fast_Clock(Fast_Clock),
	.Slow_Clock(Slow_Clock)
);

Ctrl_Module Ctrl_Module_0
(
	.Instruction(Instruction[31:26]),
	.IO_Enable(IO_Enable),
	.IO_Selection(IO_Selection),
	.Reg_Write(Reg_Write),
	.Jump_R(Jump_R),
	.Jump_I(Jump_I),
	.Stack_Enable(Stack_Enable),
	.Stack_Write(Stack_Write),
	.Branch(Branch),
	.Mem_Write(Mem_Write),
	.Mem_To_Reg(Mem_To_Reg),
	.ALU_Op(ALU_Op),
	.ALU_Src(ALU_Src),
	.Halt(Halt),
	.Long_Imm(Long_Imm),
	.Change_Context(Change_Context),
	.Draw_Select(Draw_Select)
);

Reg_Bank Reg_Bank_0
(
	.DebugZERO(DebugZERO),
	.DebugT0(DebugT0),
	.DebugT1(DebugT1),
	.DebugT2(DebugT2),
	.DebugT3(DebugT3),
	.DebugT4(DebugT4),
	.DebugT5(DebugT5),
	.DebugT6(DebugT6),
	.DebugT7(DebugT7),
	.DebugT8(DebugT8),
	.DebugT9(DebugT9),
	.DebugT10(DebugT10),
	.DebugT11(DebugT11),
	.DebugT12(DebugT12),
	.DebugT13(DebugT13),
	.DebugT14(DebugT14),
	.DebugT15(DebugT15),
	.DebugT16(DebugT16),
	.DebugT17(DebugT17),
	.DebugT18(DebugT18),
	.DebugT19(DebugT19),
	.DebugT20(DebugT20),
	.DebugT21(DebugT21),
	.DebugT22(DebugT22),
	.DebugT23(DebugT23),
	.DebugT24(DebugT24),
	.DebugT25(DebugT25),
	.DebugT26(DebugT26),
	.DebugT27(DebugT27),
	.DebugT28(DebugT28),
	.DebugT29(DebugT29),
	.DebugT30(DebugT30),
	.DebugT31(DebugT31),
	.DebugT32(DebugT32),
	.DebugT33(DebugT33),
	.DebugT34(DebugT34),
	.DebugT35(DebugT35),
	.DebugT36(DebugT36),
	.DebugT37(DebugT37),
	.DebugT38(DebugT38),
	.DebugT39(DebugT39),
	.DebugR0(DebugR0),
	.DebugR1(DebugR1),
	.DebugR2(DebugR2),
	.DebugR3(DebugR3),
	.DebugR4(DebugR4),
	.DebugR5(DebugR5),
	.DebugR6(DebugR6),
	.DebugR7(DebugR7),
	.DebugR8(DebugR8),
	.DebugR9(DebugR9),
	.DebugSP(DebugSP),
	.DebugGP(DebugGP),
	.DebugJMP(DebugJMP),
	.DebugRA(DebugRA),
	.DebugRET(DebugRET),
	.DebugBR(DebugBR),
	.DebugCTX(DebugCTX),
	.DebugK7(DebugK7),
	.DebugAX0(DebugAX0),
	.DebugAX1(DebugAX1),
	.DebugAX2(DebugAX2),
	.DebugAX3(DebugAX3),
	.DebugCRT(DebugCRT),
	.Reset(Reset),
	.Slow_Clock(Slow_Clock),
	.Fast_Clock(Fast_Clock),
	.Reg_Write(Reg_Write),
	.Write_Data(Reg_Write_Data),
	.Reg_1(Instruction[25:20]),
	.Reg_2(Instruction[19:14]),
	.Reg_3(Instruction[13:8]),
	.Data_1(Data_1),
	.Data_2(Data_2),
	.Data_3(Data_3),
	.Draw_Text_Color(Draw_Text_Color)
);

Extend_Imm Extend_Imm_0
(
	.In_Imm(Instruction[19:0]),
	.Long_Imm(Long_Imm),
	.Out_Imm(Out_Imm)
);

ALU ALU_0
(
	.True(ALU_True),
	.Result(ALU_Result),
	.Fast_Clock(Fast_Clock),
	.Input_1(Data_2),
	.Input_2(ALU_Data_3),
	.ALU_Op(ALU_Op)
);

Stack_Reg Stack_Reg_0
(
	.Reset(Reset),
	.Slow_Clock(Slow_Clock),
	.Stack_Write(Stack_Write),
	.Stack_Enable(Stack_Enable),
	.NPPC(NPPC),
	.Ret_Add(Ret_Add),
	.Err_Out(Err_Out)
);

RAM RAM_0
(
	.Write_Data(Data_1),
	.Address(ALU_Result[15:0]),
	.Mem_Write(Mem_Write),
	.Fast_Clock(Fast_Clock),
	.Slow_Clock(Slow_Clock),
	.Read_Data(Mem_Out)
);

PS2 PS2_0
(
	.KB_Clk(PS2_KB_Clk),
	.KB_Data(PS2_KB_Data),
	.Kb_Byte(Kb_Byte)
);

IO_Module IO_Module_0
(
	.Slow_Clock(Slow_Clock),
	.Fast_Clock(Fast_Clock),
	.Reset(Reset),
	.Enable(IO_Enable),
	.IO(IO_Selection),
	.Confirm(Button),
	.Data_In(Data_In),
	.Data_1(Data_1),
	.Data_2(Data_2),
	.Data_3(Data_3),
	.Debug_7Seg(Debug_7Seg),
	.Raw_Input(Raw_Input),
	.Interrupt(Interrupt),
	.Display0(Display0),
	.Display1(Display1),
	.Display2(Display2),
	.Display3(Display3),
	.Display4(Display4),
	.Display5(Display5),
	.Display6(Display6),
	.Display7(Display7),
	.Kb_Byte(Kb_Byte),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_Clk(VGA_Clk),
	.VGA_Red(VGA_Red),
	.VGA_Green(VGA_Green),
	.VGA_Blue(VGA_Blue),
	.VGA_Blank_N(VGA_Blank_N),
	.VGA_Sync_N(VGA_Sync_N),
	.Draw_Select(Draw_Select),
	.Draw_Text_Color(Draw_Text_Color)
);

Mux #(.BITS(32)) Mux_Mem
(
	.Switch(Mem_To_Reg),
	.Data_0(ALU_Result),
	.Data_1(Mem_Out),
	.Data_Out(Data_From_Mem)
);

Mux #(.BITS(32)) Mux_ALU
(
	.Switch(ALU_Src),
	.Data_0(Data_3),
	.Data_1(Out_Imm),
	.Data_Out(ALU_Data_3)
);

Mux #(.BITS(32)) Mux_IO_to_Mem
(
	.Switch(IO_Enable),
	.Data_0(Data_From_Mem),
	.Data_1(Data_In),
	.Data_Out(Reg_Write_Data)
);

Mux #(.BITS(13)) Mux_Branch
(
	.Switch(OR_Branch),
	.Data_0(NPPC),
	.Data_1(Data_1[12:0]),
	.Data_Out(Branch_Out)
);

Mux #(.BITS(13)) Mux_Jump
(
	.Switch(Jump_I),
	.Data_0(Branch_Out),
	.Data_1(Out_Imm[12:0]),
	.Data_Out(Jump_Out)
);

Mux #(.BITS(13)) Mux_Stack
(
	.Switch(Stack_Mux_Control),
	.Data_0(Jump_Out),
	.Data_1(Ret_Add),
	.Data_Out(Mux_Stack_Out)
);

Mux #(.BITS(13)) Mux_Context
(
	.Switch(Change_Context),
	.Data_0(Mux_Stack_Out),
	.Data_1(Context_PC),
	.Data_Out(NextPC)
);

//Debounce DB0 (Fast_Clock, 0, Raw_Button, Button);
//Debounce DB1 (Fast_Clock, 0, Raw_Reset, Reset);

endmodule