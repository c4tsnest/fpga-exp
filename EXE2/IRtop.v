module IRtop (
	       	//////////// CLOCK //////////
	input 	     CLK,

	//////////// KEY //////////
	input [3:0]  KEY,

	//////////// SW //////////
	input [9:0]  SW,

	//////////// LED //////////
	output [9:0] LEDR,

	//////////// Seg7 //////////
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,

	//////////// IR //////////
	input 	     IRDA_RXD,
	output 	     IRDA_TXD
);

   wire 					CLK50;
   
//=============================================================================
// For IR
//=============================================================================
   wire 					data_ready;        //IR data_ready flag
   wire [31:0] 					hex_data;   //seg data input
   // hex_data[23:16] Code assign
   // A    0x0F, B 0x13, C   0x10, Pow 0x12
   // 1    0x01, 2 0x02, 3   0x03, ^   0x1A
   // 4    0x04, 5 0x05, 6   0x06, v   0x1E
   // 7    0x07, 8 0x08, 9   0x09, ^   0x1B
   // Note 0x11, 0 0x00, Ret 0x17, v   0x1F
   // >||  0x16, < 0x14, >   0x18, Mut 0x0C
//=============================================================================

   wire [1:0] 					CalcType;  // 0: Add, 1: Sub, 2: Mul, 3: Div
   wire [3:0] 					Dig0, Dig1, Dig2, Dig3, Dig4, Dig5;
  
   
   Calc calc( CLK, data_ready, hex_data[23:16], Dig0, Dig1, Dig2, Dig3, Dig4, Dig5, CalcType );

   assign LEDR = {hex_data[23:16],CalcType};
   
   SEG_HEX uu2( //display the HEX on HEX0                               
		.iDIG(Dig0),
		.oHEX_D(HEX0)
		);  
   SEG_HEX uu3( //display the HEX on HEX1                                
		.iDIG(Dig1),         
		.oHEX_D(HEX1)
		);
   SEG_HEX uu4(//display the HEX on HEX2                                
		.iDIG(Dig2),         
               .oHEX_D(HEX2)
               );
   SEG_HEX uu5(//display the HEX on HEX3                                 
		.iDIG(Dig3),         
               .oHEX_D(HEX3)
               );
   SEG_HEX uu6(//display the HEX on HEX4                                 
		.iDIG(Dig4),         
               .oHEX_D(HEX4)
               );
   SEG_MRK uu9(//display the 
               .iDIG(CalcType) ,
               .oHEX_D(HEX5)
               );           
   
   
   IR_RECEIVE u1(
		 ///clk 50MHz////
		 .iCLK(CLK), 
		 //reset          
		 .iRST_n(1'b 1),        
		 //IRDA code input
		 .iIRDA(IRDA_RXD), 
		 //read command      
		 //.iREAD(data_read),
		 //data ready      					
		 .oDATA_READY(data_ready),
		 //decoded data 32bit
		 .oDATA(hex_data)        
		 );

endmodule // VGAtop

`define SEG_OUT_0 7'b011_1111
`define SEG_OUT_1 7'b000_0110
`define SEG_OUT_2 7'b101_1011
`define SEG_OUT_3 7'b100_1111
`define SEG_OUT_4 7'b110_0110
`define SEG_OUT_5 7'b110_1101
`define SEG_OUT_6 7'b111_1101
`define SEG_OUT_7 7'b010_0111
`define SEG_OUT_8 7'b111_1111
`define SEG_OUT_9 7'b110_1111
`define SEG_OUT_A 7'b111_0111
`define SEG_OUT_B 7'b111_1100
`define SEG_OUT_C 7'b011_1001
`define SEG_OUT_D 7'b101_1110
`define SEG_OUT_E 7'b111_1001
`define SEG_OUT_F 7'b111_0001

module SEG_MRK (
		////////////////////	4 Binary bits Input	 	////////////////////	 
		iDIG,							
		////////////////////	HEX 7-SEG Output	 	////////////////////	 
		oHEX_D		
		);

   input	  [1:0]   iDIG;				
   output [6:0] 	  oHEX_D;   

   reg [6:0] 		  oHEX_D;	

   always @(iDIG) 
     begin
	case(iDIG)
	  2'h0: oHEX_D <= ~(7'b 111_0000);
	  2'h1: oHEX_D <= ~(7'b 100_0000);
	  2'h2: oHEX_D <= ~(7'b 111_0110);
	  3'h3: oHEX_D <= ~(7'b 101_0010);
	  default: oHEX_D <= ~(7'b 111_0000);
	endcase
     end
endmodule

module SEG_HEX (
		////////////////////	4 Binary bits Input	 	////////////////////	 
		iDIG,							
		////////////////////	HEX 7-SEG Output	 	////////////////////	 
		oHEX_D		
		);

   input	  [3:0]   iDIG;				
   output [6:0] 	  oHEX_D;   

   reg [6:0] 		  oHEX_D;	

   always @(iDIG) 
     begin
	case(iDIG)
	  4'h0: oHEX_D <= ~(`SEG_OUT_0);
	  4'h1: oHEX_D <= ~(`SEG_OUT_1);
	  4'h2: oHEX_D <= ~(`SEG_OUT_2);
	  4'h3: oHEX_D <= ~(`SEG_OUT_3);
	  4'h4: oHEX_D <= ~(`SEG_OUT_4);
	  4'h5: oHEX_D <= ~(`SEG_OUT_5);
	  4'h6: oHEX_D <= ~(`SEG_OUT_6);
	  4'h7: oHEX_D <= ~(`SEG_OUT_7);
	  4'h8: oHEX_D <= ~(`SEG_OUT_8);
	  4'h9: oHEX_D <= ~(`SEG_OUT_9);
	  4'ha: oHEX_D <= ~(`SEG_OUT_A);
	  4'hb: oHEX_D <= ~(`SEG_OUT_B);
	  4'hc: oHEX_D <= ~(`SEG_OUT_C);
	  4'hd: oHEX_D <= ~(`SEG_OUT_D);
	  4'he: oHEX_D <= ~(`SEG_OUT_E);
	  4'hf: oHEX_D <= ~(`SEG_OUT_F);
	  default: oHEX_D <= ~(`SEG_OUT_0);
	endcase
     end
endmodule
