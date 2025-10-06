module pll (refclk, rst, outclk_0);
   input refclk, rst;
   output outclk_0;

   assign outclk_0 = refclk;
endmodule // pll

module vram64k (clock, data, wraddress, wren, rdaddress, q);
   input clock, wren;
   input [15:0] wraddress, rdaddress;
   input [8:0]  data;
   output reg [8:0] q;

   reg [8:0]    m[0:65535];

   always @(posedge clock) begin
      if( wren == 1) begin
         m[wraddress]<=data;
      end
      q <= m[rdaddress];

   end // UNMATCHED !!
endmodule // vram


module cram (clock, data, wraddress, wren, rdaddress, q);
   input clock, wren;
   input [8:0] wraddress, rdaddress;
   input [7:0]  data;
   output reg [7:0] q;

   reg [7:0]    m[0:511];

   always @(posedge clock) begin
      if( wren == 1) begin
         m[wraddress]<=data;
      end
      q <= m[rdaddress];

   end // UNMATCHED !!
endmodule // vram

module font (clock, address, q);
   input clock;
   input [10:0] address;
   output reg [7:0] q;

   reg [7:0]    m[0:2047];

   always @(posedge clock) begin
      q <= m[address];
   end // UNMATCHED !!
endmodule // vram

