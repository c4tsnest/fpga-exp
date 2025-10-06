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

   integer   i;

   VGAtop  vgatop( .CLK(CLK), .KEY(KEY) );
   

   always #10 CLK <= ~CLK;
   always @(posedge CLK) i<= i+1;

   initial begin
      i<=0;
      CLK <= 0;
      KEY =4'b 0000;
      
      #300  KEY =4'b 1111;
      

      #600000000
//      #60000
	$finish;
   end
endmodule


