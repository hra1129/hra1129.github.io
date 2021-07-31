; -----------------------------------------------------------------------------
;	�G�P�̏���
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�G1�̈ړ�����
;	input:
;		ix	...	�G1���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy1_move::
		; ���̓G�����쒆�łȂ���Ή������Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy1_move_active
enemy1_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_YH2], 212			; ��\��
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; �쓮���łȂ�
		ret
enemy1_move_active:
		; ��Ԃ𒲂ׂ�	256: ���ֈړ�, 255�`-127: �J�[�u�ړ�, -128: ���ֈړ�
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		ld		a, l
		or		a, a
		jr		z, enemy1_move_skip1
		cp		a, 129
		jr		c, enemy1_move_skip2
enemy1_move_skip1:
		ld		a, h
		dec		a
		jr		nz, enemy1_move_curve
		; ���֒����ړ�
		ld		a, [ix + SCA_INFO_YH]
		add		a, 2							; ����2��f�ړ�
		cp		a, 104
		jr		c, enemy1_move_skip3
		ld		a, 104
		ld		[ix + SCA_INFO_ENEMY_STATE_L], 255
		ld		[ix + SCA_INFO_ENEMY_STATE_H], 0
enemy1_move_skip3:
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		jr		enemy1_move_fire
enemy1_move_skip2:
		ld		a, h
		inc		a
		jr		nz, enemy1_move_curve
		; ���֒����ړ�
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		or		a, a
		ld		a, [ix + SCA_INFO_XH]
		jr		nz, enemy1_move_right
		sub		a, 2							; ����2��f�ړ� [dec a �� c�t���O���ω����Ȃ��̂Ŏg���Ȃ�]
		jr		nc, enemy1_move_skip4
enemy1_move_skip5:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_YH2], 212			; ��\��
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; �쓮���łȂ�
		jr		enemy1_move_skip4
enemy1_move_right:
		; �E�֒����ړ�
		add		a, 2
		cp		a, 175
		jr		nc, enemy1_move_skip5
enemy1_move_skip4:
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		jr		enemy1_move_fire
enemy1_move_curve:
		; �J�[�u�ړ�
		push	hl
		call	enemy_get_cos
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		or		a, a
		jr		z, enemy1_move_skip6
		ld		a, c
		neg
		ld		c, a
enemy1_move_skip6:
		ld		a, 88
		add		a, c
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		ld		a, 104
		add		a, b
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		pop		hl
		dec		hl
		dec		hl
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
enemy1_move_fire:
		; �e�𔭎˂���^�C�~���O���H
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy1_move_end					; ���˂̃^�C�~���O�łȂ���� enemy1_move_end ��
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; ���ˏ���
		ld		iy, player_info
		call	enemy_shot_start
enemy1_move_end:
		ret

; -----------------------------------------------------------------------------
;	�G1�̓o�ꏈ��
;	input:
;		ix	... ���@���̃A�h���X
;		iy	... �G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy1_start::
		; ���ˏ���
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 88
		jr		c, enemy1_start_reverse
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 0
		ld		[iy + SCA_INFO_XH], 16
		ld		[iy + SCA_INFO_XH2], 16
		jr		enemy1_start_skip1
enemy1_start_reverse:
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 160+16
		ld		[iy + SCA_INFO_XH], 160
		ld		[iy + SCA_INFO_XH2], 160
enemy1_start_skip1:
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0		; 256
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 1
		ld		hl, enemy1_move
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		; �X�v���C�g�̐F��ύX����
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		ld		c, 0x01
		push	iy
		call	sprite_set_color
		pop		iy
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		inc		a
		ld		c, 0x44
		push	iy
		call	sprite_set_color
		pop		iy
		; �X�v���C�g�p�^�[���ԍ���ύX����
		;		HL �� sprite_attribute_table + A * 4 + 2
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		�p�^�[���ԍ�
		ld		[hl], 3 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 4 * 4
		ret
