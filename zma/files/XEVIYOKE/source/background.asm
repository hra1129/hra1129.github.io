; =============================================================================
;	XEVI”ð‚¯ for MSX2
; -----------------------------------------------------------------------------
;	2019/8/30	t.hara
; =============================================================================

; =============================================================================
;	Background
; =============================================================================
	scope		background
background_initialize::
	ld			a, 192-8
	ld			[parts_dy], a
	ld			a, 1
	ld			[parts_dest_page], a

	ld			hl, 37 * 32
	ld			[map_address], hl

	ld			b, 13
background_initialize_loop_y:
	push		bc
	di
	call		get_map
	ei
	xor			a, a
	ld			[parts_dx], a
	ld			a, 10
	ld			[background_parts_index], a
	ld			b, 12
background_initialize_loop_x:
	push		bc
	ld			a, [background_parts_index]
	ld			hl, background_parts
	add			a, l
	jp			nc, bi_skip0
	inc			h
bi_skip0:
	ld			l, a
	ld			a, [hl]
	push		hl
	call		set_sx_and_sy
	ld			hl, parts
	di
	call		wait_vdp_command
	call		run_vdp_command
	ei
	ld			a, [parts_dx]
	add			a, 8
	ld			[parts_dx], a
	ld			a, [background_parts_index]
	inc			a
	ld			[background_parts_index], a
	pop			hl

	pop			bc
	djnz		background_initialize_loop_x
	ld			a, [parts_dy]
	sub			a, 8
	ld			[parts_dy], a
	pop			bc
	djnz		background_initialize_loop_y

	ld			a, 192-8
	ld			[parts_dy], a
	xor			a, a
	ld			[parts_dx], a
	ld			[parts_dest_page], a
	ld			[background_parts_index], a
	ld			[map_address], a
	ld			[map_address+1], a

	; initialize background
	di
	ld			hl, 16 * 30
bg_loop:
	push		hl
	call		background
	pop			hl
	dec			hl
	ld			a, l
	or			a, h
	jp			nz, bg_loop
	ei
	ret

background::
	; Is this timing to get MAP information?
	ld			a, [background_parts_index]
	or			a, a
	call		z, get_map

put_parts:
	; get number of 1st parts
	ld			hl, background_parts
	add			a, l
	jp			nc, skip0
	inc			h
skip0:
	ld			l, a
	ld			a, [hl]
	push		hl
	call		set_sx_and_sy
	ld			hl, parts
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, 2
	ld			[parts_dest_page], a
	ld			hl, parts
	call		wait_vdp_command
	call		run_vdp_command
	xor			a, a
	ld			[parts_dest_page], a
	ld			a, [parts_dx]
	add			a, 8
	ld			[parts_dx], a
	pop			hl

	; get number of 2nd parts
	inc			hl
	ld			a, [hl]
	call		set_sx_and_sy
	ld			hl, parts
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, 2
	ld			[parts_dest_page], a
	ld			hl, parts
	call		wait_vdp_command
	call		run_vdp_command
	xor			a, a
	ld			[parts_dest_page], a
	ld			a, [parts_dx]
	add			a, 8
	ld			[parts_dx], a

	; set next index
	ld			a, [background_parts_index]
	inc			a
	inc			a
	and			a, 31
	ld			[background_parts_index], a
	ret			nz

	; set next line
	ld			a, [parts_dy]
	sub			a, 8
	ld			[parts_dy], a
	ret

get_map:
	ld			hl, [map_address]
	ld			a, h				; VRAM address bit14
	rlca
	rlca
	and			a, 1
	ld			c, IO_VDP_PORT1
	or			a, 0b0000_00110		; VRAM address (bit16, bit15) = (1,1)
	di
	out			[c], a
	ld			a, 14 | 0x80
	out			[c], a

	ld			a, h
	and			a, 0b0011_1111
	out			[c], l				; VRAM address bit7...bit0
	out			[c], a				; VRAM address bit13...bit8
	ei

	ld			bc, 32
	add			hl, bc
	ld			a, h
	cp			a, 0x60				; if( hl == 0x6000 ) {
	jp			nz, get_map_skip	;     hl = 0;
	ld			hl, 0x0000			; }
get_map_skip:
	ld			[map_address], hl

	ld			bc, (32 << 8) | IO_VDP_PORT0
	ld			hl, background_parts
	inir

	ld			c, IO_VDP_PORT1
	ld			a, [reg14sav]
	di
	out			[c], a
	ld			a, 14 | 0x80
	out			[c], a
	ei
	ld			a, [background_parts_index]
	ret

set_sx_and_sy:
	; SX = (A & 31) << 3
	ld			b, a
	and			a, 31
	rlca
	rlca
	rlca
	ld			[parts_sx], a

	; SY = (A & ~31) >> 2
	ld			a, b
	and			a, ~31
	rrca
	rrca
	ld			[parts_sy], a
	ret

map_address:
	dw			0x0000

background_parts_index:
	db			0
background_parts::
	db			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	db			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

parts:
parts_sx:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
parts_sy:
	db			0				; R#34	SYh
	db			1				; R#35	SYh
parts_dx:
	db			0				; R#36	DXl
	db			0				; R#37	DXh
parts_dy:
	db			192-8			; R#38	DYl
parts_dest_page:
	db			0				; R#39	DYh
	db			8				; R#40	NXl
	db			0				; R#41	NXh
	db			8				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD
	endscope
