; -----------------------------------------------------------------------------
;	ボス敵8の処理
; -----------------------------------------------------------------------------

LEFT_PART_1ST_DOWN_TIME		= 5					; 左パーツが最初に下へ移動するまでの時間 [秒]
RIGHT_PART_1ST_DOWN_TIME	= 7					; 右パーツが最初に下へ移動するまでの時間 [秒]
LEFT_PART_DOWN_CYCLE		= 6					; 下へ移動する時間間隔
RIGHT_PART_DOWN_CYCLE		= 8					; 下へ移動する時間間隔
LEFT_PART_DOWN_SPEED		= 6					; 下へ移動する速度
RIGHT_PART_DOWN_SPEED		= 6					; 下へ移動する速度
CENTER_MOVE_SPEED			= 5					; 中央パーツ単独時の移動速度
CENTER_BEFORE_LASER_WAIT	= 50				; レーザー発射前の硬直時間
CENTER_AFTER_LASER_WAIT		= 180				; レーザー発射中の硬直時間
CENTER_LASER_CYCLE			= 60				; レーザー発射間隔
SHOT_CYCLE					= 5					; 弾を発射する間隔
SHOT_TYPE_CHANGE			= 15				; SHOT_TYPE_CHANGE発に１回自機照準で発射

; -----------------------------------------------------------------------------
;	ボス8の移動処理
;	input:
;		ix	...	敵情報のアドレス
;	output
;		なし
;	break
;		a,f,b,c,h,l
; -----------------------------------------------------------------------------
enemy_boss8_move::
		call	enemy_boss8_move_left			; 左パーツ
		call	enemy_boss8_move_right			; 右パーツ
		call	enemy_boss8_move_center			; 中央パーツ
enemy_boss8_move_dummy:
		ret

enemy_boss8_move_left:
		; 左パーツがすでに破壊済みなら何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		ret		z
		; 弾発射処理
		ld		a, [ix + SCA_INFO_XL]
		add		a, 7
		rlca
		rlca
		rlca
		ld		c, a
		ld		a, [ix + SCA_INFO_YL]
		add		a, 3
		rlca
		rlca
		rlca
		ld		b, a
		call	enemy_boss8_shot
		; 状態判定
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L]
		cp		a, 1
		jp		c, enemy_boss8_left_s0
		jp		z, enemy_boss8_left_s1
		jp		enemy_boss8_left_s2

enemy_boss8_left_s0:
		; 秒カウントタイマー
		ld		a, [wait_timer_left]
		dec		a
		ld		[wait_timer_left], a
		ret		nz
		ld		a, 60
		ld		[wait_timer_left], a
		; 左パーツが待機中なら何もしない
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret		nz
		; 下へ移動するタイミングになったので S1 へ遷移
		ld		a, 1
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
		ld		a, LEFT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret

enemy_boss8_left_s1:
		; スピードカウンタ
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret		nz
		ld		a, LEFT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		; 下へ移動させる
		ld		a, [ix + SCA_INFO_YL]
		inc		a
		ld		[ix + SCA_INFO_YL], a
		cp		a, 13
		jp		nz, enemy_boss8_left_s1_skip1
		; 13に到達した場合は次の状態へ遷移
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
enemy_boss8_left_s1_skip1:
		; 必ず表示を更新する
		ld		e, [ix + SCA_INFO_XL]
		ld		d, [ix + SCA_INFO_YL]
		call	draw_boss8_left
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_left_s2:
		; スピードカウンタ
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		ret		nz
		ld		a, LEFT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
		; 上へ移動させる
		ld		a, [ix + SCA_INFO_YL]
		dec		a
		ld		[ix + SCA_INFO_YL], a
		jp		nz, enemy_boss8_left_s2_skip1
		; 0に到達した場合は次の状態へ遷移
		ld		[ix + SCA_INFO_ENEMY_STATE_L], a
		ld		a, LEFT_PART_DOWN_CYCLE
		ld		[ix + SCA_INFO_ENEMY_STATE_H], a
enemy_boss8_left_s2_skip1:
		; 必ず表示を更新する
		ld		e, [ix + SCA_INFO_XL]
		ld		d, [ix + SCA_INFO_YL]
		call	draw_boss8_left
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_move_right::
		; 右パーツがすでに破壊済みなら何もしない
		ld		a, [ix + SCA_INFO_ENEMY_POWER3]
		or		a, a
		ret		z
		; 弾発射処理
		ld		a, [ix + SCA_INFO_XL2]
		rlca
		rlca
		rlca
		ld		c, a
		ld		a, [ix + SCA_INFO_YL2]
		add		a, 3
		rlca
		rlca
		rlca
		ld		b, a
		call	enemy_boss8_shot
		; 状態判定
		ld		a, [ix + SCA_INFO_ENEMY_STATE_L2]
		cp		a, 1
		jp		c, enemy_boss8_right_s0
		jp		z, enemy_boss8_right_s1
		jp		enemy_boss8_right_s2

enemy_boss8_right_s0:
		; 秒カウントタイマー
		ld		a, [wait_timer_right]
		dec		a
		ld		[wait_timer_right], a
		ret		nz
		ld		a, 60
		ld		[wait_timer_right], a
		; 右パーツが待機中なら何もしない
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H2]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret		nz
		; 下へ移動するタイミングになったので S1 へ遷移
		ld		a, 1
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], a
		ld		a, RIGHT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret

enemy_boss8_right_s1:
		; スピードカウンタ
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H2]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret		nz
		ld		a, RIGHT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		; 下へ移動させる
		ld		a, [ix + SCA_INFO_YL2]
		inc		a
		ld		[ix + SCA_INFO_YL2], a
		cp		a, 13
		jp		nz, enemy_boss8_right_s1_skip1
		; 13に到達した場合は次の状態へ遷移
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], a
enemy_boss8_right_s1_skip1:
		; 必ず表示を更新する
		ld		e, [ix + SCA_INFO_XL2]
		ld		d, [ix + SCA_INFO_YL2]
		call	draw_boss8_right
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_right_s2:
		; スピードカウンタ
		ld		a, [ix + SCA_INFO_ENEMY_STATE_H2]
		dec		a
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		ret		nz
		ld		a, RIGHT_PART_DOWN_SPEED
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
		; 上へ移動させる
		ld		a, [ix + SCA_INFO_YL2]
		dec		a
		ld		[ix + SCA_INFO_YL2], a
		jp		nz, enemy_boss8_right_s2_skip1
		; 0に到達した場合は次の状態へ遷移
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], a
		ld		a, RIGHT_PART_DOWN_CYCLE
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], a
enemy_boss8_right_s2_skip1:
		; 必ず表示を更新する
		ld		e, [ix + SCA_INFO_XL2]
		ld		d, [ix + SCA_INFO_YL2]
		call	draw_boss8_right
		ld		a, 1
		ld		[boss_center_update], a
		ret

enemy_boss8_move_center:
		ld		a, [ix + SCA_INFO_ENEMY_POWER5]
		or		a, a
		ret		z								; 中央パーツがすでに破壊済み または state0 なら何もしない

		; 弾発射処理
		ld		a, [ix + SCA_INFO_XL3]
		add		a, 4
		rlca
		rlca
		rlca
		ld		c, a
		ld		a, [ix + SCA_INFO_YL3]
		add		a, 6
		rlca
		rlca
		rlca
		ld		b, a
		call	enemy_boss8_shot

		ld		a, [ix + SCA_INFO_ENEMY_STATE_H3]
		cp		a, 1
		jp		c, enemy_boss8_center_s0
		jp		z, enemy_boss8_center_s1
		cp		a, 3
		jp		c, enemy_boss8_center_s2
		jp		enemy_boss8_center_s3

enemy_boss8_center_s0:
		; 更新タイマー
		ld		a, [wait_timer_center]
		dec		a
		ld		[wait_timer_center], a
		jp		nz, enemy_boss8_center_force_update
		ld		a, CENTER_MOVE_SPEED
		ld		[wait_timer_center], a
		; レーザー発射タイミング
		ld		a, [wait_timer_laser]
		dec		a
		ld		[wait_timer_laser], a
		jp		nz, enemy_boss8_center_force_update
		; レーザー発射準備状態に遷移
		ld		hl, [se_pre_laser]
		call	bgmdriver_play_sound_effect
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ld		a, CENTER_BEFORE_LASER_WAIT
		ld		[wait_timer_left], a
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		jp		draw_boss8_center
enemy_boss8_center_force_update:
		ld		a, [boss_center_update]
		or		a, a
		ret		z
		xor		a, a
		ld		[boss_center_update], a
enemy_boss8_move_center_active:
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		jp		draw_boss8_center

enemy_boss8_center_s1:
		; 更新タイマー
		ld		a, [wait_timer_center]
		dec		a
		ld		[wait_timer_center], a
		ret		nz
		ld		a, CENTER_MOVE_SPEED
		ld		[wait_timer_center], a
		; レーザー発射タイミング
		ld		a, [wait_timer_laser]
		dec		a
		ld		[wait_timer_laser], a
		jp		nz, enemy_boss8_move_center_active2
		; レーザー発射準備状態に遷移
		ld		hl, [se_pre_laser]
		call	bgmdriver_play_sound_effect
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ld		a, CENTER_BEFORE_LASER_WAIT
		ld		[wait_timer_left], a
		ld		a, 2
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		jp		draw_boss8_center2

enemy_boss8_move_center_active2::
		; X座標の位相角
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H]
		ld		de, 5
		add		hl, de
		ld		[ix + SCA_INFO_ENEMY_STATE_L], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H], h
		; b = 72*sinθ
		call	enemy_get_cos
		; a = b*0.1 = [b*3 >> 5] + 7
		; 72*3 = 216 なので >> 1 で 108 になり、符号付き 8bit に収まる
		xor		a, a
		ld		l, b
		ld		h, a
		ld		e, b
		ld		d, a
		add		hl, de
		add		hl, de
		xor		a, a
		cp		a, h
		rr		l
		ld		a, l
		sra		a
		sra		a
		sra		a
		sra		a
		add		a, 7
		ld		[ix + SCA_INFO_XL3], a
		; Y座標の位相角
		ld		l, [ix + SCA_INFO_ENEMY_STATE_L2]
		ld		h, [ix + SCA_INFO_ENEMY_STATE_H2]
		ld		de, 15
		add		hl, de
		ld		[ix + SCA_INFO_ENEMY_STATE_L2], l
		ld		[ix + SCA_INFO_ENEMY_STATE_H2], h
		; c = 72*cosθ
		call	enemy_get_cos
		ld		a, c
		; a = c/16 + 5 = [c >> 4] + 5
		sra		a
		sra		a
		sra		a
		sra		a
		neg
		add		a, 5
		ld		[ix + SCA_INFO_YL3], a
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, a
		xor		a, a
		jp		draw_boss8_center2

enemy_boss8_center_s2:							; レーザー発射準備中
		ld		a, [wait_timer_left]
		dec		a
		ld		[wait_timer_left], a
		jp		nz, enemy_boss8_center_force_update
		ld		a, CENTER_AFTER_LASER_WAIT
		ld		[wait_timer_left], a
		; レーザー発射音
		ld		hl, [se_laser]
		call	bgmdriver_play_sound_effect
		; レーザーを描画
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		ld		a, 105
		call	background_draw_laser
		ld		a, 3
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ret

enemy_boss8_center_s3:							; レーザー発射中
		ld		a, [wait_timer_left]
		dec		a
		ld		[wait_timer_left], a
		jp		nz, enemy_boss8_center_force_update
		ld		a, CENTER_MOVE_SPEED
		ld		[wait_timer_left], a
		; レーザー音停止
		ld		hl, [se_stop]
		call	bgmdriver_play_sound_effect
		; レーザーを消去
		ld		e, [ix + SCA_INFO_XL3]
		ld		d, [ix + SCA_INFO_YL3]
		xor		a, a
		call	background_draw_laser
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, [ix + SCA_INFO_ENEMY_POWER3]
		ld		a, 0
		jp		nz, enemy_boss8_center_s3_skip1	; 左右パーツの少なくとも１体が生きていれば skip1 へ
		inc		a
enemy_boss8_center_s3_skip1:
		ld		[ix + SCA_INFO_ENEMY_STATE_H3], a
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ret

; -----------------------------------------------------------------------------
;	ボス8の弾発射処理
;		c	... 発射座標X
;		b	...	発射座標Y
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,ix,iy
; -----------------------------------------------------------------------------
enemy_boss8_shot:
		ld		a, [wait_timer_shot]
		dec		a
		ld		[wait_timer_shot], a
		ret		nz
		ld		a, SHOT_CYCLE
		ld		[wait_timer_shot], a

enemy_boss8_shot2::
		push	bc
		call	enemy_shot_search
		pop		bc
		ret		z
		; 発射する弾の種類を決定する
		ld		a, [boss_shot_type]
		dec		a
		ld		[boss_shot_type], a
		jp		z, enemy_boss8_shot3

		; 回転発射の場合
		push	bc
		push	hl
		; 発射方向を回転させる
		ld		hl, [boss_shot_angle]
		ld		de, 512/11
		add		hl, de
		ld		[boss_shot_angle], hl
		; sin, cos を求める
		call	enemy_get_cos
		ld		e, c
		ld		d, b
		pop		hl
		pop		bc
		jp		enemy_shot_start_one2

		; 自機照準発射の場合
enemy_boss8_shot3:
		ld		a, SHOT_TYPE_CHANGE
		ld		[boss_shot_type], a
		push	ix
		ld		ix, boss_shot_info
		ld		iy, player_info
		ld		[ix + SCA_INFO_XH], c
		ld		[ix + SCA_INFO_YH], b
		call	enemy_shot_start_one
		pop		ix
		ret

; -----------------------------------------------------------------------------
;	ボス8の登場処理
;		iy	... 敵情報のアドレス
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy_boss8_start::
		; 当たり判定をラスボス用に切り替える
		ld		a, 2
		call	change_crash_check_routine
		; ボスシールド更新
		ld		a, 32
		ld		[iy + SCA_INFO_ENEMY_POWER], a		; 左パーツ
		ld		[iy + SCA_INFO_ENEMY_POWER3], a		; 右パーツ
		ld		a, 80
		ld		[iy + SCA_INFO_ENEMY_POWER5], a		; 中央パーツ
		; 内部状態初期化
		ld		a, 60
		ld		[wait_timer_left], a
		ld		[wait_timer_right], a
		ld		[wait_timer_center], a
		ld		a, CENTER_LASER_CYCLE
		ld		[wait_timer_laser], a
		ld		a, SHOT_CYCLE
		ld		[wait_timer_shot], a
		ld		a, SHOT_TYPE_CHANGE
		ld		[boss_shot_type], a
		ld		hl, 0
		ld		[boss_shot_angle], hl
		xor		a, a
		ld		[iy + SCA_INFO_ENEMY_STATE_L], a
		ld		[iy + SCA_INFO_ENEMY_STATE_L2], a
		ld		[iy + SCA_INFO_ENEMY_STATE_H3], a
		ld		a, LEFT_PART_1ST_DOWN_TIME
		ld		[iy + SCA_INFO_ENEMY_STATE_H], a
		ld		a, RIGHT_PART_1ST_DOWN_TIME
		ld		[iy + SCA_INFO_ENEMY_STATE_H2], a
		; X, Y座標更新 [スプライトに影響が出ないように L を使う）
		ld		a, 1
		ld		[iy + SCA_INFO_XL], a		; 左パーツX
		ld		a, 14
		ld		[iy + SCA_INFO_XL2], a		; 右パーツX
		ld		a, 7
		ld		[iy + SCA_INFO_XL3], a		; 中央パーツX
		xor		a, a
		ld		[iy + SCA_INFO_YL], a		; 左パーツY
		ld		[iy + SCA_INFO_YL2], a		; 右パーツY
		ld		[iy + SCA_INFO_YL3], a		; 中央パーツY
		; ボス表示
		ld		e, [iy + SCA_INFO_XL]
		ld		d, [iy + SCA_INFO_YL]
		call	draw_boss8_left
		ld		e, [iy + SCA_INFO_XL2]
		ld		d, [iy + SCA_INFO_YL2]
		call	draw_boss8_right
		ld		e, [iy + SCA_INFO_XL3]
		ld		d, [iy + SCA_INFO_YL3]
		call	draw_boss8_center
		; Y座標更新
		ld		a, 212
		ld		[iy + SCA_INFO_YH], a
		ld		[iy + SCA_INFO_YH2], a
		ld		[iy + SCA_INFO_YH3], a
		ld		[iy + SCA_INFO_YH4], a
		ld		[iy + SCA_INFO_YH5], a
		ld		[iy + SCA_INFO_YH6], a
		ld		[iy + SCA_INFO_YH7], a
		ld		[iy + SCA_INFO_YH8], a
		; X座標更新
		xor		a, a
		ld		[iy + SCA_INFO_XH], a
		ld		[iy + SCA_INFO_XH2], a
		ld		[iy + SCA_INFO_XH5], a
		ld		[iy + SCA_INFO_XH6], a
		ld		[iy + SCA_INFO_XH3], a
		ld		[iy + SCA_INFO_XH4], a
		ld		[iy + SCA_INFO_XH7], a
		ld		[iy + SCA_INFO_XH8], a
		ld		hl, enemy_boss8_move
		ld		[iy + SCA_INFO_ENEMY_MOVE_L], l
		ld		[iy + SCA_INFO_ENEMY_MOVE_H], h
		ld		hl, enemy_boss8_move_dummy
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
		ret

wait_timer_left:
		db		0
wait_timer_right:
		db		0
wait_timer_center:
		db		0
wait_timer_laser:
		db		0
boss_center_update::
		db		0
wait_timer_shot:
		db		0
boss_shot_angle:
		dw		0
boss_shot_type:
		db		0
boss_shot_info:
		db		0, 0, 0, 0
