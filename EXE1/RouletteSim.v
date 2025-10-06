module simtop;

   reg clk, nrst;
   reg [1:0] sw;
   wire [3:0] ledr;
   wire [6:0] hex0;

   top top (.CLOCK_50(clk), .nrst(nrst), .LEDR(ledr), .HEX0(hex0), .SW(sw));

   initial begin
      clk <= 0;
      nrst <= 0;
      #100 nrst <= 1;
      sw <= 2;
      #5000000000
//	sw <= 1;
      #5000000000
//	sw <= 0;
      
      #10000000000
	$finish;
   end

   always #10 clk <= ~clk;

endmodule


