; -----------------------------------------------------------------------------
;	敵5の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	敵5の移動処理
;	input:
;		ix	...	敵5情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy5_move::
		; この敵が動作中でなければ何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy5_move_active
enemy5_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ret
enemy5_move_active:
		; 現状の位相角を得る
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; 位相角を 90 * 7/128 [度] だけずらす
		ld		de, 2
		add		hl, de
		; 位相角を更新
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ 位相角 ]
		call	enemy_get_cos
		; a = [b / 4] + SCA_INFO_XL
		ld		a, b
		add		a, b
		cp		a, 192
		jr		nc, enemy5_move_inactive
		; Y座標更新
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		; X座標更新
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		add		a, [ix + SCA_INFO_XH]
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
enemy5_move_fire:
		; 弾を発射するタイミングか？
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy5_move_end					; 発射のタイミングでなければ enemy5_move_end へ
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; 発射処理
		ld		iy, player_info
		call	enemy_shot_start
enemy5_move_end:
		ret

; -----------------------------------------------------------------------------
;	敵5の登場処理
;		ix	... 自機情報のアドレス
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy5_start::
		; 発射処理
		; 発射処理
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 88
		jr		c, enemy5_start_reverse
		ld		[iy + SCA_INFO_ENEMY_REVERSE], -1		; 右側
		ld		[iy + SCA_INFO_XH], 160
		ld		[iy + SCA_INFO_XH2], 160
		jr		enemy5_start_skip1
enemy5_start_reverse:
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 1		; 左側
		ld		[iy + SCA_INFO_XH], 16
		ld		[iy + SCA_INFO_XH2], 16
enemy5_start_skip1:
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 0
		ld		hl, enemy5_move
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		; スプライトの色を変更する
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		ld		c, 0x01
		push	iy
		call	sprite_set_color
		pop		iy
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		inc		a
		ld		c, 0x44
		push	iy
		call	sprite_set_color
		pop		iy
		; スプライトパターン番号を変更する
		;		HL ← sprite_attribute_table + A * 4 + 2
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		パターン番号
		ld		[hl], 10 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 11 * 4
		ret
