; -----------------------------------------------------------------------------
;	�����蔻�菈��
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	���@�����蔻��
;	input:
;		�Ȃ�
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: �G���G�e�ɏՓ˂��Ă���
;	break
;		a, f, b, d, e, ix, iy
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_player_clash::
		; ���G��Ԃ��H
		ld		a, [player_invincibility]
		or		a, a
		ret		nz
		; �����蔻��
		call	check_player_clash_sub		 		; �G�E�{�X�Ƃ̂����蔻��
		jp		c, check_player_clash_skip1
		call	check_player_clash_sub2				; ���X�{�X�Ƃ̂����蔻��
		ret		nc
check_player_clash_skip1:
		; �_���[�W�����o��
		ld		hl, [se_bomb2]
		call	bgmdriver_play_sound_effect
		; ���@�Ƀ_���[�W��^����
		ld		a, [player_shield]
		dec		a
		push	af
		ld		[player_shield], a
		call	background_update_player_info
		pop		af
		jp		z, goto_gameover
		ld		a, 240								; �_���[�W���󂯂�Ǝ��@�� 4�b�Ԗ��G�ɂȂ�
		ld		[player_invincibility], a
		ret

check_player_clash_sub:
		; ���@�ƓG�̓����蔻��
		ld		ix, player_info
		ld		iy, enemy_info0
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip1
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip1:

		ld		iy, enemy_info1
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip2
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip2:

		ld		iy, enemy_info2
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip3
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip3:

		ld		iy, enemy_info3
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip4
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip4:

		ld		iy, enemy_info4
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip5
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip5:

		ld		iy, enemy_info5
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip6
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip6:

		; ���@�ƓG�e�̓����蔻��
		ld		de, SCA_INFO_SIZE
		ld		b, 15
		ld		iy, eshot_info
check_player_clash_loop:
		call	check_clash_4x4
		ret		c
		add		iy, de							; ���オ�肵�Ȃ����� C�t���O = 0
		djnz	check_player_clash_loop			; djnz �� C�t���O�s��
		ret

		; ���@�ƃ��X�{�X�̂����蔻��
check_player_clash_sub2::
		ld		ix, player_info
		ld		a, 8
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		l, [ix + SCA_INFO_YH]
		; ���W�ʒu�̃L�����N�^�擾
		call	background_get_fore_char
		cp		a, 96								; ���X�{�X�̃p�[�c 96�ȍ~ 
		ccf
		ret

; -----------------------------------------------------------------------------
;	�G�����蔻��
;	input:
;		�Ȃ�
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: ���@�e�ɏՓ˂��Ă���
;	break
;		a, f, b, d, e, h, l, ix, iy
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_enemy_clash::
		ld		hl, [crash_check_routine]
		jp		hl

check_enemy_normal_clash::
		ld		ix, enemy_info0
		ld		b, 6							; �G�͍ő�U�@
check_enemy_clash_loop1:
		push	bc
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_enemy_clash_skip1		; ���쒆�łȂ��G���Ƃ͂����蔻�肵�Ȃ�
		ld		iy, shot_info0
		call	check_clash_12x12
		call	c, enemy_clash
		ld		iy, shot_info1
		call	check_clash_12x12
		call	c, enemy_clash
		ld		iy, shot_info2
		call	check_clash_12x12
		call	c, enemy_clash
check_enemy_clash_skip1:
		ld		de, SCA_INFO_SIZE * 2
		add		ix, de
		pop		bc
		djnz	check_enemy_clash_loop1
		ret

; -----------------------------------------------------------------------------
;	�{�X1�����蔻��
;	input:
;		�Ȃ�
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: ���@�e�ɏՓ˂��Ă���
;	break
;		a, f, b, d, e, h, l, ix, iy
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_enemy_boss1_clash:
		ld		ix, enemy_info0
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_enemy_boss1_clash_skip1		; ���쒆�łȂ��G���Ƃ͂����蔻�肵�Ȃ�
		ld		iy, shot_info0
		call	check_clash_boss1
		call	c, enemy_boss1_clash
		ld		iy, shot_info1
		call	check_clash_boss1
		call	c, enemy_boss1_clash
		ld		iy, shot_info2
		call	check_clash_boss1
		call	c, enemy_boss1_clash
check_enemy_boss1_clash_skip1:
		ret

; -----------------------------------------------------------------------------
;	���X�{�X�����蔻��
;	input:
;		�Ȃ�
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: ���@�e�ɏՓ˂��Ă���
;	break
;		a, f, b, d, e, h, l, ix, iy
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_enemy_boss8_clash:
		ld		ix, shot_info0
		call	boss8_clash_sub

		ld		ix, shot_info1
		call	boss8_clash_sub

		ld		ix, shot_info2
		call	boss8_clash_sub
		ret

; -----------------------------------------------------------------------------
;	���@�e�ƃ��X�{�X�̂����蔻��[�P��]
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
boss8_clash_sub:
		; �e�̍��W
		ld		a, 4
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		l, [ix + SCA_INFO_YH]
		ld		a, l
		cp		a, 212
		ret		z									; ���˒��łȂ���Δj��ł��Ȃ�
		; ���W�ʒu�̃L�����N�^�擾
		call	background_get_fore_char
		cp		a, 96							; ���X�{�X�̃p�[�c 96�ȍ~ 
		jp		c, boss8_clash_sub_skip1
		cp		a, 106							; ���X�{�X�̎�_�p�[�c 106�ȍ~ �ł��邩�H
		jp		nc, boss8_clash_sub_skip2

boss8_clash_sub_skip1:
		inc		hl									; �����E�ׂ����ׂ�
		ld		a, [hl]
		cp		a, 96								; ���X�{�X�̃p�[�c 96�ȍ~ 
		ret		c
		cp		a, 106								; ���X�{�X�̎�_�p�[�c 106�ȍ~ �ł��邩�H
		jp		c, boss8_no_damage
boss8_clash_sub_skip2:
		ld		[ix + SCA_INFO_YH], 212				; ���@�e ��\��
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; ���˒��łȂ�
		; �ǂ̃p�[�c�Ƀ_���[�W��^�����̂����ׂ�
		ld		a, [SCA_INFO_ENEMY_POWER + enemy_info0]
		ld		b, a
		ld		a, [SCA_INFO_ENEMY_POWER3 + enemy_info0]
		or		a, b								; �����p�[�c�͑ҋ@�����H
		jp		z, boss8_center_damage			; �ҋ@���łȂ���΁A�����p�[�c�������݂��Ȃ��������p�[�c�Ƀ_���[�W
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 192/2
		jp		nc, boss8_right_damage			; �������E���Ȃ�E�p�[�c�փ_���[�W
boss8_left_damage::
		ld		a, [SCA_INFO_ENEMY_POWER + enemy_info0]
		dec		a								; ���p�[�c�Ƀ_���[�W��^���� [���@�� ShotPower �Ɋւ�炸 1�_���[�W]
		ld		[SCA_INFO_ENEMY_POWER + enemy_info0], a
		jp		nz, boss8_damage
		ld		a, [SCA_INFO_XL + enemy_info0]	; ���p�[�c�̕\��������
		ld		e, a
		ld		a, [SCA_INFO_YL + enemy_info0]
		ld		d, a
		call	draw_boss8_delete
		jp		boss8_destroy

boss8_right_damage::
		ld		a, [SCA_INFO_ENEMY_POWER3 + enemy_info0]
		dec		a								; �E�p�[�c�Ƀ_���[�W��^���� [���@�� ShotPower �Ɋւ�炸 1�_���[�W]
		ld		[SCA_INFO_ENEMY_POWER3 + enemy_info0], a
		jp		nz, boss8_damage
		ld		a, [SCA_INFO_XL2 + enemy_info0]	; �E�p�[�c�̕\��������
		ld		e, a
		ld		a, [SCA_INFO_YL2 + enemy_info0]
		ld		d, a
		call	draw_boss8_delete
		jp		boss8_destroy

boss8_center_damage::							; �����p�[�c�Ƀ_���[�W��^�����ꍇ
		ld		a, [SCA_INFO_ENEMY_POWER5 + enemy_info0]
		dec		a								; �����p�[�c�Ƀ_���[�W��^���� [���@�� ShotPower �Ɋւ�炸 1�_���[�W]
		ld		[SCA_INFO_ENEMY_POWER5 + enemy_info0], a
		jp		nz, boss8_damage
		ld		a, [SCA_INFO_XL3 + enemy_info0]	; �E�p�[�c�̕\��������
		ld		e, a
		ld		a, [SCA_INFO_YL3 + enemy_info0]
		ld		d, a
		call	draw_boss8_center_delete
		ld		hl, [se_bomb2]							; �{�X�j��
		call	bgmdriver_play_sound_effect
		; �_����ǉ�
		ld		de, 0x9999								; �����p�[�c�j��� 9999�_
		call	score_add
		call	top_score_check
		call	score_update
		; �{�X�j��v�����s
		call	enemy_boss_destroy_request
		; BGM���t��~
		call	bgmdriver_stop
		ret

boss8_destroy:
		ld		a, [SCA_INFO_ENEMY_POWER + enemy_info0]		; ���p�[�c
		ld		b, a
		ld		a, [SCA_INFO_ENEMY_POWER3 + enemy_info0]	; �E�p�[�c
		or		a, b
		jp		nz, boss8_destroy_skip1
		; �����p�[�c�̏�Ԃ�������
		xor		a, a
		ld		[SCA_INFO_ENEMY_STATE_L + enemy_info0], a
		ld		[SCA_INFO_ENEMY_STATE_H + enemy_info0], a
		ld		[SCA_INFO_ENEMY_STATE_L2 + enemy_info0], a
		ld		[SCA_INFO_ENEMY_STATE_H2 + enemy_info0], a
boss8_destroy_skip1:
		ld		hl, [se_bomb2]					; �{�X�j��
		call	bgmdriver_play_sound_effect
		; �_����ǉ�
		ld		de, 0x5000								; ���E�p�[�c�j��� 5000�_
		call	score_add
		call	top_score_check
		call	score_update
		ret

boss8_damage:
		ld		hl, [se_damage]					; �_���[�W��^��������炷
		call	bgmdriver_play_sound_effect
		; �_����ǉ�
		ld		de, 0x0003						; �{�X�_���[�W�� 3�_
		call	score_add
		call	top_score_check
		call	score_update
		ret

boss8_no_damage:								; ���X�{�X���_���[�W��H���Ȃ������ɒe����������
		ld		[ix + SCA_INFO_YH], 212			; ���@�e ��\��
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; ���˒��łȂ�
		ld		hl, [se_no_damage]				; �_���[�W��^�����Ȃ�����炷
		call	bgmdriver_play_sound_effect
		ret

; -----------------------------------------------------------------------------
;	�G�Ǝ��@�e���Փ˂����Ƃ��̏���
;	input:
;		ix	...	�Փ˂����G���̃A�h���X
;		iy	...	�Փ˂����e���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, f, b, d, e, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
enemy_clash:
		; �G�Ƀ_���[�W��^����
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		sub		a, [iy + SCA_INFO_SHOT_POWER]
		; �G����ꂽ������
		jr		c, enemy_clash_enemy_destroy			; ��ꂽ�ꍇ�A�G����������
		jr		z, enemy_clash_enemy_destroy			; ��ꂽ�ꍇ�A�G����������
		ld		[ix + SCA_INFO_ENEMY_POWER], a				; �ϋv�͂��X�V
		; �G�Ƀ_���[�W��^�������𔭐�
		ld		hl, [se_damage]
		call	bgmdriver_play_sound_effect
		; �_����ǉ�
		ld		de, 0x2									; �G�_���[�W�� 2�_
		call	score_add
		call	top_score_check
		call	score_update
enemy_clash_shot_destroy:
		; �Փ˂������@�e�����ł�����
		ld		[iy + SCA_INFO_YH], 212					; ��\��
		ld		[iy + SCA_INFO_SHOT_POWER], 0			; ���˒��łȂ�
		ret
		; �G��������
enemy_clash_enemy_destroy:
		; �G�������������𔭐�
		ld		hl, [se_bomb]
		call	bgmdriver_play_sound_effect
		; �Փ˂������@�e�����ł�����
		ld		[iy + SCA_INFO_YH], 212					; ��\��
		ld		[iy + SCA_INFO_SHOT_POWER], 0			; ���˒��łȂ�
		; �G�𔚔��p�^�[���ɕύX����
		call	enemy_bomb
		; �_����ǉ�
		ld		de, 0x100								; �G�j��� 100�_
		call	score_add
		call	top_score_check
		call	score_update
		ret

; -----------------------------------------------------------------------------
;	�{�X�Ǝ��@�e���Փ˂����Ƃ��̏���
;	input:
;		iy	...	�Փ˂����e���̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, f, b, d, e, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
enemy_boss1_clash:
		ld		ix, enemy_info0
		; �G�Ƀ_���[�W��^����
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		sub		a, [iy + SCA_INFO_SHOT_POWER]
		; �G����ꂽ������
		jr		c, enemy_boss1_clash_enemy_destroy			; ��ꂽ�ꍇ�A�G����������
		jr		z, enemy_boss1_clash_enemy_destroy			; ��ꂽ�ꍇ�A�G����������
		ld		[ix + SCA_INFO_ENEMY_POWER], a				; �ϋv�͂��X�V
		; �G�Ƀ_���[�W��^�������𔭐�
		ld		hl, [se_damage]
		call	bgmdriver_play_sound_effect
enemy_boss1_clash_shot_destroy:
		; �Փ˂������@�e�����ł�����
		ld		[iy + SCA_INFO_YH], 212					; ��\��
		ld		[iy + SCA_INFO_SHOT_POWER], 0				; ���˒��łȂ�
		; �_����ǉ�
		ld		de, 0x0003								; �{�X�_���[�W�� 3�_
		call	score_add
		call	top_score_check
		call	score_update
		ret
		; �G��������
enemy_boss1_clash_enemy_destroy:
		; �G�������������𔭐�
		ld		hl, [se_bomb2]
		call	bgmdriver_play_sound_effect
		; �Փ˂������@�e�����ł�����
		ld		[iy + SCA_INFO_YH], 212					; ��\��
		ld		[iy + SCA_INFO_SHOT_POWER], 0				; ���˒��łȂ�
		; �G�𔚔��p�^�[���ɕύX����
		call	enemy_bomb
		ld		ix, enemy_info1
		call	enemy_bomb
		ld		ix, enemy_info2
		call	enemy_bomb
		ld		ix, enemy_info3
		call	enemy_bomb
		; �_����ǉ�
		ld		de, 0x5000								; �{�X�j��� 5000�_
		call	score_add
		call	top_score_check
		call	score_update
		; �{�X�j��v�����s
		call	enemy_boss_destroy_request
		; BGM���t��~
		call	bgmdriver_stop
		ret

; -----------------------------------------------------------------------------
;	���@�e�ƒn�㕨�̂����蔻��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
plant_clash::
		ld		ix, shot_info0
		call	plant_clash_sub

		ld		ix, shot_info1
		call	plant_clash_sub

		ld		ix, shot_info2
		call	plant_clash_sub
		ret

; -----------------------------------------------------------------------------
;	���@�e�ƒn�㕨�̂����蔻��[�P��]
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
plant_clash_sub:
		; �e�̍��W
		ld		a, 4
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		l, [ix + SCA_INFO_YH]
		ld		a, l
		cp		a, 8
		ret		c								; ��[�ɔ������������Ă���n�㕨�͔j��ł��Ȃ�
		cp		a, 212
		ret		z								; ���˒��łȂ���Δj��ł��Ȃ�
		; ���W�ʒu�̃L�����N�^�擾
		call	background_get_char
		and		a, 0xFC
		cp		a, 76
		jp		z, check_item					; �n�㕨�Ȃ�p���[�A�b�v�A�C�e���o������֔��
		inc		hl								; �����E�ׂ����ׂ�
		ld		a, [hl]
		and		a, 0xFC
		cp		a, 76
		ret		nz
check_item:
		; �p���[�A�b�v�A�C�e������
		ld		a, [item_timing]
		inc		a
		and		a, 31
		ld		[item_timing], a
		jr		nz, plant_clash_sub_skip1		; �n�㕨�� 32�j�󂷂邽�тɃA�C�e���o��
		; �p���[�A�b�v�A�C�e�����o��������
		push	hl
		call	random
		ld		a, l
		pop		hl
		and		a, 8
		ld		a, 80							; �X�s�[�h�A�b�v�A�C�e��
		jr		z, plant_clash_sub_skip2
		ld		a, 84							; �V���b�g�p���[�A�b�v�A�C�e��
		jr		plant_clash_sub_skip2
plant_clash_sub_skip1:
		; �n�㕨��j�󂷂�
		ld		a, 72
plant_clash_sub_skip2:
		call	background_put_char
		; �G�������������𔭐�
		ld		hl, [se_bomb]
		call	bgmdriver_play_sound_effect
		; �Փ˂������@�e�����ł�����
		ld		[ix + SCA_INFO_YH], 212			; ��\��
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; ���˒��łȂ�
		; �_����ǉ�
		ld		de, 0x50						; �n�㕨�j��� 50�_
		call	score_add
		call	top_score_check
		call	score_update
		ret

; -----------------------------------------------------------------------------
;	���@�ƃA�C�e���̂����蔻��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
player_get_item_check::
		; ���@�̍��W
		ld		ix, player_info
		ld		a, 8
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		a, 8
		add		a, [ix + SCA_INFO_YH]
		ld		l, a
		cp		a, 8
		ret		c								; ��[�ɔ������������Ă���A�C�e���͎��Ȃ�
		cp		a, 192-8
		ret		nc								; ���[�ɔ������������Ă���A�C�e���͎��Ȃ�
		; ���W�ʒu�̃L�����N�^�擾
		call	background_get_char
		and		a, 0xFC
		cp		a, 88
		ret		nc								; �A�C�e������Ȃ��ꍇ�͔�����
		cp		a, 80
		ret		c								; �A�C�e������Ȃ��ꍇ�͔�����
		; �n�㕨��j�󂷂�
		push	af
		ld		a, 72
		call	background_put_char
		; �A�C�e���擾�̉��𔭐�������
		ld		hl, [se_get_item]
		call	bgmdriver_play_sound_effect
		; �_����ǉ�
		ld		de, 0x100						; �A�C�e���擾�� 100�_
		call	score_add
		call	top_score_check
		call	score_update
		; �X�s�[�h�A�b�v���V���b�g�p���[�A�b�v�̔���
		pop		af
		cp		a, 80
		jp		z, player_speed_up
		jp		player_shot_power_up

; -----------------------------------------------------------------------------
;	12x12 �����蔻��
;	input:
;		ix	...	����ΏۂP
;		iy	...	����ΏۂQ
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: �Փ˂��Ă���
;	break
;		a, f
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_clash_12x12:
		; A �� ABS[ ix[SCA_INFO_XH] - iy[SCA_INFO_XH] ]
		ld		a, [ix + SCA_INFO_XH]
		sub		a, [iy + SCA_INFO_XH]
		jr		nc, check_clash_12x12_skip1
		neg
check_clash_12x12_skip1:
		; if a >= 12 then return
		cp		a, 12
		ret		nc
		; A �� ABS[ ix[SCA_INFO_YH] - iy[SCA_INFO_YH] ]
		ld		a, [ix + SCA_INFO_YH]
		sub		a, [iy + SCA_INFO_YH]
		jr		nc, check_clash_12x12_skip2
		neg
check_clash_12x12_skip2:
		; if a >= 12 then return
		cp		a, 12
		ret

; -----------------------------------------------------------------------------
;	�{�X1 �����蔻��
;	input:
;		ix	...	�{�X
;		iy	...	�V���b�g
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: �Փ˂��Ă���
;	break
;		a, f
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_clash_boss1:
		; A �� ix[SCA_INFO_XH] - iy[SCA_INFO_XH]
		ld		a, [iy + SCA_INFO_XH]
		sub		a, [ix + SCA_INFO_XH]
		cp		a, -10
		jp		m, check_clash_boss1_no_crash
		cp		a, 22
		jp		p, check_clash_boss1_no_crash
		; A �� ix[SCA_INFO_YH] - iy[SCA_INFO_YH]
		ld		a, [iy + SCA_INFO_YH]
		sub		a, [ix + SCA_INFO_YH]
		cp		a, -16
		jp		m, check_clash_boss1_no_crash
		cp		a, 32
		jp		p, check_clash_boss1_no_crash
		scf
		ret
check_clash_boss1_no_crash:
		or		a, a
		ret

; -----------------------------------------------------------------------------
;	4x4 �����蔻��
;	input:
;		ix	...	����ΏۂP
;		iy	...	����ΏۂQ
;	output
;		c�t���O ... 0: �Փ˂��Ă��Ȃ�, 1: �Փ˂��Ă���
;	break
;		a, f
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
check_clash_4x4:
		; A �� ABS[ ix[SCA_INFO_XH] - iy[SCA_INFO_XH] ]
		ld		a, [ix + SCA_INFO_XH]
		sub		a, [iy + SCA_INFO_XH]
		jr		nc, check_clash_4x4_skip1
		neg
check_clash_4x4_skip1:
		; if a >= 4 then return
		cp		a, 4
		ret		nc
		; A �� ABS[ ix[SCA_INFO_YH] - iy[SCA_INFO_YH] ]
		ld		a, [ix + SCA_INFO_YH]
		sub		a, [iy + SCA_INFO_YH]
		jr		nc, check_clash_4x4_skip2
		neg
check_clash_4x4_skip2:
		; if a >= 4 then return
		cp		a, 4
		ret

; -----------------------------------------------------------------------------
;	�G�����蔻�胋�[�`���̂���ւ�
;	input:
;		a	...	�����蔻�胋�[�`���̔ԍ�
;				0: �ʏ�̓G
;				1: �{�X1
;	output
;		�Ȃ�
;	break
;		a, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
change_crash_check_routine::
		cp		a, 1
		jp		c, change_crash_check_routine1
		jp		z, change_crash_check_routine2
		jp		change_crash_check_routine3

change_crash_check_routine1:
		ld		hl, check_enemy_normal_clash
		ld		[crash_check_routine], hl
		ret

change_crash_check_routine2:
		ld		hl, check_enemy_boss1_clash
		ld		[crash_check_routine], hl
		ret

change_crash_check_routine3:
		ld		hl, check_enemy_boss8_clash
		ld		[crash_check_routine], hl
		ret

; -----------------------------------------------------------------------------
;	�����蔻�胋�[�`���̃A�h���X
; -----------------------------------------------------------------------------
crash_check_routine:
		dw		enemy_clash

; -----------------------------------------------------------------------------
;	�p���[�A�b�v�A�C�e���o���^�C�~���O
; -----------------------------------------------------------------------------
item_timing::
		db		0
