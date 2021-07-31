; -----------------------------------------------------------------------------
;	�G�̊Ǘ����[�`��
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�G�̏������i�Q�[���J�n���j
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		b,c,d,e,h,l
;	comment
;		�G���́A���L�̍\�����Ƃ�
;			unsigned char	reverse		���E�ʒu���]
;			unsigned char	x			���W
;			unsigned short	y			���8bit�����W, ����8bit�͏�����[�������͏��0]
;			unsigned char	power		�c��ϋv��
;			unsigned short	state		���
; -----------------------------------------------------------------------------
enemy_init::
		; �X�e�[�W����������
		ld		a, SCA_START_STAGE
		ld		[stage_number], a
		ld		a, 2
		ld		[enemy_shield_base], a
		ld		a, 120						; 4�̔{��
		ld		[enemy_shot_speed], a
		ret

; -----------------------------------------------------------------------------
;	�G�̏������i�X�e�[�W�̊J�n���j
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
;	comment
;		STAGE1 �̂Ƃ��́Aenemy_init �̌�ɌĂ΂��
; -----------------------------------------------------------------------------
enemy_init_stage::
		; �G�o���^�C�~���O�J�E���^���N���A
		ld		a, 1
		ld		[enemy_update_time], a
		; Y ���W��S�� 212 �ɃN���A
		ld		de, enemy_init_ret
		xor		a, a
		ld		b, 6 * 2 + SCA_SHOT_COUNT
		ld		c, 212
		ld		hl, enemy_info0
enemy_init_loop:
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], c					; SCA_INFO_YH �� 212
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], e					; SCA_INFO_ENEMY_MOVE_L �� �_�~�[
		inc		hl
		ld		[hl], d					; SCA_INFO_ENEMY_MOVE_H �� �_�~�[
		inc		hl
		djnz	enemy_init_loop
		; �G�X�v���C�g�̃X�v���C�g�ԍ�����������
		ld		b, 6
		ld		a, 2
		ld		de, SCA_INFO_SIZE * 2
		ld		hl, enemy_info0 + SCA_INFO_ENEMY_SPRITE_NUM
enemy_init_loop2:
		ld		[hl], a
		add		a, 2
		add		hl, de
		djnz	enemy_init_loop2
		; �G�o������V�����e�[�u���ɕύX
		ld		a, [stage_number]
		and		a, 7
		rlca
		ld		h, 0
		ld		l, a
		ld		de, enemy_map_table
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ld		[enemy_map_index], de
		; �G�̏o����Ԃ�������
		xor		a, a
		ld		[enemy_map_state], a
		ld		[enemy_map_enemy_count], a
		ld		[enemy_map_wait_count], a
		ld		[enemy_map_enemy_start_entry], a
		ld		[enemy_map_enemy_start_entry+1], a
		ld		[enemy_boss_state], a
		inc		a
		ld		[enemy_update_time], a
		ld		hl, SCA_BOSS_TIME
		ld		[enemy_boss_count], hl
		; �G�̓����蔻������Z�b�g
		xor		a, a
		call	change_crash_check_routine
enemy_init_ret:
		ret

; -----------------------------------------------------------------------------
;	�G�̓o�ꏈ��
;	input:
;		ix	... ���@���̃A�h���X
;		iy	... �G���̃A�h���X[�擪, 6�������Ă���K�v������]
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy_start::
		; �G�o���^�C�~���O���ǂ������f����
		ld		a, [enemy_update_time]
		dec		a
		jr		z, enemy_start_skip1
		; �o���^�C�~���O�ł͂Ȃ��̂ŁA�J�E���g�����i�߂Ĕ�����
		ld		[enemy_update_time], a
		ret
enemy_start_skip1:
		; �o���^�C�~���O�J�E���^�����Z�b�g����
		ld		a, 10
		ld		[enemy_update_time], a
		; �{�X�o��/�o�������H
		ld		hl, [enemy_boss_count]
		ld		a, l
		or		a, h
		jp		z, enemy_boss
		; �{�X�o��܂ł̃J�E���g�_�E��
		dec		hl
		ld		[enemy_boss_count], hl
		; �ҋ@���Ԃ��ݒ肳��Ă���Ή������Ȃ��Ŕ�����
		ld		a, [enemy_map_wait_count]
		or		a, a
		jr		z, enemy_start_check_map
		dec		a
		ld		[enemy_map_wait_count], a
		ret
enemy_start_check_map:
		; �G�o����Ԃ��m�F����
		ld		a, [enemy_map_state]
		cp		a, 1
		jr		c, enemy_start_read_map				; �V�����R�}���h��t���Ȃ� enemy_start_read_map ��
		jr		z, enemy_start_one_enemy			; �G�o�����Ȃ� enemy_start_one_enemy ��

enemy_start_wait_all_destroy:
		; �G�S�őҋ@��
		ld		b, 6		; �S6�@����T��
		ld		de, SCA_INFO_SIZE + SCA_INFO_SIZE
enmemy_start_destroy_check_loop:
		ld		a, [iy + SCA_INFO_YH]
		cp		a, 212
		ret		nz									; �������̓G������̂ŉ��������ɒE����
		add		iy, de
		djnz	enmemy_start_destroy_check_loop
		xor		a, a
		ld		[enemy_map_state], a				; �V�����R�}���h��t�� �̏�Ԃ֑J��
		ret

enemy_start_one_enemy:
		; �o�����ׂ��G�̐����J�E���g
		ld		a, [enemy_map_enemy_count]
		dec		a
		ld		[enemy_map_enemy_count], a
		jr		nz, enemy_start_one_enemy_skip1
		ld		[enemy_map_state], a				; �V�����R�}���h��t�� �̏�Ԃ֑J�� [�����͕K�� a = 0]
enemy_start_one_enemy_skip1:
		; �o���ł���G�����邩�T������
		ld		b, 6		; �S6�@����T��
		ld		de, SCA_INFO_SIZE + SCA_INFO_SIZE
enmemy_start_loop1:
		ld		a, [iy + SCA_INFO_YH]
		cp		a, 212
		jr		z, enemy_start_found_enemy
		add		iy, de
		djnz	enmemy_start_loop1
		ret
enemy_start_found_enemy:
		ld		a, 3
		ld		[enemy_map_wait_count], a			; �A�����ďo�����Ȃ��悤�ɏ����҂���}��
		ld		hl, [enemy_map_enemy_start_entry]
		jp		hl

enemy_start_read_map:
		; �G�o���f�[�^��ǂݎ��
		ld		hl, [enemy_map_index]
		ld		a, [hl]
		inc		hl
		; �G�o���R�}���h���H
		cp		a, 0x40
		jr		c, enemy_start_ok					; 0x3F�ȉ� �G�o��
		jr		z, enemy_start_enter_wait_destroy	; 0x40     �G�S�őҋ@
		cp		a, 0x42
		jr		c, enemy_start_entrt_wait_time		; 0x41     �P���ҋ@
		jr		z, enemy_start_jump					; 0x42     �W�����v

enemt_start_delete_stagex:
		; �w�i STAGE* �\���̏���					  0x43
		ld		[enemy_map_index], hl
		jp		background_delete_stage_message

enemy_start_jump:
		; �f�[�^�W�����v�R�}���h
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		ld		[enemy_map_index], hl
		ret

enemy_start_ok:
		; �G�o�������[�h�֑J��
		ld		e, a
		ld		a, 1
		ld		[enemy_map_state], a
		ld		a, [hl]								; �o����
		ld		[enemy_map_enemy_count], a
		inc		hl
		ld		[enemy_map_index], hl
		ld		a, e
		rlca
		ld		l, a
		ld		h, 0
		ld		de, enemy_start_table
		add		hl, de
		ld		a, [hl]
		ld		[enemy_map_enemy_start_entry+0], a
		inc		hl
		ld		a, [hl]
		ld		[enemy_map_enemy_start_entry+1], a
		ret

enemy_start_enter_wait_destroy:
		; �G�S�őҋ@�����[�h�ɑJ��
		ld		a, 2
		ld		[enemy_map_state], a
		ld		[enemy_map_index], hl
		ret

enemy_start_entrt_wait_time:
		; �P���ҋ@
		ld		a, [hl]
		ld		[enemy_map_wait_count], a
		inc		hl
		ld		[enemy_map_index], hl
		ret

enemy_start_table:
		dw		enemy1_start
		dw		enemy2_start
		dw		enemy3_start
		dw		enemy4_start
		dw		enemy5_start

; -----------------------------------------------------------------------------
;	�{�X�̏���
;	input:
;		iy	... �G���̃A�h���X[�擪, 6�������Ă���K�v������]
;	output
;		�Ȃ�
;	break
;		�S��
; -----------------------------------------------------------------------------
enemy_boss:
		ld		a, [enemy_boss_state]
		cp		a, 1
		jr		c, enemy_boss_bgm_fadeout		; 0 �Ȃ� BGM ���t�F�[�h�A�E�g�J�n
		jr		z, enemy_boss_bgm_stop_wait1	; 1 �Ȃ� BGM ��~�҂�
		cp		a, 3
		jr		c, enemy_boss_bgm_stop_wait2	; 2 �Ȃ� BGM ��~�҂�
		jr		z, enemy_boss_start				; 3 �Ȃ� �{�X�o��
		cp		a, 5
		jr		c, enemy_boss_dummy				; 4 �Ȃ� �������Ȃ�
		jr		enemy_boss_destroy				; 5 �Ȃ� �X�e�[�W�N���A����

		; state 0: BGM�t�F�[�h�A�E�g
enemy_boss_bgm_fadeout:
		inc		a
		ld		[enemy_boss_state], a
		ld		a, 30							; 10 * 16 * 1/60�b
		jp	bgmdriver_fadeout

		; state 1: BGM��~�҂�
enemy_boss_bgm_stop_wait1:
		call	bgmdriver_check_playing
		ret		nz
		ld		a, 2
		ld		[enemy_boss_state], a
		ld		hl, [bgm_boss_buz]				; boss �� �x���� �����t�J�n
		call	bgmdriver_play
		call	background_show_warning			; WARNING!! ��\��
		ret

		; state 2: �x������~�҂�
enemy_boss_bgm_stop_wait2:
		call	bgmdriver_check_playing
		ret		nz
		ld		a, 3
		ld		[enemy_boss_state], a
		call	background_delete_stage_message	; WARNING!! ������
		ret

		; state 3: �{�X�o��
enemy_boss_start::
		ld		a, 4
		ld		[enemy_boss_state], a
		ld		a, [stage_number]
		and		a, 7
		ld		hl, [bgm_boss1]					; boss1 �� BGM �����t�J�n
		cp		a, 7
		jp		nz, enemy_boss_start_skip1
		ld		hl, [bgm_finalboss]				; finalboss �� BGM �����t�J�n
enemy_boss_start_skip1:
		push	ix
		call	bgmdriver_play
		pop		ix
		ld		a, 6 * 5						; �{�X��|������̑ҋ@���Ԃ�������[5�b]
		ld		[enemy_boss_destroy_wait], a

		ld		a, [stage_number]
		and		a, 7
		rlca
		ld		l, a
		ld		h, 0
		ld		de, enemy_boss_start_table
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		jp		hl								; �{�X�J�n���[�`���փW�����v

		; state 4: �Ȃɂ����Ȃ�
enemy_boss_dummy:
		ret

		; state 5: �{�X�����ꂽ��ɃX�e�[�W�N���A��ʂ܂őҋ@
enemy_boss_destroy:
		ld		a, [enemy_boss_destroy_wait]
		dec		a
		ld		[enemy_boss_destroy_wait], a
		ret		nz
		call	goto_next_stage
		ret

; -----------------------------------------------------------------------------
;	�{�X�̔j�󏈗�
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;
; -----------------------------------------------------------------------------
enemy_boss_destroy_request::
		ld		a, 5
		ld		[enemy_boss_state], a
		ret

; -----------------------------------------------------------------------------
;	�G�̈ړ�����
;	input:
;		ix	...	�G1���̃A�h���X
;	output
;		�Ȃ�
;	break
;		�S��
; -----------------------------------------------------------------------------
enemy_move::
		ld		ix, enemy_info0
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info1
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info2
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info3
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info4
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info5
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl
		ret
enemy_move_call_hl:
		jp		hl

; -----------------------------------------------------------------------------
;	cos��
;	input:
;		hl	... �� [0 = 0[rad], 512 = 2��[rad]]
;	output
;		c	... cos��
;		b	... sin��
;	break
;		a,b,c,d,e,f,h,l
; -----------------------------------------------------------------------------
enemy_get_cos::
		push	hl
		xor		a, a
		bit		7, l
		jr		z, enemy_get_cos_skip1
		dec		a						; ��2�ی� or ��4�ی� �Ȃ�Ab = 255, ����ȊO�� b = 0
enemy_get_cos_skip1:
		ld		b, a
		ld		a, l
		xor		a, b
		and		a, 127					; 0�`��/2[rad] �ɕϊ����ꂽ cos�p�x
		ld		de, enemy_cos_table
		ld		l, a					; �Ҕ�
		add		a, e
		ld		e, a
		ld		a, 0					; �t���O��ς������Ȃ��̂� xor a �͎g���Ȃ�
		adc		a, d
		ld		d, a
		ex		de, hl
		ld		c, [hl]					; cos��
		ex		de, hl
		ld		de, enemy_cos_table
		ld		a, l
		xor		a, 127					; sin �𓾂邽�߂� cos�p�x �� a �Ɋi�[
		ld		l, a
		ld		h, 0
		add		hl, de
		ld		b, [hl]					; sin��
		pop		hl
		; ����
		bit		7, l					; ��2�ی� or ��4�ی� �Ȃ� cos�������]
		jr		z, enemy_get_cos_skip2
		ld		a, c
		neg
		ld		c, a
enemy_get_cos_skip2:
		bit		0, h					; ��3�ی� or ��4�ی� �Ȃ� cos, sin�������]
		jr		z, enemy_get_cos_skip3
		ld		a, b
		neg
		ld		b, a
		ld		a, c
		neg
		ld		c, a
enemy_get_cos_skip3:
		ret

; -----------------------------------------------------------------------------
;	�G�e���ˏ���[�P��]
;	input:
;		ix	... �e�̔��˓_
;		iy	... �e�̓��B�_
;		hl	... �e�̏��
;	output
;		�Ȃ�
;	break
;		a,b,c,h,l
; -----------------------------------------------------------------------------
enemy_shot_start_one::
		; DX �����߂�
		ld		a, [iy + SCA_INFO_XH]		; ���B�_X: �l��� 0�`175
		ld		b, [ix + SCA_INFO_XH]		; ���˓_X: �l��� 0�`175
		ld		[hl], 1						; �b��I�� ���B�_X - ���˓_X �́A���ł��邱�Ƃ������}�[�N ��t����
		sub		a, b
		jr		nc, enemy_shot_skip1
		ld		[hl], -1					; ���B�_X - ���˓_X �́A���ł��邱�Ƃ������}�[�N�ōX�V
		neg									; �������]
enemy_shot_skip1:
		inc		hl
		ld		[hl], b						; ���˓_X
		inc		hl
		ld		c, a						; c = DX
		; DY �����߂�
		ld		a, [iy + SCA_INFO_YH]		; ���B�_Y: �l��� 0�`175
		ld		b, [ix + SCA_INFO_YH]		; ���˓_Y: �l��� 0�`175
		ld		[hl], 1						; �b��I�� ���B�_Y - ���˓_Y �́A���ł��邱�Ƃ������}�[�N ��t����
		sub		a, b
		jr		nc, enemy_shot_skip2
		ld		[hl], -1					; ���B�_Y - ���˓_Y �́A���ł��邱�Ƃ������}�[�N�ōX�V
		neg									; �������]
enemy_shot_skip2:
		inc		hl
		ld		[hl], b					; ���˓_Y
		inc		hl
		; DX �� DY �̑傫�����r
		cp		a, c						; DX �̕����傫����΃L�����[�t���O������
		jr		c, enemy_shot_dx_den
enemy_shot_dy_den:						; ���ꂪ DY �̏ꍇ
		ld		[hl], 0				; ���ꂪ DY �ł��邱�Ƃ������}�[�N
		inc		hl
		ld		[hl], a					; ����� DY ����
		inc		hl
		ld		[hl], c					; ���q�� DX ����
		inc		hl
		ld		[hl], 0				; �J�E���^���N���A
		ret
enemy_shot_dx_den:						; ���ꂪ DX �̏ꍇ
		ld		[hl], 1				; ���ꂪ DX �ł��邱�Ƃ������}�[�N
		inc		hl
		ld		[hl], c					; ����� DX ����
		inc		hl
		ld		[hl], a					; ���q�� DY ����
		inc		hl
		ld		[hl], 0				; �J�E���^���N���A
		ret

; -----------------------------------------------------------------------------
;	�G�e���ˏ���[�P��]
;	input:
;		c	... �e�̔��˓_X
;		b	... �e�̔��˓_Y
;		e	... �e�̕���X
;		d	...	�e�̕���Y
;		hl	... �e�̏��
;	output
;		�Ȃ�
;	break
;		a,b,c,h,l
; -----------------------------------------------------------------------------
enemy_shot_start_one2::
		; DX �����߂�
		ld		[hl], 1					; �b��I�� ���B�_X - ���˓_X �́A���ł��邱�Ƃ������}�[�N ��t����
		ld		a, e
		or		a, a
		jp		p, enemy_shot2_skip1
		ld		[hl], -1				; ���B�_X - ���˓_X �́A���ł��邱�Ƃ������}�[�N�ōX�V
		neg								; �������]
enemy_shot2_skip1:
		inc		hl
		ld		[hl], c					; ���˓_X
		inc		hl
		ld		c, a					; c = DX
		; DY �����߂�
		ld		[hl], 1					; �b��I�� ���B�_Y - ���˓_Y �́A���ł��邱�Ƃ������}�[�N ��t����
		ld		a, d
		or		a, a
		jp		p, enemy_shot_skip2
		ld		[hl], -1				; ���B�_Y - ���˓_Y �́A���ł��邱�Ƃ������}�[�N�ōX�V
		neg								; �������]
		jp		enemy_shot_skip2

; -----------------------------------------------------------------------------
;	�G�e���ˏ���
;	input:
;		ix	... �e�̔��˓_
;		iy	... �e�̓��B�_
;	output
;		�Ȃ�
;	break
;		a,b,c,d,e,h,l,f
; -----------------------------------------------------------------------------
enemy_shot_start::
		call	enemy_shot_search
		jp		nz, enemy_shot_start_one
		ret

; -----------------------------------------------------------------------------
;	���ˉ\�ȓG�e����������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a,b,c,d,e,h,l,f
; -----------------------------------------------------------------------------
enemy_shot_search::
		ld		hl, eshot_info + SCA_INFO_YH
		ld		de, SCA_INFO_SIZE
		; �󂢂Ă�e����T�����郋�[�v
		ld		b, SCA_SHOT_COUNT		; �e���� SCA_SHOT_COUNT�Z�b�g����
enemy_shot_search_loop:
		ld		a, [hl]					; a = YH
		cp		a, 212
		jr		z, enemy_shot_found
		add		hl, de
		djnz	enemy_shot_search_loop
		xor		a, a
		ret								; �󂫂��Ȃ��̂Œ��߂�, xor a �̌�Ȃ̂ŕK�� z �ɂȂ�
enemy_shot_found:
		dec		hl
		dec		hl
		dec		hl
		or		a, a						; a �� 212 �Ȃ̂ŁA�K�� nz �ɂȂ�
		ret

; -----------------------------------------------------------------------------
;	�G�e���쏈��[1��]
;	input:
;		ix	... �e�̏��
;	output
;		�Ȃ�
;	break
;		���ׂ�
; -----------------------------------------------------------------------------
enemy_shot_move_one::
		; ���˒����H
		ld		a, [ix + SCA_INFO_YH]
		cp		a, 212
		ret		z							; ���˒��łȂ���Ή������Ȃ��Ŕ�����
		; �X���̕��ꂪ DX �� DY ���ɂ���ď�����ς���
		ld		a, [ix + SCA_INFO_ESHOT_DEN_IS_DX]
		or		a, a							; ����� DX ���H
		jr		z, enemy_shot_den_is_dy

		; ���ꂪ DX �̏ꍇ
enemy_shot_den_is_dx:
		; X�����Ɉړ�
		ld		a, [ix + SCA_INFO_XH]
		ld		b, [ix + SCA_INFO_ESHOT_X_SIG]
		add		a, b
		ld		[ix + SCA_INFO_XH], a
		; ��ʊO����
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192-8
		jr		z, enemy_shot_end
		; Y�����Ɉړ�����^�C�~���O�����f
		ld		a, [ix + SCA_INFO_ESHOT_CNT]
		add		a, [ix + SCA_INFO_ESHOT_NUM]
		jr		c, enemy_shot_dx_cnt_end	; 8bit ���I�[�o�[�t���[�����ꍇ�͈ړ��m��
		cp		a, [ix + SCA_INFO_ESHOT_DEN]
		jr		nc, enemy_shot_dx_cnt_end	; 8bit �ɂ����܂��Ă邯�ǂ�����𒴂����ꍇ
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; ����̃^�C�~���O�� Y�����Ɉړ����Ȃ�
		ret
enemy_shot_dx_cnt_end:
		; �J�E���^���X�V
		sub		a, [ix + SCA_INFO_ESHOT_DEN]		; ���������
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; ����̃^�C�~���O�� Y�����Ɉړ����Ȃ�
		; Y�����Ɉړ�
		ld		a, [ix + SCA_INFO_YH]
		ld		b, [ix + SCA_INFO_ESHOT_Y_SIG]
		add		a, b
		ld		[ix + SCA_INFO_YH], a
		; ��ʊO����
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192
		jr		z, enemy_shot_end
		ret

		; ���ꂪ DY �̏ꍇ
enemy_shot_den_is_dy:
		; Y�����Ɉړ�
		ld		a, [ix + SCA_INFO_YH]
		ld		b, [ix + SCA_INFO_ESHOT_Y_SIG]
		add		a, b
		ld		[ix + SCA_INFO_YH], a
		; ��ʊO����
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192
		jr		z, enemy_shot_end
		; X�����Ɉړ�����^�C�~���O�����f
		ld		a, [ix + SCA_INFO_ESHOT_CNT]
		add		a, [ix + SCA_INFO_ESHOT_NUM]
		jr		c, enemy_shot_dy_cnt_end	; 8bit ���I�[�o�[�t���[�����ꍇ�͈ړ��m��
		cp		a, [ix + SCA_INFO_ESHOT_DEN]
		jr		nc, enemy_shot_dy_cnt_end	; 8bit �ɂ����܂��Ă邯�ǂ�����𒴂����ꍇ
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; ����̃^�C�~���O�� Y�����Ɉړ����Ȃ�
		ret
enemy_shot_dy_cnt_end:
		; �J�E���^���X�V
		sub		a, [ix + SCA_INFO_ESHOT_DEN]		; ���������
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; ����̃^�C�~���O�� Y�����Ɉړ����Ȃ�
		; X�����Ɉړ�
		ld		a, [ix + SCA_INFO_XH]
		ld		b, [ix + SCA_INFO_ESHOT_X_SIG]
		add		a, b
		ld		[ix + SCA_INFO_XH], a
		; ��ʊO����
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192-8
		jr		z, enemy_shot_end
		ret
		; ��ʊO�ɂł��ꍇ
enemy_shot_end:
		ld		[ix + SCA_INFO_YH], 212
		ret

; -----------------------------------------------------------------------------
;	�G�e���쏈��
;	input:
;		ix	... �e�̏��
;	output
;		�Ȃ�
;	break
;		���ׂ�
; -----------------------------------------------------------------------------
enemy_shot_move::
		ld		b, SCA_SHOT_COUNT			; �G�e���� SCA_SHOT_COUNT�Z�b�g����
enemy_shot_move_loop:
		push	bc
		call	enemy_shot_move_one
		pop		bc
		ld		de, SCA_INFO_SIZE
		add		ix, de
		djnz	enemy_shot_move_loop
		ret

; -----------------------------------------------------------------------------
;	���̃X�e�[�W�ֈڂ邽�߂̏���
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		���ׂ�
; -----------------------------------------------------------------------------
enemy_next_stage::
		; �X�e�[�W�ԍ����C���N�������g
		ld		a, [stage_number]
		inc		a
		ld		[stage_number], a
		; �U�R�G�̍d�����C���N�������g
		ld		a, [enemy_shield_base]
		cp		a, SCA_MAX_ENEMY_POWER
		jr		z, enemy_next_stage_skip1
		inc		a
		ld		[enemy_shield_base], a
enemy_next_stage_skip1:
		; �U�R�G���e�������Ă���������f�N�������g
		ld		a, [enemy_shot_speed]
		cp		a, SCA_MIN_ENEMY_SHOT_INTERVAL
		jr		z, enemy_next_stage_skip2
		dec		a
		dec		a
		dec		a
		dec		a
		ld		[enemy_shot_speed], a
enemy_next_stage_skip2:
		ret

; -----------------------------------------------------------------------------
;	�{�X�J�n�e�[�u��
; -----------------------------------------------------------------------------
enemy_boss_start_table:
		dw		enemy_boss1_start
		dw		enemy_boss2_start
		dw		enemy_boss3_start
		dw		enemy_boss4_start
		dw		enemy_boss5_start
		dw		enemy_boss6_start
		dw		enemy_boss7_start
		dw		enemy_boss8_start

; -----------------------------------------------------------------------------
;	cos�ƃe�[�u��
; -----------------------------------------------------------------------------
enemy_cos_table:
		db		72, 72, 72, 72, 72, 72, 72, 72
		db		72, 72, 72, 72, 72, 72, 71, 71
		db		71, 71, 71, 71, 70, 70, 70, 70
		db		69, 69, 69, 69, 68, 68, 68, 67
		db		67, 67, 66, 66, 66, 65, 65, 64
		db		64, 64, 63, 63, 62, 62, 61, 61
		db		60, 60, 59, 59, 58, 58, 57, 57
		db		56, 56, 55, 54, 54, 53, 53, 52
		db		51, 51, 50, 50, 49, 48, 48, 47
		db		46, 45, 45, 44, 43, 43, 42, 41
		db		41, 40, 39, 38, 38, 37, 36, 35
		db		34, 34, 33, 32, 31, 30, 30, 29
		db		28, 27, 26, 26, 25, 24, 23, 22
		db		21, 21, 20, 19, 18, 17, 16, 15
		db		15, 14, 13, 12, 11, 10, 9 , 8 
		db		8 , 7 , 6 , 5 , 4 , 3 , 2 , 1 

; -----------------------------------------------------------------------------
;	�X�e�[�W���
stage_number::
		db		0					; �ʎZ�X�e�[�W�ԍ�[0 �� STAGE1]
enemy_shield_base::
		db		0					; �U�R�G�̍d��
enemy_shot_speed::
		db		0					; �U�R�G���e�������Ă������

; -----------------------------------------------------------------------------
;	�G�o�������̏��
;		0	...	�V�����R�}���h��t��
;		1	...	�G�o����
;		2	...	�G�S�őҋ@��
enemy_map_state:
		db		0

enemy_map_enemy_count:
		db		0

enemy_map_wait_count:
		db		0

enemy_map_enemy_start_entry:
		dw		0

enemy_map_index::
		dw		0

enemy_update_time:
		db		0

enemy_boss_count:
		dw		0					; �{�X�o��܂ł̃_�E���J�E���^

enemy_boss_state:
		db		0					; �{�X�̏��

enemy_boss_destroy_wait:
		db		0

; -----------------------------------------------------------------------------
;	�G�o���p�^�[���f�[�^
;		0x00�`0x03	...	�o���G�ԍ��A�����ďo����[1�`6]
;		0x04�`0x3F	... �\��[����`]
;		0x40		...	�G�S�őҋ@
;		0x41		...	�P���ҋ@�A�����đҋ@����[1/6sec]
;		0x42		...	�f�[�^�W�����v�A�����ĐV�����A�h���X[2byte]
;		0x43		...	�w�i�� STAGE* �̕\������������
;		0x44�`0xFF	...	�\��[����`]
; -----------------------------------------------------------------------------
enemy_map_table::
		dw		enemy_map_stage1
		dw		enemy_map_stage2
		dw		enemy_map_stage3
		dw		enemy_map_stage4
		dw		enemy_map_stage5
		dw		enemy_map_stage6
		dw		enemy_map_stage7
		dw		enemy_map_stage8

enemy_map_stage1::
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; STAGE1 ������
enemy_map_stage1_loop:
		db		0x01, 6			; �G2��6�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x40				; �G�S�ő҂�
		db		0x00, 4			; �G1��4�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x40				; �G�S�ő҂�
		db		0x01, 6			; �G2��6�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x40				; �G�S�ő҂�
		db		0x00, 4			; �G1��4�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x40				; �G�S�ő҂�
		db		0x03, 6			; �G4��6�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x40				; �G�S�ő҂�
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 12			; �P���ҋ@ 2�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage1_loop

enemy_map_stage2:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage2 ������
enemy_map_stage2_loop:
		db		0x03, 6			; �G4��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x00, 6			; �G1��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x01, 6			; �G2��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x00, 6			; �G1��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x03, 6			; �G4��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage2_loop

enemy_map_stage3:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage3 ������
enemy_map_stage3_loop:
		db		0x03, 12			; �G4��12�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x00, 12			; �G1��12�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x01, 12			; �G2��12�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x00, 12			; �G1��12�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x03, 12			; �G4��12�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x02, 6			; �G3��6�@�o��
		db		0x41, 6			; �P���ҋ@ 1�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage3_loop

enemy_map_stage4:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage4 ������
enemy_map_stage4_loop:
		db		0x04, 12			; �G5��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x00, 12			; �G1��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x01, 12			; �G2��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x00, 12			; �G1��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x03, 12			; �G4��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x02, 12			; �G3��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x02, 12			; �G3��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x02, 12			; �G3��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage4_loop

enemy_map_stage5:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage5 ������
enemy_map_stage5_loop:
		db		0x01, 12			; �G2��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x00, 12			; �G1��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x01, 12			; �G2��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x00, 12			; �G1��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x03, 12			; �G4��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x02, 12			; �G3��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x02, 12			; �G3��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x02, 12			; �G3��12�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage5_loop

enemy_map_stage6:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage6 ������
enemy_map_stage6_loop:
		db		0x01, 18			; �G2��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x00, 18			; �G1��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x01, 18			; �G2��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x00, 18			; �G1��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x03, 18			; �G4��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x02, 18			; �G3��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x02, 18			; �G3��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x02, 18			; �G3��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage6_loop

enemy_map_stage7:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage7 ������
enemy_map_stage7_loop:
		db		0x01, 18			; �G2��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x00, 18			; �G1��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x01, 18			; �G2��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x00, 18			; �G1��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x03, 18			; �G4��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x02, 18			; �G3��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x02, 18			; �G3��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x02, 18			; �G3��18�@�o��
		db		0x41, 1			; �P���ҋ@ 0.16�b
		db		0x40				; �G�S�ő҂�
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x04, 1			; �G5��1�@�o��
		db		0x41, 3			; �P���ҋ@ 0.5�b
		db		0x42				; �W�����v
		dw		enemy_map_stage7_loop

enemy_map_stage8:
		db		0x41, 18			; �P���ҋ@ 3�b
		db		0x43				; stage8 ������
enemy_map_stage8_loop:
		db		0x01, 18			; �G2��18�@�o��
		db		0x00, 18			; �G1��18�@�o��
		db		0x01, 18			; �G2��18�@�o��
		db		0x00, 18			; �G1��18�@�o��
		db		0x03, 18			; �G4��18�@�o��
		db		0x02, 18			; �G3��18�@�o��
		db		0x02, 18			; �G3��18�@�o��
		db		0x02, 18			; �G3��18�@�o��
		db		0x04, 18			; �G5��1�@�o��
		db		0x02, 18			; �G3��1�@�o��
		db		0x01, 18			; �G2��1�@�o��
		db		0x00, 18			; �G1��1�@�o��
		db		0x03, 18			; �G4��1�@�o��
		db		0x02, 18			; �G3��1�@�o��
		db		0x42				; �W�����v
		dw		enemy_map_stage8_loop
