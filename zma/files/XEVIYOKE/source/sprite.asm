; =============================================================================
;	Sprite for MSX2
; -----------------------------------------------------------------------------
;	2019/9/14	t.hara
; =============================================================================

sprite_attribute_table0			:= 0xEE00	; hide sprite
sprite_attribute_table1			:= 0xF200	; double buffer1
sprite_attribute_table2			:= 0xF600	; double buffer2
sprite_pattern_generator_table	:= 0xF800
sprite_color_table1				:= sprite_attribute_table1 - 512
sprite_color_table2				:= sprite_attribute_table2 - 512

sprite_hide_line		:= 216

	scope		sprite
; =============================================================================
;	sp_initializer
;	input)
;		none
;	output)
;		none
;	break)
;		af, hl
; =============================================================================
	scope		sp_initializer
sp_initializer::
	ld			c, IO_VDP_PORT1
	ld			hl, (sprite_pattern_generator_table & 0x3FFF) | 0x4000
	di
	out			[c], l
	out			[c], h
	ei
	dec			c
	ld			hl, player_sprite_pattern1
	ld			b, 32 * (2 + 2 * 8 + 1 + 1) - 512
	otir
	nop							; wait VDP
	otir
	nop							; wait VDP
	otir
	inc			c

	ld			hl, (sprite_attribute_table0 & 0x3FFF) | 0x4000
	di
	out			[c], l
	out			[c], h
	ei
	dec			c
	ld			a, sprite_hide_line
	out			[c], a
	inc			c

	ld			hl, (sprite_color_table1 & 0x3FFF) | 0x4000
	call		sp_set_color
	ld			hl, (sprite_color_table2 & 0x3FFF) | 0x4000
sp_set_color:
	di
	out			[c], l
	out			[c], h
	ei
	dec			c
	; set color of Sprite#0 and #1
	ld			hl, player_sprite_color1
	ld			b, 16 * 2
	otir
	; set color of Sprite#2...#14
	ld			a, 13
sp_set_color_shot_color_loop:
	ld			hl, ando_shot_sprite_color1
	ld			b, 16
	otir
	dec			a
	jp			nz, sp_set_color_shot_color_loop
	; set color of Sprite#15
	ld			hl, flag_sprite_color1
	ld			b, 16
	otir
	; set color of Sprite#16...31
	ld			hl, ando_part1_sprite_color1
	ld			b, 0		; is 256
	otir
	inc			c
	ret
	endscope

; =============================================================================
;	sp_begin_frame
;	input)
;		none
;	output)
;		none
;	break)
;		af, hl
; =============================================================================
	scope		sp_begin_frame
sp_begin_frame::
	ld			a, [draw_page]			; if draw_page == 1 then R#14 = 0b0000_0111
	or			a, a
	jp			z, sp_begin_frame_skip0

	; case of draw_page is 0
	ld			hl, sprite_attribute_table1 & 0x3FFF | 0x4000
	ld			[sprite_attribute_table_ptr], hl
	ret

sp_begin_frame_skip0:
	; case of draw_page is 1
	ld			hl, sprite_attribute_table2 & 0x3FFF | 0x4000
	ld			[sprite_attribute_table_ptr], hl
	ret
	endscope

; =============================================================================
;	sp_put_sprite_pair
;	input)
;		a ......... sprite# (0...31)
;		b ......... sprite pattern# (0...255)
;		d ......... X position
;		e ......... Y position
;		vscroll_sp ... next value of R#23
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
	scope		sp_put_sprite_pair
sp_put_sprite_pair::
	;	write attribute table
	push		bc
	ld			b, 0
	rlca
	rlca
	ld			c, a
	ld			hl, [sprite_attribute_table_ptr]
	add			hl, bc
	pop			bc

	;	adjust vertical position for vscroll_sp
	ld			a, [vscroll_sp]
	add			a, e
	dec			a

	;	adjust vertical position for sprite_hide_line
	cp			a, sprite_hide_line
	jp			nz, put_s1
	inc			a
put_s1:
	call		set_vram_address
	out			[c], a			;	Y position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], d			;	X position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], b			;	Pattern#
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], b			;	Dummy
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], a			;	Y position
	nop							;	VDP wait
	nop							;	VDP wait
	inc			b				;	increment and VDP wait
	out			[c], d			;	X position
	inc			b				;	increment and VDP wait
	inc			b				;	increment and VDP wait
	inc			b				;	increment and VDP wait
	out			[c], b			;	Pattern#
	ret
	endscope

; =============================================================================
;	sp_put_sprite_single
;	input)
;		a ......... sprite# (0...31)
;		b ......... sprite pattern#
;		d ......... X position
;		e ......... Y position
;		vscroll_sp ... next value of R#23
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
	scope		sp_put_sprite_single
sp_put_sprite_single::
	;	write attribute table
	push		bc
	ld			b, 0
	rlca
	rlca
	ld			c, a
	ld			hl, [sprite_attribute_table_ptr]
	add			hl, bc
	pop			bc

	;	adjust vertical position for vscroll_sp
	ld			a, [vscroll_sp]
	add			a, e
	dec			a

	;	adjust vertical position for sprite_hide_line
	cp			a, sprite_hide_line
	jp			nz, put_s1
	inc			a
put_s1:
	call		set_vram_address
	out			[c], a			;	Y position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], d			;	X position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], b			;	Pattern#
	ret
	endscope

; =============================================================================
;	sp_sprite_hide
;	input)
;		a ......... sprite# (0...31)
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
	scope		sp_sprite_hide
sp_sprite_hide::
	;	write attribute table
	push		bc
	ld			b, 0
	rlca
	rlca
	ld			c, a
	ld			hl, [sprite_attribute_table_ptr]
	add			hl, bc
	pop			bc

	;	adjust vertical position for sprite_hide_line
	ld			a, sprite_hide_line
	call		set_vram_address
	out			[c], a			;	Y position
	ret
	endscope

; =============================================================================
;	data area
; =============================================================================
sprite_count:
	db			0
sprite_color_table_ptr:
	dw			0
sprite_attribute_table_ptr:
	dw			0

	include "sprite_data.asm"
	endscope
