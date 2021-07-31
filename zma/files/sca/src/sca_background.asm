; -----------------------------------------------------------------------------
;	背景表示更新処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	ゲーム画面の表示を初期化する
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_init_game_screen::
		; スクロールカウンター初期化
		xor		a, a
		ld		[background_scroll_timing], a
		; 右側スコア表示領域をスペースで埋め尽くす
		ld		hl, PATTERN_NAME1 + 24					; locate 24,0
		ld		bc, 8									; 幅は 8文字分
		ld		e, 24									; 24ラインある
background_init_score_area_loop1:
		push	de
		push	bc
		xor		a, a										; スペースの文字コードは 0
		call	FILVRM									; 0 で塗りつぶす
		pop		bc
		ld		de, 32									; 次のラインへのオフセット
		add		hl, de
		pop		de
		dec		e
		jr		nz, background_init_score_area_loop1
background_init_put_score:
		; "HISCORE" を表示
		ld		hl, background_str_hiscore
		ld		de, PATTERN_NAME1 + 24 + 32*1		; locate 24,1
		ld		bc, 7
		call	LDIRVM
		; "SCORE" を表示
		ld		hl, background_str_score
		ld		de, PATTERN_NAME1 + 24 + 32*5		; locate 24,5
		ld		bc, 5
		call	LDIRVM
		; スコア表示更新
		call	score_update_high_score
		call	score_update
		; 自機情報表示更新
		call	background_update_player_info
		ret

; -----------------------------------------------------------------------------
;	自機情報を表示
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_update_player_info::
		; 自機情報を収集
		ld		a, [player_speed]
		inc		a
		ld		[background_str_speed_num], a
		ld		a, [player_shot]
		inc		a
		ld		[background_str_shot_num], a
		ld		a, [player_shield]
		inc		a
		ld		[background_str_shield_num], a
		; "SPEED x" を表示
		ld		hl, background_str_speed
		ld		de, PATTERN_NAME1 + 24 + 32*18			; locate 24,18
		ld		bc, 7
		call	LDIRVM
		; "SHOT  x" を表示
		ld		hl, background_str_shot
		ld		de, PATTERN_NAME1 + 24 + 32*20			; locate 24,20
		ld		bc, 7
		call	LDIRVM
		; "SHIELDx" を表示
		ld		hl, background_str_shield
		ld		de, PATTERN_NAME1 + 24 + 32*22			; locate 24,22
		ld		bc, 7
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	ゲーム画面の表示を初期化する
;	input:
;		a	...	ステージ番号 [0 = stage1]
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_draw_stage_x::
		; "STAGEx" を表示
		and		a, 7
		inc		a
		inc		a
		ld		[background_str_stage_number], a
		dec		a
		dec		a
		; 背景データのアドレスを HL に取得する
		rlca
		ld		l, a
		ld		h, 0
		ld		de, background_stage_address
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		; 背景データを描画する
		ld		a, 2
		ld		[background_is_odd], a
		ld		b, 24									; 24ライン
		ld		de, sca_screen_buffer + 576 + 576 - 24	; 下から描画する
background_draw_stage_x_loop:
		ld		a, [hl]									; 背景データは１画面分は用意してある前提。なのでループ等のチェックは無し。
		push	bc
		push	hl
		call	background_draw_parts
		ex		de, hl
		ld		de, -24-24								; background_draw_parts で DE は１つ次のラインを示すため、2ライン戻る
		add		hl, de
		ex		de, hl
		pop		hl
		pop		bc
		; 上半分と下半分を切り替える
		ld		a, [background_is_odd]
		xor		a, 2
		ld		[background_is_odd], a
		jr		z, background_draw_stage_x_skip1
		; 新しい下半分の時にアドレスをインクリメント
		inc		hl
background_draw_stage_x_skip1:
		djnz	background_draw_stage_x_loop
		; 背景データのアドレスをメモリに保持する
		ld		[background_stage_pointer], hl
		; 仮想画面を更新する
		ld		hl, sca_screen_buffer
		ld		de, sca_screen_buffer + 1
		ld		bc, 576-1
		xor		a, a
		ld		[hl], a
		ldir
		; "STAGEx" を表示
		ld		hl, background_str_stage
		ld		de, sca_screen_buffer + 9 + 24*8			; locate 9,8
		ld		bc, 6
		ldir
		; 背景更新フラグを立てる
		ld		a, 1
		ld		[background_update], a
		ret

; -----------------------------------------------------------------------------
;	ゲーム画面の STAGE*/WARNING!! の表示を消去する
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_delete_stage_message::
		ld		hl, sca_screen_buffer + 8 + 24*8			; locate 8,8
		ld		de, sca_screen_buffer + 8 + 24*8 + 1
		ld		bc, 9-1
		xor		a, a
		ld		[hl], a
		ldir
		ret

; -----------------------------------------------------------------------------
;	ゲーム画面に WARNING!! を表示
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_show_warning::
		ld		hl, background_str_warning
		ld		de, sca_screen_buffer + 8 + 24*8			; locate 8, 8
		ld		bc, 9
		ldir
		ret

; -----------------------------------------------------------------------------
;	左側をクリア
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_clear_left_side:
		; フィールド部分（スコア表示部以外の部分）を初期化する
		ld		c, VDP_VRAM_IO
		ld		hl, PATTERN_NAME1
		ld		de, 0
		ld		b, 24									; 24ラインある
background_clear_left_side_loop2:
		push	bc
		call	SETWRT
		ld		b, 24									; 幅は 24文字分
		ld		d, 0
		xor		a, a
background_clear_left_side_loop1:
		out		[c], a
		djnz	background_clear_left_side_loop1
		ld		de, 32									; 次のラインへのオフセット
		add		hl, de
		pop		bc
		djnz	background_clear_left_side_loop2
		ret

; -----------------------------------------------------------------------------
;	ゲームクリア画面の初期化
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_init_stage_clear_screen::
		; 左側をクリア
		call	background_clear_left_side
		; STAGE CLEAR! 表示
		ld		hl, background_str_stage_clear
		ld		de, PATTERN_NAME1 + 6 + 32*5			; locate 6,5
		ld		bc, 12
		call	LDIRVM
		; CLEAR BONUS 10000 表示
		ld		hl, background_str_clear_bonus
		ld		de, PATTERN_NAME1 + 3 + 32*11			; locate 3,11
		ld		bc, 17
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	ゲームオーバー画面の初期化
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_init_gameover_screen::
		; 左側をクリア
		call	background_clear_left_side
		; GAMEOVER 表示
		ld		hl, background_str_gameover
		ld		de, PATTERN_NAME1 + 8 + 32*10		; locate 8,10
		ld		bc, 9
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	背景に１ライン分を描画する
;	input:
;		a	...	パーツ番号[0～127]
;		de	...	描画先アドレス
;	output
;		なし
;	break
;		全て
;	comment
;		上半分なら background_is_odd に 0 を、下半分なら 3 を入れておく
;		de は次のラインの頭を示す位置に変化する
; -----------------------------------------------------------------------------
background_draw_parts:
		; HL = A*12 + background_map_parts = A*8+A*4 + background_map_parts
		ld		l, a
		ld		h, 0
		add		hl, hl
		add		hl, hl
		push	hl
		add		hl, hl
		pop		bc
		add		hl, bc
		ld		bc, background_map_parts
		add		hl, bc
		; 12個描画
		ld		b, 12
background_draw_loop:
		ld		a, [background_is_odd]		; 上半分か下半分か
		add		a, [hl]						; パーツ番号取得
		ld		[de], a						; 左半分を描画
		inc		a
		inc		de
		ld		[de], a						; 右半分を描画
		inc		de
		inc		hl
		djnz	background_draw_loop
		ret

; -----------------------------------------------------------------------------
;	背景のスクロール
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_scroll::
		; スクロールするタイミングか？
		ld		a, [background_scroll_timing]
		dec		a
		and		a, 15
		ld		[background_scroll_timing], a
		ret		nz
		; 背景更新フラグを立てる
		ld		a, 1
		ld		[background_update], a
		; 背景イメージをスクロールさせる
		ld		de, sca_screen_buffer + 576 * 2 - 1
		ld		hl, sca_screen_buffer + 576 * 2 - 1 - 24
		ld		bc, 24 * 23
		lddr
		; 背景データから 1byte 読み取る
		ld		hl, [background_stage_pointer]
		ld		a, [hl]
		cp		a, 0x80
		jr		c, background_scroll_update_line
		; 0x80 の場合は戻る
background_scroll2::
		inc		hl
		ld		a, l
		sub		a, [hl]
		ld		l, a
		jr		nc, background_scroll_skip0
		dec		h
background_scroll_skip0:
		ld		a, [hl]
		ld		[background_stage_pointer], hl
background_scroll_update_line:
		; 背景の一番上のラインに新しい背景を描画
		ld		de, sca_screen_buffer + 576
		call	background_draw_parts
		; 上半分と下半分を切り替える
		ld		a, [background_is_odd]
		xor		a, 2
		ld		[background_is_odd], a
		jr		z, background_scroll_skip1
		; 新しい下半分の時にアドレスをインクリメント
		ld		hl, [background_stage_pointer]
		inc		hl
		ld		[background_stage_pointer], hl
background_scroll_skip1:
		ret

; -----------------------------------------------------------------------------
;	背景を画面へ転送
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_transfer::
		; 背景が更新されていなければ何もしない
		ld		a, [background_update]
		or		a, a
		ret		z
		xor		a, a
		ld		[background_update], a
		; 背景グラフィックとオーバーラップ文字を合成しながら VRAM へ転送する
		ld		hl, PATTERN_NAME1						; 転送先 VRAM アドレス
		ld		de, sca_screen_buffer					; 転送元 DRAM アドレス
		ld		b, 24									; 24ラインある
background_transfer_loop1:
		push	bc
		push	hl										; 転送先 VRAM アドレスを保存する
		call	SETWRT									; 転送先 VRAM アドレスを VDP にセットする
		ld		l, e									; HL = 転送元 DRAM アドレス + 576
		ld		h, d
		ld		bc, 576
		add		hl, bc
		ld		bc, 24 * 256 + VDP_VRAM_IO				; B = 24, C = VDP_VRAM_IO: 幅は 24文字分
background_transfer_loop2:
		ld		a, [de]									; 転送元 DRAM アドレス の内容を取得
		or		a, a										; それは ゼロ か？
		jp		nz, background_transfer_skip1
		ld		a, [hl]									; ゼロの場合は、転送元 DRAM アドレス + 576 の内容を取得
background_transfer_skip1:
		inc		de										; アドレスインクリメント
		inc		hl										; アドレスインクリメント
		out		[c], a									; VRAM へ書き出す
		djnz	background_transfer_loop2				; 24文字分繰り返す
		pop		hl										; 転送先 VRAM アドレスを復帰
		ld		bc, 32									; 転送先 VRAM アドレスを更新する
		add		hl, bc
		pop		bc
		djnz	background_transfer_loop1
		ret

; -----------------------------------------------------------------------------
;	グラフィック座標で指示された場所にある背景キャラクタコードを返す
;	input:
;		h	...	X座標
;		l	...	Y座標
;	output
;		a	...	キャラクタコード
;		hl	...	仮想メモリアドレス
;	break
;		a, d, e, h, l, f
;	comment
;		sca_screen_buffer[ 576 + h/8 + l/8*24 ]
;		→ sca_screen_buffer[ 576 + h/8 + [l & 0xF8]*3 ]
; -----------------------------------------------------------------------------
background_get_char::
		ld		a, h
		srl		a
		srl		a
		srl		a
		ld		e, a		; e = h/8
		ld		a, l
		and		a, 0xF8		; Cフラグ = 0
		ld		l, a		; l = l & 0xF8
		rl		a
		ld		h, 0
		rl		h			; ha = [l & 0xF8] * 2
		add		a, l
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = [l & 0xF8] * 3
		ld		a, l
		add		a, e
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = h/8 + [l & 0xF8] * 3
		ld		de, sca_screen_buffer + 576
		add		hl, de
		ld		a, [hl]
		ret

; -----------------------------------------------------------------------------
;	グラフィック座標で指示された場所にある前景キャラクタコードを返す
;	input:
;		h	...	X座標
;		l	...	Y座標
;	output
;		a	...	キャラクタコード
;		hl	...	仮想メモリアドレス
;	break
;		a, d, e, h, l, f
;	comment
;		sca_screen_buffer[ h/8 + l/8*24 ]
;		→ sca_screen_buffer[ h/8 + [l & 0xF8]*3 ]
; -----------------------------------------------------------------------------
background_get_fore_char::
		ld		a, h
		srl		a
		srl		a
		srl		a
		ld		e, a		; e = h/8
		ld		a, l
		and		a, 0xF8		; Cフラグ = 0
		ld		l, a		; l = l & 0xF8
		rl		a
		ld		h, 0
		rl		h			; ha = [l & 0xF8] * 2
		add		a, l
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = [l & 0xF8] * 3
		ld		a, l
		add		a, e
		ld		l, a
		ld		a, h
		adc		a, 0
		ld		h, a		; hl = h/8 + [l & 0xF8] * 3
		ld		de, sca_screen_buffer
		add		hl, de
		ld		a, [hl]
		ret

; -----------------------------------------------------------------------------
;	グラフィックパーツを書き換える
;	input:
;		hl	...	仮想メモリアドレス
;		a	...	新しいパーツの左上キャラクタコード
;	output
;		なし
;	break
;		a, d, e, h, l, f
;	comment
;		なし
; -----------------------------------------------------------------------------
background_put_char::
		ld		e, a		; 保存
		; hl の位置をパーツの左上になるように補正する
		ld		a, [hl]
		and		a, 3
		jr		z, background_put_char_skip1	; 下位2bit が 0 なら補正の必要なし
		cp		a, 2
		jr		c, background_put_char_skip2	; 1 なら Y方向の補正は必要なし
		ld		bc, -24
		add		hl, bc							; Y方向に補正
		and		a, 1
		jr		z, background_put_char_skip1
background_put_char_skip2:
		dec		hl								; X方向に補正
background_put_char_skip1:
		; 新しいキャラクタを書き込む
		ld		a, e
		ld		[hl], a							; 左上
		inc		hl
		inc		a
		ld		[hl], a							; 右上
		ld		bc, 23
		add		hl, bc
		inc		a
		ld		[hl], a							; 左下
		inc		hl
		inc		a
		ld		[hl], a							; 右下
		; 背景更新フラグを立てる
		ld		a, 1
		ld		[background_update], a
		ret

; -----------------------------------------------------------------------------
;	ラスボス左パーツを描画する
;	input:
;		e	...	X座標
;		d	...	Y座標	[0～13]
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
draw_boss8_left::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0～13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; 転送元
		ld		de, background_boss8_left
		ld		a, 11
		ld		[background_update], a			; 次回更新するように background_update を 0以外 にしておく
		; 転送
draw_boss8_left_loop:
		ex		de, hl
		ld		bc, 8
		ldir
		ex		de, hl
		ld		bc, 24-8
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_left_loop
		ret

; -----------------------------------------------------------------------------
;	ラスボス右パーツを描画する
;	input:
;		e	...	X座標
;		d	...	Y座標	[0～13]
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
draw_boss8_right::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0～13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; 転送元
		ld		de, background_boss8_right
		ld		a, 11
		ld		[background_update], a			; 次回更新するように background_update を 0以外 にしておく
		; 転送
draw_boss8_right_loop:
		ex		de, hl
		ld		bc, 8
		ldir
		ex		de, hl
		ld		bc, 24-8
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_right_loop
		ret

; -----------------------------------------------------------------------------
;	ラスボス左右パーツを消去する
;	input:
;		e	...	X座標
;		d	...	Y座標	[0～13]
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
draw_boss8_delete::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0～13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; 転送元
		ld		a, 11
		ld		[boss_center_update], a			; 中央パーツを更新する
		ld		[background_update], a			; 次回更新するように background_update を 0以外 にしておく
		; 転送
draw_boss8_delete_loop:
		ld		e, l
		ld		d, h
		ld		[hl], 0
		inc		de
		ld		bc, 7
		ldir
		ld		bc, 24-7
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_delete_loop
		ret

; -----------------------------------------------------------------------------
;	ラスボス中央パーツを描画する1
;	input:
;		e	...	X座標
;		d	...	Y座標	[0～13]
;	output
;		なし
;	break
;		
;	comment
;		0 番のキャラは描かない
; -----------------------------------------------------------------------------
draw_boss8_center::
		inc		d
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0～13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer+1
		add		hl, bc
		; 転送元
		ld		de, background_boss8_center+1+9
		ld		c, 6
		ld		[background_update], a			; 次回更新するように background_update を 0以外 にしておく
		; 転送
draw_boss8_center_loop1:
		push	bc
		ld		b, 7
draw_boss8_center_loop2:
		ld		a, [de]
		or		a, a
		jp		z, draw_boss8_center_skip1
		ld		[hl], a
draw_boss8_center_skip1:
		inc		de
		inc		hl
		djnz	draw_boss8_center_loop2
		inc		de
		inc		de
		ld		bc, 24-7
		add		hl, bc
		pop		bc
		dec		c
		jp		nz, draw_boss8_center_loop1
		ret

; -----------------------------------------------------------------------------
;	ラスボス中央パーツを描画する2
;	input:
;		e	...	X座標
;		d	...	Y座標	[0～13]
;		a	...	0: 弱点を描画, 0以外: 弱点を描画しない
;	output
;		なし
;	break
;		
;	comment
;		0 番のキャラも描く
; -----------------------------------------------------------------------------
draw_boss8_center2::
		push	af
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0～13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; 転送元
		ld		de, background_boss8_center
		pop		af
		or		a, a
		ld		a, 8
		jp		z, draw_boss8_center2_skip1
		dec		a
draw_boss8_center2_skip1:
		ld		[background_update], a			; 次回更新するように background_update を 0以外 にしておく
		; 転送
draw_boss8_center2_loop:						; 弱点も描画する場合
		ex		de, hl
		ld		bc, 9
		ldir
		ex		de, hl
		ld		bc, 24-9
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_center2_loop
		; 下側を消去
		ld		e, l
		ld		d, h
		inc		de
		xor		a, a
		ld		[hl], a
		ld		bc, 9-1
		ldir
		ret

; -----------------------------------------------------------------------------
;	ラスボス中央パーツを消去する
;	input:
;		e	...	X座標
;		d	...	Y座標	[0～13]
;	output
;		なし
;	break
;		
;	comment
;		0 番のキャラは描かない
; -----------------------------------------------------------------------------
draw_boss8_center_delete::
		ld		a, d
		; hl = d * 24 + e = d * 16 + d * 8 + e    [d = 0～13]
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer
		add		hl, bc
		; 転送元
		ld		a, 9
		ld		[background_update], a			; 次回更新するように background_update を 0以外 にしておく
		; 転送
draw_boss8_center_delete_loop:
		ld		e, l
		ld		d, h
		ld		[hl], 0
		inc		de
		ld		bc, 8
		ldir
		ld		bc, 24-8
		add		hl, bc
		dec		a
		jp		nz, draw_boss8_center_delete_loop
		ret

		; 背景データのアドレス一覧
background_stage_address:
		dw		background_stage1
		dw		background_stage2
		dw		background_stage3
		dw		background_stage4
		dw		background_stage5
		dw		background_stage6
		dw		background_stage7
		dw		background_stage8

; -----------------------------------------------------------------------------
;	ラスボスレーザーを描画する
;	input:
;		e	...	中央パーツ左上X座標
;		d	...	中央パーツ左上Y座標
;		a	... 105: レーザーを描画する, 0: レーザーを消去する
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
background_draw_laser::
		push	af
		; hl = d * 24 + 7*24 + [e + 2] = d * 16 + d * 8 + e + 170
		ld		a, d
		rlca
		rlca
		rlca
		ld		c, a
		rlca
		ld		l, a
		ld		h, 0
		ld		b, h
		add		hl, bc
		ld		c, e
		add		hl, bc
		ld		bc, sca_screen_buffer + 170
		add		hl, bc
		; 描画するライン数を求める
		ld		a, 24-7
		sub		a, d
		ld		b, a
		pop		af
		ld		de, 24-5+1
background_draw_laser_loop1:
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		add		hl, de
		djnz	background_draw_laser_loop1
		ret

		; スクロールタイミングカウンタ
background_scroll_timing:
		db		0									; 0～15 デクリメントカウンタ

		; 次にスクロールで現れるラインが even[上半分]=0, odd[下半分]=2 か？
background_is_odd:
		db		0

		; 背景データの読み取りアドレス
background_stage_pointer::
		dw		0

		; 背景更新フラグ
background_update:
		db		0

		; "HI"
background_str_hiscore:
		db		18, 19
		; "SCORE"
background_str_score:
		db		29, 13, 25, 28, 15
		; "SPEED x"
background_str_speed:
		db		29, 26, 15, 15, 14, 0
background_str_speed_num:
		db		1									; SPEED番号 + 1
		; "SHOT  x"
background_str_shot:
		db		29, 18, 25, 30, 0 , 0
background_str_shot_num:
		db		1									; SHOT番号 + 1
		; "SHIELDx"
background_str_shield:
		db		29, 18, 19, 15, 22, 14
background_str_shield_num:
		db		1									; SHIELD番号 + 1
		; "STAGE"
background_str_stage:
		db		29, 30, 11, 17, 15
background_str_stage_number:
		db		02									; STAGE番号 + 1
		; "WARNING!!"
background_str_warning:
		db		33, 11, 28, 24, 19, 24, 17, 37, 37
		; "STAGE CLEAR!"
background_str_stage_clear:
		db		29, 30, 11, 17, 15, 0 , 13, 22, 15, 11, 28, 37
		; "CLEAR BONUS 10000"
background_str_clear_bonus:
		db		13, 22, 15, 11, 28, 0 , 12, 25, 24, 31, 29, 0
		db		2 , 1 , 1 , 1 , 1 
		; "GAME OVER"
background_str_gameover:
		db		17, 11, 23, 15, 0 , 25, 32, 15, 28
		; ラスボス 左パーツ
background_boss8_left:
		db		0,   0,   0,   0,   0,   0,   0,   0
		db		96,  101, 101, 101, 101, 101, 97,  0
		db		102, 104, 104, 104, 104, 104, 103, 112
		db		102, 104, 104, 104, 104, 104, 103, 111
		db		102, 104, 104, 104, 104, 104, 103, 108
		db		102, 104, 104, 104, 104, 104, 99,  0
		db		102, 104, 104, 104, 104, 103, 0,   0
		db		102, 104, 104, 104, 104, 103, 0,   0
		db		102, 104, 104, 104, 104, 103, 0,   0
		db		98,  100, 100, 100, 100, 99,  0,   0
		db		0,   0,   0,   0,   0,   0,   0,   0
		; ラスボス 右パーツ
background_boss8_right:
		db		0,   0,   0,   0,   0,   0,   0,   0
		db		0,   96,  101, 101, 101, 101, 101, 97
		db		110, 102, 104, 104, 104, 104, 104, 103
		db		109, 102, 104, 104, 104, 104, 104, 103
		db		106, 102, 104, 104, 104, 104, 104, 103
		db		0,   98,  104, 104, 104, 104, 104, 103
		db		0,   0,   102, 104, 104, 104, 104, 103
		db		0,   0,   102, 104, 104, 104, 104, 103
		db		0,   0,   102, 104, 104, 104, 104, 103
		db		0,   0,   98,  100, 100, 100, 100, 99
		db		0,   0,   0,   0,   0,   0,   0,   0
		; ラスボス 中央パーツ
background_boss8_center:
		db		0,   0,   0,   0,   0,   0,   0,   0,   0
		db		0,   96,  101, 101, 101, 101, 101, 97,  0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   102, 104, 104, 104, 104, 104, 103, 0
		db		0,   98,  100, 100, 100, 100, 100, 99,  0
		db		0,   0,   0,   106, 107, 108, 0,   0,   0
		; stage data
		include	"sca_stage_data.asm"
