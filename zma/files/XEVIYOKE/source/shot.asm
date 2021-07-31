; =============================================================================
;	XEVIîÇØ for MSX2
; -----------------------------------------------------------------------------
;	2019/9/16	t.hara
; =============================================================================

number_of_shots	:= 32

; =============================================================================
;	shot move
; =============================================================================
	scope		shot_process
shot_initializer::
	ld			hl, shot_table
	xor			a, a
	ld			[hl], a
	ld			[shot_round_robin], a
	ld			a, 50
	ld			[shot_appear_timing], a
	ld			[shot_appear_timing_speed], a

	; zero fill
	ld			de, shot_table + 1
	ld			bc, sa_size * number_of_shots - 1
	ldir
	ret

shot_process::
	ld			hl, [bigchar_y_sp]
	ld			bc, 56
	or			a, a
	sbc			hl, bc
	jp			nz, shot_silence

	ld			a, [shot_appear_timing]
	or			a, a
	jp			z, skip_shot_appear_timing

	dec			a
	ld			[shot_appear_timing], a

skip_shot_appear_timing:
	ld			ix, shot_table
	ld			b, number_of_shots
	ld			a, [shot_round_robin]
shot_one_process:
	ld			c, a
	push		bc
	; check active the current shot
	ld			a, [ix + sa_enable]
	or			a, a
	jp			z, shot_is_disable

	; move X position
	ld			c, [ix + sa_delta_x + 0]
	ld			b, [ix + sa_delta_x + 1]
	ld			l, [ix + sa_x_position + 0]
	ld			h, [ix + sa_x_position + 1]
	xor			a, a
	add			hl, bc
	adc			a, b
	add			hl, bc
	adc			a, b
	add			hl, bc
	adc			a, b
	jp			nz, shot_is_disable
	ld			[ix + sa_x_position + 0], l
	ld			[ix + sa_x_position + 1], h
	ld			d, h

	; move Y position
	ld			c, [ix + sa_delta_y + 0]
	ld			b, [ix + sa_delta_y + 1]
	ld			l, [ix + sa_y_position + 0]
	ld			h, [ix + sa_y_position + 1]
	xor			a, a
	add			hl, bc
	adc			a, b
	add			hl, bc
	adc			a, b
	add			hl, bc
	adc			a, b
	jp			nz, shot_is_disable
	ld			[ix + sa_y_position + 0], l
	ld			[ix + sa_y_position + 1], h
	ld			e, h

put_shot:
	pop			bc
	push		bc
	ld			hl, ando_shot_sprite_color1	; Sprite color table address
	ld			b, 72						; Pattern#  : B = 72
	call		sd_put_sprite_single
put_shot_exit:

check_crash_y:
	ld			a, [ix + sa_y_position + 1]
	ld			e, a
	ld			a, [player_y]
	sub			a, e
	jp			nc, check_crash_y_skip0
	neg
check_crash_y_skip0:
	cp			a, 8
	jp			nc, exit_crash

check_crash_x:
	ld			a, [ix + sa_x_position + 1]
	ld			d, a
	ld			a, [player_x]
	sbc			a, d
	jp			nc, check_crash_x_skip0
	cpl
check_crash_x_skip0:
	cp			a, 8
	jp			c, crash

exit_crash:
	ld			bc, sa_size
	add			ix, bc

	pop			bc
	ld			a, c
	inc			a
	cp			a, number_of_shots
	jp			nz, put_shot_skip
	xor			a, a
put_shot_skip:
	dec			b
	jp			nz, shot_one_process

prepare_next_frame:
	sub			a, 7
	jp			nc, prepare_next_frame_skip
	add			a, number_of_shots
prepare_next_frame_skip:
	ld			[shot_round_robin], a
	ret			nz

	ld			a, [shot_appear_timing_speed]
	or			a, a
	ret			z
	dec			a
	ld			[shot_appear_timing_speed], a
	ret

crash:
	ld			a, [player_is_crashed]
	or			a, a
	jp			nz, exit_crash				; Player was already chashed.

	ld			a, 50
	ld			[player_is_crashed], a
	call		bgmdriver_stop
	ld			hl, se_crash
	call		bgmdriver_play_sound_effect
	jp			exit_crash

shot_is_disable:
	ld			a, [shot_appear_timing]
	or			a, a
	jp			z, put_new_shot

	xor			a, a
	ld			[ix + sa_enable], a			; change to disable
	jp			put_shot_exit

put_new_shot:
	inc			a
	ld			[ix + sa_enable], a			; change to enable

	ld			a, [shot_appear_timing_speed]
	ld			[shot_appear_timing], a

	ld			a, [shot_type]
	inc			a
	and			a, 7
	ld			[shot_type], a

	srl			a
	jp			c, appear_direct_shot

;-----------------------------------------
appear_round_shot:
	call		set_appear_position

	call		random
	and			a, 15						; direction ID is random (0...15)
	rlca
	rlca
	ld			c, a
	ld			b, 0
	ld			hl, cos_sin_table
	add			hl, bc
	ld			c, [hl]
	inc			hl
	ld			b, [hl]
	inc			hl
	ld			[ix + sa_delta_x + 0], c
	ld			[ix + sa_delta_x + 1], b
	ld			c, [hl]
	inc			hl
	ld			b, [hl]
	inc			hl
	ld			[ix + sa_delta_y + 0], c
	ld			[ix + sa_delta_y + 1], b
	jp			put_shot

;-----------------------------------------
appear_direct_shot:
	call		set_appear_position			; d = sx; e = sy;
	push		de

appear_direct_shot_get_dx:
	ld			a, [player_x]
	ld			l, a
	ld			c, d
	xor			a, a
	ld			h, a
	ld			b, a
	sbc			hl, bc						; hl = player_x - sx
	ld			[ix + sa_delta_x + 0], l
	ld			[ix + sa_delta_x + 1], h

appear_direct_shot_abs_dx:
	ld			a, l
	inc			h
	jp			nz, appear_direct_shot_abs_dx_plus
	neg
appear_direct_shot_abs_dx_plus:
	ld			d, a

appear_direct_shot_get_dy:
	ld			a, [player_y]
	ld			l, a
	ld			c, e
	xor			a, a
	ld			h, a
	ld			b, a
	sbc			hl, bc						; hl = player_y - sy
	ld			[ix + sa_delta_y + 0], l
	ld			[ix + sa_delta_y + 1], h

appear_direct_shot_abs_dy:
	ld			a, l
	inc			h
	jp			nz, appear_direct_shot_abs_dy_plus
	neg
appear_direct_shot_abs_dy_plus:

	cp			a, d
	jp			nc, appear_direct_shot_gt_dy
	ld			a, d
appear_direct_shot_gt_dy:					;	a = max( abs(dx), abs(dy) )
	ld			d, [ix + sa_delta_x + 0]	;	d = dx
	ld			e, [ix + sa_delta_y + 0]	;	e = dy

	ld			h, 7
appear_direct_shot_calc_vector:
	cp			a, 0x80
	jp			nc, appear_direct_shot_calc_vector_exit
	rlca
	rlc			d
	rlc			e
	dec			h
	jp			nz, appear_direct_shot_calc_vector
appear_direct_shot_calc_vector_exit:

	ld			[ix + sa_delta_x + 0], d
	ld			[ix + sa_delta_y + 0], e
	pop			de
	jp			put_shot

shot_silence:
	ret

set_appear_position:
	call		random
	and			a, 3						; appear position ID is random (0...3)
	rlca
	ld			c, a
	ld			b, 0
	ld			hl, shot_start_table
	add			hl, bc
	ld			d, [hl]
	inc			hl
	ld			[ix + sa_x_position + 1], d
	ld			e, [hl]
	inc			hl
	ld			[ix + sa_y_position + 1], e
	xor			a, a
	ld			[ix + sa_x_position + 0], a
	ld			[ix + sa_y_position + 0], a
	ret

SHOT_ATTRIBUTE	macro
	db			0				; 0: disable, 1: enable
	dw			0				; delta X
	dw			0				; X position
	dw			0				; delta Y
	dw			0				; Y position
			endm

sa_enable		= 0
sa_delta_x		= 1
sa_x_position	= 3
sa_delta_y		= 5
sa_y_position	= 7
sa_size			= 9

shot_table:
	repeat I, number_of_shots
		SHOT_ATTRIBUTE
	endr

shot_round_robin::
	db			0

shot_appear_timing:
	db			0

shot_appear_timing_speed:
	db			50

shot_type:
	db			0

shot_start_table:
	db			104, 80
	db			136, 80
	db			136, 112
	db			104, 112

cos_sin_table:
	dw			244,	74
	dw			197,	162
	dw			120,	225
	dw			25,		254
	dw			-75,	244
	dw			-163,	197
	dw			-226,	120
	dw			-255,	25
	dw			-245,	-75
	dw			-198,	-163
	dw			-121,	-226
	dw			-26,	-255
	dw			74,		-245
	dw			162,	-198
	dw			225,	-121
	dw			254,	-26

se_crash:
	db			128				; priority [è¨Ç≥Ç¢ï˚Ç™óDêÊ]
	db			BGM_SE_VOL
	db			12
	db			BGM_SE_FREQ
	dw			32768				; 32768 Ç…Ç∑ÇÈÇ∆ TONE OFF
	db			BGM_SE_NOISE_FREQ
	db			20 + 0x80
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_NOISE_FREQ
	db			8 + 0x80
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_NOISE_FREQ
	db			28 + 0x80
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_NOISE_FREQ
	db			12 + 0x80
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_NOISE_FREQ
	db			31 + 0x80
	db			BGM_SE_WAIT
	db			10
	db			BGM_SE_NOISE_FREQ
	db			15 + 0x80
	db			BGM_SE_WAIT
	db			10
	db			BGM_SE_END

	endscope
