//
//	vdp_interrupt.v
//	 Interrupt controller of ESE-VDP.
//
//	Copyright (C) 2000-2006 Kunihiko Ohnaka
//	All rights reserved.
//									   http://www.ohnaka.jp/ese-vdp/
//
//	�{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
//	�������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
//
//	1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
//	  �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
//	2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
//	  ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
//	3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
//	  �Ɏg�p���Ȃ����ƁB
//
//	�{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
//	����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
//	�I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
//	�����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
//	���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
//	����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
//	�[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
//	��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
//	���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
//
//	Note that above Japanese version license is the formal document.
//	The following translation is only for reference.
//
//	Redistribution and use of this software or any derivative works,
//	are permitted provided that the following conditions are met:
//
//	1. Redistributions of source code must retain the above copyright
//	   notice, this list of conditions and the following disclaimer.
//	2. Redistributions in binary form must reproduce the above
//	   copyright notice, this list of conditions and the following
//	   disclaimer in the documentation and/or other materials
//	   provided with the distribution.
//	3. Redistributions may not be sold, nor may they be used in a
//	   commercial product or activity without specific prior written
//	   permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
//	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//	POSSIBILITY OF SUCH DAMAGE.
//
// ----------------------------------------------------------------------------
//	Update history
//	3rd.Dec.2019 by t.hara
//		Converted to VerilogHDL.
//

module VDP_INTERRUPT (
	input			RESET,
	input			CLK21M,

	input	[ 8:0]	H_CNT,
	input	[ 7:0]	Y_CNT,
	input			ACTIVE_LINE,
	input			V_BLANKING_START,
	input			CLR_VSYNC_INT,
	input			CLR_HSYNC_INT,
	output			REQ_VSYNC_INT_N,
	output			REQ_HSYNC_INT_N,
	input	[ 7:0]	REG_R19_HSYNC_INT_LINE
);
	reg				ff_vsync_int_n;
	reg				ff_hsync_int_n;
	wire			w_vsync_intr_timing;

	assign REQ_VSYNC_INT_N		= ff_vsync_int_n;
	assign REQ_HSYNC_INT_N		= ff_hsync_int_n;

	//---------------------------------------------------------------------------
	// vsync interrupt request
	//---------------------------------------------------------------------------
	assign w_vsync_intr_timing	= ( H_CNT == 9'd8 ) ? 1'b1 : 1'b0;

	always @( posedge RESET or posedge CLK21M ) begin
		if( RESET ) begin
			ff_vsync_int_n <= 1'b1;
		end
		else begin
			if( CLR_VSYNC_INT ) begin
				// v-blanking interrupt clear
				ff_vsync_int_n <= 1'b1;
			end
			else if( w_vsync_intr_timing && V_BLANKING_START ) begin
				// v-blanking interrupt request
				ff_vsync_int_n <= 1'b0;
			end
		end
	end

	//---------------------------------------------------------------------------
	//	w_hsync interrupt request
	//---------------------------------------------------------------------------
	always @( posedge RESET or posedge CLK21M ) begin
		if( RESET ) begin
			ff_hsync_int_n <= 1'b1;
		end
		else begin
			if( CLR_HSYNC_INT || (w_vsync_intr_timing && V_BLANKING_START) ) begin
				// h-blanking interrupt clear
				ff_hsync_int_n <= 1'b1;
			end
			else if( ACTIVE_LINE && (Y_CNT == REG_R19_HSYNC_INT_LINE) ) begin
				// h-blanking interrupt request
				ff_hsync_int_n <= 1'b0;
			end
		end
	end
endmodule
