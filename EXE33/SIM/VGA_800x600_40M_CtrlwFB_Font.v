module	VGA_Ctrl	(	//	Host Side
				oCurrent_X,
				oCurrent_Y,
				oRequest,
				//	VGA Side
				oVGA_HS,
				oVGA_VS,
				oVGA_SYNC,
				oVGA_BLANK,
				oVGA_R,
				oVGA_G,
				oVGA_B,
				//	Control Signal
				iCLK,	// 40MHz
				iRST_N,

				write_x,
				write_y,
				write_r,
				write_g,
				write_b,
				// Character Display
				char_x,
				char_y,
				char_code


	);
   //	Host Side
   output [10:0] 		oCurrent_X;
   output [10:0] 		oCurrent_Y;
   output 			oRequest;
   //	VGA Side
   output	reg 		oVGA_HS;
   output	reg 		oVGA_VS;
   output 			oVGA_SYNC;
   output 			oVGA_BLANK;
   //	Control Signal
   input 			iCLK;
   input 			iRST_N;	
   //	VRAM RW
   output [7:0] 		oVGA_R, oVGA_G, oVGA_B;
   input [7:0] 			write_x, write_y;
   input [2:0] 			write_r, write_g, write_b;
   // Char display
   input [4:0] 			char_x;
   input [3:0] 			char_y;
   input [7:0] 			char_code;
	
   //	Internal Registers
   reg [10:0] 			H_Cont;
   reg [10:0] 			V_Cont;
   ////////////////////////////////////////////////////////////
   //	Horizontal	Parameter
   parameter	H_FRONT	=	40;
   parameter	H_SYNC	=	128;
   parameter	H_BACK	=	88;
   parameter	H_ACT	=	800;
   parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK;
   parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT;  // 1056
   ////////////////////////////////////////////////////////////
   //	Vertical Parameter
   parameter	V_FRONT	=	1;
   parameter	V_SYNC	=	4;
   parameter	V_BACK	=	23;
   parameter	V_ACT	=	600;
   parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;
   parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;  // 628
   ////////////////////////////////////////////////////////////
   assign	oVGA_SYNC	=	1'b1;			//	This pin is unused.
   assign	oVGA_BLANK	=	~((H_Cont<H_BLANK)||(V_Cont<V_BLANK));
   assign	oRequest	=	((H_Cont>=H_BLANK && H_Cont<H_TOTAL)	&&
					 (V_Cont>=V_BLANK && V_Cont<V_TOTAL));
   assign	oCurrent_X	=	(H_Cont>=H_BLANK-1)	?	H_Cont-H_BLANK+1:	11'h0	;
   assign	oCurrent_Y	=	(V_Cont>=V_BLANK)	?	V_Cont-V_BLANK	:	11'h0	;
   wire [10:0] 			HACT;
   assign HACT = H_ACT;
   wire [15:0] 			NextVAddr;
   wire [8:0] 			vramout;
   wire [15:0] 			write_addr;

		wire [7:0]  fontdata;
   wire [7:0] 			X, Y;
   ///  rotate
//   assign X = oCurrent_X[7:0];
//   assign Y = oCurrent_Y[7:0];
   ///  rotate (2x2 pixels)
   assign X = oCurrent_X[8:1];
   assign Y = oCurrent_Y[8:1];
   

   reg [8:0] 			vramR;
	

   assign	write_addr = {write_y, write_x};

   
   wire [9:0] 			cwraddress, crdaddress;
   wire [7:0] 			cw_code, cr_code;
   wire [7:0] 			font_code;
   wire [10:0] 			fontaddr;
   
   assign cwraddress = {char_x, char_y};
   assign cw_code = char_code - 'h 20;

   assign crdaddress = {NextVAddr[15:11], NextVAddr[7:4]};
   assign fontaddr = {cr_code[6:0],NextVAddr[3:0]};
   reg [2:0] 			cxnext1, cxnext2, cxnext3, cxnext4;
   

	
   assign	NextVAddr = {X, Y};
// Blank
   assign	oVGA_R = (oCurrent_X >= 11 'b 010_0000_0000 || oCurrent_Y >= 11 'b 010_0000_0000 ) ? 8'b 0 : 
			 (cr_code == 0 ? {vramR[8:6],5'b 0} : {8{fontdata[cxnext2]}});
   assign	oVGA_G = (oCurrent_X >= 11 'b 010_0000_0000 || oCurrent_Y >= 11 'b 010_0000_0000 ) ? 8'b 0 : 
			 (cr_code == 0 ? {vramR[5:3],5'b 0} : {8{fontdata[cxnext2]}});
   assign	oVGA_B = (oCurrent_X >= 11 'b 010_0000_0000 || oCurrent_Y >= 11 'b 010_0000_0000 ) ? 8'b 0 : 
			 (cr_code == 0 ? {vramR[2:0],5'b 0} : {8{fontdata[cxnext2]}});
// Repeat
//   assign	oVGA_R = {vramR[8:6],5'b 0};
//   assign	oVGA_G = {vramR[5:3],5'b 0};
//   assign	oVGA_B = {vramR[2:0],5'b 0};

   always @(posedge iCLK) begin
      vramR <= vramout;
      cxnext1 <= NextVAddr[10:8];
      cxnext2 <= cxnext1;
      cxnext3 <= cxnext2;
      cxnext4 <= cxnext3;
   end


//   reg crom[0:65535];
//   wire cc=crom[{cr_code,NextVAddr[11:8], NextVAddr[3:0]}];




   // Character Frame Buffer 512w x 8bit code
   // CRAM x:32 x y:16 (512w x 9bit)
   cram	u11 (
	     .clock(iCLK),
	     .data(cw_code),
             .wraddress(cwraddress),
             .wren(1'b 1),
             .rdaddress(crdaddress),
             .q(cr_code)
	     );
// Font Memory (Read Only 1520w x 8bit) (2048w(=11bit))
   font u12 (
	     .clock(iCLK),
             .address(fontaddr),
             .q(fontdata)
	     );


   // VRAM 256 x 256 (65,536w x 9bit)
   vram64k	u10 (
		     .clock(iCLK),
		     .data({write_r,write_g,write_b}),
		     .wraddress(write_addr),
		     .wren(1'b 1),
		     .rdaddress(NextVAddr),
		     .q(vramout)
		     );


   
   //	Horizontal Generator: Refer to the pixel clock
   always@(posedge iCLK or negedge iRST_N)
     begin
	if(!iRST_N)
	  begin
	     H_Cont		<=	0;
	     oVGA_HS		<=	1;
	  end
	else
	  begin
	     if(H_Cont<H_TOTAL-1)
	       H_Cont	<=	H_Cont+1'b1;
	     else
	       H_Cont	<=	0;
	     //	Horizontal Sync
	     if(H_Cont==H_FRONT-1)			//	Front porch end
	       oVGA_HS	<=	1'b0;
	     if(H_Cont==H_FRONT+H_SYNC-1)	//	Sync pulse end
	       oVGA_HS	<=	1'b1;
	  end
     end
   
//	Vertical Generator: Refer to the horizontal sync
   always@(posedge oVGA_HS or negedge iRST_N)
     begin
	if(!iRST_N)
	  begin
	     V_Cont		<=	0;
	     oVGA_VS		<=	1;
	  end
	else
	  begin
	     if(V_Cont<V_TOTAL-1)
	       V_Cont	<=	V_Cont+1'b1;
	     else
	       V_Cont	<=	0;
	     //	Vertical Sync
	     if(V_Cont==V_FRONT-1)			//	Front porch end
	       oVGA_VS	<=	1'b0;
	     if(V_Cont==V_FRONT+V_SYNC-1)	//	Sync pulse end
	       oVGA_VS	<=	1'b1;
	  end
     end
endmodule
