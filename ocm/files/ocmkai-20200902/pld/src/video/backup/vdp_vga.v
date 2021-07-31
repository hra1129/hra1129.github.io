//
//  vdp_vga.vhd
//   VGA up-scan converter.
//
//  Copyright (C) 2006 Kunihiko Ohnaka
//  All rights reserved.
//                                     http://www.ohnaka.jp/ese-vdp/
//
//  �{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
//  �������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
//
//  1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
//    �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
//  2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
//    ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
//  3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
//    �Ɏg�p���Ȃ����ƁB
//
//  �{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
//  ����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
//  �I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
//  �����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
//  ���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
//  ����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
//  �[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
//  ��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
//  ���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
//
//  Note that above Japanese version license is the formal document.
//  The following translation is only for reference.
//
//  Redistribution and use of this software or any derivative works,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above
//     copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials
//     provided with the distribution.
//  3. Redistributions may not be sold, nor may they be used in a
//     commercial product or activity without specific prior written
//     permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN if ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//-----------------------------------------------------------------------------
// Memo
//   Japanese comment lines are starts with "JP:".
//   JP: ���{��̃R�����g�s�� JP:�𓪂ɕt���鎖�ɂ���
//
//-----------------------------------------------------------------------------
// Revision History
//
// 3rd,June,2018 modified by KdL
//  - Added a trick to help set a pixel ratio 1:1
//    on an LED display at 60Hz (not guaranteed on all displays)
//
// 29th,October,2006 modified by Kunihiko Ohnaka
//  - Inserted the license text
//  - Added the document part below
//
// ??th,August,2006 modified by Kunihiko Ohnaka
//  - Moved the equalization pulse generator from vdp.vhd
//
// 20th,August,2006 modified by Kunihiko Ohnaka
//  - Changed field mapping algorithm when interlace mode is enabled
//        even field  -> even line (odd  line is black)
//        odd  field  -> odd line  (even line is black)
//
// 13th,October,2003 created by Kunihiko Ohnaka
// JP: VDP�̃R�A�̎����ƕ\���f�o�C�X�ւ̏o�͂�ʃ\�[�X�ɂ����D
//
//-----------------------------------------------------------------------------
// Document
//
// JP: ESE-VDP�R�A(vdp.vhd)�����������r�f�I�M�����AVGA�^�C�~���O��
// JP: �ϊ�����A�b�v�X�L�����R���o�[�^�ł��B
// JP: NTSC�͐����������g����15.7KHz�A�����������g����60Hz�ł����A
// JP: VGA�̐����������g����31.5KHz�A�����������g����60Hz�ł���A
// JP: ���C�����������قڔ{�ɂȂ����悤�ȃ^�C�~���O�ɂȂ�܂��B
// JP: �����ŁAvdp�� ntsc���[�h�œ������A�e���C����{�̑��x��
// JP: ��x�`�悷�邱�ƂŃX�L�����R���o�[�g���������Ă��܂��B
//

module vdp_vga (
		// VDP CLOCK ... 21.477MHZ
		input			clk21m,
		input			reset,
		// VIDEO INPUT
		input	[ 5:0]	video_r_in,
		input	[ 5:0]	video_g_in,
		input	[ 5:0]	video_b_in,
		input			video_vs_in_n,
		input	[10:0]	hcounter_in,
		input	[10:0]	vcounter_in,
		// MODE
		input			pal_mode,		// caro
		input			interlace_mode,
		input			legacy_vga,
		// VIDEO OUTPUT
		output	[ 5:0]	video_r_out,
		output	[ 5:0]	video_g_out,
		output	[ 5:0]	video_b_out,
		output			video_hs_out_n,
		output			video_vs_out_n,
		// SWITCHED I/O SIGNALS
		input	[ 2:0]	ratio_mode
	);

	reg		ff_video_hs_out_n;
	reg		ff_video_vs_out_n;

	// VIDEO OUTPUT ENABLE
	reg		ff_video_out_x;

	// DOUBLE BUFFER SIGNAL
	wire	[ 9:0]	w_x_position_w;
	reg		[ 9:0]	ff_x_position_r;
	wire			w_odd_line;
	wire			w_we;
	wire	[ 5:0]	w_r_out;
	wire	[ 5:0]	w_g_out;
	wire	[ 5:0]	w_b_out;
	wire	[ 9:0]	w_disp_start_x;

	localparam		clocks_per_line			= 1368;
	localparam		center_y				= 12;		//	based on HDMI AV output

	// disp_start_x + disp_width < clocks_per_line/2 = 684
//	localparam		c_disp_start_x_init		= 684 - c_disp_width - 2;				// 106
	localparam		c_disp_width			= 576;
	localparam		c_disp_start_y			= 3;
	localparam		c_prb_height			= 25;
	localparam		c_right_x				= 684 - c_disp_width - 2;				// 106
	localparam		c_pal_right_x			= 87;									// 87
	localparam		c_center_x				= c_right_x - 32 - 2;					// 72
	localparam		c_base_left_x			= c_center_x - 32 - 2 - 3;				// 35

	assign video_r_out	= (ff_video_out_x == 1'b1) ? w_r_out : 6'd0;
	assign video_g_out	= (ff_video_out_x == 1'b1) ? w_g_out : 6'd0;
	assign video_b_out	= (ff_video_out_x == 1'b1) ? w_b_out : 6'd0;

	vdp_doublebuf u_double_buf (
		.clk			( clk21m			),
		.x_position_w	( w_x_position_w	),
		.x_position_r	( ff_x_position_r	),
		.odd_line		( w_odd_line		),
		.we				( w_we				),
		.r_in			( video_r_in		),
		.g_in			( video_g_in		),
		.b_in			( video_b_in		),
		.r_out			( w_r_out			),
		.g_out			( w_g_out			),
		.b_out			( w_b_out			)
	);

	assign w_x_position_w	=	hcounter_in[10:1] - (clocks_per_line/2 - c_disp_width - 10);
	assign w_odd_line		=	vcounter_in[1];
	assign w_we				=	1'b1;

	// pixel ratio 1:1 for led display
	function [9:0] calc_disp_start_x;
		input	[2:0]	ratio_mode;
		input			interlace_mode;
		input			pal_mode;
		input			legacy_vga;
		input	[10:0]	vcounter_in;
		input			w_odd_line;
	
		if( (ratio_mode == 3'b000 || interlace_mode || pal_mode) && legacy_vga )begin
			// legacy output
			calc_disp_start_x = c_right_x;										// 106
		end
		else if( pal_mode )begin
			// 50hz
			calc_disp_start_x = c_pal_right_x;									// 87
		end
		else if( ratio_mode == 3'b000 || interlace_mode )begin
			// 60hz
			calc_disp_start_x = c_center_x;										// 72
		end
		else if((vcounter_in < (38 + c_disp_start_y + c_prb_height)) ||
				(vcounter_in > (526 - c_prb_height) && vcounter_in < 526 ) ||
				(vcounter_in > (524 + 38 + c_disp_start_y) && vcounter_in < (524 + 38 + c_disp_start_y + c_prb_height)) ||
				(vcounter_in > (524 + 526 - c_prb_height)) )begin
			// pixel ratio 1:1 (vga mode, 60hz, not interlaced)
			//if( w_odd_line == 1'b0 )begin										// plot from top-right
			if( w_odd_line ) begin												// plot from top-left
				calc_disp_start_x = c_base_left_x + ~ratio_mode;						// 35 to 41
			end
			else begin
				calc_disp_start_x = c_right_x;									// 106
			end
		end
		else begin
			calc_disp_start_x = c_center_x;										// 72
		end
	endfunction

	assign w_disp_start_x	= calc_disp_start_x( ratio_mode, interlace_mode, pal_mode, legacy_vga, vcounter_in, w_odd_line );

	// generate h-sync signal
	always @( posedge reset or posedge clk21m )
	begin
		if( reset )begin
			ff_video_hs_out_n <= 1'b1;
		end
		else begin
			if( (hcounter_in == 0) || (hcounter_in == (clocks_per_line/2)) )begin
				ff_video_hs_out_n <= 1'b0;
			end
			else if( (hcounter_in == 40) || (hcounter_in == (clocks_per_line/2) + 40) )begin
				ff_video_hs_out_n <= 1'b1;
			end
		end
	end

	// generate v-sync signal
	// the video_vs_in_n signal is not used
	always @( posedge reset or posedge clk21m )
	begin
		if( reset )begin
			ff_video_vs_out_n <= 1'b1;
		end
		else if ( !pal_mode ) begin // caro
			if( !interlace_mode ) begin
				if( (vcounter_in == 3*2 + center_y) || (vcounter_in == 524 + 3*2 + center_y) )begin
					ff_video_vs_out_n <= 1'b0;
				end
				else if( (vcounter_in == 6*2 + center_y) || (vcounter_in == 524 + 6*2 + center_y) )begin
					ff_video_vs_out_n <= 1'b1;
				end
			end
			else begin
				if( (vcounter_in == 3*2 + center_y) || (vcounter_in == 525 + 3*2 + center_y) )begin
					ff_video_vs_out_n <= 1'b0;
				end
				else if( (vcounter_in == 6*2 + center_y) || (vcounter_in == 525 + 6*2 + center_y) )begin
					ff_video_vs_out_n <= 1'b1;
				end
			end
		end
		else begin
			if( !interlace_mode ) begin
				if( (vcounter_in == 3*2 + center_y + 6) || (vcounter_in == 626 + 3*2 + center_y + 6) )begin
					ff_video_vs_out_n <= 1'b0;
				end
				else if( (vcounter_in == 6*2 + center_y + 6) || (vcounter_in == 626 + 6*2 + center_y + 6) )begin
					ff_video_vs_out_n <= 1'b1;
				end
			end
			else begin
				if( (vcounter_in == 3*2 + center_y + 6) || (vcounter_in == 625 + 3*2 + center_y + 6) )begin
					ff_video_vs_out_n <= 1'b0;
				end
				else if( (vcounter_in == 6*2 + center_y + 6) || (vcounter_in == 625 + 6*2 + center_y + 6) )begin
					ff_video_vs_out_n <= 1'b1;
				end
			end
		end
	end

	// generate data read timing
	always @( posedge reset or posedge clk21m )
	begin
		if( reset )begin
			ff_x_position_r <= 10'd0;
		end
		else if( (hcounter_in == w_disp_start_x) ||
				 (hcounter_in == w_disp_start_x + (clocks_per_line/2)) )begin
			ff_x_position_r <= 10'd0;
		end
		else begin
			ff_x_position_r <= ff_x_position_r + 10'd1;
		end
	end

	// generate video output timing
	always @( posedge reset or posedge clk21m )
	begin
		if( reset )begin
			ff_video_out_x <= 1'b0;
		end
		else if( (hcounter_in == w_disp_start_x) ||
				((hcounter_in == w_disp_start_x + (clocks_per_line/2)) && !interlace_mode) )begin
			ff_video_out_x <= 1'b1;
		end
		else if( (hcounter_in == w_disp_start_x + c_disp_width) ||
				 (hcounter_in == w_disp_start_x + c_disp_width + (clocks_per_line/2)) )begin
			ff_video_out_x <= 1'b0;
		end
	end

	assign video_vs_out_n = ff_video_vs_out_n;
	assign video_hs_out_n = ff_video_hs_out_n;
endmodule
