; =============================================================================
;	vdp sender for CS5 format decoder
; -----------------------------------------------------------------------------
;	2019/9/30	t.hara
; =============================================================================

				scope	cs5decode_vdp
; =============================================================================
;	cs5decode_vdp_begin
;	input)
;		a .... ROPÉRÅ[Éh 0b0000Å`0b1111
;	output)
;		none
;	break)
;		all
; =============================================================================
cs5decode_vdp_begin::
				and		a, 0x0F
				or		a, VDPCMD_LMMC
				ld		[vdpcmd_cmd], a
				ret

; =============================================================================
;	cs5decode_vdp_set_palette
;	input)
;		hl ..... palette table address
;	output)
;		none
;	break)
;		af, bc, hl
; =============================================================================
cs5decode_vdp_set_palette::
				; VDP R#16 = 0 (palette index)
				xor		a, a
				ld		c, IO_VDP_PORT1
				ld		b, 16 | 0x80
				di
				out		[c], a
				out		[c], b
				ei
				inc		c					; c = IO_VDP_PORT2
				ld		b, 32
				otir
				ret

; =============================================================================
;	cs5decode_vdp_set_image_size
;	input)
;		bc .... êÖïΩâÊëfêî(2Å`512 ÇÃãÙêî)
;		de .... êÇíºâÊëfêî(1Å`212)
;	output)
;		none
;	break)
;		all
; =============================================================================
cs5decode_vdp_set_image_size::
				ld		[vdpcmd_nx], bc
				ld		[vdpcmd_ny], de
				ld		hl, write_one_pixel_first
				ld		[cs5decode_vdp_write_one_pixel + 1], hl
				ret

; =============================================================================
;	cs5decode_vdp_write_one_pixel
;	input)
;		a .... âÊëfíl (0Å`15)
;	output)
;		none
;	break)
;		all
; =============================================================================
cs5decode_vdp_write_one_pixel::
				jp		write_one_pixel_first

	write_one_pixel_first:
				ld		[vdpcmd_clr], a
				di
				;	VDP R#15 = 2
				ld			a, 2
				ld			bc, ((0x80 | 15) << 8) | IO_VDP_PORT1
				out			[c], a
				out			[c], b
	wait_vdp_command_loop1:
				in			a, [c]
				and			a, 1
				jp			nz, wait_vdp_command_loop1
				;	VDP R#15 = 0
				out			[c], a
				out			[c], b
				;	VDP R#17 = 36
				ld			a, 36
				out			[c], a
				ld			a, 0x80 | 17
				out			[c], a
				;	R#32~46 (15 registers)
				ld			hl, vdpcmd
				ld			bc, (15 << 8) | IO_VDP_PORT3
				otir
				ei

				ld		hl, write_one_pixel_next
				ld		[cs5decode_vdp_write_one_pixel + 1], hl
				ret

	write_one_pixel_next:
				ld			d, a
				di
				;	VDP R#15 = 2
				ld			a, 2
				ld			bc, ((0x80 | 15) << 8) | IO_VDP_PORT1
				out			[c], a
				out			[c], b
	wait_vdp_command_loop2:
				in			a, [c]
				rrca
				jp			nc, wait_vdp_command_loop2_exit
				rlca
				rlca
				jp			nc, wait_vdp_command_loop2
	wait_vdp_command_loop2_exit:
				;	VDP R#15 = 0
				xor			a, a
				out			[c], a
				out			[c], b
				;	VDP R#44 = d
				ld			a, 44 | 0x80
				out			[c], d
				out			[c], a
				ei
				ret

; =============================================================================
;	cs5decode_file_end
;	input)
;		none
;	output)
;		none
;	break)
;		all
; =============================================================================
cs5decode_vdp_end::
				ret

; =============================================================================
;	work area
; =============================================================================
	first_flag:
				db			0
	vdpcmd:
				dw			0				; R#36, R#37	DX
				dw			0				; R#38, R#39	DY
	vdpcmd_nx:
				dw			0				; R#40, R#41	NX
	vdpcmd_ny:
				dw			0				; R#42, R#43	NY
	vdpcmd_clr:
				db			0				; R#44			CLR
				db			0				; R#45			ARG
	vdpcmd_cmd:
				db			VDPCMD_LMMC		; R#46			CMD
				endscope
