`define rom_size 6'd8

module CLOCK_500(
		 CLOCK,
		 rst_n,
		 END,
		 KEY0_EDGE,
		 
		 DATA,
		 GO,
		 CLOCK_500,				  
		 CLOCK_2,
		 sel, state
	);
   //=======================================================
   //  PORT declarations
   //=======================================================                
   input  		 	CLOCK;
   input 		 	rst_n;
   input 		 	END;
   input 		 	KEY0_EDGE;
   input 			sel;
   output [1:0] 		state;
   
   
   output [23:0] 		DATA;
   output 			GO;
   output 			CLOCK_500;
   output 			CLOCK_2;
   
   
   reg [10:0] 			COUNTER_500;
   reg [15:0] 			ROM[`rom_size:0];
   reg [15:0] 			DATA_A;
   reg [5:0] 			address;
   
   reg 				sel1;
   reg [1:0] 			state;
   
   wire [6:0] 		volume;
   wire  CLOCK_500 = COUNTER_500[9];
   wire  CLOCK_2 	= COUNTER_500[1];
   
   wire [23:0] DATA = {8'h34, DATA_A};		//slave address + sub_address + register_data
   wire        GO = ((address <= `rom_size) && (END == 1)) ? COUNTER_500[10] : 1;
   assign volume = 127;
   
   always @(posedge CLOCK) begin
      if(!rst_n) begin
	 state <= 0; sel1 <= 1;
	 ROM[0] <= 16'h0c00;	    			 	//power down
	 ROM[1] <= 16'h0ec2;	   		    	 	//master
	 ROM[2] <= 16'h0800;	    			 	// Bypass:Enable, Dac:Enable, Sidetone:Enable, SideToneAtt:-6dB
	 ROM[3] <= 16'h1000;						//mclk
	 ROM[4] <= 16'h0017;						//
	 ROM[5] <= 16'h0217;					 	//
	 ROM[6] <= {8'h04,1'b0,volume[6:0]};		//left channel headphone output volume
	 ROM[7] <= {8'h06,1'b0,volume[6:0]};		//right channel headphone output volume
	 ROM[`rom_size] <= 16'h1201;           	//active
      end else begin
	 sel1 <= sel;
	 if( sel1==1 && sel==0 )begin
	    case(state)
	      0: ROM[2] <= 16'h0838;	    			 	// R4: Bypass:Enable, Dac:Enable, Sidetone:Enable, SideToneAtt:-6dB
	      1: ROM[2] <= 16'h0810;	    			 	// R4: Bypass:Disable, Dac:Enable, Sidetone:Disable, SideToneAtt:-6dB
	      2: ROM[2] <= 16'h0808;	    			 	// R4: Bypass:Enable, Dac:Disalbe, Sidetone:Disable, SideToneAtt:-6dB
	      3: ROM[2] <= 16'h0800;	    			 	// R4: Bypass:Disable, Dac:Disalbe, Sidetone:Disable, SideToneAtt:-6dB
	    endcase // case (state)
	 end else if( sel1==0 && sel==1 )begin
	    state <= state + 1;
	 end
      end
   end

   always @(posedge CLOCK ) begin
      if(!rst_n) COUNTER_500 <= 0;
      else COUNTER_500 <= COUNTER_500+1;
   end
   
   
   always @(negedge KEY0_EDGE or posedge END) begin
      if (!KEY0_EDGE) address<=0;
      else if (address <= `rom_size) address<=address+1;
   end
   
   always @(posedge END) 
     begin
	DATA_A <= ROM[address];
     end
endmodule
