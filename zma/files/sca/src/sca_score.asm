; -----------------------------------------------------------------------------
;	点数処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	スコアメモリを初期化
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		ゲームスタート時に呼び出す
; -----------------------------------------------------------------------------
score_init::
		; スコアを 00000000 にする
		ld		hl, 0
		ld		[current_score + 0], hl
		ld		[current_score + 2], hl
		; スコアはまだトップスコアには到達していない
		xor		a, a
		ld		[current_is_top], a
		; スコアの表示を更新する
		call	score_update
		ret

; -----------------------------------------------------------------------------
;	スコアを表示
;	input:
;		なし
;	output
;		なし
;	break
;		a, f, h, l
;	comment
;		点数が変化したときに呼び出す
; -----------------------------------------------------------------------------
score_update::
		; 点数を表示する
		ld		hl, PATTERN_NAME1 + 24 + 32*6
		call	SETWRT
		ld		hl, current_score
		call	score_outport
		; 現在の点数はトップスコアか？
		ld		a, [current_is_top]
		or		a, a
		ret		z						; トップスコアでなければ戻る
		; トップスコアの表示も更新する
		ld		hl, PATTERN_NAME1 + 24 + 32*2
		call	SETWRT
		ld		hl, current_score
		jp		score_outport

; -----------------------------------------------------------------------------
;	トップスコアを表示
;	input:
;		なし
;	output
;		なし
;	break
;		a, f, h, l
;	comment
;		点数が変化したときに呼び出す
; -----------------------------------------------------------------------------
score_update_high_score::
		; トップスコアの表示も更新する
		ld		hl, PATTERN_NAME1 + 24 + 32*2
		call	SETWRT
		ld		hl, high_score
		jp		score_outport

; -----------------------------------------------------------------------------
;	スコアに加算
;	input:
;		de	...	加算するスコア[BCD符号]
;	output
;		cフラグ
;			0: 正常に加算できた
;			1: カンストした
;	break
;		a, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
score_add::
		ld		hl, current_score + 3		; 下位からアクセスするので +3
		; 最下位2桁
		ld		a, [hl]		; ※フラグ不変
		add		a, e
		daa					; BCD符号の演算補正
		ld		[hl],a		; 更新
		dec		hl			; ※フラグ不変
		; 次の2桁
		ld		a, [hl]		; ※フラグ不変
		adc		a, d		; 最下位からの桁上がりを考慮する
		daa					; BCD符号の演算補正
		ld		[hl],a		; 更新
		dec		hl			; ※フラグ不変
		; 次の2桁
		ld		a, [hl]		; ※フラグ不変
		adc		a, 0		; 最下位からの桁上がりを考慮する
		daa					; BCD符号の演算補正
		ld		[hl],a		; 更新
		dec		hl			; ※フラグ不変
		; 次の2桁
		ld		a, [hl]		; ※フラグ不変
		adc		a, 0		; 最下位からの桁上がりを考慮する
		daa					; BCD符号の演算補正
		ld		[hl],a		; 更新
		ret		nc			; オーバーフローしていなければ抜ける
		; オーバーフローの処理 [99999999 にする]
		ld		hl, 0x9999
		ld		[current_score + 0], hl
		ld		[current_score + 2], hl
		ret

; -----------------------------------------------------------------------------
;	BCD符号のスコアを VDP へ転送
;	input:
;		hl	...	BCD形式のスコアデータのアドレス
;	output
;		なし
;	break
;		a, f, b, h, l
;	comment
;		SETWR等で、VDPにVRAMアドレス設定した状態で呼び出す
; -----------------------------------------------------------------------------
score_outport:
		xor		a, a
		ld		b, 4
score_outport_loop:
		rld
		inc		a
		out		[VDP_VRAM_IO], a
		dec		a
		rld
		inc		a
		out		[VDP_VRAM_IO], a
		dec		a
		rld
		inc		hl
		djnz	score_outport_loop
		ret

; -----------------------------------------------------------------------------
;	BCD符号のスコアを メモリ へ転送
;	input:
;		hl	...	BCD形式のスコアデータのアドレス
;		de	... 転送先メモリ
;	output
;		なし
;	break
;		a, f, b, d, e, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
score_memput::
		xor		a, a
		ld		b, 4
score_memput_loop:
		rld
		inc		a
		ld		[de], a
		inc		de
		dec		a
		rld
		inc		a
		ld		[de], a
		inc		de
		dec		a
		rld
		inc		hl
		djnz	score_memput_loop
		ret

; -----------------------------------------------------------------------------
;	スコアの大小比較
;	input:
;		hl	...	スコア1のアドレス
;		de	...	スコア2のアドレス
;	output
;		cフラグ
;			0: de ≧ hl, 1: de < hl
;		zフラグ
;			0: de ≠ hl, 1: de = hl
;	break
;		a, f, d, e, h, l
;	comment
;		cp [de], [hl] みたいなもの
; -----------------------------------------------------------------------------
score_compare::
		; 一番上の２桁
		ld		a, [de]
		cp		a, [hl]
		daa
		ret		nz			; 不一致の場合はここで確定
		inc		hl			; ※フラグ不変
		inc		de			; ※フラグ不変
		; 次の２桁
		ld		a, [de]
		cp		a, [hl]
		daa
		ret		nz			; 不一致の場合はここで確定
		inc		hl			; ※フラグ不変
		inc		de			; ※フラグ不変
		; 次の２桁
		ld		a, [de]
		cp		a, [hl]
		daa
		ret		nz			; 不一致の場合はここで確定
		inc		hl			; ※フラグ不変
		inc		de			; ※フラグ不変
		; 次の２桁
		ld		a, [de]
		cp		a, [hl]
		daa
		ret

; -----------------------------------------------------------------------------
;	現在のスコアがトップスコアかどうか判定
;	input:
;		なし
;	output
;		なし
;	break
;		a, f, d, e, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
top_score_check::
		; 既にトップスコア扱いなら何もしない
		ld		a, [current_is_top]
		or		a, a
		ret		nz
		; 現在のスコアとトップスコアを比較する
		ld		de, current_score
		ld		hl, high_score
		call	score_compare
		ret		c
		; 現在のスコアがトップスコアを超えていたらフラグを立てる
		ld		a, 1
		ld		[current_is_top], a
		ret

; -----------------------------------------------------------------------------
;	現在のスコアをハイスコアに登録
;	input:
;		なし
;	output
;		なし
;	break
;		a, f, d, e, h, l
;	comment
;		挿入ソートによりランク順位を維持する
; -----------------------------------------------------------------------------
update_score_ranking::
		; ランクインしたかどうか調査
		ld		hl, high_score
		ld		b, 10
update_score_ranking_check_loop:
		; 現在のスコアとハイスコアを比較する
		push	hl
		ld		de, current_score
		ex		de, hl
		call	score_compare						; cp ハイスコア, 現在のスコア
		pop		hl
		jr		c, update_score_rankin				; 現在のスコアの方が大きければランクインと判定
		ld		de, 8								; ハイスコア１つ分は 8byte
		add		hl, de								; 次のハイスコアアドレス
		djnz	update_score_ranking_check_loop
		ld		a, 0								; ランクインしなかった
		ret

		; ランクインした
update_score_rankin:
		push	bc									; ランクインした順位を保持
		push	hl									; 現在のスコアを挿入するアドレスを保存
		; 第10位にランクインしたのか？
		ld		a, b
		dec		a
		jp		z, update_score_rankin_skip_shift	; ランク落ち無しの場合はずらす処理をスキップ
		; ランク落ちしたスコアをずらす
		rlca										; bc = a * 8
		rlca
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, high_score + 8*8 + 7
		ld		de, high_score + 8*9 + 7
		lddr
update_score_rankin_skip_shift:
		; 現在のスコアを挿入する
		pop		de
		ld		hl, current_score
		ld		bc, 8
		ldir
		pop		bc									; b = ランクイン順位[10=1位, 9=2位 ... 1=10位]
		ld		a, 11
		sub		a, b
		ret

; -----------------------------------------------------------------------------
current_is_top:
		db		0			; current_score が high_score の第１位を超えた場合 1 にする

; -----------------------------------------------------------------------------
;	点数テーブル[BCD符号, 表示の都合で BigEndian, 8桁]
; -----------------------------------------------------------------------------
current_score:
		db		0x00, 0x00, 0x00, 0x00
current_score_name::
		db		29, 13, 11, 0

high_score::
		db		0x00, 0x00, 0x50, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x40, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x30, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x20, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x18, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x15, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x12, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x10, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x08, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x05, 0x00, 11, 11, 11, 0
