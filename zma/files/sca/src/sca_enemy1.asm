; -----------------------------------------------------------------------------
;	敵１の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	敵1の移動処理
;	input:
;		ix	...	敵1情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy1_move::
		; この敵が動作中でなければ何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy1_move_active
enemy1_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ret
enemy1_move_active:
		; 状態を調べる	256: 下へ移動, 255～-127: カーブ移動, -128: 左へ移動
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		ld		a, l
		or		a, a
		jr		z, enemy1_move_skip1
		cp		a, 129
		jr		c, enemy1_move_skip2
enemy1_move_skip1:
		ld		a, h
		dec		a
		jr		nz, enemy1_move_curve
		; 下へ直線移動
		ld		a, [ix + SCA_INFO_YH]
		add		a, 2							; 下へ2画素移動
		cp		a, 104
		jr		c, enemy1_move_skip3
		ld		a, 104
		ld		[ix + SCA_INFO_ENEMY_STATE_L], 255
		ld		[ix + SCA_INFO_ENEMY_STATE_H], 0
enemy1_move_skip3:
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		jr		enemy1_move_fire
enemy1_move_skip2:
		ld		a, h
		inc		a
		jr		nz, enemy1_move_curve
		; 左へ直線移動
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		or		a, a
		ld		a, [ix + SCA_INFO_XH]
		jr		nz, enemy1_move_right
		sub		a, 2							; 左へ2画素移動 [dec a は cフラグが変化しないので使えない]
		jr		nc, enemy1_move_skip4
enemy1_move_skip5:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		jr		enemy1_move_skip4
enemy1_move_right:
		; 右へ直線移動
		add		a, 2
		cp		a, 175
		jr		nc, enemy1_move_skip5
enemy1_move_skip4:
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		jr		enemy1_move_fire
enemy1_move_curve:
		; カーブ移動
		push	hl
		call	enemy_get_cos
		ld		a, [ix + SCA_INFO_ENEMY_REVERSE]
		or		a, a
		jr		z, enemy1_move_skip6
		ld		a, c
		neg
		ld		c, a
enemy1_move_skip6:
		ld		a, 88
		add		a, c
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		ld		a, 104
		add		a, b
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
		pop		hl
		dec		hl
		dec		hl
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
enemy1_move_fire:
		; 弾を発射するタイミングか？
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy1_move_end					; 発射のタイミングでなければ enemy1_move_end へ
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; 発射処理
		ld		iy, player_info
		call	enemy_shot_start
enemy1_move_end:
		ret

; -----------------------------------------------------------------------------
;	敵1の登場処理
;	input:
;		ix	... 自機情報のアドレス
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy1_start::
		; 発射処理
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 88
		jr		c, enemy1_start_reverse
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 0
		ld		[iy + SCA_INFO_XH], 16
		ld		[iy + SCA_INFO_XH2], 16
		jr		enemy1_start_skip1
enemy1_start_reverse:
		ld		[iy + SCA_INFO_ENEMY_REVERSE], 160+16
		ld		[iy + SCA_INFO_XH], 160
		ld		[iy + SCA_INFO_XH2], 160
enemy1_start_skip1:
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0		; 256
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 1
		ld		hl, enemy1_move
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
		ld		[hl], 3 * 4
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 4 * 4
		ret
