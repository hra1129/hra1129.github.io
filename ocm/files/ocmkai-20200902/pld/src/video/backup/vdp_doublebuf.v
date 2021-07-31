//
//  vdp_doublebuf.v
//    Double Buffered Line Memory.
//
//  Copyright (C) 2000-2006 Kunihiko Ohnaka
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
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//-----------------------------------------------------------------------------
// Memo
//   Japanese comment lines are starts with "JP:".
//   JP: ���{��̃R�����g�s�� JP:�𓪂ɕt���鎖�ɂ���
//
//-----------------------------------------------------------------------------
// Document
//
// JP: �_�u���o�b�t�@�����O�@�\�t�����C���o�b�t�@���W���[���B
// JP: vdp_vga.v �ɂ��A�b�v�X�L�����R���o�[�g�Ɏg�p���܂��B
//
// Line buffer module with double buffering function. 
// Used for upscan conversion by vdp_vga.v.
//
// JP: x_position_w �� X���W�����Cwe�� 1�ɂ���Ə������݃o�b�t�@��
// JP: �������܂��D�܂��Cx_position_r �� X���W������ƁC�ǂݍ���
// JP: �o�b�t�@����ǂݏo�����F�R�[�h�� q����o�͂����B
// JP: odd_line�M���ɂ���āC�ǂݍ��݃o�b�t�@�Ə������݃o�b�t�@��
// JP: �؂�ւ��B
//
// Put the X coordinate in x_position_w and set we to 1 to write to the write buffer. 
// When the X coordinate is put in x_position_r, the color code read from the read buffer is output from q.
// The read buffer and the write buffer are switched by the odd_line signal.
//
//-----------------------------------------------------------------------------
// History
//
// 2020/Jan/20th
//    Converted to VerilogHDL from VHDL by t.hara
//

module vdp_doublebuf (
	input			clk,
	input	[ 9:0]	x_position_w,
	input	[ 9:0]	x_position_r,
	input			odd_line,
	input			we,
	input	[ 5:0]	r_in,
	input	[ 5:0]	g_in,
	input	[ 5:0]	b_in,
	output	[ 5:0]	r_out,
	output	[ 5:0]	g_out,
	output	[ 5:0]	b_out
);

	wire			we_e;
	wire			we_o;
	wire	[ 9:0]	addr_e;
	wire	[ 9:0]	addr_o;
	wire	[ 5:0]	outr_e;
	wire	[ 5:0]	outg_e;
	wire	[ 5:0]	outb_e;
	wire	[ 5:0]	outr_o;
	wire	[ 5:0]	outg_o;
	wire	[ 5:0]	outb_o;

	// even line
	vdp_linebuf u_buf_r_even (
		.address	( addr_e	),
		.inclock	( clk		),
		.we			( we_e		),
		.data		( r_in		),
		.q			( outr_e	)
	);

	vdp_linebuf u_buf_g_even (
		.address	( addr_e	),
		.inclock	( clk		),
		.we			( we_e		),
		.data		( g_in		),
		.q			( outg_e	)
	);

	vdp_linebuf u_buf_b_even (
		.address	( addr_e	),
		.inclock	( clk		),
		.we			( we_e		),
		.data		( b_in		),
		.q			( outb_e	)
	);
	// odd line
	vdp_linebuf u_buf_r_odd (
		.address	( addr_o	),
		.inclock	( clk		),
		.we			( we_o		),
		.data		( r_in		),
		.q			( outr_o	)
	);

	vdp_linebuf u_buf_g_odd (
		.address	( addr_o	),
		.inclock	( clk		),
		.we			( we_o		),
		.data		( g_in		),
		.q			( outg_o	)
	);

	vdp_linebuf u_buf_b_odd (
		.address	( addr_o	),
		.inclock	( clk		),
		.we			( we_o		),
		.data		( b_in		),
		.q			( outb_o	)
	);

	assign we_e			= ( odd_line == 1'b0 )? we : 1'b0;
	assign we_o			= ( odd_line == 1'b1 )? we : 1'b0;

	assign addr_e		= ( odd_line == 1'b0 )? x_position_w : x_position_r;
	assign addr_o		= ( odd_line == 1'b1 )? x_position_w : x_position_r;

	assign r_out		= ( odd_line == 1'b1 )? outr_e : outr_o;
	assign g_out		= ( odd_line == 1'b1 )? outg_e : outg_o;
	assign b_out		= ( odd_line == 1'b1 )? outb_e : outb_o;
endmodule
