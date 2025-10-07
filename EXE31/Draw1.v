module draw (
    CLK,
    NRST,
    X,
    Y,
    R,
    G,
    B
);
  input CLK, NRST;
  output [7:0] X, Y;
  output [2:0] R, G, B;

  reg [7:0] X, Y;
  reg [2:0] R, G, B;
  reg  [ 2:0] state;
  reg  [23:0] cnt;
  wire [15:0] addr;
  assign addr = {Y, X} + 16'd1;

  always @(posedge CLK) begin
    if (!NRST) begin
      X <= 0;
      Y <= 0;
      R <= 0;
      G <= 0;
      B <= 0;
      state <= 0;
      cnt <= 0;
    end else begin
      if (state == 0) begin
        if (cnt == 24'hFFFFFF) state <= 1;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'hFF;
        G <= 8'hFF;
        B <= 8'hFF;
      end else if (state == 1) begin
        if (cnt == 24'hFFFFFF) state <= 2;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'h00;
        G <= 8'hFF;
        B <= 8'hFF;
      end else if (state == 2) begin
        if (cnt == 24'hFFFFFF) state <= 3;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'hFF;
        G <= 8'h0;
        B <= 8'h0;
      end else if (state == 3) begin
        if (cnt == 24'hFFFFFF) state <= 4;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'hFF;
        G <= 8'h0;
        B <= 8'hFF;
      end else if (state == 4) begin
        if (cnt == 24'hFFFFFF) state <= 5;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'h0;
        G <= 8'hFF;
        B <= 8'h0;
      end else if (state == 5) begin
        if (cnt == 24'hFFFFFF) state <= 6;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'hFF;
        G <= 8'hFF;
        B <= 8'h0;
      end else if (state == 6) begin
        if (cnt == 24'hFFFFFF) state <= 6;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= 8'h0;
        G <= addr[15:13];
        B <= addr[7:5];
      end else if (state == 7) begin
        if (cnt == 24'hFFFFFF) state <= 7;
        cnt <= cnt + 1;
        {Y, X} <= addr;
        R <= addr[7:5];
        G <= addr[15:13];
        B <= 8'h0;
      end
    end
  end


endmodule  // UNMATCHED !!
