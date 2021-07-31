//
//	vdp_package.v
//	 Package file of ESE-VDP.
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
//-----------------------------------------------------------------------------
// Memo
//	 Japanese comment lines are starts with "JP:".
//	 JP: ���{��̃R�����g�s�� JP:�𓪂ɕt���鎖�ɂ���
//
//-----------------------------------------------------------------------------
// Revision History
//
// 3rd,December,2019 modified by t.hara
//	 - Converted to VerilogHDL from VHDL.
//
// 29th,October,2006 modified by Kunihiko Ohnaka
//	 - Insert the license text.
//	 - Add the document part below.
//
//-----------------------------------------------------------------------------
// Document
//
// JP: ESE-VDP�̃p�b�P�[�W�t�@�C���ł��B
// JP: ESE-VDP�Ɋ܂܂�郂�W���[���̃R���|�[�l���g�錾��A�萔�錾�A
// JP: �^�ϊ��p�̊֐��Ȃǂ���`����Ă��܂��B
//

// vdp id
//	`define vdp_id		5'b00000	// v9938
`define vdp_id		5'b00010	// v9958

// display start position ( when adjust=(0,0) )
// [from v9938 technical data book]
// horizontal display `defines
//	[non text]
//	 * total display	  1368 clks	 - a
//	 * right border			59 clks	 - b
//	 * right blanking		27 clks	 - c
//	 * h-sync pulse width  100 clks	 - d
//	 * left blanking	   102 clks	 - e
//	 * left border			56 clks	 - f
// offset_x is the position when predotcounter_x is -8. so,
//	  => (d+e+f-8*4-8*4)/4 => (100+102+56)/4 - 16 => 48 + 1 = 49
//
// vertical display `defines (ntsc)
//							  [192 lines]  [212 lines]
//							  [even][odd]  [even][odd]
//	 * v-sync pulse width		   3	3		3	 3 lines - g
//	 * top blanking				  13 13.5	   13 13.5 lines - h
//	 * top border				  26   26	   16	16 lines - i
//	 * display time				 192  192	  212  212 lines - j
//	 * bottom border			25.5   25	 15.5	15 lines - k
//	 * bottom blanking			   3	3		3	 3 lines - l
// offset_y is the start line of top border (192 lines mode)
//	  => l+g+h => 3 + 3 + 13 = 19
//

`define clocks_per_line					1368							// 342*4

// left-top position of visible area
`define offset_x						7'b0110001						// 49

`define led_tv_x_ntsc					(-3)
`define led_tv_y_ntsc					1
`define led_tv_x_pal					(-2)
`define led_tv_y_pal					3

//	`define display_offset_ntsc				0
//	`define display_offset_pal				27

//	`define scan_line_offset_192			24
//	`define scan_line_offset_212			14

//	`define last_line_ntsc					262								// 262 & 262.5 => 3 + 13 + 26 + 192 + 25 + 3
//	`define last_line_pal					313								// 312.5 & 313 => 3 + 13 + 53 + 192 + 49 + 3

//	`define first_line_192_ntsc				(display_offset_ntsc + scan_line_offset_192)
//	`define first_line_212_ntsc				(display_offset_ntsc + scan_line_offset_212)
//	`define first_line_192_pal				(display_offset_pal + scan_line_offset_192)
//	`define first_line_212_pal				(display_offset_pal + scan_line_offset_212)

//	`define internal_x_init					102
//	`define pre_dotcounter_x_start			(-30)
//	`define pre_dotcounter_y_start			(-2)
//	`define pre_dotcounter_y_start_192_ntsc	(pre_dotcounter_y_start - display_offset_ntsc - scan_line_offset_192)
//	`define pre_dotcounter_y_start_212_ntsc	(pre_dotcounter_y_start - display_offset_ntsc - scan_line_offset_212)
//	`define pre_dotcounter_y_start_192_pal	(pre_dotcounter_y_start - display_offset_pal - scan_line_offset_192)
//	`define pre_dotcounter_y_start_212_pal	(pre_dotcounter_y_start - display_offset_pal - scan_line_offset_212)

`define left_border						235
//	`define display_area					1024

//	`define visible_area_sx					left_border
//	`define visible_area_ex					clocks_per_line

//	`define h_blanking_start				(clocks_per_line - 59 - 27 + 1)

`define v_blanking_start_192_ntsc		240
`define v_blanking_start_212_ntsc		250
`define v_blanking_start_192_pal		263
`define v_blanking_start_212_pal		273
