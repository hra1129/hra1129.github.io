; -----------------------------------------------------------------------------
;	自機の弾の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	自機の弾の初期化[一つ分]
;	input:
;		ix	...	自機弾情報のアドレス
;	output
;		なし
;	break
;		a,f,b
;	comment
;		自機弾情報は、下記の構造をとる
;			unsigned short	x			上位8bitが座標, 下位8bitは小数部[小数部は常に0]
;			unsigned short	y			上位8bitが座標, 下位8bitは小数部[小数部は常に0]
;			unsigned char	shot_power	ショットパワー[未使用時は 0]
; -----------------------------------------------------------------------------
shot_init::
		push	hl
		push	ix
		pop		hl
		xor		a, a
		ld		b, 5
shot_init_loop:
		ld		[hl], a
		inc		hl
		djnz	shot_init_loop
		pop		hl
		ret

; -----------------------------------------------------------------------------
;	自機の弾の移動処理[一つ分]
;	input:
;		ix	...	自機弾情報のアドレス
;	output
;		なし
;	break
;		a,f
; -----------------------------------------------------------------------------
shot_move::
		; この弾が発射中でなければ何もしない
		ld		a, [ix + SCA_INFO_SHOT_POWER]
		or		a, a
		jr		nz, shot_move_active
shot_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; 発射中でない
		ret
shot_move_active:
		; 弾を上に動かす
		ld		a, [ix + SCA_INFO_YH]
		sub		a, 8
		jr		c, shot_move_inactive
		ld		[ix + SCA_INFO_YH], a
		ret

; -----------------------------------------------------------------------------
;	自機の弾の発射処理
;	input:
;		ix	... 自機情報のアドレス
;		iy	... 自機弾情報のアドレス（３つ分並んでいること）
;	output
;		なし
;	break
;		a,b,d,e,f,iy
; -----------------------------------------------------------------------------
shot_fire::
		; 発射するタイミングか否か調べる
		xor		a, a
		call	GTTRIG
		ld		d, a
		ld		a, 1
		call	GTTRIG
		or		a, d
		ld		d, a
		ld		a, [shot_last_trigger]
		or		a, a
		ld		a, d						; ※フラグ不変
		ld		[shot_last_trigger], a		; ※フラグ不変
		ret		nz							; 最後に発射してからまだボタンが放されていない場合は何もしない
		or		a, a
		ret		z							; そもそもボタンが押されていなければ何もしない
		; 発射中でない弾を検索する
		ld		b, 3
		ld		de, SCA_INFO_SIZE
shot_fire_loop:
		; 現在着目している弾は、発射中か？
		ld		a, [iy + SCA_INFO_SHOT_POWER]
		or		a, a
		jr		z, shot_fire_found
		add		iy, de
		djnz	shot_fire_loop
		; 空いてる弾が無いので発射を諦める
		ret
shot_fire_found:
		; 発射処理
		ld		a, [ix + SCA_INFO_XH]
		ld		[iy + SCA_INFO_XH], a
		ld		a, [ix + SCA_INFO_YH]
		ld		[iy + SCA_INFO_YH], a
		ld		a, [ix + SCA_INFO_PLAYER_SHOT_POWER]
		ld		[iy + SCA_INFO_SHOT_POWER], a
		; 発射の効果音
		ld		hl, [se_shot]
		call	bgmdriver_play_sound_effect
		ret

shot_last_trigger:
		db		0
