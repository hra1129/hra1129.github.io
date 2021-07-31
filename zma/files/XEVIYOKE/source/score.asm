; =============================================================================
;	XEVI”ð‚¯ for MSX2
; -----------------------------------------------------------------------------
;	2019/8/30	t.hara
; =============================================================================

; =============================================================================
;	score
; =============================================================================
	scope		put_score
put_score_initializer::
	xor			a, a
	ld			[state], a
	ld			b, 10
put_score_initializer_loop:
	push		bc
	di
	call		put_score
	ei
	pop			bc
	djnz		put_score_initializer_loop
	ret

put_score::
	ld			a, [state]
	or			a, a
	jp			z, do_state0
	cp			a, 5
	jp			nz, do_other_state

do_state5:
	; update HISCORE
	ld			hl, [hiscore]
	ld			de, [score]
	or			a, a
	sbc			hl, de
	jp			nc, do_state5_skip0
	ld			[hiscore], de
do_state5_skip0:
	; initialize for HISCORE
	ld			a, 96
	ld			[parts_dx], a
	; capture current HISCORE
	ld			hl, [hiscore]
	ld			[captured_score], hl
	ld			hl, binary_search_table
	ld			[table_ptr], hl
	jp			do_other_state

do_state0:
	; initialize for SCORE
	ld			a, 24
	ld			[parts_dx], a
	; capture current SCORE
	ld			hl, [score]
	ld			[captured_score], hl
	ld			hl, binary_search_table
	ld			[table_ptr], hl
	jp			do_other_state

do_other_state:
	ld			de, [captured_score]
	ld			hl, [table_ptr]
	call		get_digit
	ld			[table_ptr], hl
	ld			[captured_score], de
	ld			hl, parts
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [parts_dx]
	add			a, 8
	ld			[parts_dx], a
	; set next state
	ld			a, [state]
	inc			a
	cp			a, 10
	ld			[state], a
	ret			nz
	xor			a, a
	ld			[state], a
	ret

get_digit:
	; bc = tbl[0]
	ld			c, [hl]
	inc			hl
	ld			b, [hl]
	inc			hl
	ex			de, hl
	xor			a, a	  ; A = 0, carry flag = 0
	sbc			hl, bc
	jp			nc, skip0_no
	add			hl, bc
	jp			skip0_yes
skip0_no:
	ld			a, 5
skip0_yes:
	ex			de, hl

	; bc = tbl[1]
	ld			c, [hl]
	inc			hl
	ld			b, [hl]
	inc			hl
	ex			de, hl
	or			a, a	  ; carry flag = 0
	sbc			hl, bc
	jp			nc, skip1_no
	add			hl, bc
	jp			skip1_yes
skip1_no:
	inc			a
	inc			a
	inc			a
skip1_yes:
	ex			de, hl

	; bc = tbl[2]
	ld			c, [hl]
	inc			hl
	ld			b, [hl]
	inc			hl
	ex			de, hl
	or			a, a	  ; carry flag = 0
	sbc			hl, bc
	jp			nc, skip2_no
	add			hl, bc
	jp			skip2_yes
skip2_no:
	inc			a
	inc			a
skip2_yes:
	ex			de, hl

	; bc = tbl[3]
	ld			c, [hl]
	inc			hl
	ld			b, [hl]
	inc			hl
	ex			de, hl
	or			a, a	  ; carry flag = 0
	sbc			hl, bc
	jp			nc, skip3_no
	add			hl, bc
	jp			skip3_yes
skip3_no:
	inc			a
skip3_yes:
	ex			de, hl
	rlca
	rlca
	rlca
	ld			[parts_sx], a
	ret

score::
	dw			0
hiscore::
	dw			0

state:
	db			0				; 0: capture current SCORE, and draw digit of 10000
								; 1: draw digit of 1000
								; 2: draw digit of 100
								; 3: draw digit of 10
								; 4: draw digit of 1
								; 5: capture current HISCORE, and draw digit of 10000
								; 6: draw digit of 1000
								; 7: draw digit of 100
								; 8: draw digit of 10
								; 9: draw digit of 1
captured_score:
	dw			0
table_ptr:
	dw			0
binary_search_table:
	dw			50000
	dw			30000
	dw			20000
	dw			10000
	dw			5000
	dw			3000
	dw			2000
	dw			1000
	dw			500
	dw			300
	dw			200
	dw			100
	dw			50
	dw			30
	dw			20
	dw			10
	dw			5
	dw			3
	dw			2
	dw			1

parts:
parts_sx:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
	db			80				; R#34	SYh
	db			1				; R#35	SYh
parts_dx:
	db			24				; R#36	DXl
	db			0				; R#37	DXh
	db			72				; R#38	DYl
	db			1				; R#39	DYh
	db			8				; R#40	NXl
	db			0				; R#41	NXh
	db			8				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD
	endscope
