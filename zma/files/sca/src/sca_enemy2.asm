; -----------------------------------------------------------------------------
;	敵２の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	敵2の移動処理
;	input:
;		ix	...	敵2情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy2_move::
		; この敵が動作中でなければ何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy2_move_active
enemy2_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ret
enemy2_move_active:
		; 現状の位相角を得る
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; 位相角を 90 * 4/128 [度] だけずらす
		ld		de, 4
		add		hl, de
		; 位相角を更新
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ 位相角 ]
		call	enemy_get_cos
		; 反転の場合は a = -b + 88, 反転でなければ a = b + 88
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		or		a, a
		ld		a, b							; ※フラグ不変
		jr		z, enemy2_move_skip1
		neg
enemy2_move_skip1:
		add		a, 88
		; X座標更新
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		; Y座標更新
		ld		a, [ix + SCA_INFO_YH]
		inc		a
		cp		a, 192
		jr		nc, enemy2_move_inactive		; 画面外へ出たら inactive へ
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy2_move_anime:
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L]
		bit		4, a
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		jr		z, enemy2_move_anime_skip1
		call	enemy2_move_graphic1
		jr		enemy2_move_fire
enemy2_move_anime_skip1:
		call	enemy2_move_graphic2
enemy2_move_fire:
		; 弾を発射するタイミングか？
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy2_move_end					; 発射のタイミングでなければ enemy2_move_end へ
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; 発射処理
		ld		iy, player_info
		call	enemy_shot_start
enemy2_move_end:
		ret

enemy2_move_graphic1:
		;		HL ← sprite_attribute_table + A * 4 + 2
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		パターン番号
		ld		[hl], 6 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 7 * 4
		ret

enemy2_move_graphic2:
		;		HL ← sprite_attribute_table + A * 4 + 2
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		パターン番号
		ld		[hl], 8 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 9 * 4
		ret

; -----------------------------------------------------------------------------
;	敵2の登場処理
;	input:
;		ix	... 自機情報のアドレス
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy2_start::
		; 発射処理
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 88
		jr		c, enemy2_start_reverse
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 1		; 右側
		jr		enemy2_start_skip1
enemy2_start_reverse:
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 0		; 左側
enemy2_start_skip1:
		ld		[iy + SCA_INFO_XH], 88
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_XH2], 88
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 0
		ld		hl, enemy2_move
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
		ld		a, [iy + SCA_INFO_ENEMY_SPRITE_NUM]
		jp		enemy2_move_graphic1
