module top;
   reg CLK, NRST;
   reg [7:0] x, y, r, g, b;

   wire [7:0] posx, posy;
   wire [2:0] posr, posg, posb;

   reg [9:0]  SW;
   reg [3:0]  KEY;
   
   wire [7:0] 					Xposin, Yposin;
   wire [8:0] 					RGBposin;

   wire [6:0] 					HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
   
   XYRGBinput  u7( .clk(CLK),  .NRST(NRST), .SW(SW), .key(KEY), .Xin(Xposin), .Yin(Yposin), .RGBin(RGBposin) );
   draw  u8 (.CLK(CLK), .NRST(NRST), .X(posx), .Y(posy), .R(posr), .G(posg), .B(posb) );

   XYtoHEX  u6(.clk(CLK), .NRST(NRST), .Xposin(Xposin), .Yposin(Yposin), 
	       .HEX0(HEX0),
	       .HEX1(HEX1),
	       .HEX2(HEX2),
	       .HEX3(HEX3),
	       .HEX4(HEX4),
	       .HEX5(HEX5) );
   


   VGA_Ctrl vga(.iCLK(CLK), .iRST_N(NRST),
		.write_x(posx), .write_y(posy), .write_r(posr), .write_g(posg), .write_b(posb) );
   integer   i;

   always #10 CLK <= ~CLK;
   always @(posedge CLK) i<= i+1;

   always @(posedge CLK ) begin
      x <= i[7:0];
      y <= i[15:8];

      r<= i[7:0];
      g<= i[7:0];
      b<= i[7:0];
   end

   initial begin
      i<=0;
      CLK <= 0;
      NRST <= 0;
      KEY =4'b 1111;
      
      #100 NRST <= 1;
      #100 SW = 9'b 00_1111_0110; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_1100_1001; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_0110_1010; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_1110_0011; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_0000_0100; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_0000_0101; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_0000_0110; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_0000_0111; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      #1000 SW = 9'b 00_0000_1000; KEY = 4'b 1101;
      #100  KEY =4'b 1111;
      

//      #600000000
      #60000
	$finish;
   end
endmodule


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


   reg [2:0]			    STX, STY;
   reg [3:0] 		    DX0, DX1, DX2, DY0, DY1, DY2;
	reg [7:0] Xi, Yi;
	
   wire [8:0] 		    XX, YY;

   assign XX = (STX==1) ? Xi - 8'd 100 :
	       (STX==2) ? Xi - 8'd 10 : Xi;

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
	1:SEG7DEC = `SEG_OUT_1;
	2:SEG7DEC = `SEG_OUT_2;
	3:SEG7DEC = `SEG_OUT_3;
	4:SEG7DEC = `SEG_OUT_4;
	5:SEG7DEC = `SEG_OUT_5;
	6:SEG7DEC = `SEG_OUT_6;
	7:SEG7DEC = `SEG_OUT_7;
	8:SEG7DEC = `SEG_OUT_8;
	9:SEG7DEC = `SEG_OUT_9;
      endcase
   endfunction

endmodule // XYtoHEX
