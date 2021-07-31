; -----------------------------------------------------------------------------
;	敵4の処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	敵4の移動処理
;	input:
;		ix	...	敵4情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy4_move::
		; この敵が動作中でなければ何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		nz, enemy4_move_active
enemy4_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ret
enemy4_move_active:
		; 現状の位相角を得る
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		; 位相角を 90 * 7/128 [度] だけずらす
		ld		de, 7
		add		hl, de
		; 位相角を更新
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = sin[ 位相角 ]
		call	enemy_get_cos
		; a = [b / 4] + SCA_INFO_XL
		ld		a, b
		sra		a
		sra		a
		add		a, [ix + SCA_INFO_XL]
		; X座標更新
		ld		[ix + SCA_INFO_XH], a
		ld		[ix + SCA_INFO_XH2], a
		; Y座標更新
		ld		a, [ix + SCA_INFO_YH]
		inc		a
		cp		a, 192
		jr		nc, enemy4_move_inactive		; 画面外へ出たら inactive へ
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy4_move_fire:
		; 弾を発射するタイミングか？
		ld		b, [ix + SCA_INFO_ENEMY_SHOT_TIMING]
		inc		b
		ld		a, [enemy_shot_speed]
		cp		a, b
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], b
		jr		nz, enemy4_move_end					; 発射のタイミングでなければ enemy4_move_end へ
		xor		a, a
		ld		[ix + SCA_INFO_ENEMY_SHOT_TIMING], a
		; 発射処理
		ld		iy, player_info
		call	enemy_shot_start
enemy4_move_end:
		ret

; -----------------------------------------------------------------------------
;	敵4の登場処理
;		ix	... 自機情報のアドレス
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy4_start::
		; 発射処理
		call	random
		ld		a, l
		sub		a, 18
		jr		c, enemy4_start_skip0				; 0～17 の場合は enemy4_start_skip0 へ
		ld		a, l
		cp		a, 176-18
		jr		c, enemy4_start_skip1
enemy4_start_skip0:									; 0～17 は 238～255 になっている。それ以外は 158～255
		sub		a, 176-18-18						; 158～255 → 18～133 になる。
enemy4_start_skip1:
		ld		[iy + SCA_INFO_XL], a				; ここに来たとき a は、18～157 になっている
		ld		[iy + SCA_INFO_XH], a
		ld		[iy + SCA_INFO_YH], 0
		ld		[iy + SCA_INFO_XH2], a
		ld		[iy + SCA_INFO_YH2], 0
		ld		a, [enemy_shield_base]
		ld		[iy + SCA_INFO_ENEMY_POWER], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], 0
		ld		[iy + SCA_INFO_ENEMY_STATE_H], 0
		ld		hl, enemy4_move
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
