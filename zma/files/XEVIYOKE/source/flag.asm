; =============================================================================
;	XEVIîÇØ for MSX2
; -----------------------------------------------------------------------------
;	2019/9/15	t.hara
; =============================================================================

; =============================================================================
;	flag move
; =============================================================================
	scope		flag_process
flag_initializer::
	ld			a, 50
	ld			[flag_wait_counter], a
	xor			a, a
	ld			[flag_enable], a
	ret

flag_process::
	ld			a, [flag_enable]
	or			a, a
	jp			z, flag_wait

flag_move:
	ld			a, [flag_y]
	inc			a
	cp			a, 192
	jp			c, flag_normal_state

	; change to disable
	xor			a, a
	ld			[flag_enable], a
	ld			a, 192

flag_normal_state:
	ld			e, a
	ld			[flag_y], a

	ld			a, [flag_x]
	ld			d, a

	ld			b, 76
	ld			hl, flag_sprite_color1
	call		sd_put_sprite_single

	ld			a, [player_is_crashed]
	or			a, a
	ret			nz						; Player is already crashed.

check_catch_the_flag_y:
	ld			a, [player_y]
	ld			c, a
	ld			a, [flag_y]
	sub			a, c
	jp			nc, check_catch_the_flag_y_skip0
	neg
check_catch_the_flag_y_skip0:
	cp			a, 8
	ret			nc

check_catch_the_flag_x:
	ld			a, [player_x]
	ld			c, a
	ld			a, [flag_x]
	sbc			a, c
	jp			nc, check_catch_the_flag_x_skip0
	neg
check_catch_the_flag_x_skip0:
	cp			a, 8
	ret			nc

increment_score:
	ld			hl, [score]
	inc			hl
	ld			[score], hl

	xor			a, a
	ld			[flag_enable], a

	ld			hl, se_get_item
	call		bgmdriver_play_sound_effect
	ret

flag_wait:
	ld			a, [flag_wait_counter]
	dec			a
	ld			[flag_wait_counter], a
	ret			nz
	ld			a, 50
	ld			[flag_wait_counter], a

appear_the_flag:
	call		random
	cp			a, 240
	jp			c, not_adjust_random
	and			a, 15		; adjust random value, when random value is over 240.
not_adjust_random:
	ld			[flag_x], a

	xor			a, a
	ld			[flag_y], a
	inc			a
	ld			[flag_enable], a
	ret

flag_wait_counter:
	db			50
flag_enable:
	db			0			; 0: disable, 1: enable
flag_x:
	db			0
flag_y:
	db			0

se_get_item:
		db		32					; priority [è¨Ç≥Ç¢ï˚Ç™óDêÊ]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		30
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		25
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		20
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		10
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		30
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		25
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		20
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		10
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_END
	endscope
