; -----------------------------------------------------------------------------
;	�^�C�g����ʏ���
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�^�C�g�����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_title::
		call	bgmdriver_stop
		call	sca_title_screen
		call	sca_title_fade_in
		call	sca_title_main
		jp		sca_title_fade_out

; -----------------------------------------------------------------------------
;	�^�C�g����ʂ̃��C�����[�v
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_title_main:
		; VDP R18 = 0
		xor		a, a
		call	sca_vdp_r18
		; �\�t�g�E�F�A�^�C�}�[���N���A
		xor		a, a
		ld		[sca_title_scroll_pos], a				; �X�N���[���ʒu��������
		ld		[sca_title_wait_counter], a				; �b�J�E���^
		ld		[software_timer], a
sca_title_main_loop:
		ld		[sca_title_last_counter], a
		; 'M'�L�[�̉����m�F
		ld		a, 4									; �L�[�}�g���N�X�ԍ�
		call	SNSMAT
		and		a, 4										; M�L�[��������Ă��邩�H
		jp		z, sca_enter_music_mode					; M�L�[�������ꂽ�̂Ȃ� MUSIC MODE �֓˓�
		; �{�^���̉����m�F
		call	get_trigger
		jr		nz, sca_title_exit_effect				; �{�^����������Ă���΃��[�v��E����
		; PUSH SPACE BAR �̓_�ŏ���
		ld		a, [software_timer]
		bit		5, a			; 32/60[�b] ���Ƃɔ��]����r�b�g�𒲂ׂ�
		ld		hl, sca_title_push_space_bar			; ���̃r�b�g�� 0 �Ȃ� sca_title_push_space_bar ��I��
		jr		z, sca_title_main_skip1
		ld		hl, sca_title_push_space_bar_delete	; ���̃r�b�g�� 1 �Ȃ� sca_title_push_space_bar_delete ��I��
sca_title_main_skip1:
		ld		de, PATTERN_NAME1 + 9 + 32*16
		ld		bc, 14
		call	LDIRVM									; �`��
		; 1/60[�b]�o�߂���̂�҂�
		ld		hl, [sca_title_last_counter]
sca_title_main_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_main_wait_loop				; �ω����Ă��Ȃ���Αҋ@����
		cp		a, 60
		jr		c, sca_title_main_loop
		; �b�J�E���^���C���N�������g����
		ld		a, [sca_title_wait_counter]
		inc		a
		ld		[sca_title_wait_counter], a
		cp		a, 10
		jr		z, sca_title_left_scroll				; 10�b�o�߂����Ȃ�X�N���[�����J�n����
		xor		a, a
		ld		[software_timer], a
		jr		sca_title_main_loop

		; PUSH SPACE BAR ��1�b�ԍ����ɓ_�ł�����G�t�F�N�g����
sca_title_exit_effect:
		; �Q�[���J�n���ʉ�
		ld		hl, [se_start]
		call	bgmdriver_play_sound_effect
		; �\�t�g�E�F�A�^�C�}�[���N���A
		xor		a, a
		ld		[software_timer], a
sca_title_exit_effect_loop:
		ld		[sca_title_last_counter], a
		; PUSH SPACE BAR �̓_�ŏ���
		ld		a, [software_timer]
		bit		1, a			; 2/60[�b] ���Ƃɔ��]����r�b�g�𒲂ׂ�
		ld		hl, sca_title_push_space_bar			; ���̃r�b�g�� 0 �Ȃ� sca_title_push_space_bar ��I��
		jr		z, sca_title_exit_effect_skip1
		ld		hl, sca_title_push_space_bar_delete	; ���̃r�b�g�� 1 �Ȃ� sca_title_push_space_bar_delete ��I��
sca_title_exit_effect_skip1:
		ld		de, PATTERN_NAME1 + 9 + 32*16
		ld		bc, 14
		call	LDIRVM									; �`��
		; 1/60[�b]�o�߂���̂�҂�
		ld		hl, [sca_title_last_counter]
sca_title_exit_effect_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_exit_effect_wait_loop		; �ω����Ă��Ȃ���Αҋ@����
		; exit_effect �J�n���� 1�b�o�߂�����E����
		cp		a, 60
		ret		nc
		jr		sca_title_exit_effect_loop

		; ���ɃX�N���[�����鏈��
sca_title_left_scroll:
		xor		a, a
		ld		[sca_title_wait_counter], a				; 10�b�҂��J�E���^�����Z�b�g
sca_title_left_scroll_loop:
		; �h�b�g�P�ʉ��X�N���[��
		ld		a, [sca_title_scroll_pos]
		ld		b, a
		and		a, 7
		call	sca_vdp_r18
		; 8�h�b�g�X�N���[���������H
		ld		a, b
		and		a, 7
		call	z, sca_title_scroll_update				; ����3bit �� 0 �̂Ƃ��ɉ�ʑS�̂����������
		; �X�N���[��������
		ld		a, [sca_title_scroll_pos]
		add		a, 1									; inc a �� C�t���O���ω����Ȃ��̂� add ���g��
		ld		[sca_title_scroll_pos], a
		jr		c, sca_title_high_score_mode
		; �{�^���̉����m�F
		call	get_trigger
		jp		nz, sca_return_title_main				; �{�^����������Ă���΃��[�v��E����
		; 1/60[�b]�o�߂���̂�҂�
		ld		hl, sca_title_last_counter
sca_title_left_scroll_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_left_scroll_wait_loop		; �ω����Ă��Ȃ���Αҋ@����
		ld		[sca_title_last_counter], a
		jr		sca_title_left_scroll_loop

		; HIGH SCORE LIST �\�����[�h [10�b�P���ҋ@]
sca_title_high_score_mode:
		call	sca_update_highscore_list
sca_title_high_score_loop:
		; �{�^���̉����m�F
		call	get_trigger
		jp		nz, sca_return_title_main				; �{�^����������Ă���΃��[�v��E����
		; 1/60[�b]�o�߂���̂�҂�
		ld		hl, [sca_title_last_counter]
sca_title_high_score_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_high_score_wait_loop		; �ω����Ă��Ȃ���Αҋ@����
		cp		a, 60
		jr		c, sca_title_high_score_loop
		; �b�J�E���^���C���N�������g����
		ld		a, [sca_title_wait_counter]
		inc		a
		ld		[sca_title_wait_counter], a
		cp		a, 10
		jr		z, sca_title_right_scroll				; 10�b�o�߂����Ȃ�X�N���[�����J�n����
		xor		a, a
		ld		[software_timer], a
		jr		sca_title_high_score_loop

		; �E�ɃX�N���[�����鏈��
sca_title_right_scroll:
		xor		a, a
		ld		[sca_title_wait_counter], a				; 10�b�҂��J�E���^�����Z�b�g
		dec		a
		ld		[sca_title_scroll_pos], a
sca_title_right_scroll_loop:
		; �h�b�g�P�ʉ��X�N���[��
		ld		a, [sca_title_scroll_pos]
		ld		b, a
		and		a, 7
		call	sca_vdp_r18
		; 8�h�b�g�X�N���[���������H
		ld		a, b
		inc		a
		and		a, 7
		call	z, sca_title_scroll_update				; ����3bit �� 7 �̂Ƃ��ɉ�ʑS�̂����������
		; �X�N���[��������
		ld		a, [sca_title_scroll_pos]
		sub		a, 1										; dec a �� C�t���O���ω����Ȃ��̂� sub ���g��
		ld		[sca_title_scroll_pos], a
		jr		c, sca_return_title_main
		; �{�^���̉����m�F
		call	get_trigger
		jr		nz, sca_return_title_main				; �{�^����������Ă���΃��[�v��E����
		; 1/60[�b]�o�߂���̂�҂�
		ld		hl, sca_title_last_counter
sca_title_right_scroll_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_right_scroll_wait_loop		; �ω����Ă��Ȃ���Αҋ@����
		ld		[sca_title_last_counter], a
		jr		sca_title_right_scroll_loop

		; 8�h�b�g�P�ʂ̃X�N���[������
sca_title_scroll_update:
		ld		hl, PATTERN_NAME1
		call	SETWRT
		; hl �� [sca_title_scroll_pos] / 8 + sca_screen_buffer
		ld		a, [sca_title_scroll_pos]
		rrca
		rrca
		rrca
		and		a, 0x1F
		ld		l, a
		ld		h, 0
		ld		de, sca_screen_buffer
		add		hl, de
		ld		c, VDP_VRAM_IO
		ld		de, 32
		ld		a, 24
sca_title_scroll_update_loop:
		ld		b, 32
		otir
		add		hl, de
		dec		a
		jp		nz, sca_title_scroll_update_loop
		ret

		; �^�C�g����ʕ\����߂��ăQ�[���J�n�҂��ɖ߂�
sca_return_title_main:
		xor		a, a
		ld		[sca_title_scroll_pos], a
		call	sca_title_scroll_update
		jp		sca_title_main

sca_enter_music_mode:
		call	sca_music_mode
		pop		hl					; �߂�A�h���X�� 1�̂Ă�
		jp		sca_title

; -----------------------------------------------------------------------------
;	�^�C�g����ʗp���z��ʏ�����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_title_memory:
		; ��������̉��z��ʂ�����������
		ld		hl, sca_screen_buffer
		ld		de, sca_screen_buffer + 1
		ld		bc, 768*2-1
		xor		a, a
		ld		[hl], a
		ldir
		; �^�C�g������ SCA �̕`��
		ld		hl, sca_title_background
		ld		de, sca_screen_buffer + 6 + 64*4
		ld		b, 9		; 9���C��
sca_title_screen_loop1:
		push	bc
		ld		bc, 19
		ldir
		ex		de, hl
		ld		bc, 64-19
		add		hl, bc
		ex		de, hl
		pop		bc
		djnz	sca_title_screen_loop1
		; �^�C�g������ PUSH SPACE BAR �̕`��
		ld		hl, sca_title_push_space_bar
		ld		de, sca_screen_buffer + 9 + 64*16
		ld		bc, 14
		ldir
		; copyright �̕`��
		ld		hl, sca_programmed_by
		ld		de, sca_screen_buffer + 6 + 64*18
		ld		bc, 17
		ldir
		ld		hl, sca_music_composed_by
		ld		de, sca_screen_buffer + 4 + 64*19
		ld		bc, 23
		ldir
		; high score list �̕`��
		ld		hl, sca_high_score_list
		ld		de, sca_screen_buffer + 41 + 64*1
		ld		bc, 15
		ldir
		ld		de, 64*2
		ld		hl, sca_screen_buffer + 41 + 64*3
		ld		[hl], 2	; '1'
		add		hl, de
		ld		[hl], 3	; '2'
		add		hl, de
		ld		[hl], 4	; '3'
		add		hl, de
		ld		[hl], 5	; '4'
		add		hl, de
		ld		[hl], 6	; '5'
		add		hl, de
		ld		[hl], 7	; '6'
		add		hl, de
		ld		[hl], 8	; '7'
		add		hl, de
		ld		[hl], 9	; '8'
		add		hl, de
		ld		[hl], 10	; '9'
		add		hl, de
		ld		[hl], 1	; '0'
		dec		hl
		ld		[hl], 2	; '1'
		; ���O�Ɠ_����`��
		ld		de, sca_screen_buffer + 43 + 64*3
		ld		hl, high_score + 4 + 8*0
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*0
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*5
		ld		hl, high_score + 4 + 8*1
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*1
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*7
		ld		hl, high_score + 4 + 8*2
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*2
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*9
		ld		hl, high_score + 4 + 8*3
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*3
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*11
		ld		hl, high_score + 4 + 8*4
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*4
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*13
		ld		hl, high_score + 4 + 8*5
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*5
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*15
		ld		hl, high_score + 4 + 8*6
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*6
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*17
		ld		hl, high_score + 4 + 8*7
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*7
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*19
		ld		hl, high_score + 4 + 8*8
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*8
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*21
		ld		hl, high_score + 4 + 8*9
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*9
		call	score_memput
		ret

; -----------------------------------------------------------------------------
;	���z��ʂ̃n�C�X�R�A��ʂ�]��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_update_highscore_list:
		; HIGH SCORE LIST �\�����X�V����
		ld		hl, PATTERN_NAME1
		call	SETWRT
		ld		hl, sca_screen_buffer + 32
		ld		c, VDP_VRAM_IO
		ld		de, 32
		ld		a, 24
sca_title_high_score_update_loop:
		ld		b, 32
		otir
		add		hl, de
		dec		a
		jp		nz, sca_title_high_score_update_loop
		ret

; -----------------------------------------------------------------------------
;	�^�C�g����ʕ\��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_title_screen:
		; �p���b�g��^�����ɂ���
		ld		a, 7
		call	fade_palette
		; �^�C�g���p�p���b�g�ݒ�
		xor		a, a
		call	change_palette
		; ���z��ʂ�������
		call	sca_title_memory
		; �X�N���[���ʒu��������
		xor		a, a
		ld		[sca_title_scroll_pos], a
		; ���z��ʂ� VRAM �ɓ]������
		call	sca_title_scroll_update
		ret

; -----------------------------------------------------------------------------
;	�l�[���G���g���[���
;	input:
;		a	...	���܃����N [1�`10]
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
name_entry::
		push	af
		push	af
		; �l�[���G���g���[��BGM�Đ�
		ld		hl, [bgm_nameentry]				; nameentry �� BGM �����t�J�n
		call	bgmdriver_play
		; ���z��ʂ�������
		call	sca_title_memory
		; ���z��ʂ� VRAM �ɓ]������
		call	sca_update_highscore_list
		pop		af
		; �J�[�\���ʒu���v�Z����
		dec		a							; hl = PATTERN_NAME1 + a * 32 * 2 + 32*3+11
		rlca								; a*32*2 �� a*64 �� a �� 6bit���V�t�g
		rlca								; 
		rlca								; 
		rlca								; 
		ld		l, a						; ����ȏ� rlca ����� 8bit ���͂ݏo���̂Ŏc��� add hl,hl �ŁB
		ld		h, 0
		add		hl, hl
		add		hl, hl
		ld		de, PATTERN_NAME1 + 32*3 + 11
		add		hl, de
		ld		[cursor_pos], hl
		; �\�����镶��[c] �� ���ʒu[b] ��������
		xor		a, a
		ld		[sca_title_wait_counter], a
		ld		b, a
		ld		a, [current_score_name + 0]
		ld		c, a
		ld		a, [software_timer]
name_entry_loop:
		ld		[sca_title_last_counter], a
		; �L�[���J�������̂�҂�
		ld		a, [sca_title_wait_counter]
		or		a, a
		jr		nz, name_entry_loop_key_check_skip
		; �L�[���������̂�҂�
		call	get_stick
		ld		[sca_title_wait_counter], a
		cp		a, 7							; ���L�[����
		jp		z, name_entry_move_left
		cp		a, 3							; �E�L�[����
		jp		z, name_entry_move_right
		cp		a, 1							; ��L�[����
		jp		z, name_entry_change_next
		cp		a, 5							; ���L�[����
		jp		z, name_entry_change_prev
		jr		name_entry_loop_key_check_end2
name_entry_loop_key_check_skip:
		call	get_stick
		ld		[sca_title_wait_counter], a
name_entry_loop_key_check_end:
		; ���ʉ�
		ld		hl, [se_name]
		call	bgmdriver_play_sound_effect
name_entry_loop_key_check_end2:
		; �J�[�\����_�ŕ\��
		ld		a, [software_timer]
		and		a, 8
		ld		a, c						; ���t���O�s��
		jr		z, name_entry_cursor_blink
		ld		a, 38						; �J�[�\������
name_entry_cursor_blink:
		ld		hl, [cursor_pos]
		call	WRTVRM
		; �L�[���͂��󂯕t����
		call	get_trigger
		jp		nz, name_entry_move_button
		; VSYNC�҂�
name_entry_vsync_wait:
		ld		a, [sca_title_last_counter]
		ld		l, a
name_entry_vsync_wait_loop:
		ld		a, [software_timer]
		cp		a, l
		jr		z, name_entry_vsync_wait_loop
		jr		name_entry_loop

		; �����L�[�̓���
get_stick:
		push	bc
		xor		a, a
		call	GTSTCK
		push	af
		ld		a, 1
		call	GTSTCK
		pop		bc
		or		a, b
		pop		bc
		ret

		; �{�^���̓���
get_trigger:
		push	bc
		xor		a, a
		call	GTTRIG
		push	af
		ld		a, 1
		call	GTTRIG
		pop		bc
		or		a, b
		pop		bc
		ret

		; ���ֈړ�
name_entry_move_left:
		ld		a, b
		or		a, a
		jp		z, name_entry_loop_key_check_end	; ����ȏ㍶�֍s���Ȃ��ꍇ�͉������Ȃ��Ŗ߂�
		; ���݈ʒu�̕����̕\�����X�V����
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		a, [hl]
		push	hl
		ld		hl, [cursor_pos]
		call	WRTVRM
		pop		hl
		; �V���������𓾂�
		dec		hl
		ld		c, [hl]
		; �J�[�\�������ֈړ�����
		ld		hl, [cursor_pos]
		dec		hl
		ld		[cursor_pos], hl
		dec		b
		jp		name_entry_loop_key_check_end

		; �E�ֈړ�
name_entry_move_right:
		ld		a, b
		cp		a, 3
		jp		z, name_entry_loop_key_check_end	; ����ȏ�E�֍s���Ȃ��ꍇ�͉������Ȃ��Ŗ߂�
		; ���݈ʒu�̕����̕\�����X�V����
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		a, [hl]
		push	hl
		ld		hl, [cursor_pos]
		call	WRTVRM
		pop		hl
		; �V���������𓾂�
		inc		hl
		ld		c, [hl]
		; �J�[�\�������ֈړ�����
		ld		hl, [cursor_pos]
		inc		hl
		ld		[cursor_pos], hl
		inc		b
		jp		name_entry_loop_key_check_end

		; ���{�^��
name_entry_change_prev:
		ld		a, b
		cp		a, 3
		jp		z, name_entry_loop_key_check_end	; �E�[�͕������͏o���Ȃ��̂ŉ������Ȃ��Ŗ߂�
		dec		c
		jp		p, name_entry_change_prev_skip
		ld		c, 37
name_entry_change_prev_skip:
		; ���݈ʒu�̕����̋L���ƕ\�����X�V����
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		[hl], c
		ld		a, c
		ld		hl, [cursor_pos]
		call	WRTVRM
		jp		name_entry_loop_key_check_end

		; ��{�^��
name_entry_change_next:
		ld		a, b
		cp		a, 3
		jp		z, name_entry_loop_key_check_end	; �E�[�͕������͏o���Ȃ��̂ŉ������Ȃ��Ŗ߂�
		inc		c
		ld		a, c
		cp		a, 38
		jp		c, name_entry_change_next_skip
		ld		c, 0
name_entry_change_next_skip:
		; ���݈ʒu�̕����̋L���ƕ\�����X�V����
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		[hl], c
		ld		a, c
		ld		hl, [cursor_pos]
		call	WRTVRM
		jp		name_entry_loop_key_check_end

		; �{�^��
name_entry_move_button:
		ld		a, b
		cp		a, 3
		jp		z, name_enter						; ���O���͊���
		; ���݈ʒu�̕����̕\�����X�V����
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		a, [hl]
		push	hl
		ld		hl, [cursor_pos]
		call	WRTVRM
		pop		hl
		; �V���������𓾂�
		inc		hl
		ld		c, [hl]
		; �J�[�\�������ֈړ�����
		ld		hl, [cursor_pos]
		inc		hl
		ld		[cursor_pos], hl
		inc		b
		; ���ʉ�
		ld		hl, [se_name]
		call	bgmdriver_play_sound_effect
		; �{�^��������܂őҋ@����
name_entry_move_button_wait:
		call	get_trigger
		jr		nz, name_entry_move_button_wait
		jp		name_entry_vsync_wait

name_enter:
		; BGM�t�F�[�h�A�E�g
		ld		a, 1
		call	bgmdriver_fadeout
		; ���ʉ�
		ld		hl, [se_start]
		call	bgmdriver_play_sound_effect
		; �{�^��������܂őҋ@����
		call	get_trigger
		jr		nz, name_enter
		; ���͂������O��]������
		pop		af
		dec		a
		rlca
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, high_score + 4
		add		hl, de
		ex		de, hl
		ld		hl, current_score_name
		ld		bc, 3
		ldir
		jp		sca_title_fade_out

; -----------------------------------------------------------------------------
;	MUSIC MODE���
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_music_mode:
		; ��ʂ��N���A����
		xor		a, a
		ld		hl, PATTERN_NAME1
		ld		bc, 768
		call	FILVRM
		; MUSIC MODE ��`�悷��
		ld		hl, PATTERN_NAME1 + 9 + 4*32
		ld		de, str_music_mode
		call	draw_str
		; SELECT ��`�悷��
		ld		hl, PATTERN_NAME1 + 10 + 8*32
		ld		de, str_select
		call	draw_str
		; PLAYING ��`�悷��
		ld		hl, PATTERN_NAME1 + 10 + 14*32
		ld		de, str_playing
		call	draw_str
		; BGM�ԍ�������
		xor		a, a
		ld		[cursor_pos], a
		ld		[playing_cursor_pos], a
		call	draw_selected_music_name
		; ���C�����[�v
sca_music_mode_loop:
		call	get_stick					; ���E�L�[���͔���
		cp		a, 3
		jp		z, sca_music_next
		cp		a, 7
		jp		z, sca_music_previous
		call	get_trigger					; �{�^�����͔���
		jp		nz, sca_music_play
		jp		sca_music_mode_loop
		; ���t�J�n
sca_music_play:
		call	delete_playing_music_name	; �Đ����̋Ȗ�������
		ld		a, [cursor_pos]				; �I�𒆂̋Ȃ��Đ��Ȃɂ���
		ld		[playing_cursor_pos], a
		cp		a, 14							; ������ EXIT �Ȃ�I������
		jp		z, sca_music_mode_exit
		call	draw_playing_music_name
		call	wait_release_trigger		; �{�^��������܂őҋ@
		jp		sca_music_mode_loop
		; ���̋�
sca_music_next:
		ld		hl, [se_shot]
		call	bgmdriver_play_sound_effect	; ���ʉ��Đ�
		call	delete_selected_music_name	; �I�𒆂̋Ȗ�������
		ld		a, [cursor_pos]				; ���̋Ȃɂ���
		inc		a
		cp		a, 15
		jr		nz, sca_music_next_skip
		xor		a, a							; �z��
sca_music_next_skip:
		ld		[cursor_pos], a
		call	draw_selected_music_name	; �V�����I�𒆂̋Ȗ���\��
		call	wait_release_stick			; �����L�[������܂őҋ@
		jp		sca_music_mode_loop
		; �O�̋�
sca_music_previous:
		ld		hl, [se_shot]
		call	bgmdriver_play_sound_effect	; ���ʉ��Đ�
		call	delete_selected_music_name	; �I�𒆂̋Ȗ�������
		ld		a, [cursor_pos]				; ���̋Ȃɂ���
		dec		a
		jp		p, sca_music_next_skip
		ld		a, 14						; �z��
		jp		sca_music_next_skip
		; �Ăяo�����֖߂�
sca_music_mode_exit:
		call	sca_title_fade_out
		ret
wait_release_stick:
		call	get_stick
		or		a, a
		jr		nz, wait_release_stick
		ret
wait_release_trigger:
		call	get_trigger
		jr		nz, wait_release_trigger
		ret

; -----------------------------------------------------------------------------
;	�I�𒆂̋Ȗ���\������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
draw_selected_music_name:
		; �I�𒆂̔ԍ�����A�Ȗ��̃A�h���X�𓾂�
		ld		a, [cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; �`�悷��
		ld		hl, PATTERN_NAME1 + 12 + 9*32
		jp		draw_str

; -----------------------------------------------------------------------------
;	�I�𒆂̋Ȗ�����������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
delete_selected_music_name:
		; �I�𒆂̔ԍ�����A�Ȗ��̃A�h���X�𓾂�
		ld		a, [cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; �`�悷��
		ld		hl, PATTERN_NAME1 + 12 + 9*32
		jp		delete_str

; -----------------------------------------------------------------------------
;	�Đ����̋Ȗ���\��/�Đ��J�n����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
draw_playing_music_name:
		; �Đ����̔ԍ�����A�Ȗ��̃A�h���X�𓾂�
		ld		a, [playing_cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		push	bc
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; �`�悷��
		ld		hl, PATTERN_NAME1 + 12 + 15*32
		call	draw_str
		; �ȃf�[�^�̃A�h���X�𓾂�
		pop		bc
		ld		hl, SCA_BGM_TABLE_ADR
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		; �Ȃ��Đ�����
		jp		bgmdriver_play

; -----------------------------------------------------------------------------
;	�Đ����̋Ȗ������������t��~����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
delete_playing_music_name:
		; ���t��~
		call	bgmdriver_stop
		; �Đ����̔ԍ�����A�Ȗ��̃A�h���X�𓾂�
		ld		a, [playing_cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; �`�悷��
		ld		hl, PATTERN_NAME1 + 12 + 15*32
		jp		delete_str

; -----------------------------------------------------------------------------
;	�������`�悷��
;	input:
;		hl	...	VRAM�A�h���X
;		de	...	������̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
draw_str:
		call	SETWRT
		; ������̒������擾
		ex		de, hl
		ld		b, [hl]
		inc		hl
		; �`��
		ld		c, VDP_VRAM_IO
		otir
		ret

; -----------------------------------------------------------------------------
;	���������������
;	input:
;		hl	...	VRAM�A�h���X
;		de	...	������̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
delete_str:
		call	SETWRT
		; ������̒������擾
		ex		de, hl
		ld		b, [hl]
		; ����
		ld		c, VDP_VRAM_IO
		xor		a, a
delete_str_loop:
		out		[c], a
		djnz	delete_str_loop
		ret

; -----------------------------------------------------------------------------
;	�p���b�g�t�F�[�h�C��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_title_fade_in:
		ld		b, 8
sca_title_fade_in_loop:
		ld		a, b
		dec		a
		push	bc
		call	fade_palette
		ld		hl, 6
		call	vsync_wait_time
		pop		bc
		djnz	sca_title_fade_in_loop
		ret

; -----------------------------------------------------------------------------
;	�p���b�g�t�F�[�h�A�E�g
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_title_fade_out:
		ld		b, 8
sca_title_fade_out_loop:
		ld		a, 8
		sub		a, b
		push	bc
		call	fade_palette
		ld		hl, 6
		call	vsync_wait_time
		pop		bc
		djnz	sca_title_fade_out_loop
		ret

; -----------------------------------------------------------------------------
;	VDP R18 �ւ̏�������
;	input:
;		a	...	�������ޒl
;	output
;		�Ȃ�
;	break
;		a
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
sca_vdp_r18:
		di								; ���荞�ݏ����̒��� VDP R15 �ɏ������ނ̂ŁA���ւɂ��Ȃ��� NG
		out		[VDP_CMDREG_IO], a
		ld		a, 0x80 + 18
		out		[VDP_CMDREG_IO], a
		ei								; ���ւ͕K�v�ȂƂ��낾���̍ŏ����ɗ}����
		ret

; -----------------------------------------------------------------------------
;	�^�C�g����ʃf�[�^
; -----------------------------------------------------------------------------
sca_title_last_counter:
		db		0

sca_title_wait_counter:
		db		0

sca_title_scroll_pos:
		db		0

cursor_pos:
		dw		0

playing_cursor_pos:
		db		0

sca_title_background:
		db		41, 38, 38, 38, 38, 00, 00, 41, 38, 38, 38, 38, 00, 00, 41, 38, 38, 38, 42	; 19����
		db		38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		43, 38, 38, 38, 42, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		00, 00, 00, 38, 38, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 38, 38, 38
		db		00, 00, 00, 38, 38, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		38, 38, 38, 38, 44, 00, 00, 43, 38, 38, 38, 38, 00, 00, 38, 38, 00, 38, 38
		db		00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
		db		00, 00, 00, 29, 13, 25, 28, 15, 00, 11, 30, 30, 11, 13, 21, 15, 28, 00, 00

sca_title_push_space_bar:
		db		26, 31, 29, 18, 00, 29, 26, 11, 13, 15, 00, 12, 11, 28					; 14����
sca_title_push_space_bar_delete:
		db		00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00					; 14����

sca_programmed_by:
		db		26, 28, 25, 17, 28, 23, 23, 15, 14, 00, 12, 35, 00, 18, 28, 11, 37		; 17����

sca_music_composed_by:
		db		23, 31, 29, 19, 13, 00, 13, 25, 23, 26, 25, 29, 15, 14, 00, 12, 35
		db		00, 45, 46, 47, 48, 49															; 23����

sca_high_score_list:
		db		18, 19, 17, 18, 00, 29, 13, 25, 28, 15, 00, 22, 19, 29, 30				; 15����

sca_bgm_name_table:
		dw		sca_stage1_bgm_name
		dw		sca_stage2_bgm_name
		dw		sca_stage3_bgm_name
		dw		sca_stage4_bgm_name
		dw		sca_stage5_bgm_name
		dw		sca_stage6_bgm_name
		dw		sca_stage7_bgm_name
		dw		sca_stage8_bgm_name
		dw		sca_warning_name
		dw		sca_boss1_bgm_name
		dw		sca_clear_bgm_name
		dw		sca_gameover_bgm_name
		dw		sca_finalboss_bgm_name
		dw		sca_nameentry_bgm_name
		dw		str_exit

sca_stage1_bgm_name:
		; GO AHEAD
		db		8  , 17, 25, 0 , 11, 18, 15, 11, 14
sca_stage2_bgm_name:
		; SNOWMAN
		db		7  , 29, 24, 25, 33, 23, 11, 24
sca_stage3_bgm_name:
		; MIDNIGHT ASSASSIN
		db		17 , 23, 19, 14, 24, 19, 17, 18, 30, 0 , 11, 29, 29, 11, 29, 29, 19, 24
sca_stage4_bgm_name:
		; ESCAPE DANCE
		db		12 , 15, 29, 13, 11, 26, 15, 0 , 14, 11, 24, 13, 15
sca_stage5_bgm_name:
		; GENOSIDE 2XXX
		db		13 , 17, 15, 24, 25, 29, 19, 14, 15, 0 , 3 , 34, 34, 34
sca_stage6_bgm_name:
		; UNDERROAD
		db		9  , 31, 24, 14, 15, 28, 28, 25, 11, 14
sca_stage7_bgm_name:
		; SPOT OF CYCLONE
		db		15 , 29, 26, 25, 30, 0 , 25, 16, 0 , 13, 35, 13, 22, 25, 24, 15
sca_stage8_bgm_name:
		; MILLION SHOWER
		db		14 , 23, 19, 22, 22, 19, 25, 24, 0 , 29, 18, 25, 33, 15, 28
sca_warning_name:
		; WARNING!!
		db		9  , 33, 11, 28, 24, 19, 24, 17, 37, 37
sca_boss1_bgm_name:
		; FEAR..
		db		6  , 16, 15, 11, 28, 40, 40
sca_clear_bgm_name:
		; STAGE CLEAR
		db		11 , 29, 30, 11, 17, 15, 0 , 13, 22, 15, 11, 28
sca_gameover_bgm_name:
		; GAME OVER
		db		9  , 17, 11, 23, 15, 0 , 25, 32, 15, 28
sca_finalboss_bgm_name:
		; DOG SOLDIER
		db		11 , 14, 25, 17, 0 , 29, 25, 22, 14, 19, 15, 28
sca_nameentry_bgm_name:
		; 20MILES 
		db		8  , 3 , 1 , 23, 19, 22, 15, 29, 0 
str_music_mode:
		; MUSIC MODE
		db		10 , 23, 31, 29, 19, 13, 0 , 23, 25, 14, 15
str_select:
		; SELECT
		db		6  , 29, 15, 22, 15, 13, 30
str_playing:
		; PLAYING
		db		7  , 26, 22, 11, 35, 19, 24, 17
str_exit:
		; EXIT
		db		4  , 15, 34, 19, 30

sca_screen_buffer::
		repeat i, 768
			dw	0
		endr
