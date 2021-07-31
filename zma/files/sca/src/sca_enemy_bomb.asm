; -----------------------------------------------------------------------------
;	敵の爆発処理
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
enemy_bomb_move::
		; 動作中か判断
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L]
		or		a, a
		jr		nz, enemy_bomb_move_active
enemy_bomb_move_inactive:
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_YH2], 212			; 非表示
		ld		[ix + SCA_INFO_ENEMY_POWER], 0	; 駆動中でない
		ret
enemy_bomb_move_active:
		; 動作中カウンタを減らす
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
		cp		a, 12
		call	z, enemy_bomb_move_graphic2
		; Y座標更新
		ld		a, [ix + SCA_INFO_YH]
		inc		a
		cp		a, 192
		jr		nc, enemy_bomb_move_inactive		; 画面外へ出たら inactive へ
		ld		[ix + SCA_INFO_YH], a
		ld		[ix + SCA_INFO_YH2], a
enemy_bomb_move_end:
		ret

enemy_bomb_move_graphic2:
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		パターン番号
		ld		[hl], 56
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 60
		ret

; -----------------------------------------------------------------------------
;	敵の情報を爆発に変更する
;		ix	... 敵情報のアドレス
;	output
;		なし
;	break
;		全て
; -----------------------------------------------------------------------------
enemy_bomb::
		; 爆発パターンに変更する
		ld		[ix + SCA_INFO_ENEMY_STATE_L], 20
		ld		[ix + SCA_INFO_ENEMY_POWER], 0
		ld		hl, enemy_bomb_move
		ld		[ix + SCA_INFO_ENEMY_MOVE_L], l
		ld		[ix + SCA_INFO_ENEMY_MOVE_H], h
		; スプライトの色を変更する
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		ld		c, 0x06
		push	ix
		call	sprite_set_color
		pop		ix
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		inc		a
		ld		c, 0x49
		push	ix
		call	sprite_set_color
		pop		ix
		; スプライトパターン番号を変更する
		;		HL ← sprite_attribute_table + A * 4 + 2
		ld		a, [ix + SCA_INFO_ENEMY_SPRITE_NUM]
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, sprite_attribute_table + 2
		add		hl, de
		;		パターン番号
		ld		[hl], 48
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		[hl], 52
		ret
