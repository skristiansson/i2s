module i2s_tb;

parameter AUDIO_DW = 32;
wire lrclk;
wire sdata;
reg [AUDIO_DW-1:0] left_tx_chan;
reg [AUDIO_DW-1:0] right_tx_chan;
wire [AUDIO_DW-1:0] left_rx_chan;
wire [AUDIO_DW-1:0] right_rx_chan;
reg sclk = 1'b1;
reg rst = 1'b1;

vlog_tb_utils vlog_tb_utils0();

always #5 sclk <= ~sclk;
initial #100 rst = 0;

i2s_tx #(
	.AUDIO_DW	(AUDIO_DW)
) i2s_tx0 (
	.sclk		(sclk),
	.rst		(rst),

	.prescaler	(32'd32),

	.lrclk		(lrclk),
	.sdata		(sdata),

	.left_chan	(left_tx_chan),
	.right_chan	(right_tx_chan)
);

i2s_rx #(
	.AUDIO_DW	(AUDIO_DW)
) i2s_rx0 (
	.sclk		(sclk),
	.rst		(rst),

	.lrclk		(lrclk),
	.sdata		(sdata),

	.left_chan	(left_rx_chan),
	.right_chan	(right_rx_chan)
);

initial begin
	left_tx_chan = 32'h01234567;
	right_tx_chan = 32'h89abcdef;
	@(negedge rst);
	@(posedge lrclk);
	@(negedge lrclk);
	@(posedge sclk);
	@(negedge sclk);
	if (left_rx_chan == left_tx_chan && right_rx_chan == right_tx_chan)
		$display("Test passed!");
	else
		$display("Test failed!");
	#100 $finish();
end

endmodule
