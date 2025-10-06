// require VGA_Ctrl.v


module Soundtop (
	       	 //////////// CLOCK //////////
		 input 	      CLOCK_50,
		 
		 //////////// KEY //////////
		 input [3:0]  KEY,
		 
		 //////////// SW //////////
		 input [9:0]  SW,
		 
		 //////////// LED //////////ledr
		 output [9:0] LEDR,
		 
		 //////////// Seg7 //////////
		 output [6:0] HEX0,
		 output [6:0] HEX1,
		 output [6:0] HEX2,
		 output [6:0] HEX3,
		 output [6:0] HEX4,
		 output [6:0] HEX5,
		 
		 //////////// VGA //////////
		 output       VGA_BLANK_N,
		 output [7:0] VGA_B,
		 output       VGA_CLK,
		 output [7:0] VGA_G,
		 output       VGA_HS,
		 output [7:0] VGA_R,
		 output       VGA_SYNC_N,
		 output       VGA_VS,
		 //////////// AUDIO //////////
		 input 	      AUD_ADCDAT,
		 inout 	      AUD_ADCLRCK,
		 inout 	      AUD_BCLK,
		 output       AUD_DACDAT,
		 inout 	      AUD_DACLRCK,
		 output       AUD_XCK,
		 
		 //////////// I2C for Audio and Video-In //////////
		 output       FPGA_I2C_SCLK,
		 inout 	      FPGA_I2C_SDAT,
		 //////////// IR //////////
		 input 	      IRDA_RXD,
		 output       IRDA_TXD
		 
		 );
   
   
   wire [10:0] 		      VGA_X;
   wire [10:0] 		      VGA_Y;
   
   wire 		      CLK40;
   
   
   wire [7:0] 		      posx, posy;
   wire [2:0] 		      posr, posg, posb;
   
   ///=======================================================
   //  REG/WIRE declarations
   //=======================================================
   wire 		      CLK_1M;
   wire 		      END;
   wire 		      KEY0_EDGE;
   wire [23:0] 		      AUD_I2C_DATA;
   wire 		      GO;
   
   //=======================================================
   //  Structural coding
   //=======================================================

   reg [15:0] 		      SL, SR, SoL, SoR;
   reg 			      ADCLR1, DACLR1;
   reg [3:0] 		      FlagLR, FlagOLR;
   reg 			      FlagIn, FlagOut;
   reg [31:0] 		      Storage[0:65535];
   reg [15:0] 		      Sin, Sout;
   reg 			      AO;

      assign NRST = KEY[0];
//   assign		AUD_DACDAT = AUD_ADCDAT;
   assign		AUD_DACDAT = AUD_DACLRCK == 0 ? SoL[15] : SoR[15];
   reg [15:0]  Tone;
	wire [11:0]  ToneTblOut;
	wire [15:0]  ToneTblAddr0;
	wire [13:0]  ToneTblAddr;
	reg [15:0]  ToneX, ToneX2, ToneX3;
	reg [15:0]  Freq;
	reg [11:0]  ToneN;
	reg [12:0]  Amp;
	reg [15:0] Sound;
	wire [15:0] SoundWire;
	wire [15:0] ToneXW;
	assign ToneXW = ToneX + Freq;
	assign ToneTblAddr0 = (ToneX < 16'd 12000) ? ToneX : ( 
									(ToneX < 16'd 24000) ? (16'd 24000-ToneX) : ( 
									(ToneX < 16'd 36000) ? (ToneX-16'd 24000) : (16'd 48000 - ToneX) ));
	assign ToneTblAddr = ToneTblAddr0[13:0];
	ToneTable u6 (.address(ToneTblAddr), .clock(AUD_BCLK), .q(ToneTblOut) );
  assign LEDR[9:2]=Sound[15:8];
//  assign LEDR[9:2]=ToneX[15:8];
	reg K3;
	
   always @(posedge AUD_BCLK) begin
      if( !NRST ) begin
	 Sout <= 1;
	 Sin <= 0;
	 Sout <=0;
	 FlagLR <= 0;
	 FlagOLR <= 0;
	 FlagIn <= 0;
	 FlagOut <= 0;
	 SR <= 0;
	 SL <= 0;
	 ToneN <= 0;
	 ToneX <= 0;
		Freq <= 16'd 400;
		Amp <= 13'h 2;
		ToneX2 <= 0;
		ToneX3 <= 0;
	 K3 <= 0;
      end else begin
		if( K3==1 && KEY[3]==0 ) begin
			if( SW[0] == 0 )  Freq <= {1'b 0, Freq[15:1]};
			else  Freq <= {Freq[14:0], 1'b 0};
		end
		
	K3 <= KEY[3];
	 ADCLR1 <= AUD_ADCLRCK;
	 DACLR1 <= AUD_DACLRCK;
	 if( FlagOut == 1 ) begin
	    if( FlagOLR == 15 ) FlagOut <= 0;
	    FlagOLR <= FlagOLR + 1;
	    if( AUD_DACLRCK == 0 ) SoL <= {SoL[14:0],1'b0};
	    else SoR <= {SoR[14:0],1'b0};
	 end else begin
	    if( DACLR1 == 1 && AUD_DACLRCK == 0 )begin
	       FlagOLR <= 0;
	       FlagOut <= 1;

//////////////////////////////////////////////////////////
			 ToneN <= ToneN+1;
		ToneX2 <= ToneX;
		ToneX3 <= ToneX2;
		if( ToneXW >= 16'd 48000 ) ToneX <= ToneXW - 16'd 48000;
		else  ToneX <= ToneXW;
		if( ToneX3 < 16'd 24000 ) begin
			Sound <= 'h 8000 + {1'b 0, ToneTblOut, 3'b 0};
		end else begin
			Sound <= 'h 8000 - {1'b 0, ToneTblOut, 3'b 0};
		end

			SoL <= Sound;
			SoR <= Sound;
//	       {SoL,SoR} <= Storage[Sout];
//	       {SoL,SoR} <= 0;
	       Sout <= Sout + 1;
	    end else if( ADCLR1 == 0 && AUD_ADCLRCK == 1 )begin
	       FlagOLR <= 0;
	       FlagOut <= 1;
	    end
	 end

	 if( FlagIn == 1 ) begin
	    if( FlagLR == 15 ) FlagIn <= 0;
	    FlagLR <= FlagLR + 1;
	    if( AUD_ADCLRCK == 0 ) SL <= {SL[14:0],AUD_ADCDAT};
	    else SR <= {SR[14:0],AUD_ADCDAT};
	 end else begin
	    if( ADCLR1 == 1 && AUD_ADCLRCK == 0 )begin
	       Storage[Sin] <= {SL,SR};
	       Sin <= Sin + 1;
	       SL <= 0;
	       FlagIn <= 1;
	       FlagLR <= 0;
	    end else if( ADCLR1 == 0 && AUD_ADCLRCK == 1 )begin
	       SR <= 0;
	       FlagIn <= 1;
	       FlagLR <= 0;
	    end
	 end
      end
   end


   keytr			u3(
				   .clock(CLK_1M),
				   .key0(KEY[1]),
				   .rst_n(NRST),
				   .KEY0_EDGE(KEY0_EDGE)
				   );
   
   //I2C output data
   CLOCK_500		u1(
			   .CLOCK(CLOCK_50),
			   .rst_n(NRST),					 
			   .sel(KEY[2]), .state(LEDR[1:0]),
			   .END(END),
			   .KEY0_EDGE(KEY0_EDGE),
			   
			   .CLOCK_500(CLK_1M),
			   .GO(GO),             
			   .CLOCK_2(AUD_XCK),
			   .DATA(AUD_I2C_DATA)
			   );
   
   //i2c controller
   i2c				u2( 
				    // Host Side
				    .CLOCK(CLK_1M),
				    .RESET(1'b1),
				    // I2C Side
				    .I2C_SDAT(FPGA_I2C_SDAT),
				    .I2C_DATA(AUD_I2C_DATA),
				    .I2C_SCLK(FPGA_I2C_SCLK),
				    // Control Signals
				    .GO(GO),
				    .END(END)
				    );

endmodule // VGAtop
