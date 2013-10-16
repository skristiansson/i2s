/*
 * Copyright (c) 2013, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>
 * All rights reserved.
 *
 * Redistribution and use in source and non-source forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in non-source form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS WORK IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * WORK, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module i2s_tx #(
	parameter AUDIO_DW	= 32
)(
	input			sclk,
	input			rst,

	output reg		lrclk,
	output			sdata,

	// Parallell datastreams
	input [AUDIO_DW-1:0]	left_chan,
	input [AUDIO_DW-1:0]	right_chan
);

reg [$clog2(AUDIO_DW)-1:0]	bit_cnt;
reg [AUDIO_DW-1:0]		left;
reg [AUDIO_DW-1:0]		right;

always @(posedge sclk)
	if (rst)
		bit_cnt <= 0;
	else
		bit_cnt <= bit_cnt - 1;

// Sample channels on the transfer of the last bit of the right channel
always @(posedge sclk)
	if (bit_cnt == 0 && lrclk) begin
		left <= left_chan;
		right <= right_chan;
	end

// left/right "clock" generation - 0 = left, 1 = right
always @(posedge sclk)
	if (rst)
		lrclk <= 1;
	else if (bit_cnt == 0)
		lrclk <= ~lrclk;

assign sdata = lrclk ? right[bit_cnt] : left[bit_cnt];

endmodule