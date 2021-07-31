; =============================================================================
;	CS5 format decoder core routine
; -----------------------------------------------------------------------------
;	2019/9/28	t.hara
; =============================================================================

MAX_LENGTH	= 255
MIN_LENGTH	= 3

; =============================================================================
;	cs5decode
;	input)
;		hl ..... コールバックテーブルのアドレス
;					[HL] ..... 圧縮コードから 1byte 取得するルーチンのアドレス
;							input)
;								none
;							output)
;								a ..... 取得した 1byte
;					[HL+2] ... パレットデータ設定ルーチンのアドレス
;							input)
;								hl .... パレットデータ(32byte)のアドレス
;							output)
;								none
;					[HL+4] ... 画像データサイズを設定するルーチンのアドレス
;							input)
;								bc .... 水平画素数(2～512 の偶数)
;								de .... 垂直画素数(1～212)
;							output)
;								none
;					[HL+6] ... 画素値を設定するルーチンのアドレス
;							input)
;								a ..... 画素値 (0～15)
;							output)
;								none
; =============================================================================
				scope	cs5decode
cs5decode::
				call	initializer

				; Get image size
				ld		b, 8
				call	read_bits
				push	de					; save width
				ld		b, 8
				call	read_bits
				ld		e, d
				pop		af					; restore width
				ld		c, a
				ld		d, 0
				ld		b, d
				inc		de
				inc		bc
				sla		c
				rl		b
				push	de
				push	bc
	cbr_set_image_size:
				call	0
				pop		bc
				pop		de
				call	mul_bc_e
				ld		[size], hl

				; decode process
	decode_loop:
				ld		b, 1
				call	read_bits
				dec		d
				ld		hl, [size]
				jp		nz, read_body		; jump to read_body, when decode case of 0b0

				ld		b, 1
				call	read_bits
				dec		d
				jp		nz, decode_case_of_0b10
	decode_case_of_0b11:
				call	read_golomb_table
				jp		decode_loop

	decode_case_of_0b10:
				call	read_palette
				ld		hl, palette
	cbr_set_palette:
				call	0
				jp		decode_loop

	mul_bc_e:								; hl = bc * e
				ld		hl, 0
				ld		d, 8
				ld		a, e
	mul_bc_e_loop:
				sla		l
				rl		h
				rlca
				jp		nc, mul_bc_e_skip
				add		hl, bc
	mul_bc_e_skip:
				dec		d
				jp		nz, mul_bc_e_loop
				ret

; -----------------------------------------------------------------------------
;	initializer
;	input)
;		hl ..... コールバックテーブルのアドレス
;	output)
;		none
;	break)
;		af, bc, de, hl
;	comment)
;		Initialize work area.
; -----------------------------------------------------------------------------
initializer:
				; initialize call back routines
				ld		e, [hl]					; de = cbr_get_one_byte
				inc		hl
				ld		d, [hl]
				inc		hl
				ld		[cbr_get_one_byte1 + 1], de
				ld		[cbr_get_one_byte2 + 1], de
				
				ld		e, [hl]					; de = cbr_set_palette
				inc		hl
				ld		d, [hl]
				inc		hl
				ld		[cbr_set_palette + 1], de

				ld		e, [hl]					; de = cbr_set_image_size
				inc		hl
				ld		d, [hl]
				inc		hl
				ld		[cbr_set_image_size + 1], de

				ld		e, [hl]					; de = cbr_write_one_pixel
				inc		hl
				ld		d, [hl]
				inc		hl
				ld		[cbr_write_one_pixel1 + 1], de
				ld		[cbr_write_one_pixel2 + 1], de
				ld		[cbr_write_one_pixel3 + 1], de

				; initialize palette table
				ld		hl, palette_init
				ld		de, palette
				ld		bc, 32
				ldir
				; initialize byte_buffer
				xor		a, a
				ld		[byte_buffer], a
				ld		[byte_buffer_bits], a
				; initialize last_data_pixels
				ld		[last_data_index], a
				ld		b, a
				ld		hl, last_data_pixels
	init_last_data_pixels_loop:
				ld		a, b
				srl		a
				srl		a
				srl		a
				srl		a
				ld		[hl], a
				inc		hl
				inc		b
				jp		nz, init_last_data_pixels_loop
				; initialize golomb_table
				xor		a, a
	init_golomb_table_loop:
				ld		[hl], a
				inc		a
				cp		a, 17
				jp		c, init_golomb_table_loop
				ret

; -----------------------------------------------------------------------------
;	read_bits
;	input)
;		b .... 要求ビット数 1～8
;	output)
;		d .... ビット列 (下詰め)
;	break)
;		all
; -----------------------------------------------------------------------------
read_bits:
				ld		a, [byte_buffer_bits]
				or		a, a							; byte_buffer_bits is 0?
				ld		c, a							; flag no change
				ld		a, [byte_buffer]				; flag no change
				call	z, call_get_one_byte
				ld		d, 0
	get_bits:
				sla		a								; a = a << 1
				rl		d								; get one bit
				dec		b								; bits--
				jp		z, finish_read_bits
				dec		c								; byte_buffer_bits--
				jp		nz, get_bits
				call	call_get_one_byte
				jp		get_bits
	
	finish_read_bits:
				dec		c								; byte_buffer_bits--
				ld		[byte_buffer], a
				ld		a, c
				ld		[byte_buffer_bits], a
				ret

	call_get_one_byte:
				ld		c, d
				push	bc
	cbr_get_one_byte1:
				call	0
				pop		bc
				ld		d, c
				ld		c, 8
				ret

; -----------------------------------------------------------------------------
;	read_palette
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	comment)
;		圧縮コードのカレント位置をパレットテーブルと見なし、パレット配列 palette 
;		にパレットテーブルを読み込む処理。
; -----------------------------------------------------------------------------
read_palette:
				ld		b, 16
				ld		hl, palette
	read_palette_loop:
				push	bc
				push	hl
				; get red
				ld		b, 3
				call	read_bits
				ld		a, d
				rlca
				rlca
				rlca
				rlca
				push	af
				; get blue
				ld		b, 3
				call	read_bits
				pop		af
				or		a, d
				pop		hl
				ld		[hl], a
				inc		hl
				; get green
				push	hl
				ld		b, 3
				call	read_bits
				pop		hl
				ld		[hl], d
				inc		hl
				pop		bc
				djnz	read_palette_loop
				ret

; -----------------------------------------------------------------------------
;	read_golomb_table
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	comment)
;		圧縮コードのカレント位置をゴロム符号テーブルと見なし、ゴロム符号配列  
;		golomb_table にゴロム符号テーブルを読み込む処理。
; -----------------------------------------------------------------------------
read_golomb_table:
				ld		b, 17
				ld		hl, golomb_table
	read_golomb_table_loop:
				push	bc
				push	hl
				; get ID# for Golomb#(b register)
				ld		b, 5
				call	read_bits
				pop		hl
				ld		[hl], d
				inc		hl
				pop		bc
				djnz	read_golomb_table_loop
				ret

; -----------------------------------------------------------------------------
;	read_body
;	input)
;		hl .... size
;	output)
;		none
;	break)
;		all
;	comment)
;		圧縮コードのカレント位置を画像本体と見なし、デコード処理を実施。
; -----------------------------------------------------------------------------
read_body:
	read_body_loop:
				push	hl							; save size
				call	read_golomb
				ld		l, a
				ld		h, golomb_table >> 8
				ld		a, [hl]
				cp		a, 16
				jp		z, read_body_id16_process

				ld		d, a
				call	put_last_data
				ld		a, d
	cbr_write_one_pixel1:
				call	0
				pop		hl							; restore size
				dec		hl
				ld		a, l
				or		a, h
				jp		nz, read_body_loop
				ret

	read_body_id16_process:
				ld		b, 8
				call	read_bits
				ld		a, d
				ld		[source_index], a
				call	read_golomb
				add		a, MIN_LENGTH
				ld		[length], a
				call	read_golomb
				ld		[repeat_count], a

				ld		a, [length]
				ld		b, a

				ld		a, [source_index]
				ld		c, a
				ld		a, [last_data_index]
				add		a, c
				ld		l, a
				ld		h, last_data_pixels >> 8
				pop		de							; restore size
	read_body_first_block_loop:
				push	bc							; save loop counter
				push	de							; save size
				ld		d, [hl]
				push	hl							; save source_index
				call	put_last_data
				ld		a, d
	cbr_write_one_pixel2:
				call	0
				pop		hl							; restore source_index
				pop		de							; restore size
				pop		bc							; restore loop counter
				inc		l
				dec		de
				ld		a, e
				or		a, d
				ret		z
				djnz	read_body_first_block_loop

				ld		a, [length]
				ld		b, a
				ld		a, [last_data_index]
				sub		a, b
				ld		l, a

				ld		a, [repeat_count]
				ld		b, a
	read_body_repeat_block_loop_j:
				push	bc							; save loop counter j

				ld		a, [length]
				ld		b, a
	read_body_repeat_block_loop_i:
				push	bc							; save loop counter i
				push	de							; save size
				ld		d, [hl]
				push	hl							; save source_index
				call	put_last_data
				ld		a, d
	cbr_write_one_pixel3:
				call	0
				pop		hl							; restore source_index
				pop		de							; restore size
				pop		bc							; restore loop counter i
				inc		l
				dec		de
				ld		a, e
				or		a, d
				jp		z, read_body_repeat_block_loop_i_break
				djnz	read_body_repeat_block_loop_i
	read_body_repeat_block_loop_i_break:
				pop		bc							; restore loop counter j
				ld		a, e
				or		a, d
				ret		z
				djnz	read_body_repeat_block_loop_j
				ex		de, hl
				jp		read_body_loop

; -----------------------------------------------------------------------------
;	put_last_data
;	input)
;		d .... 画素値 (0～15)
;	output)
;		none
;	break)
;		af, hl
;	comment)
;		最後の 256画素を保持している領域を更新する。
; -----------------------------------------------------------------------------
put_last_data:
				ld		a, [last_data_index]
				ld		l, a
				ld		h, last_data_pixels >> 8
				ld		[hl], d
				inc		a
				ld		[last_data_index], a
				ret

; -----------------------------------------------------------------------------
;	read_golomb
;	input)
;		none
;	output)
;		a .... ゴロム符号をデコードした値
;	break)
;		all
;	comment)
;		圧縮コードのカレント位置をゴロム符号と見なして、これをデコードする。
; -----------------------------------------------------------------------------
read_golomb:
				ld		d, 0						; d = 0
				ld		a, [byte_buffer_bits]
				ld		c, a						; c = byte_buffer_bits
				ld		a, [byte_buffer]			; a = byte_buffer
	read_golomb_loop1:
				or		a, a						; if a != 0 then goto read_golomb_loop1_exit
				jp		nz, read_golomb_loop1_exit
				ld		a, c						; d = d + c
				add		a, d
				ld		d, a
				push	de
	cbr_get_one_byte2:
				call	0							; a = new byte
				pop		de
				ld		c, 8						; c = 8
				jp		read_golomb_loop1

	read_golomb_loop1_exit:
				ld		[byte_buffer], a			; byte_buffer = a
				ld		a, c
				ld		[byte_buffer_bits], a		; byte_buffer_bits = c
				ld		a, d
	read_golomb_loop2:
				push	af
				ld		b, 1
				call	read_bits					; d = new 1 bit
				pop		af
				rrc		d
				jp		c, read_golomb_exit_to_count_zero
				inc		a
				jp		read_golomb_loop2

	read_golomb_exit_to_count_zero:
				ld		d, a
				rlca
				add		a, d

				push	af
				ld		b, 1
				call	read_bits
				pop		af
				rrc		d
				ret		nc

				inc		a
				push	af
				ld		b, 1
				call	read_bits
				pop		af
				rrc		d
				ret		nc
				inc		a
				ret

; -----------------------------------------------------------------------------
;	work area
; -----------------------------------------------------------------------------
width:
				db		0
height:
				db		0
size:
				dw		0
palette:
				ds		" " * (16 * 2)
palette_init:
				db		0x00, 0x00
				db		0x00, 0x00
				db		0x11, 0x06
				db		0x33, 0x07
				db		0x17, 0x01
				db		0x27, 0x03
				db		0x51, 0x01
				db		0x27, 0x06
				db		0x71, 0x01
				db		0x73, 0x03
				db		0x61, 0x06
				db		0x63, 0x06
				db		0x11, 0x04
				db		0x65, 0x02
				db		0x55, 0x05
				db		0x77, 0x07
last_data_index:
				db		0
padding:
				ds	" " * (256 - (padding & 255))
last_data_pixels:
				ds		" " * 256
golomb_table:
				ds		" " * 17
byte_buffer:
				db		0
byte_buffer_bits:
				db		0
source_index:
				db		0
length:
				db		0
repeat_count:
				db		0
				endscope
