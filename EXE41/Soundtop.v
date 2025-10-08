// require VGA_Ctrl.v


module Soundtop (
    //////////// CLOCK //////////
    input CLOCK_50,

    //////////// KEY //////////
    input [3:0] KEY,

    //////////// SW //////////
    input [9:0] SW,

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
    input        AUD_ADCDAT,
    inout        AUD_ADCLRCK,
    inout        AUD_BCLK,
    output       AUD_DACDAT,
    inout        AUD_DACLRCK,
    output       AUD_XCK,

    //////////// I2C for Audio and Video-In //////////
    output FPGA_I2C_SCLK,
    inout  FPGA_I2C_SDAT,
    //////////// IR //////////
    input  IRDA_RXD,
    output IRDA_TXD

);


  wire [10:0] VGA_X;
  wire [10:0] VGA_Y;

  wire        CLK40;


  wire [7:0] posx, posy;
  wire [2:0] posr, posg, posb;

  ///=======================================================
  //  REG/WIRE declarations
  //=======================================================
  wire        CLK_1M;
  wire        END;
  wire        KEY0_EDGE;
  wire [23:0] AUD_I2C_DATA;
  wire        GO;

  //=======================================================
  //  Structural coding
  //=======================================================

  reg [15:0] SL, SR, SoL, SoR;
  reg ADCLR1, DACLR1;
  reg [3:0] FlagLR, FlagOLR;
  reg FlagIn, FlagOut;
  reg [31:0] Storage[0:65535];
  reg [15:0] Sin, Sout;
  reg AO;

  assign NRST = KEY[0];
  // assign AUD_DACDAT = AUD_ADCDAT;
  assign AUD_DACDAT = AUD_DACLRCK == 0 ? SoL[15] : SoR[15];



  always @(posedge AUD_BCLK) begin
    if (!NRST) begin
      Sout <= 1;
      Sin <= 0;
      Sout <= 0;
      FlagLR <= 0;
      FlagOLR <= 0;
      FlagIn <= 0;
      FlagOut <= 0;
      SR <= 0;
      SL <= 0;
    end else begin
      ADCLR1 <= AUD_ADCLRCK;
      DACLR1 <= AUD_DACLRCK;
      if (FlagOut == 1) begin
        if (FlagOLR == 15) FlagOut <= 0;
        FlagOLR <= FlagOLR + 1;
        if (AUD_DACLRCK == 0) SoL <= {SoL[14:0], 1'b0};
        else SoR <= {SoR[14:0], 1'b0};
      end else begin
        if (DACLR1 == 1 && AUD_DACLRCK == 0) begin
          FlagOLR <= 0;
          FlagOut <= 1;
          {SoL, SoR} <= Storage[Sout];
          // {SoL,SoR} <= 0;
          Sout <= Sout + 1;
        end else if (ADCLR1 == 0 && AUD_ADCLRCK == 1) begin
          FlagOLR <= 0;
          FlagOut <= 1;
        end
      end

      if (FlagIn == 1) begin
        if (FlagLR == 15) FlagIn <= 0;
        FlagLR <= FlagLR + 1;
        if (AUD_ADCLRCK == 0) SL <= {SL[14:0], AUD_ADCDAT};
        else SR <= {SR[14:0], AUD_ADCDAT};
      end else begin
        if (ADCLR1 == 1 && AUD_ADCLRCK == 0) begin
          Storage[Sin] <= {SL, SR};
          Sin <= Sin + 1;
          SL <= 0;
          FlagIn <= 1;
          FlagLR <= 0;
        end else if (ADCLR1 == 0 && AUD_ADCLRCK == 1) begin
          SR <= 0;
          FlagIn <= 1;
          FlagLR <= 0;
        end
      end
    end
  end


  keytr u3 (
      .clock(CLK_1M),
      .key0(KEY[1]),
      .rst_n(NRST),
      .KEY0_EDGE(KEY0_EDGE)
  );

  //I2C output data
  CLOCK_500 u1 (
      .CLOCK(CLOCK_50),
      .rst_n(NRST),
      .sel(KEY[2]),
      .state(LEDR[1:0]),
      .END(END),
      .KEY0_EDGE(KEY0_EDGE),

      .CLOCK_500(CLK_1M),
      .GO(GO),
      .CLOCK_2(AUD_XCK),
      .DATA(AUD_I2C_DATA)
  );

  //i2c controller
  i2c u2 (
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

endmodule  // VGAtop
