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
				ld			hl, write_one_pixel_first
				ld			[write_one_pixel_select + 1], hl
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
				ld			a, [byte_buffer]
				jp			nz, write_one_pixel_process
				inc			a
				ld			[byte_buffer_flag], a
				ld			a, d
				rlca
				rlca
				rlca
				rlca
				ld			[byte_buffer], a
				ret

	write_one_pixel_process:
				or			a, d
	write_one_pixel_select:
				jp			write_one_pixel_first

	write_one_pixel_first:
				ld			hl, write_one_pixel_next
				ld			[write_one_pixel_select + 1], hl
				di
				;	VDP R#14 = 0
				ld			d, 0
				ld			bc, ((0x80 | 14) << 8) | IO_VDP_PORT1
				out			[c], d
				out			[c], b
				;	VRAM ADDRESS 0x0000 (write mode)
				out			[c], d
				ld			d, 0x40
				out			[c], d
				ei
	write_one_pixel_next:
				out			[IO_VDP_PORT0], a
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
				ret

; =============================================================================
;	work area
; =============================================================================
	byte_buffer_flag:
				db			0
	byte_buffer:
				db			0
	first_flag:
				db			0
				endscope
