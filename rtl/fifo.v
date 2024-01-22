//`define FULL 3'b010;

module fifo (
  input  wire       rst_n,
  input  wire       clk,
  input  wire [7:0] din,
  input  wire       rwe,
  input  wire       wwe,
  output  reg       full,
  output  reg       empty,
  output  reg [7:0] dout
);
reg [3:0] ptr;

reg [7:0] mem [0:8];

localparam FULL = 4'b1000;
//localparam FULL = 3'b101;

always@(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      mem[0] <= 8'b0;
      mem[1] <= 8'b0;
      mem[2] <= 8'b0;
      mem[3] <= 8'b0;
      mem[4] <= 8'b0;
      mem[5] <= 8'b0;
      mem[6] <= 8'b0;
      mem[7] <= 8'b0;
      mem[8] <= 8'b0;
   end else if(wwe == 1) begin
      mem[ptr] <= din;
   end else if(empty == 0 && rwe == 1) begin
      mem[0] <= mem[1];
      mem[1] <= mem[2];
      mem[2] <= mem[3];
      mem[3] <= mem[4];
      mem[4] <= mem[5];
      mem[5] <= mem[6];
      mem[6] <= mem[7];
      mem[7] <= mem[8];
      mem[8] <= 0;
   end
end

always@(posedge clk or negedge rst_n) begin
   if(!rst_n) ptr <= 0;
   else if(full == 0 && wwe == 1)  ptr <= ptr + 1;
   else if(empty == 0 && rwe == 1) ptr <= ptr - 1;
end

always@(posedge clk or negedge rst_n) begin
   if(~rst_n) dout <= 0;
   else if(rwe == 1) dout <= mem[0];
end

reg full_r, empty_r;
always@(posedge clk or negedge rst_n) begin
   if(!rst_n) full_r <= 0;
   else if(ptr == FULL && wwe == 1) full_r <= 1;
   else if(ptr == FULL && rwe == 1) full_r <= 0;
end

always@(posedge clk or negedge rst_n) begin
   if(!rst_n) full_r <= 0;
   else if(ptr == 1 && rwe == 1) empty_r <= 1;
   else if(ptr == 0 && wwe == 1) empty_r <= 0;
end

always@(*) begin
   if(ptr == FULL && wwe == 1)      full = 1;
   else if(ptr == FULL && rwe == 1) full = 0;
   else if(ptr == FULL)             full = full_r;
   else if(ptr < FULL)              full = 0;
end
always@(posedge clk or negedge rst_n) begin
   if(!rst_n) empty <= 0;
   else if(ptr == 0 && wwe == 1) empty <= 0;
   else if(ptr == 1 && rwe == 1) empty <= 1;
   else if(ptr > 0)         	   empty <= 0;
end

endmodule