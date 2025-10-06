module top;
   reg CLK, NRST;
   reg [7:0] x, y, r, g, b;

   wire [7:0] posx, posy;
   wire [2:0] posr, posg, posb;

   draw  u8 (.CLK(CLK), .NRST(NRST), .X(posx), .Y(posy), .R(posr), .G(posg), .B(posb) );

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
      #100 NRST <= 1;

      #600000000
	$finish;
   end
endmodule
