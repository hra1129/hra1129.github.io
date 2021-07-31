; -----------------------------------------------------------------------------
;	パレット制御
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	パレットセットを変更する
;	input:
;		a	...	パレットセットの番号 [0～7]
;	output
;		なし
;	break
;		
;	comment
;		16色パレットの設定値を集めたデータをパレットセットと呼ぶことにする。
;		本ソース最後についている複数のパレットセットの中から所望のセットを指定
;		する。
; -----------------------------------------------------------------------------
change_palette::
		; hl = a * 32 + palette_set0
		rlca
		rlca
		rlca
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		bc, palette_set0
		add		hl, bc
		ld		[palette_adr], hl
change_palette_sub:
		; VDP R16 = 0 [palette0 から設定する]
		xor		a, a
		di					; 割り込み処理中も VDP_CMDREG_IO を使うので割禁排他
		out		[VDP_CMDREG_IO], a
		ld		a, 16 + 0x80
		out		[VDP_CMDREG_IO], a
		ei					; これ以降は排他必要なし
		ld		a, [palette_fade]
		ld		b, a
		rlca
		rlca
		rlca
		rlca
		or		a, b
		ld		c, a
		ld		b, 16
change_palette_loop:
		; 赤と青
		ld		a, [hl]
		inc		hl
		or		a, 0x88		; &B1XXX1XXX にする
		sub		a, c
		jp		m, change_palette_skip1
		and		a, 0x0F		; 赤が bit7 に桁借りした場合 0 にクリア
change_palette_skip1:
		bit		3, a
		jp		nz, change_palette_skip2
		and		a, 0xF0		; 青が bit3 に桁借りした場合 0 にクリア
change_palette_skip2:
		and		a, 0x77
		out		[VDP_PALREG_IO], a
		; 緑
		ld		a, [hl]
		inc		hl
		or		a, 0x08		; &B00001XXX にする
		sub		a, c
		bit		3, a
		jp		nz, change_palette_skip3
		xor		a, a			; 緑が bit3 に桁借りした場合 0 にクリア
change_palette_skip3:
		and		a, 0x07
		out		[VDP_PALREG_IO], a
		djnz	change_palette_loop
		ret

; -----------------------------------------------------------------------------
;	パレットのフェードアウト・イン
;	input
;		a	...	フェードアウト量（0:そのまま ～ 7:真っ黒）
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
fade_palette::
		ld		[palette_fade], a
		ld		hl, [palette_adr]
		jp		change_palette_sub

; -----------------------------------------------------------------------------
;	パレットフェード設定
palette_fade:
		db		0
palette_adr:
		dw		palette_set0

; -----------------------------------------------------------------------------
;	パレットデータ[1set 32byte]
palette_set0:	;  RB     -G		; タイトル・stage1 の色 [昼]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x11, 0x06		; 2
		db		0x33, 0x07		; 3
		db		0x17, 0x01		; 4
		db		0x27, 0x03		; 5
		db		0x51, 0x01		; 6
		db		0x27, 0x06		; 7
		db		0x71, 0x01		; 8
		db		0x73, 0x03		; 9
		db		0x61, 0x06		; 10
		db		0x63, 0x06		; 11
		db		0x11, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x44, 0x04		; 14
		db		0x77, 0x07		; 15

palette_set1:	;  RB     -G		; stage2 の色 [夕方]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x21, 0x06		; 2
		db		0x43, 0x07		; 3
		db		0x27, 0x01		; 4
		db		0x37, 0x03		; 5
		db		0x50, 0x01		; 6
		db		0x37, 0x06		; 7
		db		0x70, 0x01		; 8
		db		0x72, 0x03		; 9
		db		0x71, 0x06		; 10
		db		0x73, 0x06		; 11
		db		0x10, 0x04		; 12
		db		0x75, 0x02		; 13
		db		0x64, 0x04		; 14
		db		0x77, 0x07		; 15

palette_set2:	;  RB     -G		: stage3 の色 [夜]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x04, 0x05		; 2
		db		0x05, 0x06		; 3
		db		0x07, 0x01		; 4
		db		0x07, 0x03		; 5
		db		0x33, 0x00		; 6
		db		0x07, 0x06		; 7
		db		0x65, 0x00		; 8
		db		0x75, 0x02		; 9
		db		0x63, 0x04		; 10
		db		0x63, 0x05		; 11
		db		0x03, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x44, 0x04		; 14
		db		0x66, 0x06		; 15

palette_set3:	;  RB     -G		; stage4 の色 [朝焼け]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x31, 0x06		; 2
		db		0x53, 0x07		; 3
		db		0x37, 0x01		; 4
		db		0x47, 0x03		; 5
		db		0x50, 0x00		; 6
		db		0x47, 0x06		; 7
		db		0x70, 0x00		; 8
		db		0x72, 0x02		; 9
		db		0x71, 0x06		; 10
		db		0x73, 0x06		; 11
		db		0x20, 0x04		; 12
		db		0x75, 0x03		; 13
		db		0x64, 0x04		; 14
		db		0x76, 0x06		; 15

palette_set4:	;  RB     -G		; stage5 の色 [昼]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x11, 0x06		; 2
		db		0x33, 0x07		; 3
		db		0x17, 0x01		; 4
		db		0x27, 0x03		; 5
		db		0x51, 0x01		; 6
		db		0x27, 0x06		; 7
		db		0x71, 0x01		; 8
		db		0x73, 0x03		; 9
		db		0x61, 0x06		; 10
		db		0x63, 0x06		; 11
		db		0x11, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x55, 0x05		; 14
		db		0x77, 0x07		; 15

palette_set5:	;  RB     -G		; stage6 の色 [夕方]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x21, 0x06		; 2
		db		0x43, 0x07		; 3
		db		0x27, 0x01		; 4
		db		0x37, 0x03		; 5
		db		0x50, 0x01		; 6
		db		0x37, 0x06		; 7
		db		0x70, 0x01		; 8
		db		0x72, 0x03		; 9
		db		0x71, 0x06		; 10
		db		0x73, 0x06		; 11
		db		0x10, 0x04		; 12
		db		0x75, 0x02		; 13
		db		0x64, 0x04		; 14
		db		0x77, 0x07		; 15

palette_set6:	;  RB     -G		: stage7 の色 [夜]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x04, 0x05		; 2
		db		0x05, 0x06		; 3
		db		0x07, 0x01		; 4
		db		0x07, 0x03		; 5
		db		0x33, 0x00		; 6
		db		0x07, 0x06		; 7
		db		0x65, 0x00		; 8
		db		0x75, 0x02		; 9
		db		0x63, 0x04		; 10
		db		0x63, 0x05		; 11
		db		0x03, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x44, 0x04		; 14
		db		0x66, 0x06		; 15

palette_set7:	;  RB     -G		: stage8 の色 [基地]
		db		0x00, 0x00		; 0
		db		0x00, 0x00		; 1
		db		0x11, 0x06		; 2
		db		0x33, 0x07		; 3
		db		0x14, 0x02		; 4
		db		0x27, 0x03		; 5
		db		0x60, 0x00		; 6
		db		0x07, 0x07		; 7
		db		0x70, 0x03		; 8
		db		0x73, 0x04		; 9
		db		0x70, 0x07		; 10
		db		0x73, 0x07		; 11
		db		0x11, 0x04		; 12
		db		0x65, 0x02		; 13
		db		0x55, 0x05		; 14
		db		0x77, 0x07		; 15
