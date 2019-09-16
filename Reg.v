module RegFile
(
    output [31:0] Debug2,       //Outputs Reg 2
    output [31:0] Debug3,       //Outputs Reg 3
    input Reset,                //Makes sure Reg 0 is always 0
    input Slow_Clock,           //Write Clock
    input Reg_Write,            //Write to Reg Flag
    input [31:0] Write_Data,    //Data that will be written in the Reg selected by Reg_WR
    input [5:0] Reg_1,          //First Register Selection (Read)
    input [5:0] Reg_2,          //Second Register Selection (Read)
    input [5:0] Reg_WR,         //Third Register Selection (Read or Write)
    output [31:0] Data_1,   //Data that will outputted by the Reg selected by Reg_1
    output [31:0] Data_2,   //Data that will outputted by the Reg selected by Reg_2
    output [31:0] Data_3    //Data that will outputted by the Reg selected by Reg_WR
);

reg [31:0] RegBank[63:0];

assign Data_1 = RegBank[Reg_1];
assign Data_2 = RegBank[Reg_2];
assign Data_3 = RegBank[Reg_WR];

assign Debug2 = RegBank[2];
assign Debug3 = RegBank[3];

always @ (negedge Slow_Clock)
begin
	if (Reset)
	begin
		RegBank[0] <= {32{1'b0}};
	end
	else if (Reg_Write && (Reg_WR != 6'b000000))
	begin
		RegBank[Reg_WR] <= Write_Data;
	end
end

endmodule