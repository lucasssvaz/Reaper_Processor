module Reaper_Processor
(
	input Raw_Button_I,
	input [17:0] Raw_Input,
	input Sys_Clock,
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
	output [31:0] Debug,
	output [31:0] Out_Int,
	output [7:0] PC,
	output Clock
);


//==============================================================

wire Raw_Button;
assign Button = ~Raw_Button_I;
wire Raw_Reset;
assign Reset = ~Raw_Reset_I;
reg [7:0] NPPC;
//wire Clock;
wire Halt;
//wire [7:0] PC;
wire [7:0] NextPC;
wire [31:0] Instruction;
wire Interrupt;
wire IO_Enable;
wire IO_Selection;
wire Reg_Write;
wire R_Type;
wire Jump;
wire Stack_Enable;
wire Stack_Write;
wire Branch;
wire Mem_Write;
wire W_Only;
wire Mem_To_Reg;
wire [4:0] ALU_Op;
wire ALU_Src;
wire Long_Imm;
wire [5:0] Mux_RT_Out;
wire [5:0] Mux_WO_Out;
wire [31:0] Reg_Write_Data;
wire [31:0] Data_1;
wire [31:0] Data_2;
wire [31:0] Data_3;
wire [31:0] Out_Imm;
wire [31:0] Data_To_Reg;
wire [31:0] Data_In;
wire [31:0] Data_From_Mem;
wire [7:0] Ret_Add;
wire ALU_True;
wire [31:0] ALU_Result;
wire [31:0] ALU_Data_2;
wire Button;
reg AND_Branch;
wire [7:0] Branch_Out;
wire [7:0] Jump_Out;
reg Stack_Mux_Control;
wire [31:0] Mem_Out;
wire Reset;


//======================================================================================


always @ (PC)
begin
	NPPC <= PC + 1;
end

always @ (Branch or ALU_True)
begin
	AND_Branch <= Branch & ALU_True;
end

always @ (Stack_Enable or Stack_Write)
begin
	Stack_Mux_Control <= Stack_Enable & !(Stack_Write);
end


//======================================================================================

Program_Counter Program_Counter0 (.Interrupt(Interrupt), .Reset(Reset), .Sys_Clock(Clock), .Halt(Halt), .NextPC(NextPC), .PC(PC));

ROM ROM0 (.PC(PC), .Sys_Clock(Sys_Clock), .Instruction(Instruction));

ClockManager ClockManager0 (.Reset(Reset), .Clk(Sys_Clock), .New_Clock(Clock));

Ctrl_Module Ctrl_Module0 (Instruction[31:26], IO_Enable, IO_Selection, Reg_Write, R_Type, Jump, Stack_Enable, Stack_Write, Branch, Mem_Write, W_Only, Mem_To_Reg, ALU_Op, ALU_Src, Halt, Long_Imm);

Mux6 Mux_R_Type (.Switch(R_Type), .Data_0(Instruction[19:14]), .Data_1(Instruction[13:8]), .Data_Out(Mux_RT_Out));

Mux6 Mux_W_Only (.Switch(W_Only), .Data_0(Mux_RT_Out), .Data_1(Instruction[25:20]), .Data_Out(Mux_WO_Out));

RegFile RegFile0 (Debug, Reset, Clock, Sys_Clock, Reg_Write, Reg_Write_Data, Instruction[25:20], Instruction[19:14], Mux_WO_Out, Data_1, Data_2, Data_3);

Extend_Imm Extend_Imm0 (Instruction[19:0], Long_Imm, Out_Imm);

ALU ALU0 (ALU_True, ALU_Result, Sys_Clock, Data_1, ALU_Data_2, ALU_Op);

Mux32 Mux_ALU (.Switch(ALU_Src), .Data_0(Data_2), .Data_1(Out_Imm), .Data_Out(ALU_Data_2));

StackFile StackFile0 (Reset, Clock, Stack_Write, Stack_Enable, NPPC, Ret_Add, Err_Out);

RAM RAM0 (Data_2, ALU_Result[15:0], Mem_Write, Sys_Clock, Clock,	Mem_Out);

Mux32 Mux_Mem (.Switch(Mem_To_Reg), .Data_0(ALU_Result), .Data_1(Mem_Out), .Data_Out(Data_From_Mem));

IO_Module IO_Module0 (Clock, Reset, IO_Enable, IO_Selection, Button, Data_In, Data_1, Out_Int, Raw_Input, Interrupt, Display0, Display1, Display2, Display3, Display4, Display5, Display6, Display7);

//Debounce DB0 (Sys_Clock, 0, Raw_Button, Button);

//Debounce DB1 (Sys_Clock, 0, Raw_Reset, Reset);

//assign Reg_Write_Data = Data_From_Mem;

Mux32 Mux_IO (.Switch(IO_Enable), .Data_0(Data_From_Mem), .Data_1(Data_In), .Data_Out(Reg_Write_Data));

Mux8 Mux_Branch (.Switch(AND_Branch), .Data_0(NPPC), .Data_1(Data_3[7:0]), .Data_Out(Branch_Out));

Mux8 Mux_Jump (.Switch(Jump), .Data_0(Branch_Out), .Data_1(Data_1[7:0]), .Data_Out(Jump_Out));

Mux8 Mux_Stack (.Switch(Stack_Mux_Control), .Data_0(Jump_Out), .Data_1(Ret_Add), .Data_Out(NextPC));


endmodule