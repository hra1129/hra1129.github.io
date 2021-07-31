; -----------------------------------------------------------------------------
;	�G4�̏���
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�G4�̈ړ�����
;	input:
;		ix	...	�G4���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy4_move::
		; ���̓G�����쒆�łȂ���Ή������Ȃ�
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy4_move_active
enemy4_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_YH2], 212			; ��\��
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; �쓮���łȂ�
		ret
enemy4_move_active:
		; ����̈ʑ��p�𓾂�
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; �ʑ��p�� 90 * 7/128 [�x] �������炷
		ld		de, 7
		add		hl, de
		; �ʑ��p���X�V
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ �ʑ��p ]
		call	enemy_get_cos
		; a = [b / 4] + SCA_INFO_XL
		ld		a, b
		sra		a
		sra		a
		add		a, [ix + SCA_INFO_XL]
		; X���W�X�V
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		; Y���W�X�V
		ld		a, [ix + SCA_INFO_YH]
		inc		a
		cp		a, 192
		jr		nc, enemy4_move_inactive		; ��ʊO�֏o���� inactive ��
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy4_move_fire:
		; �e�𔭎˂���^�C�~���O���H
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy4_move_end					; ���˂̃^�C�~���O�łȂ���� enemy4_move_end ��
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; ���ˏ���
		ld		iy, player_info
		call	enemy_shot_start
enemy4_move_end:
		ret

; -----------------------------------------------------------------------------
;	�G4�̓o�ꏈ��
;		ix	... ���@���̃A�h���X
;		iy	... �G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy4_start::
		; ���ˏ���
		call	random
		ld		a, l
		sub		a, 18
		jr		c, enemy4_start_skip0				; 0�`17 �̏ꍇ�� enemy4_start_skip0 ��
		ld		a, l
		cp		a, 176-18
		jr		c, enemy4_start_skip1
enemy4_start_skip0:									; 0�`17 �� 238�`255 �ɂȂ��Ă���B����ȊO�� 158�`255
		sub		a, 176-18-18						; 158�`255 �� 18�`133 �ɂȂ�B
enemy4_start_skip1:
		ld		[iy + SCA_INFO_XL], a				; �����ɗ����Ƃ� a �́A18�`157 �ɂȂ��Ă���
		ld		[iy + SCA_INFO_XH], a
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_XH2], a
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 0
		ld		hl, enemy4_move
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
