; -----------------------------------------------------------------------------
;	SCA main program
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�G���g���[�|�C���g
; -----------------------------------------------------------------------------
		org		0x8400

sca_main::
		ld		sp, 0x8300						; �X�^�b�N�|�C���^��������[BASIC�ɂ͖߂�Ȃ�]
		call	game_init						; �e�평����
sca_main_loop:
		call	sca_title						; �^�C�g�����
		call	state_init						; �Q�[���J�n���̏�����
		call	game_start						; ���C�����[�v
		call	update_score_ranking			; �n�C�X�R�A�X�V
		or		a, a
		call	nz, name_entry					; �n�C�X�R�A�o�^�L�O���O����
		call	bgmdriver_stop
		jr		sca_main_loop

; -----------------------------------------------------------------------------
;	����������
; -----------------------------------------------------------------------------
game_init:
		; MSX turboR �̏ꍇ�� Z80 ���[�h�ɐ؂�ւ���
		ld		a, [MSXVER]
		cp		a, 3
		jp		c, game_init_skip
		ld		a, 0x80						; �������[�hLED���������AZ80���[�h�ɐ؂�ւ���
		call	CHGCPU
game_init_skip:
		; �X�v���C�g��������
		call	sprite_init
		; BGM Driver ������
		call	bgmdriver_initialize
		; ���荞�ݏ�����������
		call	vsync_init
		ret

; -----------------------------------------------------------------------------
;	�Q�[����Ԃ̏�����
; -----------------------------------------------------------------------------
state_init:
		; �_����������
		call	score_init
		; ���@��������
		ld		ix, player_info
		call	player_init
		; �G��������
		call	enemy_init
		; �A�C�e�������^�C�~���O������
		xor		a, a
		ld		[item_timing], a
		ret

; -----------------------------------------------------------------------------
;	�X�e�[�W��Ԃ̏�����
; -----------------------------------------------------------------------------
stage_init:
		; ���@��������
		ld		ix, player_info
		call	player_stage_init
		; ���@�e��������
		ld		ix, shot_info0
		call	shot_init
		ld		ix, shot_info1
		call	shot_init
		ld		ix, shot_info2
		call	shot_init
		; �G��������
		call	enemy_init_stage
		; �p���b�g��ݒ�
		ld		a, [stage_number]
		and		a, 7
		call	change_palette
		xor		a, a
		call	fade_palette
		ret

; -----------------------------------------------------------------------------
;	���C�����[�v
; -----------------------------------------------------------------------------
game_start::
		; �e�평����
		call	stage_init							; �Q�[���̓�����Ԃ�������
		call	background_init_game_screen			; �Q�[�����̔w�i��������
		ld		a, [stage_number]
		call	background_draw_stage_x				; "STAGEx" ��\��
		xor		a, a
		ld		[stage_clear_flag], a				; �X�e�[�W�N���A�t���O
		; �Q�[��BGM���t�J�n
		ld		a, [stage_number]
		and		a, 7
		rlca
		ld		l, a
		ld		h, 0
		ld		de, SCA_BGM_TABLE_ADR					; stage �� BGM �����t�J�n
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		call	bgmdriver_play
game_loop:
		; �Q�[���N���A�������H
		ld		a, [stage_clear_flag]
		or		a, a
		jp		nz, game_stage_clear				; �X�e�[�W�N���A���Q�[���I�[�o�[
		; ���݂̃^�C�}�[�l��ۑ����Ă���
		ld		a, [software_timer]
		ld		[last_timer], a
		; ���@�e�ƒn�㕨�̂����蔻�菈��
		call	plant_clash
		; ���@�ƃA�C�e���̂����蔻�菈��
		call	player_get_item_check
		; �w�i�X�N���[������
		call	background_scroll
		call	background_transfer
		; ���@�̈ړ�����
		ld		ix, player_info
		call	player_move
		; ���@�e�̔��ˏ���
		ld		ix, player_info
		ld		iy, shot_info0
		call	shot_fire
		; ���@�e�̈ړ�����
		ld		ix, shot_info0
		call	shot_move
		ld		ix, shot_info1
		call	shot_move
		ld		ix, shot_info2
		call	shot_move
		; ���@�̓����蔻�菈��
		call	check_player_clash
		; �G�̓����蔻�菈��
		call	check_enemy_clash
		; �G�̈ړ�����
		ld		ix, enemy_info0
		call	enemy_move
		; �G�̏o������
		ld		ix, player_info
		ld		iy, enemy_info0
		call	enemy_start
		; �G�e�̈ړ�����
		ld		ix, eshot_info
		call	enemy_shot_move
		; �X�v���C�g�̕\���X�V����
		ld		ix, player_info
		call	sprite_update
		; �^�C�}�[�l���ω�����܂őҋ@����
		ld		a, [last_timer]
		ld		hl, software_timer
game_wait_loop:
		cp		a, [hl]
		jp		nz, game_loop
		jr		game_wait_loop

; -----------------------------------------------------------------------------
;	�X�e�[�W�N���A����
; -----------------------------------------------------------------------------
game_stage_clear:
		; �Q�[���I�[�o�[�����f
		dec		a
		jp		nz, game_gameover					; �t���O���Q�[���I�[�o�[�������Ă���ꍇ
		ld		a, [player_shield]					; ���@�ƃ{�X�������ɉ�ꂽ�ꍇ���Q�[���I�[�o�[
		or		a, a
		jp		z, game_gameover
		; �{�X�j��BGM
		ld		hl, [bgm_clear]
		call	bgmdriver_play
		; �{�X�j��BGM��~�҂�
game_stage_clear_loop:
		call	bgmdriver_check_playing
		jr		nz, game_stage_clear_loop
		; ��ʂ��N���A
		call	background_init_stage_clear_screen	; ��ʍ������N���A
		call	sprite_all_clear					; �X�v���C�g���N���A
		; ���ԑ҂�
		ld		hl, 30								; 0.5�b
		call	vsync_wait_time
		; �X�e�[�W�N���A�{�[�i�X 10000�_���Z
		ld		b, 10
game_stage_clear_score_loop:
		push	bc
		; 1000�_���Z
		ld		de, 0x1000
		call	score_add
		call	top_score_check
		call	score_update
		; ���ʉ�
		ld		hl, [se_damage]
		call	bgmdriver_play_sound_effect
		; ���ԑ҂�
		ld		hl, 10								; 0.1�b
		call	vsync_wait_time
		pop		bc
		djnz	game_stage_clear_score_loop
		; �V�[���h���P���Z
		ld		a, [player_shield]
		cp		a, 9
		jr		z, game_shield_max
		inc		a
		ld		[player_shield], a
		call	background_update_player_info
game_shield_max:
		; ���ԑ҂�
		ld		hl, 60*3							; 3�b
		call	vsync_wait_time
		; �G��i��������
		call	enemy_next_stage
		; ���̃X�e�[�W�J�n
		jp		game_start

; -----------------------------------------------------------------------------
;	�Q�[���I�[�o�[����
; -----------------------------------------------------------------------------
game_gameover:
		; ��ʂ��N���A
		call	background_init_gameover_screen
		call	sprite_all_clear					; �X�v���C�g���N���A
		; �Q�[���I�[�o�[�a�f�l
		ld		hl, [bgm_gameover]
		call	bgmdriver_play
		; BGM���t�I���҂�
game_gameover_loop:
		call	bgmdriver_check_playing
		jr		nz, game_gameover_loop
		; ���ԑ҂�
		ld		hl, 60*1							; 1�b
		call	vsync_wait_time
		ret

; -----------------------------------------------------------------------------
;	�X�e�[�W�N���A�֑J��
; -----------------------------------------------------------------------------
goto_next_stage::
		ld		a, 1
		ld		[stage_clear_flag], a
		ret

; -----------------------------------------------------------------------------
;	�Q�[���I�[�o�[�֑J��
; -----------------------------------------------------------------------------
goto_gameover::
		ld		a, 2
		ld		[stage_clear_flag], a
		ret

; -----------------------------------------------------------------------------
;	���[�N�G���A
; -----------------------------------------------------------------------------
last_timer:
		db		0

stage_clear_flag:
		db		0					; 0: �ʏ�, 1: �X�e�[�W�N���A, 2: �Q�[���I�[�o�[

; -----------------------------------------------------------------------------
;	���@���
; -----------------------------------------------------------------------------
player_info::
		repeat i, SCA_INFO_SIZE
			db	0		; 0
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 1
		endr
enemy_info0::
		repeat i, SCA_INFO_SIZE
			db	0		; 2
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 3
		endr
enemy_info1::
		repeat i, SCA_INFO_SIZE
			db	0		; 4
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 5
		endr
enemy_info2::
		repeat i, SCA_INFO_SIZE
			db	0		; 6
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 7
		endr
enemy_info3::
		repeat i, SCA_INFO_SIZE
			db	0		; 8
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 9
		endr
enemy_info4::
		repeat i, SCA_INFO_SIZE
			db	0		; 10
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 11
		endr
enemy_info5::
		repeat i, SCA_INFO_SIZE
			db	0		; 12
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 13
		endr
eshot_info::
		repeat i, SCA_INFO_SIZE
			db	0		; 14	0
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 15	1
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 16	2
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 17	3
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 18	4
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 19	5
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 20	6
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 21	7
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 22	8
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 23	9
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 24	10
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 25	11
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 26	12
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 27	13
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 28	14
		endr
shot_info0::
		repeat i, SCA_INFO_SIZE
			db	0		; 29
		endr
shot_info1::
		repeat i, SCA_INFO_SIZE
			db	0		; 30
		endr
shot_info2::
		repeat i, SCA_INFO_SIZE
			db	0		; 31
		endr
