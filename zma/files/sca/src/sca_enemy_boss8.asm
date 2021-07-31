; -----------------------------------------------------------------------------
;	�{�X�G8�̏���
; -----------------------------------------------------------------------------

LEFT_PART_1ST_DOWN_TIME		= 5					; ���p�[�c���ŏ��ɉ��ֈړ�����܂ł̎��� [�b]
RIGHT_PART_1ST_DOWN_TIME	= 7					; �E�p�[�c���ŏ��ɉ��ֈړ�����܂ł̎��� [�b]
LEFT_PART_DOWN_CYCLE		= 6					; ���ֈړ����鎞�ԊԊu
RIGHT_PART_DOWN_CYCLE		= 8					; ���ֈړ����鎞�ԊԊu
LEFT_PART_DOWN_SPEED		= 6					; ���ֈړ����鑬�x
RIGHT_PART_DOWN_SPEED		= 6					; ���ֈړ����鑬�x
CENTER_MOVE_SPEED			= 5					; �����p�[�c�P�Ǝ��̈ړ����x
CENTER_BEFORE_LASER_WAIT	= 50				; ���[�U�[���ˑO�̍d������
CENTER_AFTER_LASER_WAIT		= 180				; ���[�U�[���˒��̍d������
CENTER_LASER_CYCLE			= 60				; ���[�U�[���ˊԊu
SHOT_CYCLE					= 5					; �e�𔭎˂���Ԋu
SHOT_TYPE_CHANGE			= 15				; SHOT_TYPE_CHANGE���ɂP�񎩋@�Ə��Ŕ���

; -----------------------------------------------------------------------------
;	�{�X8�̈ړ�����
;	input:
;		ix	...	�G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy_boss8_move::
		call	enemy_boss8_move_left			; ���p�[�c
		call	enemy_boss8_move_right			; �E�p�[�c
		call	enemy_boss8_move_center			; �����p�[�c
enemy_boss8_move_dummy:
		ret

enemy_boss8_move_left:
		; ���p�[�c�����łɔj��ς݂Ȃ牽�����Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		ret		z
		; �e���ˏ���
		ld		a, [ix + SCA_INFO_XL]
		add		a, 7
		rlca
		rlca
		rlca
		ld		c, a
		ld		a, [ix + SCA_INFO_YL]
		add		a, 3
		rlca
		rlca
		rlca
		ld		b, a
		call	enemy_boss8_shot
		; ��Ԕ���
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L]
		cp		a, 1
		jp		c, enemy_boss8_left_s0
		jp		z, enemy_boss8_left_s1
		jp		enemy_boss8_left_s2

enemy_boss8_left_s0:
		; �b�J�E���g�^�C�}�[
		ld		a, [wait_timer_left]
		dec		a
		ld		[wait_timer_left], a
		ret		nz
		ld		a, 60
		ld		[wait_timer_left], a
		; ���p�[�c���ҋ@���Ȃ牽�����Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret		nz
		; ���ֈړ�����^�C�~���O�ɂȂ����̂� S1 �֑J��
		ld		a, 1
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
		ld		a, LEFT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret

enemy_boss8_left_s1:
		; �X�s�[�h�J�E���^
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret		nz
		ld		a, LEFT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		; ���ֈړ�������
		ld		a, [ix + SCA_INFO_YL]
		inc		a
		ld		[ix + SCA_INFO_YL], a
		cp		a, 13
		jp		nz, enemy_boss8_left_s1_skip1
		; 13�ɓ��B�����ꍇ�͎��̏�Ԃ֑J��
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
enemy_boss8_left_s1_skip1:
		; �K���\�����X�V����
		ld		e, [ix + SCA_INFO_XL]
		ld		d, [ix + SCA_INFO_YL]
		call	draw_boss8_left
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_left_s2:
		; �X�s�[�h�J�E���^
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret		nz
		ld		a, LEFT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		; ��ֈړ�������
		ld		a, [ix + SCA_INFO_YL]
		dec		a
		ld		[ix + SCA_INFO_YL], a
		jp		nz, enemy_boss8_left_s2_skip1
		; 0�ɓ��B�����ꍇ�͎��̏�Ԃ֑J��
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
		ld		a, LEFT_PART_DOWN_CYCLE
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
enemy_boss8_left_s2_skip1:
		; �K���\�����X�V����
		ld		e, [ix + SCA_INFO_XL]
		ld		d, [ix + SCA_INFO_YL]
		call	draw_boss8_left
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_move_right::
		; �E�p�[�c�����łɔj��ς݂Ȃ牽�����Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_POWER3]
		or		a, a
		ret		z
		; �e���ˏ���
		ld		a, [ix + SCA_INFO_XL2]
		rlca
		rlca
		rlca
		ld		c, a
		ld		a, [ix + SCA_INFO_YL2]
		add		a, 3
		rlca
		rlca
		rlca
		ld		b, a
		call	enemy_boss8_shot
		; ��Ԕ���
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L2]
		cp		a, 1
		jp		c, enemy_boss8_right_s0
		jp		z, enemy_boss8_right_s1
		jp		enemy_boss8_right_s2

enemy_boss8_right_s0:
		; �b�J�E���g�^�C�}�[
		ld		a, [wait_timer_right]
		dec		a
		ld		[wait_timer_right], a
		ret		nz
		ld		a, 60
		ld		[wait_timer_right], a
		; �E�p�[�c���ҋ@���Ȃ牽�����Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H2]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret		nz
		; ���ֈړ�����^�C�~���O�ɂȂ����̂� S1 �֑J��
		ld		a, 1
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], a
		ld		a, RIGHT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret

enemy_boss8_right_s1:
		; �X�s�[�h�J�E���^
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H2]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret		nz
		ld		a, RIGHT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		; ���ֈړ�������
		ld		a, [ix + SCA_INFO_YL2]
		inc		a
		ld		[ix + SCA_INFO_YL2], a
		cp		a, 13
		jp		nz, enemy_boss8_right_s1_skip1
		; 13�ɓ��B�����ꍇ�͎��̏�Ԃ֑J��
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], a
enemy_boss8_right_s1_skip1:
		; �K���\�����X�V����
		ld		e, [ix + SCA_INFO_XL2]
		ld		d, [ix + SCA_INFO_YL2]
		call	draw_boss8_right
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_right_s2:
		; �X�s�[�h�J�E���^
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H2]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret		nz
		ld		a, RIGHT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		; ��ֈړ�������
		ld		a, [ix + SCA_INFO_YL2]
		dec		a
		ld		[ix + SCA_INFO_YL2], a
		jp		nz, enemy_boss8_right_s2_skip1
		; 0�ɓ��B�����ꍇ�͎��̏�Ԃ֑J��
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], a
		ld		a, RIGHT_PART_DOWN_CYCLE
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
enemy_boss8_right_s2_skip1:
		; �K���\�����X�V����
		ld		e, [ix + SCA_INFO_XL2]
		ld		d, [ix + SCA_INFO_YL2]
		call	draw_boss8_right
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_move_center:
		ld		a, [ix + SCA_INFO_ENEMY_POWER5]
		or		a, a
		ret		z								; �����p�[�c�����łɔj��ς� �܂��� state0 �Ȃ牽�����Ȃ�

		; �e���ˏ���
		ld		a, [ix + SCA_INFO_XL3]
		add		a, 4
		rlca
		rlca
		rlca
		ld		c, a
		ld		a, [ix + SCA_INFO_YL3]
		add		a, 6
		rlca
		rlca
		rlca
		ld		b, a
		call	enemy_boss8_shot

		ld		a, [ix + SCA_INFO_ENEMY_STATE_H3]
		cp		a, 1
		jp		c, enemy_boss8_center_s0
		jp		z, enemy_boss8_center_s1
		cp		a, 3
		jp		c, enemy_boss8_center_s2
		jp		enemy_boss8_center_s3

enemy_boss8_center_s0:
		; �X�V�^�C�}�[
		ld		a, [wait_timer_center]
		dec		a
		ld		[wait_timer_center], a
		jp		nz, enemy_boss8_center_force_update
		ld		a, CENTER_MOVE_SPEED
		ld		[wait_timer_center], a
		; ���[�U�[���˃^�C�~���O
		ld		a, [wait_timer_laser]
		dec		a
		ld		[wait_timer_laser], a
		jp		nz, enemy_boss8_center_force_update
		; ���[�U�[���ˏ�����ԂɑJ��
		ld		hl, [se_pre_laser]
		call	bgmdriver_play_sound_effect
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ld		a, CENTER_BEFORE_LASER_WAIT
		ld		[wait_timer_left], a
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		jp		draw_boss8_center
enemy_boss8_center_force_update:
		ld		a, [boss_center_update]
		or		a, a
		ret		z
		xor		a, a
		ld		[boss_center_update], a
enemy_boss8_move_center_active:
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		jp		draw_boss8_center

enemy_boss8_center_s1:
		; �X�V�^�C�}�[
		ld		a, [wait_timer_center]
		dec		a
		ld		[wait_timer_center], a
		ret		nz
		ld		a, CENTER_MOVE_SPEED
		ld		[wait_timer_center], a
		; ���[�U�[���˃^�C�~���O
		ld		a, [wait_timer_laser]
		dec		a
		ld		[wait_timer_laser], a
		jp		nz, enemy_boss8_move_center_active2
		; ���[�U�[���ˏ�����ԂɑJ��
		ld		hl, [se_pre_laser]
		call	bgmdriver_play_sound_effect
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ld		a, CENTER_BEFORE_LASER_WAIT
		ld		[wait_timer_left], a
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		jp		draw_boss8_center2

enemy_boss8_move_center_active2::
		; X���W�̈ʑ��p
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		ld		de, 5
		add		hl, de
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = 72*sin��
		call	enemy_get_cos
		; a = b*0.1 = [b*3 >> 5] + 7
		; 72*3 = 216 �Ȃ̂� >> 1 �� 108 �ɂȂ�A�����t�� 8bit �Ɏ��܂�
		xor		a, a
		ld		l, b
		ld		h, a
		ld		e, b
		ld		d, a
		add		hl, de
		add		hl, de
		xor		a, a
		cp		a, h
		rr		l
		ld		a, l
		sra		a
		sra		a
		sra		a
		sra		a
		add		a, 7
		ld		[ix + SCA_INFO_XL3], a
		; Y���W�̈ʑ��p
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L2]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H2]
		ld		de, 15
		add		hl, de
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], h
		; c = 72*cos��
		call	enemy_get_cos
		ld		a, c
		; a = c/16 + 5 = [c >> 4] + 5
		sra		a
		sra		a
		sra		a
		sra		a
		neg
		add		a, 5
		ld		[ix + SCA_INFO_YL3], a
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, a
		xor		a, a
		jp		draw_boss8_center2

enemy_boss8_center_s2:							; ���[�U�[���ˏ�����
		ld		a, [wait_timer_left]
		dec		a
		ld		[wait_timer_left], a
		jp		nz, enemy_boss8_center_force_update
		ld		a, CENTER_AFTER_LASER_WAIT
		ld		[wait_timer_left], a
		; ���[�U�[���ˉ�
		ld		hl, [se_laser]
		call	bgmdriver_play_sound_effect
		; ���[�U�[��`��
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		ld		a, 105
		call	background_draw_laser
		ld		a, 3
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ret

enemy_boss8_center_s3:							; ���[�U�[���˒�
		ld		a, [wait_timer_left]
		dec		a
		ld		[wait_timer_left], a
		jp		nz, enemy_boss8_center_force_update
		ld		a, CENTER_MOVE_SPEED
		ld		[wait_timer_left], a
		; ���[�U�[����~
		ld		hl, [se_stop]
		call	bgmdriver_play_sound_effect
		; ���[�U�[������
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		xor		a, a
		call	background_draw_laser
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, [ix + SCA_INFO_ENEMY_POWER3]
		ld		a, 0
		jp		nz, enemy_boss8_center_s3_skip1	; ���E�p�[�c�̏��Ȃ��Ƃ��P�̂������Ă���� skip1 ��
		inc		a
enemy_boss8_center_s3_skip1:
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ret

; -----------------------------------------------------------------------------
;	�{�X8�̒e���ˏ���
;		c	... ���ˍ��WX
;		b	...	���ˍ��WY
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,ix,iy
; -----------------------------------------------------------------------------
enemy_boss8_shot:
		ld		a, [wait_timer_shot]
		dec		a
		ld		[wait_timer_shot], a
		ret		nz
		ld		a, SHOT_CYCLE
		ld		[wait_timer_shot], a

enemy_boss8_shot2::
		push	bc
		call	enemy_shot_search
		pop		bc
		ret		z
		; ���˂���e�̎�ނ����肷��
		ld		a, [boss_shot_type]
		dec		a
		ld		[boss_shot_type], a
		jp		z, enemy_boss8_shot3

		; ��]���˂̏ꍇ
		push	bc
		push	hl
		; ���˕�������]������
		ld		hl, [boss_shot_angle]
		ld		de, 512/11
		add		hl, de
		ld		[boss_shot_angle], hl
		; sin, cos �����߂�
		call	enemy_get_cos
		ld		e, c
		ld		d, b
		pop		hl
		pop		bc
		jp		enemy_shot_start_one2

		; ���@�Ə����˂̏ꍇ
enemy_boss8_shot3:
		ld		a, SHOT_TYPE_CHANGE
		ld		[boss_shot_type], a
		push	ix
		ld		ix, boss_shot_info
		ld		iy, player_info
		ld		[ix + SCA_INFO_XH], c
		ld		[ix + SCA_INFO_YH], b
		call	enemy_shot_start_one
		pop		ix
		ret

; -----------------------------------------------------------------------------
;	�{�X8�̓o�ꏈ��
;		iy	... �G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy_boss8_start::
		; �����蔻������X�{�X�p�ɐ؂�ւ���
		ld		a, 2
		call	change_crash_check_routine
		; �{�X�V�[���h�X�V
		ld		a, 32
		ld		[iy + SCA_INFO_ENEMY_POWER], a		; ���p�[�c
		ld		[iy + SCA_INFO_ENEMY_POWER3], a		; �E�p�[�c
		ld		a, 80
		ld		[iy + SCA_INFO_ENEMY_POWER5], a		; �����p�[�c
		; ������ԏ�����
		ld		a, 60
		ld		[wait_timer_left], a
		ld		[wait_timer_right], a
		ld		[wait_timer_center], a
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ld		a, SHOT_CYCLE
		ld		[wait_timer_shot], a
		ld		a, SHOT_TYPE_CHANGE
		ld		[boss_shot_type], a
		ld		hl, 0
		ld		[boss_shot_angle], hl
		xor		a, a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L2], a
		ld		[iy + SCA_INFO_ENEMY_STATE_H3], a
		ld		a, LEFT_PART_1ST_DOWN_TIME
		ld		[iy + SCA_INFO_ENEMY_STATE_H], a
		ld		a, RIGHT_PART_1ST_DOWN_TIME
		ld		[iy + SCA_INFO_ENEMY_STATE_H2], a
		; X, Y���W�X�V [�X�v���C�g�ɉe�����o�Ȃ��悤�� L ���g���j
		ld		a, 1
		ld		[iy + SCA_INFO_XL], a		; ���p�[�cX
		ld		a, 14
		ld		[iy + SCA_INFO_XL2], a		; �E�p�[�cX
		ld		a, 7
		ld		[iy + SCA_INFO_XL3], a		; �����p�[�cX
		xor		a, a
		ld		[iy + SCA_INFO_YL], a		; ���p�[�cY
		ld		[iy + SCA_INFO_YL2], a		; �E�p�[�cY
		ld		[iy + SCA_INFO_YL3], a		; �����p�[�cY
		; �{�X�\��
		ld		e, [iy + SCA_INFO_XL]
		ld		d, [iy + SCA_INFO_YL]
		call	draw_boss8_left
		ld		e, [iy + SCA_INFO_XL2]
		ld		d, [iy + SCA_INFO_YL2]
		call	draw_boss8_right
		ld		e, [iy + SCA_INFO_XL3]
		ld		d, [iy + SCA_INFO_YL3]
		call	draw_boss8_center
		; Y���W�X�V
		ld		a, 212
		ld		[iy + SCA_INFO_YH], a
		ld		[iy + SCA_INFO_YH2], a
		ld		[iy + SCA_INFO_YH3], a
		ld		[iy + SCA_INFO_YH4], a
		ld		[iy + SCA_INFO_YH5], a
		ld		[iy + SCA_INFO_YH6], a
		ld		[iy + SCA_INFO_YH7], a
		ld		[iy + SCA_INFO_YH8], a
		; X���W�X�V
		xor		a, a
		ld		[iy + SCA_INFO_XH], a
		ld		[iy + SCA_INFO_XH2], a
		ld		[iy + SCA_INFO_XH5], a
		ld		[iy + SCA_INFO_XH6], a
		ld		[iy + SCA_INFO_XH3], a
		ld		[iy + SCA_INFO_XH4], a
		ld		[iy + SCA_INFO_XH7], a
		ld		[iy + SCA_INFO_XH8], a
		ld		hl, enemy_boss8_move
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		ld		hl, enemy_boss8_move_dummy
		ld		de, SCA_INFO_SIZE * 2
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		ret

wait_timer_left:
		db		0
wait_timer_right:
		db		0
wait_timer_center:
		db		0
wait_timer_laser:
		db		0
boss_center_update::
		db		0
wait_timer_shot:
		db		0
boss_shot_angle:
		dw		0
boss_shot_type:
		db		0
boss_shot_info:
		db		0, 0, 0, 0
