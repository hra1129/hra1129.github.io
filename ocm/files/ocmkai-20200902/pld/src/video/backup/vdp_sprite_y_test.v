//
//  vdp_sprite_y_test.v
//    Sprite module.
//
//  Copyright (C) 2004-2006 Kunihiko Ohnaka
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
//---------------------------------------------------------------------------
// Memo
//   Japanese comment lines are starts with "JP:".
//   JP: ���{��̃R�����g�s�� JP:�𓪂ɕt���鎖�ɂ���
//
//---------------------------------------------------------------------------
// Revision History
//
// 31th,December,2019 modified by t.hara
//   - Converted to VerilogHDL from VHDL.
//   - Separated from vdp_sprite.
//   - Renewal.
//
// 10th,December,2019 modified by t.hara
//   - modified delay of Sprite attribute table address.
//
// 29th,October,2006 modified by Kunihiko Ohnaka
//   - Insert the license text.
//   - Add the document part below.
//
// 26th,August,2006 modified by Kunihiko Ohnaka
//   - latch the base addresses every eight dot cycle
//     (DRAM RAS/CAS access emulation)
//
// 20th,August,2006 modified by Kunihiko Ohnaka
//   - Change the drawing algorithm.
//   - Add sprite collision checking function.
//   - Add sprite over-mapped checking function.
//   - Many bugs are fixed, and it works fine.
//   - (first release virsion)
//
// 17th,August,2004 created by Kunihiko Ohnaka
//   - Start new sprite module implementing.
//     * This module uses Block RAMs so that shrink the
//       circuit size.
//     * Separate sprite module from vdp.vhd.
//

module vdp_sprite_y_test (
	// VDP CLOCK ... 21.477MHZ
	input			clk21m,
	input			reset,

	input	[ 1:0]	dot_state,
	input	[ 2:0]	eight_dot_state,
	input			sp_y_test_state,

	input	[ 8:0]	dot_counter_x,
	input	[ 8:0]	current_y,

	// VDP STATUS REGISTERS OF SPRITE
	input			vdp_s0_reset_timing,
	output			vdp_s0_sp_overmapped,
	output	[ 4:0]	vdp_s0_sp_overmapped_num,
	// VDP REGISTERS
	input			reg_r1_sp_size,
	input			reg_r1_sp_zoom,
	input			sp_mode2,
	input	[9:0]	attribute_table_address,

	input	[ 2:0]	current_render_sp,
	output	[ 4:0]	render_sp,
	output	[ 3:0]	render_sp_num,

	input	[ 7:0]	vram_q,
	output	[16:0]	vram_a
);
	reg		[ 4:0]	ff_current_sp;				//	0...31: This is the number of the current sprite.
	reg		[ 7:0]	ff_target_sp_y_pos;
	wire	[ 7:0]	w_target_sp_relative_y_pos;
	wire			w_target_sp_active;
	reg		[ 3:0]	ff_render_sp_num;			//	0...8: render sprite#0...#7 and overmap(#8)
	wire			w_overmap;
	reg		[ 4:0]	ff_render_sp [0:7];

	reg				ff_sp_overmap;
	reg		[4:0]	ff_sp_overmap_num;

	wire	[ 7:0]	w_sprite_off_line;
	wire			w_sprite_off;

	assign w_sprite_off_line	= { 4'b1101, sp_mode2, 3'b000 };
	assign w_sprite_off			= (ff_target_sp_y_pos == w_sprite_off_line) ? 1'b1 : 1'b0;

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_current_sp <= 5'd0;
		end
		else if( sp_y_test_state && (dot_state == 2'b10) && (eight_dot_state == 3'd4) ) begin
			if( dot_counter_x[7:3] == 5'd0 ) begin
				ff_current_sp <= 5'd0;
			end
			else if( !w_sprite_off ) begin
				ff_current_sp <= ff_current_sp + 5'd1;
			end
		end
		else begin
			//	hold
		end
	end

	assign vram_a	= { attribute_table_address, ff_current_sp, 2'b00 };

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_target_sp_y_pos <= 8'd0;
		end
		else if( sp_y_test_state && (dot_state == 2'b01) && (eight_dot_state == 3'd6) ) begin
			ff_target_sp_y_pos <= vram_q;
		end
	end

	assign w_target_sp_relative_y_pos	= current_y[7:0] - ff_target_sp_y_pos;
	assign w_target_sp_active			= ((w_target_sp_relative_y_pos[7:3] == 5'd0) && !reg_r1_sp_size && !reg_r1_sp_zoom) ? 1'b1:
										  ((w_target_sp_relative_y_pos[7:4] == 4'd0) &&  reg_r1_sp_size && !reg_r1_sp_zoom) ? 1'b1:
										  ((w_target_sp_relative_y_pos[7:4] == 4'd0) && !reg_r1_sp_size &&  reg_r1_sp_zoom) ? 1'b1:
										  ((w_target_sp_relative_y_pos[7:5] == 3'd0) &&  reg_r1_sp_size &&  reg_r1_sp_zoom) ? 1'b1: 1'b0;
	assign w_overmap					= sp_mode2 ? ff_render_sp_num[3] : ff_render_sp_num[2];

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_render_sp_num <= 4'd0;
		end
		else if( (dot_state == 2'b11) && (dot_counter_x == 9'b1_1111_1111) ) begin
			ff_render_sp_num <= 4'd0;
		end
		else if( sp_y_test_state && (dot_state == 2'b11) && (eight_dot_state == 3'd6) ) begin
			if( w_target_sp_active && !w_overmap && !w_sprite_off ) begin
				ff_render_sp_num <= ff_render_sp_num + 4'd1;
			end
		end
	end

	always @( posedge clk21m ) begin
		if( sp_y_test_state && (dot_state == 2'b11) && (eight_dot_state == 3'd6) ) begin
			if( !w_overmap ) begin
				ff_render_sp[ ff_render_sp_num[2:0] ] <= ff_current_sp;
			end
		end
	end

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_sp_overmap		<= 1'b0;
		end
		else if( vdp_s0_reset_timing ) begin
			ff_sp_overmap		<= 1'b0;
		end
		else if( sp_y_test_state && (dot_state == 2'b11) && (eight_dot_state == 3'd6 && !w_sprite_off) ) begin
			if( w_overmap ) begin
				ff_sp_overmap		<= 1'b1;
			end
			else begin
				//	hold
			end
		end
	end

	always @( posedge reset or posedge clk21m ) begin
		if( reset ) begin
			ff_sp_overmap_num	<= 5'd0;
		end
		else if( vdp_s0_reset_timing ) begin
			ff_sp_overmap_num	<= 5'd0;
		end
		else if( sp_y_test_state && (dot_state == 2'b11) && (eight_dot_state == 3'd6 && !w_sprite_off) ) begin
			if( w_overmap && !ff_sp_overmap ) begin
				ff_sp_overmap_num	<= ff_current_sp;
			end
		end
	end

	assign vdp_s0_sp_overmapped		= ff_sp_overmap;
	assign vdp_s0_sp_overmapped_num	= ff_sp_overmap_num;

	assign render_sp				= ff_render_sp[ current_render_sp ];
	assign render_sp_num			= ff_render_sp_num;
endmodule
