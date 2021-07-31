; -----------------------------------------------------------------------------
;	�G�Q�̏���
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�G2�̈ړ�����
;	input:
;		ix	...	�G2���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy2_move::
		; ���̓G�����쒆�łȂ���Ή������Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy2_move_active
enemy2_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_YH2], 212			; ��\��
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; �쓮���łȂ�
		ret
enemy2_move_active:
		; ����̈ʑ��p�𓾂�
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; �ʑ��p�� 90 * 4/128 [�x] �������炷
		ld		de, 4
		add		hl, de
		; �ʑ��p���X�V
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ �ʑ��p ]
		call	enemy_get_cos
		; ���]�̏ꍇ�� a = -b + 88, ���]�łȂ���� a = b + 88
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		or		a, a
		ld		a, b							; ���t���O�s��
		jr		z, enemy2_move_skip1
		neg
enemy2_move_skip1:
		add		a, 88
		; X���W�X�V
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		; Y���W�X�V
		ld		a, [ix + SCA_INFO_YH]
		inc		a
		cp		a, 192
		jr		nc, enemy2_move_inactive		; ��ʊO�֏o���� inactive ��
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy2_move_anime:
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L]
		bit		4, a
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		jr		z, enemy2_move_anime_skip1
		call	enemy2_move_graphic1
		jr		enemy2_move_fire
enemy2_move_anime_skip1:
		call	enemy2_move_graphic2
enemy2_move_fire:
		; �e�𔭎˂���^�C�~���O���H
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy2_move_end					; ���˂̃^�C�~���O�łȂ���� enemy2_move_end ��
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; ���ˏ���
		ld		iy, player_info
		call	enemy_shot_start
enemy2_move_end:
		ret

enemy2_move_graphic1:
		;		HL �� sprite_attribute_table + A * 4 + 2
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		�p�^�[���ԍ�
		ld		[hl], 6 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 7 * 4
		ret

enemy2_move_graphic2:
		;		HL �� sprite_attribute_table + A * 4 + 2
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		�p�^�[���ԍ�
		ld		[hl], 8 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 9 * 4
		ret

; -----------------------------------------------------------------------------
;	�G2�̓o�ꏈ��
;	input:
;		ix	... ���@���̃A�h���X
;		iy	... �G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy2_start::
		; ���ˏ���
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 88
		jr		c, enemy2_start_reverse
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 1		; �E��
		jr		enemy2_start_skip1
enemy2_start_reverse:
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 0		; ����
enemy2_start_skip1:
		ld		[iy + SCA_INFO_XH], 88
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_XH2], 88
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 0
		ld		hl, enemy2_move
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
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		jp		enemy2_move_graphic1
