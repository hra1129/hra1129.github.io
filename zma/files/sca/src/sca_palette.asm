; -----------------------------------------------------------------------------
;	�p���b�g����
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�p���b�g�Z�b�g��ύX����
;	input:
;		a	...	�p���b�g�Z�b�g�̔ԍ� [0�`7]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		16�F�p���b�g�̐ݒ�l���W�߂��f�[�^���p���b�g�Z�b�g�ƌĂԂ��Ƃɂ���B
;		�{�\�[�X�Ō�ɂ��Ă��镡���̃p���b�g�Z�b�g�̒����珊�]�̃Z�b�g���w��
;		����B
; -----------------------------------------------------------------------------
change_palette::
		; hl = a * 32 + palette_set0
		rlca
		rlca
		rlca
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		bc, palette_set0
		add		hl, bc
		ld		[palette_adr], hl
change_palette_sub:
		; VDP R16 = 0 [palette0 ����ݒ肷��]
		xor		a, a
		di					; ���荞�ݏ������� VDP_CMDREG_IO ���g���̂Ŋ��֔r��
		out		[VDP_CMDREG_IO], a
		ld		a, 16 + 0x80
		out		[VDP_CMDREG_IO], a
		ei					; ����ȍ~�͔r���K�v�Ȃ�
		ld		a, [palette_fade]
		ld		b, a
		rlca
		rlca
		rlca
		rlca
		or		a, b
		ld		c, a
		ld		b, 16
change_palette_loop:
		; �ԂƐ�
		ld		a, [hl]
		inc		hl
		or		a, 0x88		; &B1XXX1XXX �ɂ���
		sub		a, c
		jp		m, change_palette_skip1
		and		a, 0x0F		; �Ԃ� bit7 �Ɍ��؂肵���ꍇ 0 �ɃN���A
change_palette_skip1:
		bit		3, a
		jp		nz, change_palette_skip2
		and		a, 0xF0		; �� bit3 �Ɍ��؂肵���ꍇ 0 �ɃN���A
change_palette_skip2:
		and		a, 0x77
		out		[VDP_PALREG_IO], a
		; ��
		ld		a, [hl]
		inc		hl
		or		a, 0x08		; &B00001XXX �ɂ���
		sub		a, c
		bit		3, a
		jp		nz, change_palette_skip3
		xor		a, a			; �΂� bit3 �Ɍ��؂肵���ꍇ 0 �ɃN���A
change_palette_skip3:
		and		a, 0x07
		out		[VDP_PALREG_IO], a
		djnz	change_palette_loop
		ret

; -----------------------------------------------------------------------------
;	�p���b�g�̃t�F�[�h�A�E�g�E�C��
;	input
;		a	...	�t�F�[�h�A�E�g�ʁi0:���̂܂� �` 7:�^�����j
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
fade_palette::
		ld		[palette_fade], a
		ld		hl, [palette_adr]
		jp		change_palette_sub

; -----------------------------------------------------------------------------
;	�p���b�g�t�F�[�h�ݒ�
palette_fade:
		db		0
palette_adr:
		dw		palette_set0

; -----------------------------------------------------------------------------
;	�p���b�g�f�[�^[1set 32byte]
palette_set0:	;  RB     -G		; �^�C�g���Estage1 �̐F [��]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x11, 0x06		; 2
		db		0x33, 0x07		; 3
		db		0x17, 0x01		; 4
		db		0x27, 0x03		; 5
		db		0x51, 0x01		; 6
		db		0x27, 0x06		; 7
		db		0x71, 0x01		; 8
		db		0x73, 0x03		; 9
		db		0x61, 0x06		; 10
		db		0x63, 0x06		; 11
		db		0x11, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x44, 0x04		; 14
		db		0x77, 0x07		; 15

palette_set1:	;  RB     -G		; stage2 �̐F [�[��]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x21, 0x06		; 2
		db		0x43, 0x07		; 3
		db		0x27, 0x01		; 4
		db		0x37, 0x03		; 5
		db		0x50, 0x01		; 6
		db		0x37, 0x06		; 7
		db		0x70, 0x01		; 8
		db		0x72, 0x03		; 9
		db		0x71, 0x06		; 10
		db		0x73, 0x06		; 11
		db		0x10, 0x04		; 12
		db		0x75, 0x02		; 13
		db		0x64, 0x04		; 14
		db		0x77, 0x07		; 15

palette_set2:	;  RB     -G		: stage3 �̐F [��]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x04, 0x05		; 2
		db		0x05, 0x06		; 3
		db		0x07, 0x01		; 4
		db		0x07, 0x03		; 5
		db		0x33, 0x00		; 6
		db		0x07, 0x06		; 7
		db		0x65, 0x00		; 8
		db		0x75, 0x02		; 9
		db		0x63, 0x04		; 10
		db		0x63, 0x05		; 11
		db		0x03, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x44, 0x04		; 14
		db		0x66, 0x06		; 15

palette_set3:	;  RB     -G		; stage4 �̐F [���Ă�]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x31, 0x06		; 2
		db		0x53, 0x07		; 3
		db		0x37, 0x01		; 4
		db		0x47, 0x03		; 5
		db		0x50, 0x00		; 6
		db		0x47, 0x06		; 7
		db		0x70, 0x00		; 8
		db		0x72, 0x02		; 9
		db		0x71, 0x06		; 10
		db		0x73, 0x06		; 11
		db		0x20, 0x04		; 12
		db		0x75, 0x03		; 13
		db		0x64, 0x04		; 14
		db		0x76, 0x06		; 15

palette_set4:	;  RB     -G		; stage5 �̐F [��]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x11, 0x06		; 2
		db		0x33, 0x07		; 3
		db		0x17, 0x01		; 4
		db		0x27, 0x03		; 5
		db		0x51, 0x01		; 6
		db		0x27, 0x06		; 7
		db		0x71, 0x01		; 8
		db		0x73, 0x03		; 9
		db		0x61, 0x06		; 10
		db		0x63, 0x06		; 11
		db		0x11, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x55, 0x05		; 14
		db		0x77, 0x07		; 15

palette_set5:	;  RB     -G		; stage6 �̐F [�[��]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x21, 0x06		; 2
		db		0x43, 0x07		; 3
		db		0x27, 0x01		; 4
		db		0x37, 0x03		; 5
		db		0x50, 0x01		; 6
		db		0x37, 0x06		; 7
		db		0x70, 0x01		; 8
		db		0x72, 0x03		; 9
		db		0x71, 0x06		; 10
		db		0x73, 0x06		; 11
		db		0x10, 0x04		; 12
		db		0x75, 0x02		; 13
		db		0x64, 0x04		; 14
		db		0x77, 0x07		; 15

palette_set6:	;  RB     -G		: stage7 �̐F [��]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x04, 0x05		; 2
		db		0x05, 0x06		; 3
		db		0x07, 0x01		; 4
		db		0x07, 0x03		; 5
		db		0x33, 0x00		; 6
		db		0x07, 0x06		; 7
		db		0x65, 0x00		; 8
		db		0x75, 0x02		; 9
		db		0x63, 0x04		; 10
		db		0x63, 0x05		; 11
		db		0x03, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x44, 0x04		; 14
		db		0x66, 0x06		; 15

palette_set7:	;  RB     -G		: stage8 �̐F [��n]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x11, 0x06		; 2
		db		0x33, 0x07		; 3
		db		0x14, 0x02		; 4
		db		0x27, 0x03		; 5
		db		0x60, 0x00		; 6
		db		0x07, 0x07		; 7
		db		0x70, 0x03		; 8
		db		0x73, 0x04		; 9
		db		0x70, 0x07		; 10
		db		0x73, 0x07		; 11
		db		0x11, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x55, 0x05		; 14
		db		0x77, 0x07		; 15
