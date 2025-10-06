module XYRGBinput (
    input clk,
    input NRST,
    input [9:0] SW,
    input [3:0] key,
    output reg [7:0] Xin,
    output reg [7:0] Yin,
    output reg [8:0] RGBin
);

  reg [2:0] k0;

  always @(posedge clk) begin
    if (!NRST) begin
      Xin <= 0;
      Yin <= 0;
      k0 <= 0;
      RGBin <= 0;
    end else begin
      if (k0[0] == 1 && key[1] == 0 && SW[9:8] == 2'b00) begin  // Key[1] pressed
        Xin <= SW[7:0];
      end else if (k0[0] == 1 && key[1] == 0 && SW[9:8] == 2'b01) begin  // Key[2] pressed
        Yin <= SW[7:0];
      end else if (k0[0] == 1 && key[1] == 0 && SW[9:8] == 2'b10) begin  // Key[3] pressed
        RGBin <= {SW[5:4], 1'b0, SW[3:2], 1'b0, SW[1:0], 1'b0};
      end
      k0 <= key[3:1];
    end

  end



endmodule  // XYRGBinput
