; -----------------------------------------------------------------------------
;	�G�̔�������
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
enemy_bomb_move::
		; ���쒆�����f
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L]
		or		a, a
		jr		nz, enemy_bomb_move_active
enemy_bomb_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_YH2], 212			; ��\��
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; �쓮���łȂ�
		ret
enemy_bomb_move_active:
		; ���쒆�J�E���^�����炷
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
		cp		a, 12
		call	z, enemy_bomb_move_graphic2
		; Y���W�X�V
		ld		a, [ix + SCA_INFO_YH]
		inc		a
		cp		a, 192
		jr		nc, enemy_bomb_move_inactive		; ��ʊO�֏o���� inactive ��
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy_bomb_move_end:
		ret

enemy_bomb_move_graphic2:
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		�p�^�[���ԍ�
		ld		[hl], 56
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 60
		ret

; -----------------------------------------------------------------------------
;	�G�̏��𔚔��ɕύX����
;		ix	... �G���̃A�h���X
;	output
;		�Ȃ�
;	break
;		�S��
; -----------------------------------------------------------------------------
enemy_bomb::
		; �����p�^�[���ɕύX����
		ld		[ix + SCA_INFO_ENEMY_STATE_L], 20
		ld		[ix + SCA_INFO_ENEMY_POWER], 0
		ld		hl, enemy_bomb_move
		ld		[ix + SCA_INFO_ENEMY_MOVE_L], l
		ld		[ix + SCA_INFO_ENEMY_MOVE_H], h
		; �X�v���C�g�̐F��ύX����
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		ld		c, 0x06
		push	ix
		call	sprite_set_color
		pop		ix
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		inc		a
		ld		c, 0x49
		push	ix
		call	sprite_set_color
		pop		ix
		; �X�v���C�g�p�^�[���ԍ���ύX����
		;		HL �� sprite_attribute_table + A * 4 + 2
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		�p�^�[���ԍ�
		ld		[hl], 48
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 52
		ret
