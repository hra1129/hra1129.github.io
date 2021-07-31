; -----------------------------------------------------------------------------
;	�G5�̏���
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�G5�̈ړ�����
;	input:
;		ix	...	�G5���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy5_move::
		; ���̓G�����쒆�łȂ���Ή������Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy5_move_active
enemy5_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_YH2], 212			; ��\��
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; �쓮���łȂ�
		ret
enemy5_move_active:
		; ����̈ʑ��p�𓾂�
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; �ʑ��p�� 90 * 7/128 [�x] �������炷
		ld		de, 2
		add		hl, de
		; �ʑ��p���X�V
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ �ʑ��p ]
		call	enemy_get_cos
		; a = [b / 4] + SCA_INFO_XL
		ld		a, b
		add		a, b
		cp		a, 192
		jr		nc, enemy5_move_inactive
		; Y���W�X�V
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		; X���W�X�V
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		add		a, [ix + SCA_INFO_XH]
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
enemy5_move_fire:
		; �e�𔭎˂���^�C�~���O���H
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy5_move_end					; ���˂̃^�C�~���O�łȂ���� enemy5_move_end ��
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; ���ˏ���
		ld		iy, player_info
		call	enemy_shot_start
enemy5_move_end:
		ret

; -----------------------------------------------------------------------------
;	�G5�̓o�ꏈ��
;		ix	... ���@���̃A�h���X
;		iy	... �G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy5_start::
		; ���ˏ���
		; ���ˏ���
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 88
		jr		c, enemy5_start_reverse
		ld		[iy + SCA_INFO_ENEMY_REVERSE], -1		; �E��
		ld		[iy + SCA_INFO_XH], 160
		ld		[iy + SCA_INFO_XH2], 160
		jr		enemy5_start_skip1
enemy5_start_reverse:
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 1		; ����
		ld		[iy + SCA_INFO_XH], 16
		ld		[iy + SCA_INFO_XH2], 16
enemy5_start_skip1:
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 0
		ld		hl, enemy5_move
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
		ld		[hl], 10 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 11 * 4
		ret
