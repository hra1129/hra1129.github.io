; -----------------------------------------------------------------------------
;	�w�i�\���X�V����
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�Q�[����ʂ̕\��������������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_init_game_screen::
		; �X�N���[���J�E���^�[������
		xor		a, a
		ld		[background_scroll_timing], a
		; �E���X�R�A�\���̈���X�y�[�X�Ŗ��ߐs����
		ld		hl, PATTERN_NAME1 + 24					; locate 24,0
		ld		bc, 8									; ���� 8������
		ld		e, 24									; 24���C������
background_init_score_area_loop1:
		push	de
		push	bc
		xor		a, a										; �X�y�[�X�̕����R�[�h�� 0
		call	FILVRM									; 0 �œh��Ԃ�
		pop		bc
		ld		de, 32									; ���̃��C���ւ̃I�t�Z�b�g
		add		hl, de
		pop		de
		dec		e
		jr		nz, background_init_score_area_loop1
background_init_put_score:
		; "HISCORE" ��\��
		ld		hl, background_str_hiscore
		ld		de, PATTERN_NAME1 + 24 + 32*1		; locate 24,1
		ld		bc, 7
		call	LDIRVM
		; "SCORE" ��\��
		ld		hl, background_str_score
		ld		de, PATTERN_NAME1 + 24 + 32*5		; locate 24,5
		ld		bc, 5
		call	LDIRVM
		; �X�R�A�\���X�V
		call	score_update_high_score
		call	score_update
		; ���@���\���X�V
		call	background_update_player_info
		ret

; -----------------------------------------------------------------------------
;	���@����\��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_update_player_info::
		; ���@�������W
		ld		a, [player_speed]
		inc		a
		ld		[background_str_speed_num], a
		ld		a, [player_shot]
		inc		a
		ld		[background_str_shot_num], a
		ld		a, [player_shield]
		inc		a
		ld		[background_str_shield_num], a
		; "SPEED x" ��\��
		ld		hl, background_str_speed
		ld		de, PATTERN_NAME1 + 24 + 32*18			; locate 24,18
		ld		bc, 7
		call	LDIRVM
		; "SHOT  x" ��\��
		ld		hl, background_str_shot
		ld		de, PATTERN_NAME1 + 24 + 32*20			; locate 24,20
		ld		bc, 7
		call	LDIRVM
		; "SHIELDx" ��\��
		ld		hl, background_str_shield
		ld		de, PATTERN_NAME1 + 24 + 32*22			; locate 24,22
		ld		bc, 7
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	�Q�[����ʂ̕\��������������
;	input:
;		a	...	�X�e�[�W�ԍ� [0 = stage1]
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_draw_stage_x::
		; "STAGEx" ��\��
		and		a, 7
		inc		a
		inc		a
		ld		[background_str_stage_number], a
		dec		a
		dec		a
		; �w�i�f�[�^�̃A�h���X�� HL �Ɏ擾����
		rlca
		ld		l, a
		ld		h, 0
		ld		de, background_stage_address
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		; �w�i�f�[�^��`�悷��
		ld		a, 2
		ld		[background_is_odd], a
		ld		b, 24									; 24���C��
		ld		de, sca_screen_buffer + 576 + 576 - 24	; ������`�悷��
background_draw_stage_x_loop:
		ld		a, [hl]									; �w�i�f�[�^�͂P��ʕ��͗p�ӂ��Ă���O��B�Ȃ̂Ń��[�v���̃`�F�b�N�͖����B
		push	bc
		push	hl
		call	background_draw_parts
		ex		de, hl
		ld		de, -24-24								; background_draw_parts �� DE �͂P���̃��C�����������߁A2���C���߂�
		add		hl, de
		ex		de, hl
		pop		hl
		pop		bc
		; �㔼���Ɖ�������؂�ւ���
		ld		a, [background_is_odd]
		xor		a, 2
		ld		[background_is_odd], a
		jr		z, background_draw_stage_x_skip1
		; �V�����������̎��ɃA�h���X���C���N�������g
		inc		hl
background_draw_stage_x_skip1:
		djnz	background_draw_stage_x_loop
		; �w�i�f�[�^�̃A�h���X���������ɕێ�����
		ld		[background_stage_pointer], hl
		; ���z��ʂ��X�V����
		ld		hl, sca_screen_buffer
		ld		de, sca_screen_buffer + 1
		ld		bc, 576-1
		xor		a, a
		ld		[hl], a
		ldir
		; "STAGEx" ��\��
		ld		hl, background_str_stage
		ld		de, sca_screen_buffer + 9 + 24*8			; locate 9,8
		ld		bc, 6
		ldir
		; �w�i�X�V�t���O�𗧂Ă�
		ld		a, 1
		ld		[background_update], a
		ret

; -----------------------------------------------------------------------------
;	�Q�[����ʂ� STAGE*/WARNING!! �̕\������������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_delete_stage_message::
		ld		hl, sca_screen_buffer + 8 + 24*8			; locate 8,8
		ld		de, sca_screen_buffer + 8 + 24*8 + 1
		ld		bc, 9-1
		xor		a, a
		ld		[hl], a
		ldir
		ret

; -----------------------------------------------------------------------------
;	�Q�[����ʂ� WARNING!! ��\��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_show_warning::
		ld		hl, background_str_warning
		ld		de, sca_screen_buffer + 8 + 24*8			; locate 8, 8
		ld		bc, 9
		ldir
		ret

; -----------------------------------------------------------------------------
;	�������N���A
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_clear_left_side:
		; �t�B�[���h�����i�X�R�A�\�����ȊO�̕����j������������
		ld		c, VDP_VRAM_IO
		ld		hl, PATTERN_NAME1
		ld		de, 0
		ld		b, 24									; 24���C������
background_clear_left_side_loop2:
		push	bc
		call	SETWRT
		ld		b, 24									; ���� 24������
		ld		d, 0
		xor		a, a
background_clear_left_side_loop1:
		out		[c], a
		djnz	background_clear_left_side_loop1
		ld		de, 32									; ���̃��C���ւ̃I�t�Z�b�g
		add		hl, de
		pop		bc
		djnz	background_clear_left_side_loop2
		ret

; -----------------------------------------------------------------------------
;	�Q�[���N���A��ʂ̏�����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_init_stage_clear_screen::
		; �������N���A
		call	background_clear_left_side
		; STAGE CLEAR! �\��
		ld		hl, background_str_stage_clear
		ld		de, PATTERN_NAME1 + 6 + 32*5			; locate 6,5
		ld		bc, 12
		call	LDIRVM
		; CLEAR BONUS 10000 �\��
		ld		hl, background_str_clear_bonus
		ld		de, PATTERN_NAME1 + 3 + 32*11			; locate 3,11
		ld		bc, 17
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	�Q�[���I�[�o�[��ʂ̏�����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_init_gameover_screen::
		; �������N���A
		call	background_clear_left_side
		; GAMEOVER �\��
		ld		hl, background_str_gameover
		ld		de, PATTERN_NAME1 + 8 + 32*10		; locate 8,10
		ld		bc, 9
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	�w�i�ɂP���C������`�悷��
;	input:
;		a	...	�p�[�c�ԍ�[0�`127]
;		de	...	�`���A�h���X
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�㔼���Ȃ� background_is_odd �� 0 ���A�������Ȃ� 3 �����Ă���
;		de �͎��̃��C���̓��������ʒu�ɕω�����
; -----------------------------------------------------------------------------
background_draw_parts:
		; HL = A*12 + background_map_parts = A*8+A*4 + background_map_parts
		ld		l, a
		ld		h, 0
		add		hl, hl
		add		hl, hl
		push	hl
		add		hl, hl
		pop		bc
		add		hl, bc
		ld		bc, background_map_parts
		add		hl, bc
		; 12�`��
		ld		b, 12
background_draw_loop:
		ld		a, [background_is_odd]		; �㔼������������
		add		a, [hl]						; �p�[�c�ԍ��擾
		ld		[de], a						; ��������`��
		inc		a
		inc		de
		ld		[de], a						; �E������`��
		inc		de
		inc		hl
		djnz	background_draw_loop
		ret

; -----------------------------------------------------------------------------
;	�w�i�̃X�N���[��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_scroll::
		; �X�N���[������^�C�~���O���H
		ld		a, [background_scroll_timing]
		dec		a
		and		a, 15
		ld		[background_scroll_timing], a
		ret		nz
		; �w�i�X�V�t���O�𗧂Ă�
		ld		a, 1
		ld		[background_update], a
		; �w�i�C���[�W���X�N���[��������
		ld		de, sca_screen_buffer + 576 * 2 - 1
		ld		hl, sca_screen_buffer + 576 * 2 - 1 - 24
		ld		bc, 24 * 23
		lddr
		; �w�i�f�[�^���� 1byte �ǂݎ��
		ld		hl, [background_stage_pointer]
		ld		a, [hl]
		cp		a, 0x80
		jr		c, background_scroll_update_line
		; 0x80 �̏ꍇ�͖߂�
background_scroll2::
		inc		hl
		ld		a, l
		sub		a, [hl]
		ld		l, a
		jr		nc, background_scroll_skip0
		dec		h
background_scroll_skip0:
		ld		a, [hl]
		ld		[background_stage_pointer], hl
background_scroll_update_line:
		; �w�i�̈�ԏ�̃��C���ɐV�����w�i��`��
		ld		de, sca_screen_buffer + 576
		call	background_draw_parts
		; �㔼���Ɖ�������؂�ւ���
		ld		a, [background_is_odd]
		xor		a, 2
		ld		[background_is_odd], a
		jr		z, background_scroll_skip1
		; �V�����������̎��ɃA�h���X���C���N�������g
		ld		hl, [background_stage_pointer]
		inc		hl
		ld		[background_stage_pointer], hl
background_scroll_skip1:
		ret

; -----------------------------------------------------------------------------
;	�w�i����ʂ֓]��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_transfer::
		; �w�i���X�V����Ă��Ȃ���Ή������Ȃ�
		ld		a, [background_update]
		or		a, a
		ret		z
		xor		a, a
		ld		[background_update], a
		; �w�i�O���t�B�b�N�ƃI�[�o�[���b�v�������������Ȃ��� VRAM �֓]������
		ld		hl, PATTERN_NAME1						; �]���� VRAM �A�h���X
		ld		de, sca_screen_buffer					; �]���� DRAM �A�h���X
		ld		b, 24									; 24���C������
background_transfer_loop1:
		push	bc
		push	hl										; �]���� VRAM �A�h���X��ۑ�����
		call	SETWRT									; �]���� VRAM �A�h���X�� VDP �ɃZ�b�g����
		ld		l, e									; HL = �]���� DRAM �A�h���X + 576
		ld		h, d
		ld		bc, 576
		add		hl, bc
		ld		bc, 24 * 256 + VDP_VRAM_IO				; B = 24, C = VDP_VRAM_IO: ���� 24������
background_transfer_loop2:
		ld		a, [de]									; �]���� DRAM �A�h���X �̓��e���擾
		or		a, a										; ����� �[�� ���H
		jp		nz, background_transfer_skip1
		ld		a, [hl]									; �[���̏ꍇ�́A�]���� DRAM �A�h���X + 576 �̓��e���擾
background_transfer_skip1:
		inc		de										; �A�h���X�C���N�������g
		inc		hl										; �A�h���X�C���N�������g
		out		[c], a									; VRAM �֏����o��
		djnz	background_transfer_loop2				; 24�������J��Ԃ�
		pop		hl										; �]���� VRAM �A�h���X�𕜋A
		ld		bc, 32									; �]���� VRAM �A�h���X���X�V����
		add		hl, bc
		pop		bc
		djnz	background_transfer_loop1
		ret

; -----------------------------------------------------------------------------
;	�O���t�B�b�N���W�Ŏw�����ꂽ�ꏊ�ɂ���w�i�L�����N�^�R�[�h��Ԃ�
;	input:
;		h	...	X���W
;		l	...	Y���W
;	output
;		a	...	�L�����N�^�R�[�h
;		hl	...	���z�������A�h���X
;	break
;		a, d, e, h, l, f
;	comment
;		sca_screen_buffer[ 576 + h/8 + l/8*24 ]
;		�� sca_screen_buffer[ 576 + h/8 + [l & 0xF8]*3 ]
; -----------------------------------------------------------------------------
background_get_char::
		ld		a, h
		srl		a
		srl		a
		srl		a
		ld		e, a		; e = h/8
		ld		a, l
		and		a, 0xF8		; C�t���O = 0
		ld		l, a		; l = l & 0xF8
		rl		a
		ld		h, 0
		rl		h			; ha = [l & 0xF8] * 2
		add		a, l
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = [l & 0xF8] * 3
		ld		a, l
		add		a, e
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = h/8 + [l & 0xF8] * 3
		ld		de, sca_screen_buffer + 576
		add		hl, de
		ld		a, [hl]
		ret

; -----------------------------------------------------------------------------
;	�O���t�B�b�N���W�Ŏw�����ꂽ�ꏊ�ɂ���O�i�L�����N�^�R�[�h��Ԃ�
;	input:
;		h	...	X���W
;		l	...	Y���W
;	output
;		a	...	�L�����N�^�R�[�h
;		hl	...	���z�������A�h���X
;	break
;		a, d, e, h, l, f
;	comment
;		sca_screen_buffer[ h/8 + l/8*24 ]
;		�� sca_screen_buffer[ h/8 + [l & 0xF8]*3 ]
; -----------------------------------------------------------------------------
background_get_fore_char::
		ld		a, h
		srl		a
		srl		a
		srl		a
		ld		e, a		; e = h/8
		ld		a, l
		and		a, 0xF8		; C�t���O = 0
		ld		l, a		; l = l & 0xF8
		rl		a
		ld		h, 0
		rl		h			; ha = [l & 0xF8] * 2
		add		a, l
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = [l & 0xF8] * 3
		ld		a, l
		add		a, e
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = h/8 + [l & 0xF8] * 3
		ld		de, sca_screen_buffer
		add		hl, de
		ld		a, [hl]
		ret

; -----------------------------------------------------------------------------
;	�O���t�B�b�N�p�[�c������������
;	input:
;		hl	...	���z�������A�h���X
;		a	...	�V�����p�[�c�̍���L�����N�^�R�[�h
;	output
;		�Ȃ�
;	break
;		a, d, e, h, l, f
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_put_char::
		ld		e, a		; �ۑ�
		; hl �̈ʒu���p�[�c�̍���ɂȂ�悤�ɕ␳����
		ld		a, [hl]
		and		a, 3
		jr		z, background_put_char_skip1	; ����2bit �� 0 �Ȃ�␳�̕K�v�Ȃ�
		cp		a, 2
		jr		c, background_put_char_skip2	; 1 �Ȃ� Y�����̕␳�͕K�v�Ȃ�
		ld		bc, -24
		add		hl, bc							; Y�����ɕ␳
		and		a, 1
		jr		z, background_put_char_skip1
background_put_char_skip2:
		dec		hl								; X�����ɕ␳
background_put_char_skip1:
		; �V�����L�����N�^����������
		ld		a, e
		ld		[hl], a							; ����
		inc		hl
		inc		a
		ld		[hl], a							; �E��
		ld		bc, 23
		add		hl, bc
		inc		a
		ld		[hl], a							; ����
		inc		hl
		inc		a
		ld		[hl], a							; �E��
		; �w�i�X�V�t���O�𗧂Ă�
		ld		a, 1
		ld		[background_update], a
		ret

; -----------------------------------------------------------------------------
;	���X�{�X���p�[�c��`�悷��
;	input:
;		e	...	X���W
;		d	...	Y���W	[0�`13]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
draw_boss8_left::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0�`13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; �]����
		ld		de, background_boss8_left
		ld		a, 11
		ld		[background_update], a			; ����X�V����悤�� background_update �� 0�ȊO �ɂ��Ă���
		; �]��
draw_boss8_left_loop:
		ex		de, hl
		ld		bc, 8
		ldir
		ex		de, hl
		ld		bc, 24-8
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_left_loop
		ret

; -----------------------------------------------------------------------------
;	���X�{�X�E�p�[�c��`�悷��
;	input:
;		e	...	X���W
;		d	...	Y���W	[0�`13]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
draw_boss8_right::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0�`13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; �]����
		ld		de, background_boss8_right
		ld		a, 11
		ld		[background_update], a			; ����X�V����悤�� background_update �� 0�ȊO �ɂ��Ă���
		; �]��
draw_boss8_right_loop:
		ex		de, hl
		ld		bc, 8
		ldir
		ex		de, hl
		ld		bc, 24-8
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_right_loop
		ret

; -----------------------------------------------------------------------------
;	���X�{�X���E�p�[�c����������
;	input:
;		e	...	X���W
;		d	...	Y���W	[0�`13]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
draw_boss8_delete::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0�`13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; �]����
		ld		a, 11
		ld		[boss_center_update], a			; �����p�[�c���X�V����
		ld		[background_update], a			; ����X�V����悤�� background_update �� 0�ȊO �ɂ��Ă���
		; �]��
draw_boss8_delete_loop:
		ld		e, l
		ld		d, h
		ld		[hl], 0
		inc		de
		ld		bc, 7
		ldir
		ld		bc, 24-7
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_delete_loop
		ret

; -----------------------------------------------------------------------------
;	���X�{�X�����p�[�c��`�悷��1
;	input:
;		e	...	X���W
;		d	...	Y���W	[0�`13]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		0 �Ԃ̃L�����͕`���Ȃ�
; -----------------------------------------------------------------------------
draw_boss8_center::
		inc		d
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0�`13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer+1
		add		hl, bc
		; �]����
		ld		de, background_boss8_center+1+9
		ld		c, 6
		ld		[background_update], a			; ����X�V����悤�� background_update �� 0�ȊO �ɂ��Ă���
		; �]��
draw_boss8_center_loop1:
		push	bc
		ld		b, 7
draw_boss8_center_loop2:
		ld		a, [de]
		or		a, a
		jp		z, draw_boss8_center_skip1
		ld		[hl], a
draw_boss8_center_skip1:
		inc		de
		inc		hl
		djnz	draw_boss8_center_loop2
		inc		de
		inc		de
		ld		bc, 24-7
		add		hl, bc
		pop		bc
		dec		c
		jp		nz, draw_boss8_center_loop1
		ret

; -----------------------------------------------------------------------------
;	���X�{�X�����p�[�c��`�悷��2
;	input:
;		e	...	X���W
;		d	...	Y���W	[0�`13]
;		a	...	0: ��_��`��, 0�ȊO: ��_��`�悵�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		0 �Ԃ̃L�������`��
; -----------------------------------------------------------------------------
draw_boss8_center2::
		push	af
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0�`13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; �]����
		ld		de, background_boss8_center
		pop		af
		or		a, a
		ld		a, 8
		jp		z, draw_boss8_center2_skip1
		dec		a
draw_boss8_center2_skip1:
		ld		[background_update], a			; ����X�V����悤�� background_update �� 0�ȊO �ɂ��Ă���
		; �]��
draw_boss8_center2_loop:						; ��_���`�悷��ꍇ
		ex		de, hl
		ld		bc, 9
		ldir
		ex		de, hl
		ld		bc, 24-9
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_center2_loop
		; ����������
		ld		e, l
		ld		d, h
		inc		de
		xor		a, a
		ld		[hl], a
		ld		bc, 9-1
		ldir
		ret

; -----------------------------------------------------------------------------
;	���X�{�X�����p�[�c����������
;	input:
;		e	...	X���W
;		d	...	Y���W	[0�`13]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		0 �Ԃ̃L�����͕`���Ȃ�
; -----------------------------------------------------------------------------
draw_boss8_center_delete::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0�`13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; �]����
		ld		a, 9
		ld		[background_update], a			; ����X�V����悤�� background_update �� 0�ȊO �ɂ��Ă���
		; �]��
draw_boss8_center_delete_loop:
		ld		e, l
		ld		d, h
		ld		[hl], 0
		inc		de
		ld		bc, 8
		ldir
		ld		bc, 24-8
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_center_delete_loop
		ret

		; �w�i�f�[�^�̃A�h���X�ꗗ
background_stage_address:
		dw		background_stage1
		dw		background_stage2
		dw		background_stage3
		dw		background_stage4
		dw		background_stage5
		dw		background_stage6
		dw		background_stage7
		dw		background_stage8

; -----------------------------------------------------------------------------
;	���X�{�X���[�U�[��`�悷��
;	input:
;		e	...	�����p�[�c����X���W
;		d	...	�����p�[�c����Y���W
;		a	... 105: ���[�U�[��`�悷��, 0: ���[�U�[����������
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
background_draw_laser::
		push	af
		; hl = d * 24 + 7*24 + [e + 2] = d * 16 + d * 8 + e + 170
		ld		a, d
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer + 170
		add		hl, bc
		; �`�悷�郉�C���������߂�
		ld		a, 24-7
		sub		a, d
		ld		b, a
		pop		af
		ld		de, 24-5+1
background_draw_laser_loop1:
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		add		hl, de
		djnz	background_draw_laser_loop1
		ret

		; �X�N���[���^�C�~���O�J�E���^
background_scroll_timing:
		db		0									; 0�`15 �f�N�������g�J�E���^

		; ���ɃX�N���[���Ō���郉�C���� even[�㔼��]=0, odd[������]=2 ���H
background_is_odd:
		db		0

		; �w�i�f�[�^�̓ǂݎ��A�h���X
background_stage_pointer::
		dw		0

		; �w�i�X�V�t���O
background_update:
		db		0

		; "HI"
background_str_hiscore:
		db		18, 19
		; "SCORE"
background_str_score:
		db		29, 13, 25, 28, 15
		; "SPEED x"
background_str_speed:
		db		29, 26, 15, 15, 14, 0
background_str_speed_num:
		db		1									; SPEED�ԍ� + 1
		; "SHOT  x"
background_str_shot:
		db		29, 18, 25, 30, 0 , 0
background_str_shot_num:
		db		1									; SHOT�ԍ� + 1
		; "SHIELDx"
background_str_shield:
		db		29, 18, 19, 15, 22, 14
background_str_shield_num:
		db		1									; SHIELD�ԍ� + 1
		; "STAGE"
background_str_stage:
		db		29, 30, 11, 17, 15
background_str_stage_number:
		db		02									; STAGE�ԍ� + 1
		; "WARNING!!"
background_str_warning:
		db		33, 11, 28, 24, 19, 24, 17, 37, 37
		; "STAGE CLEAR!"
background_str_stage_clear:
		db		29, 30, 11, 17, 15, 0 , 13, 22, 15, 11, 28, 37
		; "CLEAR BONUS 10000"
background_str_clear_bonus:
		db		13, 22, 15, 11, 28, 0 , 12, 25, 24, 31, 29, 0
		db		2 , 1 , 1 , 1 , 1 
		; "GAME OVER"
background_str_gameover:
		db		17, 11, 23, 15, 0 , 25, 32, 15, 28
		; ���X�{�X ���p�[�c
background_boss8_left:
		db		0,   0,   0,   0,   0,   0,   0,   0
		db		96,  101, 101, 101, 101, 101, 97,  0
		db		102, 104, 104, 104, 104, 104, 103, 112
		db		102, 104, 104, 104, 104, 104, 103, 111
		db		102, 104, 104, 104, 104, 104, 103, 108
		db		102, 104, 104, 104, 104, 104, 99,  0
		db		102, 104, 104, 104, 104, 103, 0,   0
		db		102, 104, 104, 104, 104, 103, 0,   0
		db		102, 104, 104, 104, 104, 103, 0,   0
		db		98,  100, 100, 100, 100, 99,  0,   0
		db		0,   0,   0,   0,   0,   0,   0,   0
		; ���X�{�X �E�p�[�c
background_boss8_right:
		db		0,   0,   0,   0,   0,   0,   0,   0
		db		0,   96,  101, 101, 101, 101, 101, 97
		db		110, 102, 104, 104, 104, 104, 104, 103
		db		109, 102, 104, 104, 104, 104, 104, 103
		db		106, 102, 104, 104, 104, 104, 104, 103
		db		0,   98,  104, 104, 104, 104, 104, 103
		db		0,   0,   102, 104, 104, 104, 104, 103
		db		0,   0,   102, 104, 104, 104, 104, 103
		db		0,   0,   102, 104, 104, 104, 104, 103
		db		0,   0,   98,  100, 100, 100, 100, 99
		db		0,   0,   0,   0,   0,   0,   0,   0
		; ���X�{�X �����p�[�c
background_boss8_center:
		db		0,   0,   0,   0,   0,   0,   0,   0,   0
		db		0,   96,  101, 101, 101, 101, 101, 97,  0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   98,  100, 100, 100, 100, 100, 99,  0
		db		0,   0,   0,   106, 107, 108, 0,   0,   0
		; stage data
		include	"sca_stage_data.asm"
