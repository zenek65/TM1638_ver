module spi(
clk,
reset_n,
din,
din_ready,
din_rw,
dout,
dout_ready,
ack,
spi_clk,
spi_cs_n,
spi_do,
spi_dir,
spi_di,
last_byte
);

parameter clk_freq = 1000000; //Hz
localparam clk_freq_l = (clk_freq > 1000000) ? clk_freq : 1000001;
localparam clk_div = (clk_freq_l % 1000000 > 0) ? (clk_freq_l / 1000000)+1:(clk_freq_l / 1000000);
localparam clk_div_bits = $clog2(clk_div);  //bits width 

input wire clk;
input wire reset_n;
input wire [7:0] din;
input wire din_ready;
input wire din_rw;
output wire [7:0] dout;
output reg dout_ready;
output wire ack;
output reg spi_clk;
output reg spi_cs_n;
output wire spi_do;
output reg spi_dir;
input wire spi_di;
input wire last_byte;


reg [clk_div_bits :0] divider ;
reg [7:0] shift;
reg [7:0] in_buf;
reg rw; 
reg busy; 
reg [3:0] bit_cnt;
reg last_byte_r;



assign ack = (din_ready & !busy & !last_byte_r) ; 
assign spi_do = (spi_dir) ? shift[bit_cnt[2:0]] : 1'b0;
assign dout = shift;

always @(posedge clk) begin
	if (!reset_n) begin
	  divider <= 0;
		spi_clk <= 1'b1;
		busy <= 1'b0;
		bit_cnt <= 0;
		spi_cs_n <= 1'b1;
		spi_dir <= 1'b1;
		dout_ready <= 1'b0;
	end else begin
	  if (dout_ready !=1'b0) dout_ready <= 1'b0;  //dout_ready one cycle high
	  if (divider != 0) begin 
		  divider <= divider - 1'b1;
		end else begin
		  divider <= clk_div - 1'b1; 
			if (busy) begin
			  spi_dir <= !rw;
				if (spi_cs_n) begin
				  spi_cs_n <= 1'b0;
				end else
				begin
					if (spi_clk) begin
						if ((bit_cnt[3:0]==4'b1111)&&(!rw)) shift<=in_buf; 
						//if ((bit_cnt[3:0]!=4'b0111) && (bit_cnt[3:0]!=4'b1110)&& (bit_cnt[3:0]!=4'b1101)&& (bit_cnt[3:0]!=4'b1101)) begin
						if ((bit_cnt[3:0] < 4'b0111) || (bit_cnt[3:0] == 4'b1111)) begin
						spi_clk <= 1'b0;
						end
						if (!rw) begin 
							//spi_do <= shift[bit_cnt[2:0]];
							//spi_cs_n <= 1'b0;
						end
						bit_cnt <= bit_cnt + 1'b1;
					end else begin  //!spi_clk
						spi_clk <= 1'b1;
						if ((bit_cnt[3:0]<=4'b0111) && (rw)) shift[bit_cnt[2:0]] <= spi_di;
						if (bit_cnt == 4'b0111) begin
							busy <= 1'b0;
							if (rw) dout_ready <= 1'b1; 
						end
					end 
				end
			
			end else begin  //!busy
				  spi_cs_n <= 1'b1;
					spi_dir <= 1'b1;
					last_byte_r<= 1'b0;
			end
		end
	  
		if (ack) begin
		  busy 	<= 1'b1;
			rw 		<= din_rw;
			last_byte_r <= last_byte;
			if (!din_rw) begin  //tx
			  in_buf <= din; 
			  bit_cnt <= 4'b1111;
			end else begin  //rx
			  if (rw) bit_cnt <= 4'b1111; else bit_cnt <= 4'b1100;  //Twait 2us write to read
			end
		end
	end
end

endmodule