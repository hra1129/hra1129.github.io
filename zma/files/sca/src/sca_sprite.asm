; -----------------------------------------------------------------------------
;	�X�v���C�g�\���X�V����
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	DRAM��̃X�v���C�g�A�g���r���[�g�e�[�u���C���[�W��������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a,b,c,d,e,f
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sprite_init::
		; �X�v���C�g�A�g���r���[�g�e�[�u���� 212 �ŏ���������
		ld		hl, sprite_attribute_table
		ld		de, sprite_attribute_table + 1
		ld		bc, 4*32 - 1
		ld		[hl], 212
		ldir
		; �X�v���C�g�p�^�[���ԍ���������
		ld		b, 32
		ld		de, sprite_pattern_data
		ld		hl, sprite_attribute_table + 2
sprite_init_loop1:
		ld		a, [de]
		ld		[hl], a
		inc		de
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		djnz	sprite_init_loop1
		ret

; -----------------------------------------------------------------------------
;	�X�v���C�g�J���[���Z�b�g����
;	input
;		a ...	�X�v���C�g�ԍ�[0�`31]
;		c ...	�F�f�[�^
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		COLOR SPRITE[a] = c �ɑ���
; -----------------------------------------------------------------------------
sprite_set_color::
		; hl = SPRITE_COLOR + a * 16
		ld		hl, SPRITE_COLOR
		rlca			; c�t���O�͕K�� 0
		rlca			; c�t���O�͕K�� 0
		rlca			; c�t���O�͕K�� 0
		rlca
		jr		nc, sprite_set_color_skip1
		inc		h
sprite_set_color_skip1:
		ld		l, a	; SPRITE_COLOR �̉���8bit �� 0x00 �Ȃ̂� a+l �� a �Ɠ����B�Ȃ̂ő�������ŗǂ��B
		; a = �F�f�[�^
		ld		a, c
		; bc = 16
		ld		bc, 16
		jp		FILVRM

; -----------------------------------------------------------------------------
;	DRAM��̃X�v���C�g�A�g���r���[�g�e�[�u���C���[�W���X�V
;	input:
;		ix	...	���e�[�u���̃A�h���X
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sprite_update::
		; ���e�[�u���̍��W��DRAM��̃A�g���r���[�g�e�[�u���C���[�W�֓]��
		ld		de, SCA_INFO_SIZE
		ld		hl, sprite_attribute_table
		ld		b, 32
sprite_update_loop:
		ld		a, [ix + SCA_INFO_YH]
		ld		[hl], a
		inc		hl
		ld		a, [ix + SCA_INFO_XH]
		ld		[hl], a
		inc		hl
		inc		hl
		inc		hl
		add		ix, de
		djnz	sprite_update_loop
sprite_update_player:
		; ���@�����G��Ԃ��H
		ld		a, [player_invincibility]
		or		a, a
		jr		z, sprite_update_transfer
		inc		a
		jr		z, sprite_update_transfer
		; 1/30�̃^�C�~���O���H
		ld		a, [software_timer]
		and		a, 1
		jr		z, sprite_update_transfer
		; ���@���\���ɂ���i�_�ł�����j
		ld		a, 212
		ld		[sprite_attribute_table + 0], a
		ld		[sprite_attribute_table + 4], a
sprite_update_transfer:
		; �A�g���r���[�g�e�[�u���C���[�W��VRAM�֓]��
		ld		hl, sprite_attribute_table
		ld		de, SPRITE_ATTRIBUTE
		ld		bc, 4*32
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	�X�v���C�g��S��������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sprite_all_clear::
		ld		b, 32
		ld		hl, sprite_attribute_table
		ld		a, 212
sprite_all_clear_loop:
		ld		[hl], a
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		djnz	sprite_all_clear_loop
		jp		sprite_update_transfer

sprite_attribute_table::
		repeat i, 32				; [+0:Y���W, +1:X���W, +2:�p�^�[���ԍ�, +3:���g�p] �� 32����
			db	0, 0, 0, 0
		endr

sprite_pattern_data:
		db		0 , 4 , 12, 16, 24, 28, 32, 36
		db		40, 44, 48, 52, 56, 60, 20, 20
		db		20, 20, 20, 20, 20, 20, 20, 20
		db		20, 20, 20, 20, 20, 8 , 8 , 8 
