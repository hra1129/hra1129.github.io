; =============================================================================
;	file reader for CS5 format decoder
; -----------------------------------------------------------------------------
;	2019/9/30	t.hara
; =============================================================================

				scope	cs5decode_file
; =============================================================================
;	cs5decode_file_begin
;	input)
;		hl ..... 読み込むファイル名のアドレス
;	output)
;		a ...... 0: 失敗, 1: 成功
;	break)
;		all
; =============================================================================
cs5decode_file_begin::
				; copy file name to FCB
				ld		de, fcb
				call	file_name_to_fcb
				; zero fill
				ld		hl, fcb_current_block
				ld		b, 25
				xor		a, a
				call	memset
				; open target file
				ld		de, fcb
				ld		c, BDOS_FUNC_FCB_OPEN_FILE
				call	BDOS_ON_MSXDOS
				inc		a
				ret		z
				; change read buffer
				ld		de, 0x80
				ld		c, BDOS_FUNC_SET_DTA
				call	BDOS_ON_MSXDOS
				; initialize dta
				ld		a, 128
				ld		[dta_index], a
				ret

; =============================================================================
;	cs5decode_file_get_one_byte
;	input)
;		none
;	output)
;		a ...... 取得した 1byte
;	break)
;		all
; =============================================================================
cs5decode_file_get_one_byte::
				ld		a, [dta_index]
				cp		a, 128
				call	z, read_one_block

				or		a, 0x80
				ld		l, a
				ld		h, 0
				sub		a, 0x7F
				ld		[dta_index], a
				ld		a, [hl]
				ret

	read_one_block:
				ld		c, BDOS_FUNC_FCB_SEQ_READ
				ld		de, fcb
				call	BDOS_ON_MSXDOS
				xor		a, a
				ret

; =============================================================================
;	cs5decode_file_end
;	input)
;		hl ..... 読み込むファイル名のアドレス
;	output)
;		a ...... 0: 失敗, 1: 成功
;	break)
;		all
; =============================================================================
cs5decode_file_end::
				; close file
				ld		c, BDOS_FUNC_FCB_CLOSE_FILE
				ld		de, fcb
				call	BDOS_ON_MSXDOS
				ret

; =============================================================================
;	work area
; =============================================================================
fcb:
fcb_drive_id:
				db		0					; 0: default drive, 1: A, 2: B ...
fcb_file_name:
				ds		"        "			; file name
fcb_ext_name:
				ds		"   "				; ext. file name
fcb_current_block:
				dw		0					; current block
				dw		0					; recode size
				dd		0					; file size
				dw		0					; date
				dw		0					; time
				db		0					; device ID
				db		0					; directory location
				dw		0					; top cluster
				dw		0					; last access cluster
				dw		0					; relative cluster number
				db		0					; current record
				dd		0					; random record
dta_index:
				db		128					; index of read buffer (0...128)
				endscope
