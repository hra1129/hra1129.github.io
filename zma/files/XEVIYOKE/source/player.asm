; =============================================================================
;	XEVI”ð‚¯ for MSX2
; -----------------------------------------------------------------------------
;	2019/8/30	t.hara
; =============================================================================

; =============================================================================
;	player move
; =============================================================================
	scope		player_move
player_initializer::
	xor			a, a
	ld			[player_is_crashed], a
	ld			a, 106-8
	ld			[player_y], a
	ld			a, 128-8
	ld			[player_x], a
	ret

player_move::
	;	Is player clashed?
	ld			a, [player_is_crashed]
	or			a, a
	jp			nz, clashed_effect

	;	get stick value
	xor			a, a
	call		gtstick		; get stick(0)
	push		af
	ld			a, 1
	call		gtstick		; get stick(1)
	pop			bc
	or			a, b
	ld			c, a
	ld			b, 0
	ld			hl, direction_y_table
	adc			hl, bc
	ld			c, [hl]		; b = direction_y_table[ stick(0) or stick(1) ]
	ld			a, [player_y]
	add			a, c

	cp			a, 16 - 2
	jp			nz, skip0
	ld			a, 16
skip0:
	cp			a, 192 - 16 + 2
	jp			nz, skip1
	ld			a, 192 - 16
skip1:
	ld			e, a
	ld			[player_y], a

	ld			c, 9
	add			hl, bc
	ld			c, [hl]		; b = direction_x_table[ stick(0) or stick(1) ]
	ld			a, [player_x]
	add			a, c

	cp			a, 0 - 2
	jp			nz, skip2
	xor			a, a
skip2:
	cp			a, 240 + 2
	jp			nz, skip3
	ld			a, 240
skip3:
	ld			d, a
	ld			[player_x], a
put_player:
	xor			a, a
	ld			b, a
	ld			hl, player_sprite_color1
	call		sd_put_sprite_pair
	ret

clashed_effect:
	dec			a
	ld			[player_is_crashed], a

	and			a, 1
	jp			z, clashed_effect_blind
	
	ld			a, [player_x]
	ld			d, a
	ld			a, [player_y]
	ld			e, a
	jp			put_player

clashed_effect_blind:
	ld			e, 192
	jp			put_player

direction_y_table:
	db			0			; 0
	db			-2			; 1
	db			-2 			; 2
	db			0 			; 3
	db			2 			; 4
	db			2 			; 5
	db			2 			; 6
	db			0			; 7
	db			-2			; 8
direction_x_table:
	db			0			; 0
	db			0			; 1
	db			2			; 2
	db			2			; 3
	db			2			; 4
	db			0			; 5
	db			-2			; 6
	db			-2			; 7
	db			-2			; 8
player_y::
	db			0
player_x::
	db			0
player_is_crashed::
	db			0
	endscope
