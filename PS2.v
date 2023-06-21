// KB Only - Updates on key release
module PS2
(
	input KB_Clk,
	input KB_Data,
	output reg [7:0] Kb_Byte
	//output reg [7:0] Data_Recv,
	//output reg [7:0] Last_Data,
	//output reg [23:0] Recv_Buffer
);

reg [3:0] Bit_Counter;
reg Flag_Done;
reg [7:0] Data_Recv;
reg [7:0] Last_Data;
reg [23:0] Recv_Buffer;

localparam [7:0] RELEASE_BIT = 8'hF0;

initial begin
	Bit_Counter <= 4'b0;
	Flag_Done <= 1'b0;
	Recv_Buffer <= RELEASE_BIT;
	Data_Recv <= RELEASE_BIT;
	Kb_Byte <= RELEASE_BIT;
	Last_Data <= 8'hF1;
end

always @ (negedge KB_Clk) begin
	case(Bit_Counter)
		0: ; //Start bit
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
		Bit_Counter <= Bit_Counter + 4'b1;
	else if(Bit_Counter == 10)
	begin
		Bit_Counter <= 0;
	end
end

always @ (posedge Flag_Done) begin
	Data_Recv <= Recv_Buffer;
	
	if(Data_Recv != Last_Data) begin
		Kb_Byte <= Data_Recv;
	end
	
	Last_Data <= Data_Recv;
end
endmodule