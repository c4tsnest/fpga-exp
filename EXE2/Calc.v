module Calc( CLK, data_ready, hex_data, Dig0, Dig1, Dig2, Dig3, Dig4, Dig5, CalcType);
   input CLK, data_ready;
   input [7:0] hex_data;
   output [3:0] Dig0, Dig1, Dig2, Dig3, Dig4, Dig5;
   output [1:0] CalcType;
   
   
//=============================================================================
// For IR
//=============================================================================
   // A    0x0F, B 0x13, C   0x10, Pow 0x12
   // 1    0x01, 2 0x02, 3   0x03, ^   0x1A
   // 4    0x04, 5 0x05, 6   0x06, v   0x1E
   // 7    0x07, 8 0x08, 9   0x09, ^   0x1B
   // Note 0x11, 0 0x00, Ret 0x17, v   0x1F
   // >||  0x16, < 0x14, >   0x18, Mut 0x0C
//=============================================================================

   reg [15:0] 	Accum, Datain, OldData;
   reg [15:0] 	Calc;
   reg [1:0] 	CalcType;  // 0: Add, 1: Sub, 2: Mul, 3: Div
   reg [2:0] 	Cnt;
   reg 		DispFlag;
   reg 		odataready, oodataready;
   reg [3:0] 	Dig0, Dig1, Dig2, Dig3, Dig4, Dig5;
   
   wire [15:0] 	DispNum, D10;
   assign DispNum = (DispFlag == 0) ? Datain : Accum;
   assign  D10 = Datain * 'd10;

   always @(posedge CLK) begin
      OldData <= DispNum;
      if( DispNum != OldData ) Cnt <= 5;
      if( Cnt != 0 ) begin
	 case (Cnt)
	   5 :
	     begin
		Dig0 <= OldData % 10;
		Calc <= OldData / 10;
	     end
	   4 :
	     begin
		Dig1 <= Calc % 10;
		Calc <= Calc / 10;
	     end
	   3 :
	     begin
		Dig2 <= Calc % 10;
		Calc <= Calc / 10;
	     end
	   2 :
	     begin
		Dig3 <= Calc % 10;
		Calc <= Calc / 10;
	     end
	   1 :
	     begin
		Dig4 <= Calc % 10;
		Calc <= Calc / 10;
	     end
	 endcase
	 Cnt <= Cnt -1;
      end

      odataready <= data_ready;
      oodataready <= odataready;
      if( odataready && !oodataready ) begin
	 case ( hex_data )
	   8'h 12 : // Pow, Reset
	     begin
		Accum <= 0;
		Datain <= 0;
		CalcType <= 0;
		DispFlag <= 0;
	     end
	   8'h 00, 8'h 01, 8'h 02, 8'h 03, 8'h 04, 8'h 05, 8'h 06, 8'h 07, 8'h 08, 8'h 09 :
	     begin
		Datain <= D10 + {12'b0,hex_data[3:0]};
		DispFlag <= 0;
	     end
	   8'h 0C, 8'h 1A, 8'h 1E, 8'h 1B, 8'h 1F :
	     begin
		DispFlag <= 1;
		Datain <= 0;
		case ( hex_data )
		  8'h 1A : CalcType <= 3;
		  8'h 1E : CalcType <= 2;
		  8'h 1B : CalcType <= 1;
		  8'h 1F : CalcType <= 0;
		endcase
		case (CalcType)
		  0 : Accum <= Accum + Datain;
		  1 : Accum <= Accum - Datain;
		  2 : Accum <= Accum * Datain;
		  3 : Accum <= Accum / Datain;
		endcase
	     end
	   
	 endcase //
	 
      end
   end

endmodule // Calc
	     
