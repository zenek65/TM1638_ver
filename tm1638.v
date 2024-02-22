module tm1638 (
clk,
reset_n,
spi_di,
spi_clk,
spi_cs_n,
spi_dir,
spi_do,
buttons,
dig_1,
dig_2,
dig_3,
dig_4,
dig_5,
dig_6,
dig_7,
dig_8,
leds,
disp_on,
bright
);

parameter clk_freq = 1000000; //Hz

input wire 	clk;
input wire 	reset_n;

input wire	spi_di;
output wire spi_clk;
output wire spi_cs_n;
output wire spi_dir;
output wire spi_do;


output reg [7:0] buttons;
input wire [7:0] dig_1;
input wire [7:0] dig_2;
input wire [7:0] dig_3;
input wire [7:0] dig_4;
input wire [7:0] dig_5;
input wire [7:0] dig_6;
input wire [7:0] dig_7;
input wire [7:0] dig_8;
input wire [7:0] leds;
input wire	 		 disp_on;
input wire [2:0] bright;


localparam INIT=0;
localparam MODE=1;
localparam LEDS_OUT=2;
localparam BUTTONS_IN=3;


//spi
reg [7:0] din;
reg din_ready;
reg din_rw;
wire [7:0] dout;
wire dout_ready;
wire ack;
reg	last_byte;

reg [2:0]cnt;
reg [1:0]cnt1;
reg [3:0]w_cnt;

reg cs_n_1;

always @(posedge clk)  begin
  if (!reset_n) begin
	  cnt <= INIT;
	  cnt1[1:0] <= 2'b0;
		w_cnt[3:0] <= 4'b0;
		din_ready <= 1'b0;
		din_rw <= 1'b0;
		last_byte <= 1'b0;
	end else begin
	  
	  cs_n_1 <= spi_cs_n;
	  if (cnt==INIT) begin
			din_rw <= 1'b0;
			din<={4'h8,disp_on,bright[2:0]};
			din_ready <= 1'b1;
			last_byte <= 1'b1;
			if (ack) begin
				//din_ready <= 1'b0;
				cnt <= MODE;
			end
		end else
		if (cnt==MODE) begin
			din_rw <= 1'b0;
			din<=8'h40;
			din_ready <= 1'b1;
			last_byte <= 1'b1;
			if (ack) begin
				//din_ready <= 1'b0;
				cnt <= LEDS_OUT;
				cnt1 <= 0;
			end	
		end else
		if (cnt==LEDS_OUT) begin
		  if (cnt1==0) begin
			  din<=8'hC0;
				din_rw <= 1'b0;
				din_ready <= 1'b1;
				last_byte <= 1'b0;
				if (ack) begin
				  //din_ready <= 1'b0;
					cnt1 <= 1;
					w_cnt <= 0;
				end
			end else
			if (cnt1==1) begin
				if (w_cnt ==0) begin
					din<=dig_1;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 1;
					end
				end else if (w_cnt ==1) begin
					din<={7'b0,leds[7]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 2;
					end
				end else if (w_cnt ==2) begin
					din<=dig_2;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 3;
					end
				end else if (w_cnt ==3) begin
					din<={7'b0,leds[6]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 4;
					end
				end else if (w_cnt ==4) begin
					din<=dig_3;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 5;
					end
				end else if (w_cnt ==5) begin
					din<={7'b0,leds[5]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 6;
					end
				end else if (w_cnt ==6) begin
					din<=dig_4;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 7;
					end
				end else if (w_cnt ==7) begin
					din<={7'b0,leds[4]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 8;
					end
				end else if (w_cnt ==8) begin
					din<=dig_5;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 9;
					end
				end else if (w_cnt ==9) begin
					din<={7'b0,leds[3]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 10;
					end
				end else if (w_cnt ==10) begin
					din<=dig_6;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 11;
					end
				end else if (w_cnt ==11) begin
					din<={7'b0,leds[2]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 12;
					end
				end else if (w_cnt ==12) begin
					din<=dig_7;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 13;
					end
				end else if (w_cnt ==13) begin
					din<={7'b0,leds[1]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 14;
					end
				end else if (w_cnt ==14) begin
					din<=dig_8;
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 15;
					end
				end else if (w_cnt ==15) begin
					din<={7'b0,leds[0]};
					din_ready <= 1'b1;
					last_byte <= 1'b1;
					if (ack) begin
						//din_ready <= 1'b0;
						cnt <= BUTTONS_IN;
						cnt1 <= 0;
						w_cnt <= 0;
					end
				end  		
		  end 	
		end 
		if (cnt==BUTTONS_IN) begin
		  if (cnt1==0) begin
			  din<=8'h42;  //read key cmd
				din_ready <= 1'b1;
				last_byte <= 1'b0;
				if (ack) begin
				  //din_ready <= 1'b0;
					cnt1 <= 1;
				end
			end else  //wstawic odczyt i zmiana pinu rw
		  if (cnt1==1) begin
			  if (w_cnt ==0) begin
					din_rw <= 1'b1;
					//din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 1;
					end
				end else if (w_cnt ==1) begin
					if (dout_ready) {buttons[7],buttons[3]} <= {dout[0],dout[4]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 2;
					end
				end else if (w_cnt ==2) begin
					if (dout_ready) {buttons[6],buttons[2]} <= {dout[0],dout[4]};
					din_ready <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						w_cnt <= 3;
					end
				end else if (w_cnt ==3) begin
					if (dout_ready) {buttons[5],buttons[1]} <= {dout[0],dout[4]};
					din_ready <= 1'b1;
					last_byte <= 1'b1;
					if (ack) begin
						din_ready <= 1'b0;
						cnt1 <= 2;
					end
				end
			end else
			if (cnt1==2) begin
			  if (dout_ready) begin
				  {buttons[4],buttons[0]} <= {dout[0],dout[4]};
					cnt1 <= 0;
					cnt <= INIT;
				end
			end 	
		end		
  end
end





spi #(.clk_freq( clk_freq))spi_1(
.clk(clk),
.reset_n(reset_n),
.din(din),
.din_ready(din_ready),
.din_rw(din_rw),
.dout(dout),
.dout_ready(dout_ready),
.ack(ack),
.spi_clk(spi_clk),
.spi_cs_n(spi_cs_n),
.spi_do(spi_do),
.spi_dir(spi_dir),
.spi_di(spi_di),
.last_byte(last_byte)
);

endmodule
