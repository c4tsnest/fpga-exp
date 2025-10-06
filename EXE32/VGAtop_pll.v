// require VGA_Ctrl.v


module VGAtop (
	       	//////////// CLOCK //////////
	input 		          		CLK,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);


   wire [10:0] 					VGA_X;
   wire [10:0] 					VGA_Y;
   
   wire [7:0] 					Xposin, Yposin;
   wire [8:0] 					RGBposin;
   
   wire 					CLK40;
   
   assign NRST = KEY[0];
   assign VGA_CLK = CLK40;
   assign LEDR = SW;
   
   
   wire [7:0] 					posx, posy;
   wire [2:0] 					posr, posg, posb;
   wire [7:0] 					posxw, posyw;
   wire [2:0] 					posrw, posgw, posbw;
   
   reg 						putpixel, k3;
	reg [3:0] putcnt;
   
   assign posxw = (putpixel == 0) ? posx : Xposin;
   assign posyw = (putpixel == 0) ? posy : Yposin;
   assign posrw = (putpixel == 0) ? posr : RGBposin[8:6];
   assign posgw = (putpixel == 0) ? posg : RGBposin[5:3];
   assign posbw = (putpixel == 0) ? posb : RGBposin[2:0];
   
   always @(posedge CLK40) begin
      if( !NRST ) begin
	 putpixel <= 0;
	 k3 <= 1;
      end else begin
	 if( k3 == 1 && KEY[3] == 0 ) begin
	    putpixel <= 1;
		 putcnt <=1;
	 end else if( putpixel == 1 ) begin
		if( putcnt == 0 ) putpixel <= 0;
		putcnt <= putcnt + 1;
	 end
	 k3 <= KEY[3];
	 
      end
   end
   
   XYtoHEX  u6(.clk(CLK40), .NRST(NRST), .Xposin(Xposin), .Yposin(Yposin), 
	       .HEX0(HEX0),
	       .HEX1(HEX1),
	       .HEX2(HEX2),
	       .HEX3(HEX3),
	       .HEX4(HEX4),
	       .HEX5(HEX5) );
   
   
   XYRGBinput  u7( .clk(CLK40),  .NRST(NRST), .SW(SW), .key(KEY), .Xin(Xposin), .Yin(Yposin), .RGBin(RGBposin) );
   
   
   pll pll (.refclk(CLK), .rst(~NRST), .outclk_0(CLK40));
   
   draw  u8 (.CLK(CLK40), .NRST(NRST), .X(posx), .Y(posy), .R(posr), .G(posg), .B(posb) );
   
   VGA_Ctrl	u9	(	//	Host Side
				.oCurrent_X(VGA_X),
				.oCurrent_Y(VGA_Y),
				.oRequest(VGA_Read),
				//	VGA Side
				.oVGA_HS(VGA_HS),
				.oVGA_VS(VGA_VS),
				.oVGA_SYNC(VGA_SYNC_N),
				.oVGA_BLANK(VGA_BLANK_N),
				.oVGA_R(VGA_R),
				.oVGA_G(VGA_G),
				.oVGA_B(VGA_B),

				//	Control Signal
				.iCLK(CLK40),
				.iRST_N(NRST),
			
		
				.write_x(posxw),
				.write_y(posyw),
				.write_r(posrw),
				.write_g(posgw),
				.write_b(posbw)
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

module XYtoHEX(input clk, input NRST, input [7:0] Xposin, input [7:0] Yposin,
	       output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 );
   
   
   reg [2:0] 			STX, STY;
   reg [3:0] 			DX0, DX1, DX2, DY0, DY1, DY2;
   reg [7:0] 			Xi, Yi;
   
   wire [8:0] 			XX, YY;
   
   assign XX = (STX==1) ? Xi - 8'd 100 :
	       (STX==2) ? Xi - 8'd 10 : Xi;
   assign YY = (STY==1) ? Yi - 8'd 100 :
	       (STY==2) ? Yi - 8'd 10 : Yi;
   
   always @(posedge clk) begin
      if( !NRST) begin
	 DX0 <= 0;
	 DX1 <= 0;
	 DX2 <= 0;
	 DY0 <= 0;
	 DY1 <= 0;
	 DY2 <= 0;
	 STX <= 0;
	 STY <= 0;
      end else begin
	 if( STX == 0 ) begin
	    Xi <= Xposin;
	    STX <= 1;
	    HEX0 <= SEG7DEC(DX0);
	    HEX1 <= SEG7DEC(DX1);
	    HEX2 <= SEG7DEC(DX2);
	    DX0 <= 0;
	    DX1 <= 0;
	    DX2 <= 0;
	    
	 end else if( STX == 1 ) begin
	    if( XX[8] == 1 ) STX <= 2;
	    else begin
	       Xi <= XX[7:0];
	       DX2 <= DX2 + 1;
	    end
	 end else if( STX == 2 ) begin
	    if( XX[8] == 1 ) STX <= 3;
	    else begin
	       Xi <= XX[7:0];
	       DX1 <= DX1 + 1;
	    end
	 end else if( STX == 3 ) begin
	    DX0 <= Xi[3:0];
	    STX <= 0;
	 end
	 if( STY == 0 ) begin
	    Yi <= Yposin;
	    STY <= 1;
	    HEX3 <= SEG7DEC(DY0);
	    HEX4 <= SEG7DEC(DY1);
	    HEX5 <= SEG7DEC(DY2);
		 	 DY0 <= 0;
	 DY1 <= 0;
	 DY2 <= 0;
	 end else if( STY == 1 ) begin
	    if( YY[8] == 1 ) STY <= 2;
	    else begin
	       Yi <= YY[7:0];
	       DY2 <= DY2 + 1;
	    end
	 end else if( STY == 2 ) begin
	    if( YY[8] == 1 ) STY <= 3;
	    else begin
	       Yi <= YY[7:0];
	       DY1 <= DY1 + 1;
	    end
	 end else if( STY == 3 ) begin
	    DY0 <= Yi[3:0];
	    STY <= 0;
	 end
      end
   end

   function[6:0] SEG7DEC;
      input [3:0] 	    IN;
      case(IN)
	0:SEG7DEC = ~(`SEG_OUT_0);
	1:SEG7DEC = ~(`SEG_OUT_1);
	2:SEG7DEC = ~(`SEG_OUT_2);
	3:SEG7DEC = ~(`SEG_OUT_3);
	4:SEG7DEC = ~(`SEG_OUT_4);
	5:SEG7DEC = ~(`SEG_OUT_5);
	6:SEG7DEC = ~(`SEG_OUT_6);
	7:SEG7DEC = ~(`SEG_OUT_7);
	8:SEG7DEC = ~(`SEG_OUT_8);
	9:SEG7DEC = ~(`SEG_OUT_9);
      endcase
   endfunction

endmodule // XYtoHEX
