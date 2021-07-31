; =============================================================================
;	XEVI”ð‚¯ for MSX2
; -----------------------------------------------------------------------------
;	2019/9/15	t.hara
; =============================================================================

; =============================================================================
;	interrupt
; =============================================================================
	scope		interrupt_process
interrupt_initializer::
	; initialize interrupt hooks
	di
	;	h_keyi
	ld			hl, h_keyi			; Source address
	ld			de, h_keyi_next		; Destination address
	ld			bc, 5				; Transfer length
	ldir							; Block transfer

	ld			a, 0xC3				; 'jp xxxx' code
	ld			[h_keyi], a			; hook update
	ld			hl, h_keyi_interrupt_handler
	ld			[h_keyi + 1], hl
	ld			hl, h_keyi_next		; set pass through
	ld			[hsync_interrupt_address + 1], hl

	;	h_timi
	ld			hl, h_timi			; Source address
	ld			de, h_timi_next		; Destination address
	ld			bc, 5				; Transfer length
	ldir							; Block transfer

	ld			a, 0xC3				; 'jp xxxx' code
	ld			[h_timi], a			; hook update
	ld			hl, h_timi_next		; set pass through
	ld			[h_timi + 1], hl
	ei
	ret

title_interrupt_initializer::
	di
	ld			hl, h_keyi_next
	ld			[hsync_interrupt_address + 1], hl
	ld			hl, h_timi_interrupt_handler_for_title
	ld			[h_timi + 1], hl

	ld			c, IO_VDP_PORT1
	;	R#0 = R#0 or 0b0001_0000 : Set disable to Horizontal sync interrupt.
	ld			a, [REG0SAV]
	and			a, 0b1110_1111
	out			[c], a
	ld			a, 0 | 0x80
	out			[c], a

	;	R#23 = 0
	xor			a, a
	out			[c], a
	ld			a, 23 | 0x80
	out			[c], a

	;	R#15 = 1  : This is status register pointer.
	ld			a, 1					; S#1
	out			[c], a
	ld			a, 15 | 0x80
	out			[c], a
	in			a, [c]					; clear horizontal sync interrupt flag.

	;	R#15 = 0
	ld			b, 0					; S#0
	out			[c], b
	ld			b, 15 | 0x80
	out			[c], b
	ei
	ret

main_interrupt_initializer::
	di
	ld			hl, h_keyi_next
	ld			[hsync_interrupt_address + 1], hl
	ld			hl, h_timi_interrupt_handler
	ld			[h_timi + 1], hl

	ld			c, IO_VDP_PORT1
	;	R#23 = 64
	ld			a, 64
	out			[c], a
	ld			a, 23 | 0x80
	out			[c], a
	;	R#19 = 63
	ld			a, 63
	out			[c], a
	ld			a, 19 | 0x80
	out			[c], a
	;	R#0 = R#0 or 0b0001_0000 : Set enable to Horizontal sync interrupt.
	ld			a, [REG0SAV]
	or			a, 0b0001_0000
	out			[c], a
	ld			a, 0 | 0x80
	out			[c], a
	ei
	ret
	endscope

; =============================================================================
;	H.TIMI interrupt handler for title
; =============================================================================
	scope		h_timi_interrupt_handler_for_title
h_timi_interrupt_handler_for_title::
	call		bgmdriver_interrupt_handler
	call		sd_change_attribute0
	call		title_tick
	ret
	endscope

; =============================================================================
;	H.TIMI interrupt handler
; =============================================================================
	scope		h_timi_interrupt_handler
h_timi_interrupt_handler::
	;	Display SCORE area
	ld			c, IO_VDP_PORT1
	;	R#2 = 0b0011_1111 : Set display page to 1
	ld			a, 0b0011_1111
	out			[c], a
	ld			a, 2 | 0x80
	out			[c], a
	;	R#23 = 64
	ld			a, 64
	out			[c], a
	ld			a, 23 | 0x80
	out			[c], a
	;	R#19 = 64 + 16
	ld			a, 64 + 16 - hsync_intr_adjust
	out			[c], a
	ld			a, 19 | 0x80
	out			[c], a
	; Sprite Doubler
	call		sd_change_attribute0

	;	next hsync interrupt address
	ld			hl, hsync_interrupt_1st
	ld			[hsync_interrupt_address + 1], hl

	;	change vsync flag to 1
	ld			a, 1
	ld			[vsync_flag], a
vsync_flag_skip:

h_timi_next::
	ret
	ret
	ret
	ret
	ret
	endscope

; =============================================================================
;	H.KEYI interrupt handler
; =============================================================================
	scope		h_keyi_interrupt_handler
h_keyi_interrupt_handler::
	; Is this Horizontal sync interrupt?
	ld			c, IO_VDP_PORT1
	;	R#15 = 1  : This is status register pointer.
	ld			a, 1					; S#1
	out			[c], a
	ld			a, 15 | 0x80
	out			[c], a
	in			a, [c]

	;	R#15 = 0
	ld			b, 0					; S#0
	out			[c], b
	ld			b, 15 | 0x80
	out			[c], b

	;	Check FH bit (bit0).
	rrca
hsync_interrupt_address::
	jp			c, hsync_interrupt_1st			; Goto old h_keyi hook when this is not Horizontal interrupt.
	jp			h_keyi_next

hsync_interrupt_2nd::
	;	Sprite Doubler
	call		sd_change_attribute2
	;	BGM Driver
	call		bgmdriver_interrupt_handler
	ret											; jp			h_keyi_next

hsync_interrupt_1st::
	;	Display MAIN area
	ld			a, [draw_page]
	or			a, a
	;	R#2 = 0b0101_1111 : Set display page to 2
	ld			a, 0b0101_1111
	jp			z, set_display_page
	;	R#2 = 0b0001_1111 : Set display page to 0
	ld			a, 0b0001_1111
set_display_page:
	out			[c], a
	ld			a, 2 | 0x80
	out			[c], a
	; Change vertical scroll and care of horizontal sync interrupt.
	;	R#23 = vscroll
	ld			a, [vscroll]
	out			[c], a
	ld			b, 23 | 0x80
	out			[c], b
	;	R#19 = vscroll + 104 - adj
	add			a, 104 - hsync_intr_adjust
	out			[c], a
	ld			a, 19 | 0x80
	out			[c], a
	;	Sprite Doubler
	call		sd_change_attribute1

	; next hsync interrupt
	ld			hl, hsync_interrupt_2nd
	ld			[hsync_interrupt_address + 1], hl

	ret											; call		bigchar_bg_move_intr2

h_keyi_next::
	ret
	ret
	ret
	ret
	ret
	endscope
