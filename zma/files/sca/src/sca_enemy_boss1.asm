; -----------------------------------------------------------------------------
;	ボス敵1の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	ボス1の移動処理
;	input:
;		ix	...	敵情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy_boss1_move::
		; このボスが動作中でなければ何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy_boss1_move_active
enemy_boss1_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212		; 非表示
		ld		[ix + SCA_INFO_YH3], 212		; 非表示
		ld		[ix + SCA_INFO_YH4], 212		; 非表示
		ld		[ix + SCA_INFO_YH5], 212		; 非表示
		ld		[ix + SCA_INFO_YH6], 212		; 非表示
		ld		[ix + SCA_INFO_YH7], 212		; 非表示
		ld		[ix + SCA_INFO_YH8], 212		; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ld		[ix + SCA_INFO_ENEMY_POWER3], 0	; 駆動中でない
		ld		[ix + SCA_INFO_ENEMY_POWER5], 0	; 駆動中でない
		ld		[ix + SCA_INFO_ENEMY_POWER7], 0	; 駆動中でない
		ret
enemy_boss1_move_active:
		; 現状のY位相角を得る
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; Y位相角を 90 * 5/128 [度] だけずらす
		ld		de, 5
		add		hl, de
		; Y位相角を更新
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ 位相角 ]
		call	enemy_get_cos
		; a = b + 96 - 16
		ld		a, 96 - 16
		add		a, b
		; Y座標更新
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		ld		[ix + SCA_INFO_YH3], a
		ld		[ix + SCA_INFO_YH4], a
		add		a, 16
		ld		[ix + SCA_INFO_YH5], a
		ld		[ix + SCA_INFO_YH6], a
		ld		[ix + SCA_INFO_YH7], a
		ld		[ix + SCA_INFO_YH8], a
		; 現状のX位相角を得る
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L2]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H2]
		; X位相角を 90 * [random & 7]/128 [度] だけずらす
		ld		de, 3
		add		hl, de
		; X位相角を更新
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], h
		; c = cos[ 位相角 ]
		call	enemy_get_cos
		; a = c + 96 - 16
		ld		a, 96 - 16
		add		a, c
		; X座標更新
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		ld		[ix + SCA_INFO_XH5], a
		ld		[ix + SCA_INFO_XH6], a
		add		a, 16
		ld		[ix + SCA_INFO_XH3], a
		ld		[ix + SCA_INFO_XH4], a
		ld		[ix + SCA_INFO_XH7], a
		ld		[ix + SCA_INFO_XH8], a

enemy_boss1_move_fire:
		; 弾を発射するタイミングか？
		ld		a, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		a
		and		a, 31
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		jr		nz, enemy_boss1_move_end					; 発射のタイミングでなければ enemy_boss1_move_end へ
		; 発射処理
		ld		iy, player_info
		call	enemy_shot_start
enemy_boss1_move_end:
enemy_boss1_move_dummy:
		ret

; -----------------------------------------------------------------------------
;	ボス1の登場処理
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy_boss1_start::
		; 当たり判定をボス用に切り替える
		ld		a, 1
		call	change_crash_check_routine
		; ボスシールド更新
		ld		a, 64
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[ix + SCA_INFO_ENEMY_POWER3], a
		ld		[ix + SCA_INFO_ENEMY_POWER5], a
		ld		[ix + SCA_INFO_ENEMY_POWER7], a
		; 位相更新
		ld		hl, 384							; 270度
		ld		[iy + SCA_INFO_ENEMY_STATE_L], l
		ld		[iy + SCA_INFO_ENEMY_STATE_H], h
		ld		[iy + SCA_INFO_ENEMY_STATE_L2], l
		ld		[iy + SCA_INFO_ENEMY_STATE_H2], h
		; Y座標更新
		xor		a, a
		ld		[iy + SCA_INFO_YH], a
		ld		[iy + SCA_INFO_YH2], a
		ld		[iy + SCA_INFO_YH3], a
		ld		[iy + SCA_INFO_YH4], a
		add		a, 16
		ld		[iy + SCA_INFO_YH5], a
		ld		[iy + SCA_INFO_YH6], a
		ld		[iy + SCA_INFO_YH7], a
		ld		[iy + SCA_INFO_YH8], a
		; X座標更新
		ld		a, 96 - 16
		ld		[iy + SCA_INFO_XH], a
		ld		[iy + SCA_INFO_XH2], a
		ld		[iy + SCA_INFO_XH5], a
		ld		[iy + SCA_INFO_XH6], a
		add		a, 16
		ld		[iy + SCA_INFO_XH3], a
		ld		[iy + SCA_INFO_XH4], a
		ld		[iy + SCA_INFO_XH7], a
		ld		[iy + SCA_INFO_XH8], a
		ld		hl, enemy_boss1_move
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		ld		hl, enemy_boss1_move_dummy
		ld		de, SCA_INFO_SIZE * 2
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		add		iy, de
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		; スプライトの色を変更する
		ld		a, 2
		ld		c, 0x01
		call	sprite_set_color
		ld		a, 3
		ld		c, 0x48
		call	sprite_set_color
		ld		a, 4
		ld		c, 0x01
		call	sprite_set_color
		ld		a, 5
		ld		c, 0x48
		call	sprite_set_color
		ld		a, 6
		ld		c, 0x01
		call	sprite_set_color
		ld		a, 7
		ld		c, 0x48
		call	sprite_set_color
		ld		a, 8
		ld		c, 0x01
		call	sprite_set_color
		ld		a, 9
		ld		c, 0x48
		call	sprite_set_color
		; スプライトパターン番号を変更する
		ld		hl, sprite_attribute_table + 2 + 2*4
		ld		de, 4
		;		パターン番号
		ld		[hl], 16 * 4
		add		hl, de
		ld		[hl], 17 * 4
		add		hl, de
		ld		[hl], 18 * 4
		add		hl, de
		ld		[hl], 19 * 4
		add		hl, de
		ld		[hl], 20 * 4
		add		hl, de
		ld		[hl], 21 * 4
		add		hl, de
		ld		[hl], 22 * 4
		add		hl, de
		ld		[hl], 23 * 4
		ret
