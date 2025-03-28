; =============================================================================
;	XEVI���� for MSX2
; -----------------------------------------------------------------------------
;	2019/8/30	t.hara
; =============================================================================

player_sprite_pattern1::		; #0
	db			0x01, 0x03, 0x03, 0x03, 0x0F, 0x03, 0x0E, 0x1F
	db			0x2F, 0x5F, 0xBF, 0xBE, 0xBF, 0xBF, 0xBB, 0x23
	db			0x80, 0xC0, 0xC0, 0xC0, 0xF0, 0xC0, 0x70, 0xF8
	db			0xF4, 0xFA, 0xFD, 0x7D, 0xFD, 0xFD, 0xDD, 0xC4
player_sprite_pattern2::		; #4
	db			0x01, 0x03, 0x02, 0x02, 0x0E, 0x0E, 0x0F, 0x1F
	db			0x3F, 0x7F, 0xFB, 0xFB, 0xEB, 0xEB, 0xE8, 0x23
	db			0x80, 0xC0, 0x40, 0x40, 0x50, 0x70, 0xD0, 0xD0
	db			0xDC, 0xD6, 0xD7, 0xD7, 0xD7, 0xD7, 0x17, 0xC4
ando_part1_sprite_pattern1::	; #8
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F
	db			0x60, 0x30, 0x18, 0x1C, 0x0C, 0x06, 0x07, 0x03
ando_part1_sprite_pattern2::	; #12
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F
	db			0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40
	db			0xDF, 0xEF, 0xF7, 0xEB, 0xF7, 0xFD, 0xFA, 0xFD
ando_part2_sprite_pattern1::	; #16
	db			0x00, 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02
	db			0x04, 0x08, 0x14, 0x28, 0x38, 0x50, 0xB0, 0x70
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
ando_part2_sprite_pattern2::	; #20
	db			0x00, 0x00, 0x80, 0xC0, 0xE0, 0xF0, 0xF8, 0xFE
	db			0xFF, 0xFF, 0xFB, 0xF7, 0xE7, 0xEF, 0xCF, 0x8F
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x80, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC, 0xFE
ando_part3_sprite_pattern1::	; #24
	db			0x00, 0x00, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40
	db			0x80, 0xE0, 0xF8, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF
	db			0xFF, 0x7F, 0xC0, 0x70, 0x38, 0x1E, 0x07, 0x03
	db			0x05, 0x09, 0x12, 0x24, 0xC9, 0xF2, 0xFF, 0xFF
ando_part3_sprite_pattern2::	; #28
	db			0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F
	db			0xFF, 0xFF, 0xFF, 0xEF, 0xEF, 0xEF, 0xEF, 0xEF
	db			0x00, 0x80, 0x7F, 0xAF, 0xD7, 0xED, 0xFA, 0xFD
	db			0xFA, 0xF6, 0xED, 0xDB, 0xB6, 0xED, 0xF8, 0xFE
ando_part4_sprite_pattern1::	; #32
	db			0x00, 0x01, 0x02, 0x05, 0x8A, 0xF4, 0xD8, 0x30
	db			0x60, 0xD0, 0xC8, 0x24, 0x93, 0xCF, 0x7F, 0xFF
	db			0x00, 0x00, 0xC0, 0x20, 0x10, 0x08, 0x04, 0x02
	db			0x01, 0x07, 0x1F, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF
ando_part4_sprite_pattern2::	; #36
	db			0xFF, 0xFF, 0xFF, 0xFE, 0x7D, 0x3B, 0x67, 0xCF
	db			0x9F, 0x2F, 0x37, 0xDB, 0x6D, 0x36, 0x98, 0x60
	db			0x00, 0x80, 0x00, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC
	db			0xFF, 0xFE, 0xF8, 0xE0, 0x80, 0x00, 0x00, 0x00
ando_part5_sprite_pattern1::	; #40
	db			0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0xE0
	db			0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0x00
	db			0xFF, 0xFF, 0xFF, 0xFF, 0xF4, 0x92, 0x09, 0x05
	db			0x02, 0x05, 0x1B, 0x2F, 0x58, 0xA0, 0x40, 0x00
ando_part5_sprite_pattern2::	; #44
	db			0xEF, 0xEF, 0xEF, 0xEF, 0xEE, 0xF8, 0xE3, 0x9F
	db			0x3F, 0x1F, 0x0F, 0x07, 0x03, 0x01, 0x01, 0x00
	db			0xFE, 0xF8, 0xE0, 0x80, 0x0B, 0x6D, 0xF6, 0xFB
	db			0xFF, 0xFE, 0xFC, 0xF0, 0xE7, 0xDF, 0xBF, 0xFF
ando_part6_sprite_pattern1::	; #48
	db			0x80, 0xE0, 0x38, 0x97, 0x25, 0x48, 0x90, 0xA0
	db			0xC0, 0xE0, 0xF8, 0xEC, 0xC6, 0x83, 0x01, 0x00
	db			0x08, 0x08, 0x08, 0xFF, 0xFF, 0x3F, 0x0F, 0x03
	db			0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x00
ando_part6_sprite_pattern2::	; #52
	db			0x7F, 0x1F, 0xC7, 0x68, 0xDA, 0xB7, 0x6F, 0x5F
	db			0x3F, 0x1F, 0x07, 0x13, 0x39, 0x7C, 0xFE, 0xFF
	db			0xF7, 0xF7, 0xF7, 0x00, 0x00, 0xC0, 0xF0, 0xFC
	db			0xFC, 0xF8, 0xF0, 0xE0, 0xC0, 0x80, 0x00, 0x00
ando_part7_sprite_pattern1::	; #56
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x0E, 0x06, 0x05, 0x07, 0x0A, 0x14, 0x28, 0x50
	db			0x20, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0x00
ando_part7_sprite_pattern2::	; #60
	db			0x7F, 0x3F, 0x1F, 0x0F, 0x07, 0x03, 0x01, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0xF1, 0xFB, 0xFE, 0xFC, 0xFD, 0xFB, 0xF7, 0xEF
	db			0x5F, 0x1F, 0x0F, 0x07, 0x03, 0x01, 0x00, 0x00
ando_part8_sprite_pattern1::	; #64
	db			0xFC, 0xF8, 0x70, 0x20, 0x30, 0x18, 0x0C, 0x06
	db			0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
ando_part8_sprite_pattern2::	; #68
	db			0x03, 0x07, 0x8F, 0xDF, 0xCF, 0xE7, 0xF3, 0xF9
	db			0xFC, 0xF8, 0xF0, 0xE0, 0xC0, 0x80, 0x00, 0x00
	db			0xFE, 0xFC, 0xF8, 0xF0, 0xE0, 0xC0, 0x80, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
ando_shot_sprite_pattern::		; #72
	db			0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x05, 0x0B
	db			0x0B, 0x05, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0xA0, 0xD0
	db			0xD0, 0xA0, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00
flag_sprite_pattern::			; #76
	db			0x7C, 0xC6, 0xC0, 0x7C, 0x06, 0xC6, 0x7C, 0x00
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01
	db			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
	db			0xE0, 0xF8, 0xFE, 0xF8, 0xE0, 0x80, 0xC0, 0xC0

player_sprite_color1::
	db			0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03
	db			0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03
player_sprite_color2::
	db			0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x44, 0x46
	db			0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46
ando_part1_sprite_color1::
	db			0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part1_sprite_color2::
	db			0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E, 0x4E
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part2_sprite_color1::
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part2_sprite_color2::
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part3_sprite_color1::
	db			0x0D, 0x0D, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part3_sprite_color2::
	db			0x4E, 0x4E, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part4_sprite_color1::
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part4_sprite_color2::
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part5_sprite_color1::
	db			0x0C, 0x0C, 0x0C, 0x0C, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part5_sprite_color2::
	db			0x4B, 0x4B, 0x4B, 0x4B, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part6_sprite_color1::
	db			0x0C, 0x0C, 0x0C, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part6_sprite_color2::
	db			0x4B, 0x4B, 0x4B, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part7_sprite_color1::
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part7_sprite_color2::
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_part8_sprite_color1::
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
	db			0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B
ando_part8_sprite_color2::
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
	db			0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D, 0x4D
ando_shot_sprite_color1::
	db			0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A
	db			0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A
flag_sprite_color1::
	db			0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x01
	db			0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
