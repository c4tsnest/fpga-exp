module top;
   reg CLK, data_ready;
   reg [7:0] hex_data;
   wire [3:0] Dig0, Dig1, Dig2, Dig3, Dig4, Dig5;



   Calc c( CLK, data_ready, hex_data, Dig0, Dig1, Dig2, Dig3, Dig4, Dig5 );

   initial begin
      CLK=0;
      data_ready=0;
      hex_data=0;

      #100 data_ready=1;
      hex_data = 'h 12;
      #20  data_ready=0;

      #200 data_ready=1;
      hex_data = 'h 01;
      #20  data_ready=0;

      #200 data_ready=1;
      hex_data = 'h 01;
      #20  data_ready=0;

      #200 data_ready=1;
      hex_data = 'h 02;
      #20  data_ready=0;

      #200 data_ready=1;
      hex_data = 'h 1E;
      #20  data_ready=0;
      
      #200 data_ready=1;
      hex_data = 'h 02;
      #20  data_ready=0;

      #200 data_ready=1;
      hex_data = 'h 0C;
      #20  data_ready=0;
      
      #10000
	$finish;
   end


   always #10 CLK <= ~CLK;
   


endmodule // top
