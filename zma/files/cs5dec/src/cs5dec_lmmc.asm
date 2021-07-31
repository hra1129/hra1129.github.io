; =============================================================================
;	CS5 format decoder
; -----------------------------------------------------------------------------
;	2019/9/21	t.hara
; =============================================================================

				include		"msx.asm"

				org			0x100

; =============================================================================
				scope		main
main::
				; change to SCREEN5
				ld			a, [SCRMOD]
				ld			[save_screen_mode], a
				ld			a, 5
				ld			iy, [EXPTBL0 - 1]
				ld			ix, CHGMOD
				call		CALSLT

				ld			hl, 0x0081
	skip_white_space:
				ld			a, [hl]
				cp			a, 0x0d
				jp			z, usage_exit
				cp			a, 0x20
				jp			nz, break_skip_white_space
				inc			hl
				jp			skip_white_space
	break_skip_white_space:
				ld			a, h
				cp			a, 0x01
				jp			nc, usage_exit

				; decoder
				call		cs5decode_file_begin
				or			a, a
				jp			z, error_exit

				ld			a, VDPROP_IMP
				call		cs5decode_vdp_begin

				ld			hl, cbr_get_one_byte
				call		cs5decode

				call		cs5decode_vdp_end

				call		cs5decode_file_end

				; key wait
	key_wait:
				ld			c, BDOS_FUNC_DIRECT_CON_GETC_WOE
				call		BDOS_ON_MSXDOS
				cp			a, 0x20
				jp			z, finish_exit
				cp			a, 0x0d
				jp			nz, key_wait

				ld			hl, default_palette
				call		cs5decode_vdp_set_palette

	finish_exit:
				call		restore_screen
				ld			c, BDOS_FUNC_STR_OUT
				ld			de, finish_message
				call		BDOS_ON_MSXDOS
				ret

	usage_exit:
				call		restore_screen
				ld			c, BDOS_FUNC_STR_OUT
				ld			de, usage_message
				call		BDOS_ON_MSXDOS
				ret

	error_exit:
				call		restore_screen
				ld			c, BDOS_FUNC_STR_OUT
				ld			de, error_message
				call		BDOS_ON_MSXDOS
				ret

	restore_screen:
				ld			a, [save_screen_mode]
				ld			iy, [EXPTBL0 - 1]
				ld			ix, CHGMOD
				jp			CALSLT

finish_message:
				ds			"CS5DEC (C)2019 HRA!"
				db			0x0d, 0x0a
				ds			"Completed."
				db			0x0d, 0x0a
				ds			"$"
usage_message:
				ds			"Usage> CS5DEC <INPUT.CS5>"
				db			0x0d, 0x0a
				ds			"$"
error_message:
				ds			"[ERROR] Cannot open file."
				db			0x0d, 0x0a
				ds			"$"

save_screen_mode:
				db			0

default_palette:
				db			0x00, 0x00
				db			0x00, 0x00
				db			0x11, 0x06
				db			0x33, 0x07
				db			0x17, 0x01
				db			0x27, 0x03
				db			0x51, 0x01
				db			0x27, 0x06
				db			0x71, 0x01
				db			0x73, 0x03
				db			0x61, 0x06
				db			0x63, 0x06
				db			0x11, 0x04
				db			0x65, 0x02
				db			0x55, 0x05
				db			0x77, 0x07

cbr_get_one_byte:
				dw			cs5decode_file_get_one_byte
cbr_set_palette:
				dw			cs5decode_vdp_set_palette
cbr_set_image_size:
				dw			cs5decode_vdp_set_image_size
cbr_write_one_pixel:
				dw			cs5decode_vdp_write_one_pixel
				endscope

; =============================================================================
				include			"cs5dec_core.asm"
				include			"cs5dec_file_reader.asm"
				include			"cs5dec_vdp_lmmc_sender.asm"
				include			"string.asm"
