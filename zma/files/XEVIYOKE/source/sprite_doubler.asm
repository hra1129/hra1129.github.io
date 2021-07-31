; =============================================================================
;	SpriteDoubler for MSX2
; -----------------------------------------------------------------------------
;	2019/8/31	t.hara
; =============================================================================

sprite_attribute_table0			:= 0x1EE00	; hide sprite
sprite_attribute_table1			:= 0x1F200	; double buffer1
sprite_attribute_table2			:= 0x1F600	; double buffer2
sprite_pattern_generator_table	:= 0x1F800
sprite_color_table1				:= sprite_attribute_table1 - 512
sprite_color_table2				:= sprite_attribute_table2 - 512

sprite_hide_line		:= 216

	scope		sprite_doubler
; =============================================================================
;	sd_initializer
;	input)
;		none
;	output)
;		none
;	break)
;		af, hl
; =============================================================================
	scope		sd_initializer
sd_initializer::
	ld			c, IO_VDP_PORT1

	di
	; set sprite pattern to sprite generator table
	ld			a, sprite_pattern_generator_table >> 14
	ld			[reg14sav], a
	out			[c], a
	ld			a, 14 | 0x80
	out			[c], a

	ld			hl, (sprite_pattern_generator_table & 0x3FFF) | 0x4000
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

	; set sprite_attribute_table0
	ld			hl, (sprite_attribute_table0 & 0x3FFF) | 0x4000
	di
	out			[c], l
	out			[c], h
	ei
	dec			c
	ld			a, sprite_hide_line
	out			[c], a
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
;		af, c, hl
; =============================================================================
	scope		sd_begin_frame
sd_begin_frame::
	ld			hl, (sprite_attribute_table1 - 0x0200) & 0x3FFF | 0x4000
	ld			[sprite_color_table1_ptr], hl

	ld			hl, (sprite_attribute_table2 - 0x0200) & 0x3FFF | 0x4000
	ld			[sprite_color_table2_ptr], hl

	ld			hl, sprite_attribute_table1 & 0x3FFF | 0x4000
	ld			[sprite_attribute_table1_ptr], hl

	ld			hl, sprite_attribute_table2 & 0x3FFF | 0x4000
	ld			[sprite_attribute_table2_ptr], hl

	xor			a, a
	ld			[sprite_count1], a
	ld			[sprite_count2], a

	; R#14
	di
	ld			a, [draw_page]			; if draw_page == 1 then R#14 = 0b0000_0111
	rlca								;                   else R#14 = 0b0000_0011
	or			a, 0b0000_0011
	ld			c, IO_VDP_PORT1
	out			[c], a
	ld			[reg14sav], a
	ld			a, 14 | 0x80
	out			[c], a
	ei
	ret
	endscope

; =============================================================================
;	sd_change_attriblute0
;	input)
;		none
;	output)
;		none
;	break)
;		a, c
; =============================================================================
	scope		sd_change_attribute0
sd_change_attribute0::
	ld			c, IO_VDP_PORT1
	;	R#5 : Set sprite attribute table base address (A14-A9)
	ld			a, ( ((sprite_attribute_table0 >> 9) << 2) | 0b0000_0011 ) & 255
	out			[c], a
	ld			a, 5 | 0x80
	out			[c], a
	;	R#11 : Set sprite attribute table base address (A16-A15)
	ld			a, sprite_attribute_table0 >> 15
	out			[c], a
	ld			a, 11 | 0x80
	out			[c], a
	ret
	endscope

; =============================================================================
;	sd_change_attriblute1
;	input)
;		none
;	output)
;		none
;	break)
;		a, c
; =============================================================================
	scope		sd_change_attribute1
sd_change_attribute1::
	ld			c, IO_VDP_PORT1
	;	R#5 : Set sprite attribute table base address (A14-A9)
	ld			a, ( ((sprite_attribute_table1 >> 9) << 2) | 0b0000_0011 ) & 255
	out			[c], a
	ld			a, 5 | 0x80
	out			[c], a
	; R#11 = 0b0000_00?1: ? is display_page ( 0: page0, 1: page2 )
	ld			a, [draw_page]
	xor			a, 2
	inc			a
	out			[c], a
	ld			a, 11 | 0x80
	out			[c], a
	ret
	endscope

; =============================================================================
;	sd_change_attriblute2
;	input)
;		none
;	output)
;		none
;	break)
;		a, c
; =============================================================================
	scope		sd_change_attribute2
sd_change_attribute2::
	ld			c, IO_VDP_PORT1
	;	R#5 : Set sprite attribute table base address (A14-A9)
	ld			a, ( ((sprite_attribute_table2 >> 9) << 2) | 0b0000_0011 ) & 255
	out			[c], a
	ld			a, 5 | 0x80
	out			[c], a
	ret
	endscope

; =============================================================================
;	sd_put_sprite_pair
;	input)
;		b ......... sprite pattern#
;		d ......... X position
;		e ......... Y position
;		hl ........ sprite color data address
;		vscroll_sp ... next value of R#23
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
	scope		sd_put_sprite_pair
sd_put_sprite_pair::
	ld			a, e
	cp			a, 104
	jp			nc, put_lower
put_upper:
	;	check sprite count overflow in upper
	ld			a, [sprite_count1]
	cp			a, 32
	jp			nc, skip_put_upper
	inc			a
	inc			a
	ld			[sprite_count1], a

	;	write attribute table
	push		bc
	push		hl
	ld			hl, [sprite_attribute_table1_ptr]
	call		set_vram_address
	pop			hl

	;	adjust vertical position for vscroll_sp
	ld			a, [vscroll_sp]
	add			a, e
	dec			a

	;	adjust vertical position for sprite_hide_line
	cp			a, sprite_hide_line
	jp			nz, put_upper_s1
	inc			a
put_upper_s1:
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

	;	write color table
	push		hl
	ld			hl, [sprite_color_table1_ptr]
	call		set_vram_address
	ld			bc, 16 * 2
	add			hl, bc
	ld			[sprite_color_table1_ptr], hl
	pop			hl

	;	write color table
	push		hl
	ld			bc, ((16 * 2) << 8) | IO_VDP_PORT0
	otir

	ld			hl, [sprite_attribute_table1_ptr]
	ld			bc, 4 * 2
	add			hl, bc
	ld			[sprite_attribute_table1_ptr], hl
	pop			hl
	pop			bc

skip_put_upper:
	ld			a, e
	cp			a, 104 - 16
	ret			c
put_lower:
	;	check sprite count overflow in upper
	ld			a, [sprite_count2]
	cp			a, 32
	ret			nc
	inc			a
	inc			a
	ld			[sprite_count2], a

	;	write attribute table
	push		hl
	ld			hl, [sprite_attribute_table2_ptr]
	call		set_vram_address
	pop			hl

	;	adjust vertical position for vscroll_sp
	ld			a, [vscroll_sp]
	add			a, e
	dec			a

	;	adjust vertical position for sprite_hide_line
	cp			a, sprite_hide_line
	jp			nz, put_lower_s1
	inc			a
put_lower_s1:
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

	;	write color table
	push		hl
	ld			hl, [sprite_color_table2_ptr]
	call		set_vram_address
	ld			bc, 16 * 2
	add			hl, bc
	ld			[sprite_color_table2_ptr], hl
	pop			hl

	;	write color table
	ld			bc, ((16 * 2) << 8) | IO_VDP_PORT0
	otir

	ld			hl, [sprite_attribute_table2_ptr]
	ld			bc, 4 * 2
	add			hl, bc
	ld			[sprite_attribute_table2_ptr], hl
	ret
	endscope

; =============================================================================
;	sd_put_sprite_single
;	input)
;		b ......... sprite pattern#
;		d ......... X position
;		e ......... Y position
;		hl ........ sprite color data address
;		vscroll_sp ... next value of R#23
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
	scope		sd_put_sprite_single
sd_put_sprite_single::
	ld			a, e
	cp			a, 104
	jp			nc, put_lower
put_upper:
	;	check sprite count overflow in upper
	ld			a, [sprite_count1]
	cp			a, 32
	jp			nc, skip_put_upper
	inc			a
	ld			[sprite_count1], a

	;	write attribute table
	push		bc
	push		hl
	ld			hl, [sprite_attribute_table1_ptr]
	call		set_vram_address
	pop			hl

	;	adjust vertical position for vscroll_sp
	ld			a, [vscroll_sp]
	add			a, e
	dec			a

	;	adjust vertical position for sprite_hide_line
	cp			a, sprite_hide_line
	jp			nz, put_upper_s1
	inc			a
put_upper_s1:
	out			[c], a			;	Y position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], d			;	X position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], b			;	Pattern#

	;	write color table
	push		hl
	ld			hl, [sprite_color_table1_ptr]
	call		set_vram_address
	ld			bc, 16
	add			hl, bc
	ld			[sprite_color_table1_ptr], hl
	pop			hl

	;	write color table
	push		hl
	ld			bc, (16 << 8) | IO_VDP_PORT0
	otir

	ld			hl, [sprite_attribute_table1_ptr]
	ld			bc, 4
	add			hl, bc
	ld			[sprite_attribute_table1_ptr], hl
	pop			hl
	pop			bc

skip_put_upper:
	ld			a, e
	cp			a, 104 - 16
	ret			c
put_lower:
	;	check sprite count overflow in upper
	ld			a, [sprite_count2]
	cp			a, 32
	ret			nc
	inc			a
	ld			[sprite_count2], a

	;	write attribute table
	push		hl
	ld			hl, [sprite_attribute_table2_ptr]
	call		set_vram_address
	pop			hl

	;	adjust vertical position for vscroll_sp
	ld			a, [vscroll_sp]
	add			a, e
	dec			a

	;	adjust vertical position for sprite_hide_line
	cp			a, sprite_hide_line
	jp			nz, put_lower_s1
	inc			a
put_lower_s1:
	out			[c], a			;	Y position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], d			;	X position
	nop							;	VDP wait
	nop							;	VDP wait
	nop							;	VDP wait
	out			[c], b			;	Pattern#

	;	write color table
	push		hl
	ld			hl, [sprite_color_table2_ptr]
	call		set_vram_address
	ld			bc, 16
	add			hl, bc
	ld			[sprite_color_table2_ptr], hl
	pop			hl

	;	write color table
	ld			bc, (16 << 8) | IO_VDP_PORT0
	otir

	ld			hl, [sprite_attribute_table2_ptr]
	ld			bc, 4
	add			hl, bc
	ld			[sprite_attribute_table2_ptr], hl
	ret
	endscope

; =============================================================================
;	sd_finalize
;	input)
;		none
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
	scope		sd_finalize
sd_finalize::
	;	check sprite count overflow in upper
	ld			a, [sprite_count1]
	cp			a, 32
	jp			nc, skip_put_upper

	ld			hl, [sprite_attribute_table1_ptr]
	call		set_vram_address

	ld			a, sprite_hide_line
	out			[c], a			;	Y position
skip_put_upper:

	;	check sprite count overflow in upper
	ld			a, [sprite_count2]
	cp			a, 32
	ret			nc

	ld			hl, [sprite_attribute_table2_ptr]
	call		set_vram_address

	ld			a, sprite_hide_line
	out			[c], a			;	Y position
	ret
	endscope

; =============================================================================
;	data area
; =============================================================================
sprite_count1:
	db			0
sprite_count2:
	db			0
sprite_color_table1_ptr:
	dw			0
sprite_color_table2_ptr:
	dw			0
sprite_attribute_table1_ptr:
	dw			0
sprite_attribute_table2_ptr:
	dw			0

	include "sprite_data.asm"
	endscope
