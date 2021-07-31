; -----------------------------------------------------------------------------
;	���@�̒e�̏���
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	���@�̒e�̏�����[���]
;	input:
;		ix	...	���@�e���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f,b
;	comment
;		���@�e���́A���L�̍\�����Ƃ�
;			unsigned short	x			���8bit�����W, ����8bit�͏�����[�������͏��0]
;			unsigned short	y			���8bit�����W, ����8bit�͏�����[�������͏��0]
;			unsigned char	shot_power	�V���b�g�p���[[���g�p���� 0]
; -----------------------------------------------------------------------------
shot_init::
		push	hl
		push	ix
		pop		hl
		xor		a, a
		ld		b, 5
shot_init_loop:
		ld		[hl], a
		inc		hl
		djnz	shot_init_loop
		pop		hl
		ret

; -----------------------------------------------------------------------------
;	���@�̒e�̈ړ�����[���]
;	input:
;		ix	...	���@�e���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a,f
; -----------------------------------------------------------------------------
shot_move::
		; ���̒e�����˒��łȂ���Ή������Ȃ�
		ld		a, [ix + SCA_INFO_SHOT_POWER]
		or		a, a
		jr		nz, shot_move_active
shot_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; ���˒��łȂ�
		ret
shot_move_active:
		; �e����ɓ�����
		ld		a, [ix + SCA_INFO_YH]
		sub		a, 8
		jr		c, shot_move_inactive
		ld		[ix + SCA_INFO_YH], a
		ret

; -----------------------------------------------------------------------------
;	���@�̒e�̔��ˏ���
;	input:
;		ix	... ���@���̃A�h���X
;		iy	... ���@�e���̃A�h���X�i�R������ł��邱�Ɓj
;	output
;		�Ȃ�
;	break
;		a,b,d,e,f,iy
; -----------------------------------------------------------------------------
shot_fire::
		; ���˂���^�C�~���O���ۂ����ׂ�
		xor		a, a
		call	GTTRIG
		ld		d, a
		ld		a, 1
		call	GTTRIG
		or		a, d
		ld		d, a
		ld		a, [shot_last_trigger]
		or		a, a
		ld		a, d						; ���t���O�s��
		ld		[shot_last_trigger], a		; ���t���O�s��
		ret		nz							; �Ō�ɔ��˂��Ă���܂��{�^����������Ă��Ȃ��ꍇ�͉������Ȃ�
		or		a, a
		ret		z							; ���������{�^����������Ă��Ȃ���Ή������Ȃ�
		; ���˒��łȂ��e����������
		ld		b, 3
		ld		de, SCA_INFO_SIZE
shot_fire_loop:
		; ���ݒ��ڂ��Ă���e�́A���˒����H
		ld		a, [iy + SCA_INFO_SHOT_POWER]
		or		a, a
		jr		z, shot_fire_found
		add		iy, de
		djnz	shot_fire_loop
		; �󂢂Ă�e�������̂Ŕ��˂���߂�
		ret
shot_fire_found:
		; ���ˏ���
		ld		a, [ix + SCA_INFO_XH]
		ld		[iy + SCA_INFO_XH], a
		ld		a, [ix + SCA_INFO_YH]
		ld		[iy + SCA_INFO_YH], a
		ld		a, [ix + SCA_INFO_PLAYER_SHOT_POWER]
		ld		[iy + SCA_INFO_SHOT_POWER], a
		; ���˂̌��ʉ�
		ld		hl, [se_shot]
		call	bgmdriver_play_sound_effect
		ret

shot_last_trigger:
		db		0
