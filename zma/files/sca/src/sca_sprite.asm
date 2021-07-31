; -----------------------------------------------------------------------------
;	スプライト表示更新処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	DRAM上のスプライトアトリビュートテーブルイメージを初期化
;	input:
;		なし
;	output
;		なし
;	break
;		a,b,c,d,e,f
;	comment
;		なし
; -----------------------------------------------------------------------------
sprite_init::
		; スプライトアトリビュートテーブルを 212 で初期化する
		ld		hl, sprite_attribute_table
		ld		de, sprite_attribute_table + 1
		ld		bc, 4*32 - 1
		ld		[hl], 212
		ldir
		; スプライトパターン番号を初期化
		ld		b, 32
		ld		de, sprite_pattern_data
		ld		hl, sprite_attribute_table + 2
sprite_init_loop1:
		ld		a, [de]
		ld		[hl], a
		inc		de
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		djnz	sprite_init_loop1
		ret

; -----------------------------------------------------------------------------
;	スプライトカラーをセットする
;	input
;		a ...	スプライト番号[0～31]
;		c ...	色データ
;	output
;		なし
;	break
;		全て
;	comment
;		COLOR SPRITE[a] = c に相当
; -----------------------------------------------------------------------------
sprite_set_color::
		; hl = SPRITE_COLOR + a * 16
		ld		hl, SPRITE_COLOR
		rlca			; cフラグは必ず 0
		rlca			; cフラグは必ず 0
		rlca			; cフラグは必ず 0
		rlca
		jr		nc, sprite_set_color_skip1
		inc		h
sprite_set_color_skip1:
		ld		l, a	; SPRITE_COLOR の下位8bit は 0x00 なので a+l は a と同じ。なので代入だけで良い。
		; a = 色データ
		ld		a, c
		; bc = 16
		ld		bc, 16
		jp		FILVRM

; -----------------------------------------------------------------------------
;	DRAM上のスプライトアトリビュートテーブルイメージを更新
;	input:
;		ix	...	情報テーブルのアドレス
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
sprite_update::
		; 情報テーブルの座標をDRAM上のアトリビュートテーブルイメージへ転送
		ld		de, SCA_INFO_SIZE
		ld		hl, sprite_attribute_table
		ld		b, 32
sprite_update_loop:
		ld		a, [ix + SCA_INFO_YH]
		ld		[hl], a
		inc		hl
		ld		a, [ix + SCA_INFO_XH]
		ld		[hl], a
		inc		hl
		inc		hl
		inc		hl
		add		ix, de
		djnz	sprite_update_loop
sprite_update_player:
		; 自機が無敵状態か？
		ld		a, [player_invincibility]
		or		a, a
		jr		z, sprite_update_transfer
		inc		a
		jr		z, sprite_update_transfer
		; 1/30のタイミングか？
		ld		a, [software_timer]
		and		a, 1
		jr		z, sprite_update_transfer
		; 自機を非表示にする（点滅させる）
		ld		a, 212
		ld		[sprite_attribute_table + 0], a
		ld		[sprite_attribute_table + 4], a
sprite_update_transfer:
		; アトリビュートテーブルイメージをVRAMへ転送
		ld		hl, sprite_attribute_table
		ld		de, SPRITE_ATTRIBUTE
		ld		bc, 4*32
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	スプライトを全消去する
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
sprite_all_clear::
		ld		b, 32
		ld		hl, sprite_attribute_table
		ld		a, 212
sprite_all_clear_loop:
		ld		[hl], a
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		djnz	sprite_all_clear_loop
		jp		sprite_update_transfer

sprite_attribute_table::
		repeat i, 32				; [+0:Y座標, +1:X座標, +2:パターン番号, +3:未使用] が 32枚分
			db	0, 0, 0, 0
		endr

sprite_pattern_data:
		db		0 , 4 , 12, 16, 24, 28, 32, 36
		db		40, 44, 48, 52, 56, 60, 20, 20
		db		20, 20, 20, 20, 20, 20, 20, 20
		db		20, 20, 20, 20, 20, 8 , 8 , 8 
