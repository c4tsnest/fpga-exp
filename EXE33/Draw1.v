module draw(CLK, NRST, X, Y, R, G, B, CX, CY, CHAR, SW, KEY);
   input [9:0] SW;
   input [3:0] KEY;
   input CLK, NRST;
   output [7:0] X, Y;
   output [2:0] R, G, B;
	output reg [4:0] CX;
	output reg [3:0] CY;
	output reg [7:0] CHAR;
	
   reg [7:0] 	X, Y;
   reg [2:0] 	R, G, B;
   reg [2:0] 	state;
   reg [3:0] 	state2;
   reg [23:0] 	cnt;
   wire [15:0] 	addr;
   reg [8:0] 	SW1, SW2;
   reg 		k2, state2flag;
   

   assign addr = {Y,X}+16'd 1;

   always @(posedge CLK) begin
      if( !NRST ) begin
	 X <=0;
	 Y <=0;
	 R<=0;
	 G<=0;
	 B<=0;
	 state <=0;
	 CX <= 0;
	 CY <= 0;
	 CHAR <= 0;
	 state2 <= 0;
	 state2flag <= 0;
	 cnt <= 0;
	 SW1 <= 0;
	 k2 <= 1;
      end else begin
	 k2 <= KEY[2];
	 if( state2flag == 0 && k2 == 1 && KEY[2]== 0 ) begin
	    SW1 <= SW[8:0];
	    SW2 <= SW1;
	    state2flag <= 1;
	    state2 <= 0;
	 end else if( state2flag ) begin
	    state2 <= state2 + 1;
	    case (state2)
	      0: begin
		 CX <= SW2[8:4];
		 CY <= SW2[3:0];
		 CHAR <= 'h 20;
	      end
	      1: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      2: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      3: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      4: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      5: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      6: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      7: begin
		 CX <= CX + 1;
		 CHAR <= 'h 20;
	      end
	      8: begin
		 CX <= SW1[8:4];
		 CY <= SW1[3:0];
		 CHAR <= 'h 4d;
	      end
	      9: begin
		 CX <= CX + 1;
		 CHAR <= 'h 61;
	      end
	      10: begin
		 CX <= CX + 1;
		 CHAR <= 'h 6b;
	      end
	      11: begin
		 CX <= CX + 1;
		 CHAR <= 'h 6f;
	      end
	      12: begin
		 CX <= CX + 1;
		 CHAR <= 'h 74;
	      end
	      13: begin
		 CX <= CX + 1;
		 CHAR <= 'h 6f;
	      end
	      14: begin
		 CX <= CX + 1;
		 CHAR <= 'h 2e;
	      end
	      15: begin
		 CX <= CX + 1;
		 CHAR <= 'h 49;
		 state2flag <= 0;
	      end
	    endcase	
	 end
	
	if( state == 0 )begin
	    if( cnt == 24'h FFFFFF ) state <= 1;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h FF;
	    G<=8'h FF;
	    B<=8'h FF;
	 end else if( state == 1 )begin
	    if( cnt == 24'h FFFFFF ) state <= 2;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h 00;
	    G<=8'h FF;
	    B<=8'h FF;
	 end else if( state == 2 )begin
	    if( cnt == 24'h FFFFFF ) state <= 3;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h FF;
	    G<=8'h 0;
	    B<=8'h 0;
	 end else if( state == 3 )begin
	    if( cnt == 24'h FFFFFF ) state <= 4;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h FF;
	    G<=8'h 0;
	    B<=8'h FF;
	 end else if( state == 4 )begin
	    if( cnt == 24'h FFFFFF ) state <= 5;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h 0;
	    G<=8'h FF;
	    B<=8'h 0;
	 end else if( state == 5 )begin
	    if( cnt == 24'h FFFFFF ) state <= 6;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h FF;
	    G<=8'h FF;
	    B<=8'h 0;
	 end else if( state == 6 )begin
	    if( cnt == 24'h FFFFFF ) state <= 7;
	    cnt <= cnt + 1;
	    {Y,X} <= addr;
	    R<=8'h 0;
	    G<= addr[15:13];
	    B<= addr[7:5];
	 end else if( state == 7 )begin
	    {Y,X} <= 0;
	    R<= 0;
	    G<= 0;
	    B<= 0;
	 end
      end
   end
   
	 
endmodule // UNMATCHED !!
