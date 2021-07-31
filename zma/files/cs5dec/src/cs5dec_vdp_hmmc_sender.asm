; =============================================================================
;	vdp sender for CS5 format decoder
; -----------------------------------------------------------------------------
;	2019/9/30	t.hara
; =============================================================================

				scope		cs5decode_vdp
; =============================================================================
;	cs5decode_vdp_begin
;	input)
;		none
;	output)
;		none
;	break)
;		all
; =============================================================================
cs5decode_vdp_begin::
				xor			a, a
				ld			[byte_buffer_flag], a
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
				xor			a, a
				ld			c, IO_VDP_PORT1
				ld			b, 16 | 0x80
				di
				out			[c], a
				out			[c], b
				ei
				inc			c					; c = IO_VDP_PORT2
				ld			b, 32
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
				ld			[vdpcmd_nx], bc
				ld			[vdpcmd_ny], de
				ld			hl, write_one_pixel_first
				ld			[write_one_pixel_select + 1], hl

				di
				ld			hl, h_keyi
				ld			de, h_keyi_old
				ld			bc, 5
				ldir
				ld			hl, my_h_keyi_transfer
				ld			de, my_h_keyi
				ld			bc, my_h_keyi_end - my_h_keyi_transfer
				ldir
				ld			a, 0xc3
				ld			[h_keyi], a
				ld			hl, my_h_keyi
				ld			[h_keyi + 1], hl
				ei
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
				ld			d, a
				ld			a, [byte_buffer_flag]
				or			a, a
				ld			a, [vdpcmd_clr]
				jp			nz, write_one_pixel_process
				inc			a
				ld			[byte_buffer_flag], a
				ld			a, d
				rlca
				rlca
				rlca
				rlca
				ld			[vdpcmd_clr], a
				ret

	write_one_pixel_process:
				or			a, d
	write_one_pixel_select:
				jp			write_one_pixel_first

	write_one_pixel_first:
				ld			[vdpcmd_clr], a
				di
				;	VDP R#15 = 2
				ld			a, 2
				ld			bc, ((0x80 | 15) << 8) | IO_VDP_PORT1
				out			[c], a
				out			[c], b
	wait_vdp_command_loop1:
				in			a, [c]
				rrca
				jp			c, wait_vdp_command_loop1
				;	VDP R#17 = 36
				ld			a, 36
				out			[c], a
				ld			a, 0x80 | 17
				out			[c], a
				;	R#36~46 (11 registers)
				ld			hl, vdpcmd
				ld			bc, (11 << 8) | IO_VDP_PORT3
				otir
				ei

				xor			a, a
				ld			[byte_buffer_flag], a
				ld			hl, write_one_pixel_next
				ld			[write_one_pixel_select + 1], hl
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
				rlca
				jp			c, wait_vdp_command_loop2_exit
				rrca
				rrca
				jp			c, wait_vdp_command_loop2
	wait_vdp_command_loop2_exit:
				;	VDP R#44 = d
				ld			a, 44 | 0x80
				out			[c], d
				out			[c], a
				ei
				xor			a, a
				ld			[byte_buffer_flag], a
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
				di
				ld			hl, h_keyi_old
				ld			de, h_keyi
				ld			bc, 5
				ldir
				;	VDP R#15 = 0
				xor			a, a
				ld			bc, ((0x80 | 15) << 8) | IO_VDP_PORT1
				out			[c], a
				out			[c], b
				ei
				ret

; =============================================================================
;	work area
; =============================================================================
	byte_buffer_flag:
				db			0
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
				db			VDPCMD_HMMC		; R#46			CMD

; =============================================================================
;	h_keyi
; =============================================================================
	my_h_keyi	= 0x8000

	my_h_keyi_transfer:
				;	VDP R#15 = 0
				xor			a, a
				ld			bc, ((0x80 | 15) << 8) | IO_VDP_PORT1
				out			[c], a
				out			[c], b
	h_keyi_old:
				db			0, 0, 0, 0, 0
	my_h_keyi_end:
				endscope
