; =============================================================================
;	XEVIîÇØ for MSX2
; -----------------------------------------------------------------------------
;	2019/9/15	t.hara
; =============================================================================

; =============================================================================
;	Title screen
; =============================================================================
	scope		title_process
title_process::
	; initialize VDP registers
	ld			c, IO_VDP_PORT1
	di
	;	R#2 = 0b0001_1111 : Set display page to 0
	ld			a, 0b0001_1111
	out			[c], a
	ld			a, 2 | 0x80
	out			[c], a

	; Hide sprite
	ld			a, 0b1101_1111					; Change Sprite attribute table to 0xEE00
	out			[c], a
	ld			a, 5 | 0x80
	out			[c], a

	;	Palette
	ld			c, IO_VDP_PORT1
	ld			a, 4					; Palette#
	out			[c], a
	ld			a, 16 | 0x80
	out			[c], a					; R#16 = palette#
	inc			c

	ld			a, 0x30
	out			[c], a
	xor			a, a
	out			[c], a
	ei

	; Update SCORE
	call		put_score_initializer
	ld			hl, score_copy
	call		wait_vdp_command
	call		run_vdp_command

	; Clear Screen
	ld			hl, clear_screen
	call		wait_vdp_command
	call		run_vdp_command

	; Make up title logo (horizontal magnify)
	ld			a, 192
	ld			[title_logo_copy1_sx], a
	xor			a, a
	ld			[title_logo_copy1_dx], a
	ld			[blink_push_trigger_flag], a
	ld			b, 64
make_up_title_logo_loop1:
	push		bc

	ld			hl, title_logo_copy1
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, [title_logo_copy1_dx]
	inc			a
	ld			[title_logo_copy1_dx], a
	ld			hl, title_logo_copy1
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, [title_logo_copy1_sx]
	inc			a
	ld			[title_logo_copy1_sx], a
	ld			a, [title_logo_copy1_dx]
	inc			a
	ld			[title_logo_copy1_dx], a
	pop			bc
	djnz		make_up_title_logo_loop1

	; Make up title logo (vertical magnify)
	ld			a, 192 + 23
	ld			[title_logo_copy2_sy], a
	ld			a, 192 + 47
	ld			[title_logo_copy2_dy], a
	ld			b, 24
make_up_title_logo_loop2:
	push		bc

	ld			hl, title_logo_copy2
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, [title_logo_copy2_dy]
	dec			a
	ld			[title_logo_copy2_dy], a
	ld			hl, title_logo_copy2
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, [title_logo_copy2_sy]
	dec			a
	ld			[title_logo_copy2_sy], a
	ld			a, [title_logo_copy2_dy]
	dec			a
	ld			[title_logo_copy2_dy], a
	pop			bc
	djnz		make_up_title_logo_loop2

	ld			a, 254
	ld			[title_logo_copy3_dx], a
	ld			a, 20
	ld			[blink_push_trigger], a

	;	R#1 BL bit = 1 (enable display)
	call		wait_vdp_command
	di
	ld			c, IO_VDP_PORT1
	ld			a, [reg1sav]
	or			a, 0b0100_0000
	out			[c], a
	ld			a, 1 | 0x80
	out			[c], a
	ei

	; Title loop
title_loop:
	; check trigger
	xor			a, a
	push		bc
	call		gttrig
	pop			bc
	or			a, a
	jp			nz, title_finalize		; if( strig(0) != 0 ) goto title_finalize

	xor			a, a
	inc			a
	push		bc
	call		gttrig
	pop			bc
	or			a, a
	jp			nz, title_finalize		; if( strig(1) != 0 ) goto title_finalize

	; randomizer update
	call		random

	; display "push trigger"
	ld			a, [blink_push_trigger]
	dec			a
	ld			[blink_push_trigger], a
	jp			nz, skip_blink_push_trigger
	ld			a, 20
	ld			[blink_push_trigger], a
	call		update_push_trigger
skip_blink_push_trigger:

	; display title logo
	ld			a, [title_logo_copy3_dx]
	cp			a, 64
	jp			z, title_loop_skip

	ld			hl, title_logo_copy3
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, [title_logo_copy3_dx]
	dec			a
	dec			a
	ld			[title_logo_copy3_dx], a
title_loop_skip:

	call		title_wait
	jp			title_loop

title_tick::
	ld			a, 1
	ld			[title_wait_flag], a
	ret

title_finalize:
	ld			hl, se_start
	call		bgmdriver_play_sound_effect
	ld			b, 50
title_finalize_loop:
	push		bc
	call		update_push_trigger
	call		title_wait
	pop			bc
	djnz		title_finalize_loop

	; R#1 BL bit = 0 (disable display)
	di
	ld			c, IO_VDP_PORT1
	ld			a, [reg1sav]
	and			a, 0b1011_1111
	out			[c], a
	ld			a, 1 | 0x80
	out			[c], a
	ei
	ret

title_wait:
	ld			a, [title_wait_flag]
	or			a, a
	jr			z, title_wait
	xor			a, a
	ld			[title_wait_flag], a
	ret

update_push_trigger:
	ld			a, [blink_push_trigger_flag]
	xor			a, 1
	ld			[blink_push_trigger_flag], a
	jp			nz, erase_push_trigger
	ld			a, 0b1101_0000				; HMMM command (Block Copy)
	jp			draw_push_trigger
erase_push_trigger:
	ld			a, 0b1100_0000				; HMMV command (BOX Fill)
draw_push_trigger:
	ld			[push_trigger_copy_cmd], a
	ld			hl, push_trigger_copy
	call		wait_vdp_command
	call		run_vdp_command
	ret

title_wait_flag:
	db			0
blink_push_trigger:
	db			0
blink_push_trigger_flag:
	db			0

title_logo_copy1:
title_logo_copy1_sx:
	db			192				; R#32	SXl
	db			0				; R#33	SXh
	db			88				; R#34	SYl
	db			1				; R#35	SYh
title_logo_copy1_dx:
	db			0				; R#36	DXl
	db			0				; R#37	DXh
	db			192				; R#38	DYl
	db			1				; R#39	DYh
	db			1				; R#40	NXl
	db			0				; R#41	NXh
	db			24				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44	CLR
	db			0				; R#45	ARG
	db			0b1001_0000		; R#46	CMD	LMMM

title_logo_copy2:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
title_logo_copy2_sy:
	db			192 + 23		; R#34	SYl
	db			1				; R#35	SYh
	db			0				; R#36	DXl
	db			0				; R#37	DXh
title_logo_copy2_dy:
	db			192 + 47		; R#38	DYl
	db			1				; R#39	DYh
	db			128				; R#40	NXl
	db			0				; R#41	NXh
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44	CLR
	db			0				; R#45	ARG
	db			0b1101_0000		; R#46	CMD	HMMM

title_logo_copy3:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
	db			192				; R#34	SYl
	db			1				; R#35	SYh
title_logo_copy3_dx:
	db			254				; R#36	DXl
	db			0				; R#37	DXh
	db			56				; R#38	DYl
	db			0				; R#39	DYh
	db			128				; R#40	NXl
	db			0				; R#41	NXh
	db			48				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44	CLR
	db			0				; R#45	ARG
	db			0b1101_0000		; R#46	CMD	HMMM

score_copy:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
	db			64				; R#34	SYl
	db			1				; R#35	SYh
	db			0				; R#36	DXl
	db			0				; R#37	DXh
	db			0				; R#38	DYl
	db			0				; R#39	DYh
	db			0				; R#40	NXl
	db			1				; R#41	NXh
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44	CLR
	db			0				; R#45	ARG
	db			0b1110_0000		; R#46	CMD	YMMM

push_trigger_copy:
	db			80				; R#32	SXl
	db			0				; R#33	SXh
	db			80				; R#34	SYl
	db			1				; R#35	SYh
	db			80				; R#36	DXl
	db			0				; R#37	DXh
	db			160				; R#38	DYl
	db			0				; R#39	DYh
	db			96				; R#40	NXl
	db			0				; R#41	NXh
	db			8				; R#42	NYl
	db			0				; R#43	NYh
	db			0x00			; R#44	CLR
	db			0				; R#45	ARG
push_trigger_copy_cmd:
	db			0b1101_0000		; R#46	CMD	HMMM or HMMV

clear_screen:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
	db			0				; R#34	SYl
	db			0				; R#35	SYh
	db			0				; R#36	DXl
	db			0				; R#37	DXh
	db			16				; R#38	DYl
	db			0				; R#39	DYh
	db			0				; R#40	NXl
	db			1				; R#41	NXh
	db			240				; R#42	NYl
	db			0				; R#43	NYh
	db			0x00			; R#44	CLR
	db			0				; R#45	ARG
	db			0b1100_0000		; R#46	CMD	HMMV

se_start:
	db			240					; priority [è¨Ç≥Ç¢ï˚Ç™óDêÊ]
	db			BGM_SE_VOL
	db			12
	db			BGM_SE_FREQ
	dw			500
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_FREQ
	dw			400
	db			BGM_SE_WAIT
	db			7
	db			BGM_SE_FREQ
	dw			300
	db			BGM_SE_WAIT
	db			10
	db			BGM_SE_FREQ
	dw			200
	db			BGM_SE_WAIT
	db			15
	db			BGM_SE_VOL
	db			8
	db			BGM_SE_FREQ
	dw			400
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_FREQ
	dw			300
	db			BGM_SE_WAIT
	db			7
	db			BGM_SE_FREQ
	dw			200
	db			BGM_SE_WAIT
	db			10
	db			BGM_SE_FREQ
	dw			100
	db			BGM_SE_WAIT
	db			15
	db			BGM_SE_VOL
	db			4
	db			BGM_SE_FREQ
	dw			300
	db			BGM_SE_WAIT
	db			5
	db			BGM_SE_FREQ
	dw			200
	db			BGM_SE_WAIT
	db			7
	db			BGM_SE_FREQ
	dw			100
	db			BGM_SE_WAIT
	db			10
	db			BGM_SE_FREQ
	dw			50
	db			BGM_SE_WAIT
	db			15
	db			BGM_SE_END
	endscope
