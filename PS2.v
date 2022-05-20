// KB Only - Updates on key release
module PS2
(
	input KB_Clk,
	input KB_Data,
	output reg [7:0] KB_Char
);

reg [7:0] Recv_Buffer;
reg [7:0] Data_Recv;
reg [3:0] Bit_Counter;
reg Flag_Done;

localparam [7:0] RELEASE_BIT = 8'hF0;

initial
begin
	Bit_Counter <= 4'b0;
	Flag_Done <= 1'b0;
	Recv_Buffer <= RELEASE_BIT;
	Data_Recv <= RELEASE_BIT;
	KB_Char <= RELEASE_BIT;
end

always @ (negedge KB_Clk)
begin
	case(Bit_Counter)
		0: ; //first bit
		1: Recv_Buffer[0] <= KB_Data;
		2: Recv_Buffer[1] <= KB_Data;
		3: Recv_Buffer[2] <= KB_Data;
		4: Recv_Buffer[3] <= KB_Data;
		5: Recv_Buffer[4] <= KB_Data;
		6: Recv_Buffer[5] <= KB_Data;
		7: Recv_Buffer[6] <= KB_Data;
		8: Recv_Buffer[7] <= KB_Data;
		9: Flag_Done <= 1'b1; //Parity bit
		10: Flag_Done <= 1'b0; //Ending bit
	endcase

	if(Bit_Counter <= 9)
		Bit_Counter <= Bit_Counter + 1;
	else if(Bit_Counter == 10)
		Bit_Counter <= 0;
end

always @ (posedge Flag_Done)
begin
	if(Recv_Buffer == RELEASE_BIT)
		KB_Char <= Data_Recv;
	else
 		Data_Recv <= Recv_Buffer;
end

endmodule