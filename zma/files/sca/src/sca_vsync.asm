; -----------------------------------------------------------------------------
;	垂直同期割り込み
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	垂直同期割り込み処理の初期化
;	input:
;		なし
;	output
;		なし
;	break
;		a,b,c,d,e,f
;	comment
;		割り込み処理を乗っ取る。元の割り込み処理は遅すぎるので呼び出さない。
;		BASIC の入力画面へ戻る前に vsync_term を実行しなければならない。
; -----------------------------------------------------------------------------
vsync_init::
		; H_TIMI を書き換えている最中に割り込みが入らないように割禁にしておく
		di
		; H_TIMI を書き換える前に、元の内容を待避しておく
		ld		hl, H_TIMI
		ld		de, h_timi_backup
		ld		bc, 5
		ldir
		; H_TIMI を書き換える
		ld		a, 0xC3						; jp xxxx 命令コード
		ld		[H_TIMI + 0], a
		ld		hl, vsync_interrupt_handler
		ld		[H_TIMI + 1], hl
		; 割禁解除
		ei
		ret

; -----------------------------------------------------------------------------
;	垂直同期割り込みの後始末
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		割り込み処理を元通りに戻す。
; -----------------------------------------------------------------------------
vsync_term::
		; H_TIMI を書き換えている最中に割り込みが入らないように割禁にしておく
		di
		; H_TIMI を復元する
		ld		hl, h_timi_backup
		ld		de, H_TIMI
		ld		bc, 5
		ldir
		; 割禁解除
		ei
		ret

; -----------------------------------------------------------------------------
;	割り込み処理ルーチン
;	input
;		なし
;	output
;		なし
;	break
;		なし
;	comment
;		なし
; -----------------------------------------------------------------------------
vsync_interrupt_handler::
		push	af
		; VDP に対して「割り込み信号を CPU が受け取ったこと」を知らせるために、VDP S0 を読む
		xor		a, a
		out		[VDP_CMDREG_IO], a
		ld		a, 0x80 + 15
		out		[VDP_CMDREG_IO], a		; VDP R15 ← 0
		in		a, [VDP_CMDREG_IO]		; a ← VDP S0
		ld		[STATFL], a				; ワークエリアに保存用メモリが用意されてるので、そこに保存させて貰う

		; BGMドライバーの割り込み処理ルーチンを呼び出す
		call	bgmdriver_interrupt_handler

		; ソフトウェアタイマーの処理
		ld		a, [software_timer]
		inc		a
		ld		[software_timer], a
		pop		af
		ei								; 割禁解除
		ret								; MSX は Z80用汎用周辺LSIは使用していないので reti は必要ない

; -----------------------------------------------------------------------------
;	時間待ち
;	input:
;		hl	...	待機する時間 [1/60[sec]単位]
;	output
;		なし
;	break
;		
;	comment
;		誤差 -1/60[sec] ～ 0[sec]
;		hl = 0 の場合は、65536/60[sec] として処理される。
; -----------------------------------------------------------------------------
vsync_wait_time::
		ld		a, [software_timer]
		ld		c, a
vsync_wait_time_loop:
		ld		a, [software_timer]
		cp		a, c
		jr		z, vsync_wait_time_loop
		dec		hl
		ld		a, l
		or		a, h
		jr		nz, vsync_wait_time
		ret

software_timer::
		db		0						; 1/60[sec] 単位でインクリメントするソフトウェアタイマー

h_timi_backup:
		db		0, 0, 0, 0, 0
