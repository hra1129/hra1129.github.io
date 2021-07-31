; =============================================================================
;	XEVI”ð‚¯ for MSX2
; -----------------------------------------------------------------------------
;	2019/8/30	t.hara
; =============================================================================

; =============================================================================
;	Big character move (sprite part)
; =============================================================================
	scope		bigchar_sp_move
bigchar_initializer::
	ld			hl, -200
	ld			[bigchar_y], hl
	ld			[bigchar_y_sp], hl
	ld			a, 88 + 8 - 2
	ld			[bg_backup_top], a
	xor			a, a
	ld			[bigchar_y_vscroll], a
	inc			a
	ld			[first_flag], a
	ret

bigchar_sp_move::
	ld			hl, [bigchar_y_sp]
	;	Part7 and 8
	ld			bc, 80
	add			hl, bc
	ld			a, h
	or			a, a
	jp			nz, end_of_put_sprite

	;	Part7
	push		hl
	ld			b, 56			; sprite pattern#
	ld			d, 88			; X position
	ld			e, l			; Y position
	ld			hl, ando_part7_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part8
	push		hl
	ld			b, 64			; sprite pattern#
	ld			d, 152			; X position
	ld			e, l			; Y position
	ld			hl, ando_part8_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part5 and 6
	ld			bc, -16
	add			hl, bc
	ld			a, h
	or			a, a
	jp			nz, end_of_put_sprite

	;	Part5
	push		hl
	ld			b, 40			; sprite pattern#
	ld			d, 80			; X position
	ld			e, l			; Y position
	ld			hl, ando_part5_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part6
	push		hl
	ld			b, 48			; sprite pattern#
	ld			d, 160			; X position
	ld			e, l			; Y position
	ld			hl, ando_part6_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part3 and 4
	ld			bc, -48
	add			hl, bc
	ld			a, h
	or			a, a
	jp			nz, end_of_put_sprite

	;	Part3
	push		hl
	ld			b, 24			; sprite pattern#
	ld			d, 80			; X position
	ld			e, l			; Y position
	ld			hl, ando_part3_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part4
	push		hl
	ld			b, 32			; sprite pattern#
	ld			d, 160			; X position
	ld			e, l			; Y position
	ld			hl, ando_part4_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part1 and 2
	ld			bc, -16
	add			hl, bc
	ld			a, h
	or			a, a
	jp			nz, end_of_put_sprite

	;	Part1
	push		hl
	ld			b, 8			; sprite pattern#
	ld			d, 88			; X position
	ld			e, l			; Y position
	ld			hl, ando_part1_sprite_color1
	call		sd_put_sprite_pair
	pop			hl

	;	Part2
	ld			b, 16			; sprite pattern#
	ld			d, 152			; X position
	ld			e, l			; Y position
	ld			hl, ando_part2_sprite_color1
	call		sd_put_sprite_pair
	jp			end_of_put_sprite

end_of_put_sprite:
	;	Is BigChar moving?
	ld			hl, [bigchar_y_sp]
	ld			bc, 56
	or			a, a
	sbc			hl, bc
	ret			p

bigchar_move_state:
	ld			hl, [bigchar_y_sp]
	inc			hl
	ld			[bigchar_y_sp], hl
	ret
	endscope

; =============================================================================
;	Big character move (bg part1)
; =============================================================================
	scope		bigchar_bg_move_intr1
bigchar_bg_move_1::
	ld			a, [draw_page]
	ld			[line_a_left_dest_page], a
	ld			[line_a_right_dest_page], a
	ld			[line_b_left_dest_page], a
	ld			[line_b_right_dest_page], a
	ld			[line_c_dest_page], a
	ld			[backup_copy_src_page], a
	ld			[body_a_dest_page], a
	ld			[body_b_dest_page], a
	ld			[body_c_dest_page], a
	ld			[body_d_dest_page], a
	ld			[body_e_dest_page], a
	ld			[body_f_dest_page], a
	;	Check stop of bigchar
	ld			a, [bigchar_y + 1]
	or			a, a
	jp			nz, put_body_1
	ld			a, [bigchar_y]
	cp			a, 56
	jp			nz, put_body_1
	ld			b, a
	ld			a, [vscroll_next]
	add			a, b
	ld			[bigchar_y_vscroll], a

	;	restore line_a
	add			a, 64
	ld			[line_a_left_dy], a
	ld			[line_a_right_dy], a
	ld			e, a

	ld			a, [bg_backup_top]		;	line_a = a + 64
	add			a, 64
	cp			a, 192					;	line_a = (line_a <= 192) ? line_a : line_a - 96
	jp			c, line_a_skip0
	sub			a, 104
line_a_skip0:
	ld			[line_a_left_sy], a
	ld			[line_a_right_sy], a
	ld			d, a

	;	run HMMM for line_a (left 1st part)
	ld			hl, line_a_left
	call		wait_vdp_command
	call		run_vdp_command

	;	run HMMM for line_a (right 1st part)
	ld			hl, line_a_right
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, d
	inc			a
	cp			a, 192
	jp			c, line_a_skip1
	ld			a, 88
line_a_skip1:
	ld			[line_a_left_sy], a
	ld			[line_a_right_sy], a

	ld			a, e
	inc			a
	ld			[line_a_left_dy], a
	ld			[line_a_right_dy], a
	;	run HMMM for line_a (left 2nd part)
	ld			hl, line_a_left
	call		wait_vdp_command
	call		run_vdp_command

	;	run HMMM for line_a (right 2nd part)
	ld			hl, line_a_right
	call		wait_vdp_command
	call		run_vdp_command

	;	restore line_b
	ld			a, [bigchar_y_vscroll]
	add			a, 80
	ld			[line_b_left_dy], a
	ld			[line_b_right_dy], a
	ld			e, a

	ld			a, [bg_backup_top]
	cp			a, 192 - 80
	jp			c, line_b_skip0
	sub			a, 104
line_b_skip0:
	add			a, 80
	ld			[line_b_left_sy], a
	ld			[line_b_right_sy], a
	ld			d, a

	;	run HMMM for line_b (left 1st part)
	ld			hl, line_b_left
	call		wait_vdp_command
	call		run_vdp_command

	;	run HMMM for line_b (right 1st part)
	ld			hl, line_b_right
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, d
	inc			a
	cp			a, 192
	jp			c, line_b_skip1
	ld			a, 88
line_b_skip1:
	ld			[line_b_left_sy], a
	ld			[line_b_right_sy], a

	ld			a, e
	inc			a
	ld			[line_b_left_dy], a
	ld			[line_b_right_dy], a
	;	run HMMM for line_b (left 2nd part)
	ld			hl, line_b_left
	call		wait_vdp_command
	call		run_vdp_command

	;	run HMMM for line_b (right 2nd part)
	ld			hl, line_b_right
	call		wait_vdp_command
	call		run_vdp_command

	;	restore line_c
	ld			a, [bigchar_y_vscroll]
	add			a, 96
	ld			[line_c_dy], a
	ld			e, a

	ld			a, [bg_backup_top]
	cp			a, 192 - 96
	jp			c, line_c_skip0
	sub			a, 104
line_c_skip0:
	add			a, 96
	ld			[line_c_sy], a
	ld			d, a

	;	run HMMM for line_c 1st part
	ld			hl, line_c
	call		wait_vdp_command
	call		run_vdp_command

	ld			a, d
	inc			a
	cp			a, 192
	jp			c, line_c_skip1
	ld			a, 88
line_c_skip1:
	ld			[line_c_sy], a

	ld			a, e
	inc			a
	ld			[line_c_dy], a
	;	run HMMM for line_c 2nd part
	ld			hl, line_c
	call		wait_vdp_command
	call		run_vdp_command

	;	backup copy
backup:
	ld			a,[bigchar_y_vscroll]
	ld			[backup_copy_sy], a
	ld			a, [first_flag]
	or			a, a
	jp			nz, backup_skip

	;	run HMMM for backup copy
	ld			hl, backup_copy
	call		wait_vdp_command
	call		run_vdp_command
backup_skip:
	xor			a, a
	ld			[first_flag], a

	;	Update bg_backup_top
	ld			a, [bg_backup_top]
	dec			a
	cp			a, 87
	jp			nz, backup_skip0
	ld			a, 191
backup_skip0:
	ld			[bg_backup_top], a
	ld			[backup_copy_dy], a

put_body_1:
	;	Does display the body_a?
put_body_a:
	ld			hl, [bigchar_y]
	ld			a, h
	or			a, a					;	Is hl less than 0 ?
	jp			nz, put_body_a_end		;	Yes, go to next.

	;	Is body_a divided?
	ld			a, [draw_page]
	ld			[body_a_dest_page], a
	ld			a, [vscroll_next]
	add			a, l
	cp			a, 256 - 16 + 1
	ld			[body_a_dy], a			;	DY1 = vscroll_next + bigchar_y
	ld			hl, body_a
	jp			nc, body_a_is_divided

body_a_is_not_divided:
	ld			a, 88
	ld			[body_a_sy], a
	ld			a, 16
	ld			[body_a_ny], a
	call		wait_vdp_command
	call		run_vdp_command
	jp			put_body_a_end
body_a_is_divided:
	neg
	ld			[body_a_ny], a			;	NY1 = neg DY1
	ld			a, 88
	ld			[body_a_sy], a			;	SY1 = 88
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [body_a_ny]
	add			a, 88
	ld			[body_a_sy], a			;	SY2 = NY1 + 88
	ld			a, [body_a_dy]
	and			a, 15
	ld			[body_a_ny], a			;	NY2 = DY1 and 15
	xor			a, a
	ld			[body_a_dy], a			;	DY2 = 0
	ld			hl, body_a
	call		wait_vdp_command
	call		run_vdp_command
put_body_a_end:
	ret

bigchar_bg_move_2::
	;	Does display the body_c?
put_body_c:
	ld			hl, [bigchar_y]
	ld			bc, 32
	add			hl, bc					;	hl = bigchar_y + 32
	ld			a, h
	or			a, a					;	Is hl less than 0 ?
	jp			nz, put_body_c_end		;	Yes, go to next.

	;	Is body_e divided?
	ld			a, [draw_page]
	ld			[body_c_dest_page], a
	ld			a, [vscroll_next]
	add			a, l
	cp			a, 256 - 16 + 1
	ld			[body_c_dy], a			;	DY1 = vscroll_next + bigchar_y + 32
	ld			hl, body_c
	jp			nc, body_c_is_divided

body_c_is_not_divided:
	ld			a, 120
	ld			[body_c_sy], a
	ld			a, 16
	ld			[body_c_ny], a
	call		wait_vdp_command
	call		run_vdp_command
	jp			put_body_c_end
body_c_is_divided:
	neg
	ld			[body_c_ny], a			;	NY1 = neg DY1
	ld			a, 120
	ld			[body_c_sy], a			;	SY1 = 120
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [body_c_ny]
	add			a, 120
	ld			[body_c_sy], a			;	SY2 = NY1 + 120
	ld			a, [body_c_dy]
	and			a, 15
	ld			[body_c_ny], a			;	NY2 = DY1 and 15
	xor			a, a
	ld			[body_c_dy], a			;	DY2 = 0
	ld			hl, body_c
	call		wait_vdp_command
	call		run_vdp_command
put_body_c_end:
	ret

bigchar_bg_move_3::
	;	Check stop of bigchar
	ld			a, [bigchar_y + 1]
	or			a, a
	jp			nz, put_body_3
	ld			a, [bigchar_y]
	cp			a, 56
	jp			nz, put_body_3

put_body_3:
	;	Does display the body_b?
put_body_b:
	ld			hl, [bigchar_y]
	ld			bc, 16
	add			hl, bc					;	hl = bigchar_y + 16
	ld			a, h
	or			a, a					;	Is hl less than 0 ?
	jp			nz, put_body_b_end		;	Yes, go to next.

	;	Is body_b divided?
	ld			a, [vscroll_next]
	add			a, l
	cp			a, 256 - 16 + 1
	ld			[body_b_dy], a			;	DY1 = vscroll_next + bigchar_y + 16
	ld			hl, body_b
	jp			nc, body_b_is_divided

body_b_is_not_divided:
	ld			a, 104
	ld			[body_b_sy], a
	ld			a, 16
	ld			[body_b_ny], a
	call		wait_vdp_command
	call		run_vdp_command
	jp			put_body_b_end
body_b_is_divided:
	neg
	ld			[body_b_ny], a			;	NY1 = neg DY1
	ld			a, 104
	ld			[body_b_sy], a			;	SY1 = 104
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [body_b_ny]
	add			a, 104
	ld			[body_b_sy], a			;	SY2 = NY1 + 104
	ld			a, [body_b_dy]
	and			a, 15
	ld			[body_b_ny], a			;	NY2 = DY1 and 15
	xor			a, a
	ld			[body_b_dy], a			;	DY2 = 0
	ld			hl, body_b
	call		wait_vdp_command
	call		run_vdp_command
put_body_b_end:
	ret

bigchar_bg_move_4::
	;	Does display the body_d?
put_body_d:
	ld			hl, [bigchar_y]
	ld			bc, 64
	add			hl, bc					;	hl = bigchar_y + 64
	ld			a, h
	or			a, a					;	Is hl less than 0 ?
	jp			nz, put_body_d_end		;	Yes, go to next.

	;	Is body_d divided?
	ld			a, [vscroll_next]
	add			a, l
	cp			a, 256 - 16 + 1
	ld			[body_d_dy], a			;	DY1 = vscroll_next + bigchar_y + 64
	ld			hl, body_d
	jp			nc, body_d_is_divided

body_d_is_not_divided:
	ld			a, 152
	ld			[body_d_sy], a
	ld			a, 16
	ld			[body_d_ny], a
	call		wait_vdp_command
	call		run_vdp_command
	jp			put_body_d_end
body_d_is_divided:
	neg
	ld			[body_d_ny], a			;	NY1 = neg DY1
	ld			a, 152
	ld			[body_d_sy], a			;	SY1 = 152
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [body_d_ny]
	add			a, 152
	ld			[body_d_sy], a			;	SY2 = NY1 + 152
	ld			a, [body_d_dy]
	and			a, 15
	ld			[body_d_ny], a			;	NY2 = DY1 and 15
	xor			a, a
	ld			[body_d_dy], a			;	DY2 = 0
	ld			hl, body_d
	call		wait_vdp_command
	call		run_vdp_command
put_body_d_end:
	ret

bigchar_bg_move_5::
	;	Does display the body_f?
put_body_f:
	ld			hl, [bigchar_y]
	ld			bc, 48
	add			hl, bc					;	hl = bigchar_y + 48
	ld			a, h
	or			a, a					;	Is hl less than 0 ?
	jp			nz, put_body_f_end		;	Yes, go to next.

	;	Is body_e divided?
	ld			a, [draw_page]
	ld			[body_f_dest_page], a
	ld			a, [vscroll_next]
	add			a, l
	cp			a, 256 - 16 + 1
	ld			[body_f_dy], a			;	DY1 = vscroll_next + bigchar_y + 48
	ld			hl, body_f
	jp			nc, body_f_is_divided

body_f_is_not_divided:
	ld			a, 136
	ld			[body_f_sy], a
	ld			a, 16
	ld			[body_f_ny], a
	call		wait_vdp_command
	call		run_vdp_command
	jp			put_body_f_end
body_f_is_divided:
	neg
	ld			[body_f_ny], a			;	NY1 = neg DY1
	ld			a, 136
	ld			[body_f_sy], a			;	SY1 = 136
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [body_f_ny]
	add			a, 136
	ld			[body_f_sy], a			;	SY2 = NY1 + 136
	ld			a, [body_f_dy]
	and			a, 15
	ld			[body_f_ny], a			;	NY2 = DY1 and 15
	xor			a, a
	ld			[body_f_dy], a			;	DY2 = 0
	ld			hl, body_f
	call		wait_vdp_command
	call		run_vdp_command
put_body_f_end:
	ret

bigchar_bg_move_6::
	;	Does display the body_e?
put_body_e:
	ld			hl, [bigchar_y]
	ld			bc, 80
	add			hl, bc					;	hl = bigchar_y + 80
	ld			a, h
	or			a, a					;	Is hl less than 0 ?
	jp			nz, put_body_e_end		;	Yes, go to next.

	;	Is body_e divided?
	ld			a, [draw_page]
	ld			[body_e_dest_page], a
	ld			a, [vscroll_next]
	add			a, l
	cp			a, 256 - 16 + 1
	ld			[body_e_dy], a			;	DY1 = vscroll_next + bigchar_y + 80
	ld			hl, body_e
	jp			nc, body_e_is_divided

body_e_is_not_divided:
	ld			a, 168
	ld			[body_e_sy], a
	ld			a, 16
	ld			[body_e_ny], a
	call		wait_vdp_command
	call		run_vdp_command
	jp			put_body_e_end
body_e_is_divided:
	neg
	ld			[body_e_ny], a			;	NY1 = neg DY1
	ld			a, 168
	ld			[body_e_sy], a			;	SY1 = 168
	call		wait_vdp_command
	call		run_vdp_command
	ld			a, [body_e_ny]
	add			a, 168
	ld			[body_e_sy], a			;	SY2 = NY1 + 168
	ld			a, [body_e_dy]
	and			a, 15
	ld			[body_e_ny], a			;	NY2 = DY1 and 15
	xor			a, a
	ld			[body_e_dy], a			;	DY2 = 0
	ld			hl, body_e
	call		wait_vdp_command
	call		run_vdp_command
put_body_e_end:

	;	Is BigChar moving?
	ld			hl, [bigchar_y]
	ld			bc, 56
	or			a, a
	sbc			hl, bc
	jp			p, palette_blink

bigchar_move_state:
	ld			hl, [bigchar_y]
	inc			hl
	ld			[bigchar_y], hl
	ret

palette_blink:
	ld			c, IO_VDP_PORT1
	ld			a, 4					; Palette#
	di
	out			[c], a
	ld			a, 16 | 0x80
	out			[c], a					; R#16 = palette#
	ei
	inc			c

	ld			a, [palette_blink_rb]
	out			[c], a
	xor			a, a
	out			[c], a

	ld			a, [palette_blink_rb_dir]
	or			a, a
	ld			a, [palette_blink_rb]
	jp			nz, palette_blink_skip
	add			a, 0x10
	ld			[palette_blink_rb], a
	cp			a, 0x70
	ret			nz
	ld			a, 1
	ld			[palette_blink_rb], a
	ret

palette_blink_skip:
	sub			a, 0x10
	ld			[palette_blink_rb], a
	ret			nz
	inc			a
	ld			[palette_blink_rb_dir], a
	ret

palette_blink_rb:
	db			0x30
palette_blink_rb_dir:
	db			0

bigchar_y::
	dw			-200
bigchar_y_sp::
	dw			-200
bigchar_y_vscroll::
	db			0
bg_backup_top::
	db			88 + 8 - 2
first_flag::
	db			1

line_a_left:
	db			0				; R#32	SXl
	db			0				; R#33	SXh
line_a_left_sy:
	db			0				; R#34	SYl
	db			1				; R#35	SYh
	db			80				; R#36	DXl
	db			0				; R#37	DXh
line_a_left_dy:
	db			0				; R#38	DYl
line_a_left_dest_page:
	db			0				; R#39	DYh
	db			16				; R#40	NXl
	db			0				; R#41	NXh
line_a_left_ny:
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

line_a_right:
	db			80				; R#32	SXl
	db			0				; R#33	SXh
line_a_right_sy:
	db			0				; R#34	SYl
	db			1				; R#35	SYh
	db			160				; R#36	DXl
	db			0				; R#37	DXh
line_a_right_dy:
	db			0				; R#38	DYl
line_a_right_dest_page:
	db			0				; R#39	DYh
	db			16				; R#40	NXl
	db			0				; R#41	NXh
line_a_right_ny:
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

line_b_left:
	db			16				; R#32	SXl
	db			0				; R#33	SXh
line_b_left_sy:
	db			0				; R#34	SYl
	db			1				; R#35	SYh
	db			96				; R#36	DXl
	db			0				; R#37	DXh
line_b_left_dy:
	db			0				; R#38	DYl
line_b_left_dest_page:
	db			0				; R#39	DYh
	db			8				; R#40	NXl
	db			0				; R#41	NXh
line_b_left_ny:
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

line_b_right:
	db			72				; R#32	SXl
	db			0				; R#33	SXh
line_b_right_sy:
	db			0				; R#34	SYl
	db			1				; R#35	SYh
	db			152				; R#36	DXl
	db			0				; R#37	DXh
line_b_right_dy:
	db			0				; R#38	DYl
line_b_right_dest_page:
	db			0				; R#39	DYh
	db			8				; R#40	NXl
	db			0				; R#41	NXh
line_b_right_ny:
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

line_c:
	db			24				; R#32	SXl
	db			0				; R#33	SXh
line_c_sy:
	db			0				; R#34	SYl
	db			1				; R#35	SYh
	db			104				; R#36	DXl
	db			0				; R#37	DXh
line_c_dy:
	db			0				; R#38	DYl
line_c_dest_page:
	db			0				; R#39	DYh
	db			48				; R#40	NXl
	db			0				; R#41	NXh
line_c_ny:
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

backup_copy:
	db			80				; R#32	SXl
	db			0				; R#33	SXh
backup_copy_sy:
	db			0				; R#34	SYl
backup_copy_src_page:
	db			0				; R#35	SYh
	db			0				; R#36	DXl
	db			0				; R#37	DXh
backup_copy_dy:
	db			88 + 96 - 2		; R#38	DYl
	db			1				; R#39	DYh
	db			96				; R#40	NXl
	db			0				; R#41	NXh
backup_copy_ny:
	db			1				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

body_a:
	db			120				; R#32	SXl
	db			0				; R#33	SXh
body_a_sy:
	db			88				; R#34	SYh
	db			1				; R#35	SYh
	db			104				; R#36	DXl
	db			0				; R#37	DXh
body_a_dy:
	db			0				; R#38	DYl
body_a_dest_page:
	db			0				; R#39	DYh
	db			48				; R#40	NXl
	db			0				; R#41	NXh
body_a_ny:
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

body_b:
	db			112				; R#32	SXl
	db			0				; R#33	SXh
body_b_sy:
	db			104				; R#34	SYh
	db			1				; R#35	SYh
	db			96				; R#36	DXl
	db			0				; R#37	DXh
body_b_dy:
	db			0				; R#38	DYl
body_b_dest_page:
	db			0				; R#39	DYh
	db			64				; R#40	NXl
	db			0				; R#41	NXh
body_b_ny:
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

body_c:
	db			96				; R#32	SXl
	db			0				; R#33	SXh
body_c_sy:
	db			120				; R#34	SYh
	db			1				; R#35	SYh
	db			80				; R#36	DXl
	db			0				; R#37	DXh
body_c_dy:
	db			0				; R#38	DYl
body_c_dest_page:
	db			0				; R#39	DYh
	db			96				; R#40	NXl
	db			0				; R#41	NXh
body_c_ny:
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

body_f:
	db			96				; R#32	SXl
	db			0				; R#33	SXh
body_f_sy:
	db			136				; R#34	SYh
	db			1				; R#35	SYh
	db			80				; R#36	DXl
	db			0				; R#37	DXh
body_f_dy:
	db			0				; R#38	DYl
body_f_dest_page:
	db			0				; R#39	DYh
	db			96				; R#40	NXl
	db			0				; R#41	NXh
body_f_ny:
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

body_d:
	db			112				; R#32	SXl
	db			0				; R#33	SXh
body_d_sy:
	db			152				; R#34	SYh
	db			1				; R#35	SYh
	db			96				; R#36	DXl
	db			0				; R#37	DXh
body_d_dy:
	db			0				; R#38	DYl
body_d_dest_page:
	db			0				; R#39	DYh
	db			64				; R#40	NXl
	db			0				; R#41	NXh
body_d_ny:
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD

body_e:
	db			120				; R#32	SXl
	db			0				; R#33	SXh
body_e_sy:
	db			168				; R#34	SYh
	db			1				; R#35	SYh
	db			104				; R#36	DXl
	db			0				; R#37	DXh
body_e_dy:
	db			0				; R#38	DYl
body_e_dest_page:
	db			0				; R#39	DYh
	db			48				; R#40	NXl
	db			0				; R#41	NXh
body_e_ny:
	db			16				; R#42	NYl
	db			0				; R#43	NYh
	db			0				; R#44
	db			0				; R#45
	db			0b1101_0000		; R#46	CMD
	endscope
