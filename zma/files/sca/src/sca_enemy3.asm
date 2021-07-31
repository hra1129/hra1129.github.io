; -----------------------------------------------------------------------------
;	敵3の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	敵3の移動処理
;	input:
;		ix	...	敵3情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy3_move::
		; この敵が動作中でなければ何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy3_move_active
enemy3_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ret
enemy3_move_active:
		; Y座標更新
		ld		a, [ix + SCA_INFO_YH]
		add		a, 3
		cp		a, 192
		jr		nc, enemy3_move_inactive		; 画面外へ出たら inactive へ
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy3_move_fire:
		; 弾を発射するタイミングか？
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy3_move_end					; 発射のタイミングでなければ enemy3_move_end へ
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; 発射処理
		ld		iy, player_info
		call	enemy_shot_start
enemy3_move_end:
		ret

; -----------------------------------------------------------------------------
;	敵3の登場処理
;	input:
;		ix	... 自機情報のアドレス
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy3_start::
		; 発射処理
		call	random
		ld		a, l
		cp		a, 192-16
		jr		c, enemy3_start_skip1
		sub		a, 192-16
enemy3_start_skip1:
		ld		[iy + SCA_INFO_XH], a
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_XH2], a
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		hl, enemy3_move
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
