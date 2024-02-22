module tm1638_bus (
clk,
reset_n,
din,
dout,
wr,
rd,
addr,
spi_di,
spi_clk,
spi_cs_n,
spi_dir,
spi_do,
cs_tm1638
);

parameter cfg_addr = 12'hff0;
parameter clk_freq = 50000000; //Hz

input wire 	clk;
input wire 	reset_n;

input wire	spi_di;
output wire spi_clk;
output wire spi_cs_n;
output wire spi_dir;
output wire spi_do;
output reg cs_tm1638;

input wire  [7:0] din;
output reg [7:0] dout;
input wire   			wr;
input wire   			rd;
input wire [15:0] addr;


reg [7:0] dig_1; 
reg [7:0] dig_2; 
reg [7:0] dig_3; 
reg [7:0] dig_4; 
reg [7:0] dig_5; 
reg [7:0] dig_6; 
reg [7:0] dig_7; 
reg [7:0] dig_8; 
reg [7:0] leds; 
reg 			disp_on;
reg [2:0] bright;
wire [7:0] buttons;

//assign  dout = buttons;  

always @(addr or rd or wr) begin
  if (addr[15:4] == cfg_addr) begin
	  cs_tm1638 = rd;
	  case (addr[3:0]) 
			4'b 0000: dout = dig_1;
			4'b 0001: dout = dig_2;
			4'b 0010: dout = dig_3;
			4'b 0011: dout = dig_4;
			4'b 0100: dout = dig_5;
			4'b 0101: dout = dig_6;
			4'b 0110: dout = dig_7;
			4'b 0111: dout = dig_8;
			4'b 1000: dout = leds;
			//4'b 1001: dout = buttons;
			4'b 1111: dout ={4'b0,disp_on,bright};
			default: dout = buttons; 
		endcase
	end else begin
	  cs_tm1638 = 1'b0;
	end
end

always @(posedge clk) begin
  if (!reset_n) begin
	  dig_1<=8'h00;
	  dig_2<=8'h00;
	  dig_3<=8'h00;
	  dig_4<=8'h00;
	  dig_5<=8'h00;
	  dig_6<=8'h00;
	  dig_7<=8'h00;
	  dig_8<=8'h00;
		leds <=8'h00;
	  disp_on <= 1'b1;
		bright<=7;
	end else begin
    if (addr[15:4] == cfg_addr) begin
      if (wr) begin
			  case (addr[3:0]) 
					4'b 0000: dig_1 <= din;
					4'b 0001: dig_2 <= din;
					4'b 0010: dig_3 <= din;
					4'b 0011: dig_4 <= din;
					4'b 0100: dig_5 <= din;
					4'b 0101: dig_6 <= din;
					4'b 0110: dig_7 <= din;
					4'b 0111: dig_8 <= din;
					4'b 1000: leds <= din;
					4'b 1111: {disp_on,bright} <= din[3:0];
				endcase
			end
    end
  end
end


tm1638 #(.clk_freq( clk_freq)) tm1638_inst(
.clk(clk),
.reset_n(reset_n),
.spi_di(spi_di),
.spi_clk(spi_clk),
.spi_cs_n(spi_cs_n),
.spi_dir(spi_dir),
.spi_do(spi_do),
.buttons(buttons),
.dig_1(dig_1),
.dig_2(dig_2),
.dig_3(dig_3),
.dig_4(dig_4),
.dig_5(dig_5),
.dig_6(dig_6),
.dig_7(dig_7),
.dig_8(dig_8),
.leds(leds),
.disp_on(disp_on),
.bright(bright)
);

endmodule