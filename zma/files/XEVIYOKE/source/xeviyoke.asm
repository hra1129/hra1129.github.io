; =============================================================================
;	XEVI”ð‚¯ for MSX2
; -----------------------------------------------------------------------------
;	2019/8/30	t.hara
; =============================================================================

	include		"msx.asm"

	bsave_header	start_address, end_address, entry_point

hsync_intr_adjust	:= 3

	org			0xA000
start_address:
; =============================================================================
;	entry point
; =============================================================================
	scope		entry_point
entry_point::
	call		initializer
loop:
	call		title_phase
	call		main_phase
	jp			loop
	endscope

; =============================================================================
;	initializer
; =============================================================================
	scope		initializer
initializer::
	call	bgmdriver_initialize
	call	interrupt_initializer
	di
	; initialize sprite pattern
	call		sd_initializer

	; initialize VDP registers
	ld			c, IO_VDP_PORT1
	;	R#9 = R#9 and 0b0111_1111 : Change to 192line mode
	ld			a, [REG9SAV]
	and			a, 0b0111_1111
	ld			[REG9SAV], a
	out			[c], a
	ld			a, 9 | 0x80
	out			[c], a
	;	R#5 = 0b1110_1111 : Set sprite attribute table base address (A14-A9)
	ld			a, 0b1110_1111
	out			[c], a
	ld			a, 5 | 0x80
	out			[c], a
	;	R#11 = 0b0000_0011 : Set sprite attribute table base address (A16-A15)
	ld			a, 0b0000_0011
	out			[c], a
	ld			a, 11 | 0x80
	out			[c], a
	;	R#6 = 0b0011_1111 : Set pattern generator table base address (A16-A11)
	ld			a, 0b0011_1111
	out			[c], a
	ld			a, 6 | 0x80
	out			[c], a
	ei
	ret
	endscope

; =============================================================================
;	title_phase
; =============================================================================
	scope		title_phase
title_phase::
	call		title_interrupt_initializer
	call		title_process
	ret
	endscope

; =============================================================================
;	main_phase
; =============================================================================
	scope		main_phase
main_phase::
	xor			a, a
	ld			[vscroll], a
	ld			[vsync_flag], a
	dec			a
	ld			[vscroll_next], a
	ld			a, 2
	ld			[draw_page], a

	call		background_initialize
	call		player_initializer
	call		flag_initializer
	call		bigchar_initializer
	call		shot_initializer
	call		main_interrupt_initializer
	;	Clear SCORE
	ld			hl, 0
	ld			[score], hl
	call		put_score_initializer
	;	BGM start
	ld			hl, bgm_data
	call		bgmdriver_play
	;	R#1 BL bit = 1 (enable display)
	di
	ld			c, IO_VDP_PORT1
	ld			a, [reg1sav]
	or			a, 0b0100_0000
	out			[c], a
	ld			a, 1 | 0x80
	out			[c], a
	ei

main_loop::
	;	draw phage
	ld			a, [draw_page]
	xor			a, 2
	ld			[draw_page], a
	;	vertical scroll
	ld			a, [vscroll_next]
	ld			[vscroll], a
	dec			a
	ld			[vscroll_next], a
	;	wait vsync
	call		wait_vsync
	;	Background
	call		background
skip_vscroll:

	;	Update score view
	call		put_score
	;	Sprite initializer for frame
	call		sd_begin_frame
	;	BigChar move 1
	call		bigchar_bg_move_1
	;	Player move
	call		player_move
	;	BigChar move 2
	call		bigchar_bg_move_2
	;	Flag move
	call		flag_process
	;	BigChar move 3
	call		bigchar_bg_move_3
	;	Background
	call		background
	;	wait vsync
	call		wait_vsync
	;	BigChar move 1
	call		bigchar_bg_move_4
	;	Big character move
	call		shot_process
	;	BigChar move 2
	call		bigchar_bg_move_5
	call		bigchar_sp_move
	;	BigChar move 3
	call		bigchar_bg_move_6
	;	Sprite doubler
	call		sd_finalize
	;	end check
	ld			a, [player_is_crashed]
	cp			a, 1
	jp			nz, main_loop

	;	R#1 BL bit = 0 (disable display)
	di
	ld			c, IO_VDP_PORT1
	ld			a, [reg1sav]
	and			a, 0b1011_1111
	out			[c], a
	ld			a, 1 | 0x80
	out			[c], a
	ei
	ret

wait_vsync:
	;	vsync timing check
	ld			a, [vsync_flag]
	or			a, a
	jp			z, wait_vsync
	xor			a, a
	ld			[vsync_flag], a
	ret

	endscope

	include "player.asm"
	include "flag.asm"
	include "bigchar.asm"
	include "shot.asm"
	include "background.asm"
	include "score.asm"
	include "title.asm"
	include "vdp_control.asm"
	include "interrupt.asm"

; =============================================================================
;	random
;	input)
;		none
;	output)
;		a ... random value 0...255
;	break)
;		af, b
; =============================================================================
	scope		random
random::
	ld			a, [random_seed1]
	rlca
	ld			b, a
	ld			a, [random_seed2]
	rrca
	rrca
	xor			a, b
	dec			a
	ld			[random_seed1], a
	ld			a, b
	inc			a
	ld			[random_seed2], a
	ret
random_seed1:
	db			0b1001_1101
random_seed2:
	db			0b1010_0011
	endscope

; =============================================================================
;	sprite
; =============================================================================
	include		"sprite_doubler.asm"

; =============================================================================
;	BGM driver
; =============================================================================
	include		"bgmdriver.asm"
bgm_data::
	include		"bgm.asm"

; =============================================================================
;	data area
; =============================================================================
vscroll::
	db			0						; Vertical scroll position for MAIN area.
vscroll_sp::
vscroll_next::
	db			255
draw_page::
	db			2
vsync_flag::
	dw			0
end_address::
