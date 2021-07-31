; -----------------------------------------------------------------------------
;	���@����
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	���@�̏����������i�Q�[���J�n���j
;	input:
;		ix	...	���@���̃A�h���X
;	output
;		�Ȃ�
;	break
;		�Ȃ�
;	comment
;		���@���́A���L�̍\�����Ƃ�
;			unsigned short	x			���8bit�����W, ����8bit�͏�����
;			unsigned short	y			���8bit�����W, ����8bit�͏�����
;			unsigned short	p_vector	�ړ��x�N�g���e�[�u���̃A�h���X
;			unsigned char	shot_power	�V���b�g�p���[
; -----------------------------------------------------------------------------
player_init::
		push	hl
		push	ix
		pop		hl
		; ���@��񏉊���
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		a, SCA_PLAYER_SPEED
		ld		[player_speed], a
		rlca
		ld		e, a
		ld		d, 0
		ld		bc, player_move_vector_table
		ex		de, hl
		add		hl, bc
		ld		c, [hl]
		inc		hl
		ld		b, [hl]
		ex		de, hl
		ld		[hl], c
		inc		hl
		ld		[hl], b
		inc		hl
		ld		a, SCA_PLAYER_SHOT
		ld		[player_shot], a
		add		a, 2
		ld		[hl], a
		ld		a, SCA_INVINCIBILITY
		ld		[player_invincibility], a
		ld		a, SCA_PLAYER_SHIELD
		ld		[player_shield], a
		pop		hl
		ret

; -----------------------------------------------------------------------------
;	���@�̏����������i�X�e�[�W�J�n���j
;	input:
;		ix	...	���@���̃A�h���X
;	output
;		�Ȃ�
;	break
;		�Ȃ�
;	comment
;		���@���́A���L�̍\�����Ƃ�
;			unsigned short	x			���8bit�����W, ����8bit�͏�����
;			unsigned short	y			���8bit�����W, ����8bit�͏�����
;			unsigned short	p_vector	�ړ��x�N�g���e�[�u���̃A�h���X
;			unsigned char	shot_power	�V���b�g�p���[
; -----------------------------------------------------------------------------
player_stage_init::
		push	hl
		push	ix
		pop		hl
		; X���W������
		ld		[hl], 0
		inc		hl
		ld		[hl], 88
		inc		hl
		; Y���W������
		ld		[hl], 0
		inc		hl
		ld		[hl], 191-16
		pop		hl
		ret

; -----------------------------------------------------------------------------
;	���@�̈ړ�����
;	input:
;		ix	...	���@���̃A�h���X
;	output
;		�Ȃ�
;	break
;		ix�ȊO�S��
; -----------------------------------------------------------------------------
player_move::
		; ���G���[�h������
		ld		a, [player_invincibility]
		or		a, a
		jr		z, player_move_skip1
		inc		a
		jr		z, player_move_skip1			; �f�o�b�O�p���G���[�h�̏ꍇ�f�N�������g���Ȃ�
		dec		a
		dec		a
		ld		[player_invincibility], a
player_move_skip1:
		push	ix
		; �J�[�\���L�[�̏�Ԃ𓾂�
		xor		a, a
		call	GTSTCK
		push	af
		; �W���C�X�e�B�b�N�P�̏�Ԃ𓾂�
		ld		a, 1
		call	GTSTCK
		; �J�[�\���L�[��ԁA�W���C�X�e�B�b�N�P��Ԃ��~�b�N�X
		pop		bc
		or		a, b
		; �A�h���X�I�t�Z�b�g�ɕϊ� [ iy = p_vector + a * 4 ]
		pop		ix
		cp		a, 9
		jr		c, player_move_skip2
		xor		a, a
player_move_skip2:
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		c, [ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_L]
		ld		b, [ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_H]
		add		hl, bc
		push	hl
		pop		iy
		; X���W�Ɉړ��x�N�g�������Z���Đ����ړ�
		ld		l, [ix + SCA_INFO_XL]
		ld		h, [ix + SCA_INFO_XH]
		ld		c, [iy + 0]
		ld		b, [iy + 1]
		add		hl, bc
		; ��ʊO�ɂ͂ݏo�������`�F�b�N
		ld		a, h
		cp		a, 192-16
		jr		c, player_move_x_success1
		; �͂ݏo���������𔻕�
player_move_x_fail1:
		cp		a, 224
		; ���Ȃ獶�[����t��
		ld		hl, 0			; ���t���O�ω�����
		jr		nc, player_move_x_success1
		; �E�Ȃ�E�[����t��
		ld		hl, (191-16)*256+0
player_move_x_success1:
		; X���W���X�V
		ld		[ix + SCA_INFO_XL], l
		ld		[ix + SCA_INFO_XH], h
		ld		[ix + SCA_INFO_XH2], h
		; Y���W�Ɉړ��x�N�g�������Z���Đ����ړ�
		ld		l, [ix + SCA_INFO_YL]
		ld		h, [ix + SCA_INFO_YH]
		ld		c, [iy + 2]
		ld		b, [iy + 3]
		add		hl, bc
		; ��ʊO�ɂ͂ݏo�������`�F�b�N
		ld		a, h
		cp		a, 192-16
		jr		c, player_move_y_success1
		; �͂ݏo���������𔻕�
player_move_y_fail1:
		cp		a, 224
		; ��Ȃ��[����t��
		ld		hl, 0			; ���t���O�ω�����
		jr		nc, player_move_y_success1
		; ���Ȃ牺�[����t��
		ld		hl, (191-16)*256+0
player_move_y_success1:
		; Y���W���X�V
		ld		[ix + SCA_INFO_YL], l
		ld		[ix + SCA_INFO_YH], h
		ld		[ix + SCA_INFO_YH2], h
		ret

; -----------------------------------------------------------------------------
;	���@�̃X�s�[�h�A�b�v
;	input:
;		ix	...	���@���̃A�h���X
;	output
;		�Ȃ�
;	break
;		ix�ȊO�S��
; -----------------------------------------------------------------------------
player_speed_up::
		ld		a, [player_speed]
		cp		a, 7
		ret		z				; ���łɍő�Ȃ�X�s�[�h�A�b�v���Ȃ�
		inc		a
		ld		[player_speed], a
		; �ړ��x�N�g���A�h���X�֕ϊ�
		rlca
		ld		l, a
		ld		h, 0
		ld		de, player_move_vector_table
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; �ړ��x�N�g�����X�V
		ld		[ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_L], e
		ld		[ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_H], d
		; ���@���̕\�����X�V
		jp		background_update_player_info

; -----------------------------------------------------------------------------
;	���@�̃V���b�g�p���[�A�b�v
;	input:
;		ix	...	���@���̃A�h���X
;	output
;		�Ȃ�
;	break
;		ix�ȊO�S��
; -----------------------------------------------------------------------------
player_shot_power_up::
		ld		a, [player_shot]
		cp		a, 7
		ret		z				; ���łɍő�Ȃ�p���[�A�b�v���Ȃ�
		inc		a
		ld		[player_shot], a
		; �V���b�g�p���[���X�V
		add		a, 2
		ld		[ix + SCA_INFO_PLAYER_SHOT_POWER], a
		; ���@���̕\�����X�V
		jp		background_update_player_info

player_move_vector0:			; 1.0�{��
		dw		0, 0			; �E
		dw		0, -256			; ��
		dw		181, -181		; �^
		dw		256, 0			; ��
		dw		181, 181		; �_
		dw		0, 256			; ��
		dw		-181, 181		; �^
		dw		-256, 0			; ��
		dw		-181, -181		; �_

player_move_vector1:			; 1.2�{��
		dw		0, 0			; �E
		dw		0, -307			; ��
		dw		217, -217		; �^
		dw		307, 0			; ��
		dw		217, 217		; �_
		dw		0, 307			; ��
		dw		-217, 217		; �^
		dw		-307, 0			; ��
		dw		-217, -217		; �_

player_move_vector2:			; 1.4�{��
		dw		0, 0			; �E
		dw		0, -358			; ��
		dw		253, -253		; �^
		dw		358, 0			; ��
		dw		253, 253		; �_
		dw		0, 358			; ��
		dw		-253, 253		; �^
		dw		-358, 0			; ��
		dw		-253, -253		; �_

player_move_vector3:			; 1.6�{��
		dw		0, 0			; �E
		dw		0, -409			; ��
		dw		290, -290		; �^
		dw		409, 0			; ��
		dw		290, 290		; �_
		dw		0, 409			; ��
		dw		-290, 290		; �^
		dw		-409, 0			; ��
		dw		-290, -290		; �_

player_move_vector4:			; 1.8�{��
		dw		0, 0			; �E
		dw		0, -460			; ��
		dw		325, -325		; �^
		dw		460, 0			; ��
		dw		325, 325		; �_
		dw		0, 460			; ��
		dw		-325, 325		; �^
		dw		-460, 0			; ��
		dw		-325, -325		; �_

player_move_vector5:			; 2.0�{��
		dw		0, 0			; �E
		dw		0, -512			; ��
		dw		362, -362		; �^
		dw		512, 0			; ��
		dw		362, 362		; �_
		dw		0, 512			; ��
		dw		-362, 362		; �^
		dw		-512, 0			; ��
		dw		-362, -362		; �_

player_move_vector6:			; 2.2�{��
		dw		0, 0			; �E
		dw		0, -563			; ��
		dw		398, -398		; �^
		dw		563, 0			; ��
		dw		398, 398		; �_
		dw		0, 563			; ��
		dw		-398, 398		; �^
		dw		-563, 0			; ��
		dw		-398, -398		; �_

player_move_vector7:			; 2.4�{��
		dw		0, 0			; �E
		dw		0, -614			; ��
		dw		434, -434		; �^
		dw		614, 0			; ��
		dw		434, 434		; �_
		dw		0, 614			; ��
		dw		-434, 434		; �^
		dw		-614, 0			; ��
		dw		-434, -434		; �_

player_move_vector_table:
		dw		player_move_vector0
		dw		player_move_vector1
		dw		player_move_vector2
		dw		player_move_vector3
		dw		player_move_vector4
		dw		player_move_vector5
		dw		player_move_vector6
		dw		player_move_vector7

player_speed::
		db		0				; ���@�̈ړ����x 0�`7 �̂W�i�K
player_shot::
		db		0				; ���@�̒e�̈З� 0�`7 �̂W�i�K
player_shield::
		db		0				; ���@�̃V�[���h 0�`8 �̂X�i�K�i0�̓Q�[���I�[�o�[�j
player_invincibility::
		db		0				; 0: �ʏ�, 255: ���G, 1�`254: ��莞�Ԗ��G[���l�͎c�莞��, 1/60[sec]�P��]
