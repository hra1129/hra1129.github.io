; -----------------------------------------------------------------------------
;	自機処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	自機の初期化処理（ゲーム開始時）
;	input:
;		ix	...	自機情報のアドレス
;	output
;		なし
;	break
;		なし
;	comment
;		自機情報は、下記の構造をとる
;			unsigned short	x			上位8bitが座標, 下位8bitは小数部
;			unsigned short	y			上位8bitが座標, 下位8bitは小数部
;			unsigned short	p_vector	移動ベクトルテーブルのアドレス
;			unsigned char	shot_power	ショットパワー
; -----------------------------------------------------------------------------
player_init::
		push	hl
		push	ix
		pop		hl
		; 自機情報初期化
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		a, SCA_PLAYER_SPEED
		ld		[player_speed], a
		rlca
		ld		e, a
		ld		d, 0
		ld		bc, player_move_vector_table
		ex		de, hl
		add		hl, bc
		ld		c, [hl]
		inc		hl
		ld		b, [hl]
		ex		de, hl
		ld		[hl], c
		inc		hl
		ld		[hl], b
		inc		hl
		ld		a, SCA_PLAYER_SHOT
		ld		[player_shot], a
		add		a, 2
		ld		[hl], a
		ld		a, SCA_INVINCIBILITY
		ld		[player_invincibility], a
		ld		a, SCA_PLAYER_SHIELD
		ld		[player_shield], a
		pop		hl
		ret

; -----------------------------------------------------------------------------
;	自機の初期化処理（ステージ開始時）
;	input:
;		ix	...	自機情報のアドレス
;	output
;		なし
;	break
;		なし
;	comment
;		自機情報は、下記の構造をとる
;			unsigned short	x			上位8bitが座標, 下位8bitは小数部
;			unsigned short	y			上位8bitが座標, 下位8bitは小数部
;			unsigned short	p_vector	移動ベクトルテーブルのアドレス
;			unsigned char	shot_power	ショットパワー
; -----------------------------------------------------------------------------
player_stage_init::
		push	hl
		push	ix
		pop		hl
		; X座標初期化
		ld		[hl], 0
		inc		hl
		ld		[hl], 88
		inc		hl
		; Y座標初期化
		ld		[hl], 0
		inc		hl
		ld		[hl], 191-16
		pop		hl
		ret

; -----------------------------------------------------------------------------
;	自機の移動処理
;	input:
;		ix	...	自機情報のアドレス
;	output
;		なし
;	break
;		ix以外全て
; -----------------------------------------------------------------------------
player_move::
		; 無敵モードを時限
		ld		a, [player_invincibility]
		or		a, a
		jr		z, player_move_skip1
		inc		a
		jr		z, player_move_skip1			; デバッグ用無敵モードの場合デクリメントしない
		dec		a
		dec		a
		ld		[player_invincibility], a
player_move_skip1:
		push	ix
		; カーソルキーの状態を得る
		xor		a, a
		call	GTSTCK
		push	af
		; ジョイスティック１の状態を得る
		ld		a, 1
		call	GTSTCK
		; カーソルキー状態、ジョイスティック１状態をミックス
		pop		bc
		or		a, b
		; アドレスオフセットに変換 [ iy = p_vector + a * 4 ]
		pop		ix
		cp		a, 9
		jr		c, player_move_skip2
		xor		a, a
player_move_skip2:
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		c, [ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_L]
		ld		b, [ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_H]
		add		hl, bc
		push	hl
		pop		iy
		; X座標に移動ベクトルを加算して水平移動
		ld		l, [ix + SCA_INFO_XL]
		ld		h, [ix + SCA_INFO_XH]
		ld		c, [iy + 0]
		ld		b, [iy + 1]
		add		hl, bc
		; 画面外にはみ出したかチェック
		ld		a, h
		cp		a, 192-16
		jr		c, player_move_x_success1
		; はみ出した方向を判別
player_move_x_fail1:
		cp		a, 224
		; 左なら左端張り付き
		ld		hl, 0			; ※フラグ変化無し
		jr		nc, player_move_x_success1
		; 右なら右端張り付き
		ld		hl, (191-16)*256+0
player_move_x_success1:
		; X座標を更新
		ld		[ix + SCA_INFO_XL], l
		ld		[ix + SCA_INFO_XH], h
		ld		[ix + SCA_INFO_XH2], h
		; Y座標に移動ベクトルを加算して垂直移動
		ld		l, [ix + SCA_INFO_YL]
		ld		h, [ix + SCA_INFO_YH]
		ld		c, [iy + 2]
		ld		b, [iy + 3]
		add		hl, bc
		; 画面外にはみ出したかチェック
		ld		a, h
		cp		a, 192-16
		jr		c, player_move_y_success1
		; はみ出した方向を判別
player_move_y_fail1:
		cp		a, 224
		; 上なら上端張り付き
		ld		hl, 0			; ※フラグ変化無し
		jr		nc, player_move_y_success1
		; 下なら下端張り付き
		ld		hl, (191-16)*256+0
player_move_y_success1:
		; Y座標を更新
		ld		[ix + SCA_INFO_YL], l
		ld		[ix + SCA_INFO_YH], h
		ld		[ix + SCA_INFO_YH2], h
		ret

; -----------------------------------------------------------------------------
;	自機のスピードアップ
;	input:
;		ix	...	自機情報のアドレス
;	output
;		なし
;	break
;		ix以外全て
; -----------------------------------------------------------------------------
player_speed_up::
		ld		a, [player_speed]
		cp		a, 7
		ret		z				; すでに最大ならスピードアップしない
		inc		a
		ld		[player_speed], a
		; 移動ベクトルアドレスへ変換
		rlca
		ld		l, a
		ld		h, 0
		ld		de, player_move_vector_table
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; 移動ベクトルを更新
		ld		[ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_L], e
		ld		[ix + SCA_INFO_PLAYER_MOVE_VEC_TBL_H], d
		; 自機情報の表示を更新
		jp		background_update_player_info

; -----------------------------------------------------------------------------
;	自機のショットパワーアップ
;	input:
;		ix	...	自機情報のアドレス
;	output
;		なし
;	break
;		ix以外全て
; -----------------------------------------------------------------------------
player_shot_power_up::
		ld		a, [player_shot]
		cp		a, 7
		ret		z				; すでに最大ならパワーアップしない
		inc		a
		ld		[player_shot], a
		; ショットパワーを更新
		add		a, 2
		ld		[ix + SCA_INFO_PLAYER_SHOT_POWER], a
		; 自機情報の表示を更新
		jp		background_update_player_info

player_move_vector0:			; 1.0倍速
		dw		0, 0			; ・
		dw		0, -256			; ↑
		dw		181, -181		; ／
		dw		256, 0			; →
		dw		181, 181		; ＼
		dw		0, 256			; ↓
		dw		-181, 181		; ／
		dw		-256, 0			; ←
		dw		-181, -181		; ＼

player_move_vector1:			; 1.2倍速
		dw		0, 0			; ・
		dw		0, -307			; ↑
		dw		217, -217		; ／
		dw		307, 0			; →
		dw		217, 217		; ＼
		dw		0, 307			; ↓
		dw		-217, 217		; ／
		dw		-307, 0			; ←
		dw		-217, -217		; ＼

player_move_vector2:			; 1.4倍速
		dw		0, 0			; ・
		dw		0, -358			; ↑
		dw		253, -253		; ／
		dw		358, 0			; →
		dw		253, 253		; ＼
		dw		0, 358			; ↓
		dw		-253, 253		; ／
		dw		-358, 0			; ←
		dw		-253, -253		; ＼

player_move_vector3:			; 1.6倍速
		dw		0, 0			; ・
		dw		0, -409			; ↑
		dw		290, -290		; ／
		dw		409, 0			; →
		dw		290, 290		; ＼
		dw		0, 409			; ↓
		dw		-290, 290		; ／
		dw		-409, 0			; ←
		dw		-290, -290		; ＼

player_move_vector4:			; 1.8倍速
		dw		0, 0			; ・
		dw		0, -460			; ↑
		dw		325, -325		; ／
		dw		460, 0			; →
		dw		325, 325		; ＼
		dw		0, 460			; ↓
		dw		-325, 325		; ／
		dw		-460, 0			; ←
		dw		-325, -325		; ＼

player_move_vector5:			; 2.0倍速
		dw		0, 0			; ・
		dw		0, -512			; ↑
		dw		362, -362		; ／
		dw		512, 0			; →
		dw		362, 362		; ＼
		dw		0, 512			; ↓
		dw		-362, 362		; ／
		dw		-512, 0			; ←
		dw		-362, -362		; ＼

player_move_vector6:			; 2.2倍速
		dw		0, 0			; ・
		dw		0, -563			; ↑
		dw		398, -398		; ／
		dw		563, 0			; →
		dw		398, 398		; ＼
		dw		0, 563			; ↓
		dw		-398, 398		; ／
		dw		-563, 0			; ←
		dw		-398, -398		; ＼

player_move_vector7:			; 2.4倍速
		dw		0, 0			; ・
		dw		0, -614			; ↑
		dw		434, -434		; ／
		dw		614, 0			; →
		dw		434, 434		; ＼
		dw		0, 614			; ↓
		dw		-434, 434		; ／
		dw		-614, 0			; ←
		dw		-434, -434		; ＼

player_move_vector_table:
		dw		player_move_vector0
		dw		player_move_vector1
		dw		player_move_vector2
		dw		player_move_vector3
		dw		player_move_vector4
		dw		player_move_vector5
		dw		player_move_vector6
		dw		player_move_vector7

player_speed::
		db		0				; 自機の移動速度 0～7 の８段階
player_shot::
		db		0				; 自機の弾の威力 0～7 の８段階
player_shield::
		db		0				; 自機のシールド 0～8 の９段階（0はゲームオーバー）
player_invincibility::
		db		0				; 0: 通常, 255: 無敵, 1～254: 一定時間無敵[数値は残り時間, 1/60[sec]単位]
