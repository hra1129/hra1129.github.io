; -----------------------------------------------------------------------------
;	敵の管理ルーチン
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	敵の初期化（ゲーム開始時）
;	input:
;		なし
;	output
;		なし
;	break
;		b,c,d,e,h,l
;	comment
;		敵情報は、下記の構造をとる
;			unsigned char	reverse		左右位置反転
;			unsigned char	x			座標
;			unsigned short	y			上位8bitが座標, 下位8bitは小数部[小数部は常に0]
;			unsigned char	power		残り耐久力
;			unsigned short	state		状態
; -----------------------------------------------------------------------------
enemy_init::
		; ステージ情報を初期化
		ld		a, SCA_START_STAGE
		ld		[stage_number], a
		ld		a, 2
		ld		[enemy_shield_base], a
		ld		a, 120						; 4の倍数
		ld		[enemy_shot_speed], a
		ret

; -----------------------------------------------------------------------------
;	敵の初期化（ステージの開始時）
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
;	comment
;		STAGE1 のときは、enemy_init の後に呼ばれる
; -----------------------------------------------------------------------------
enemy_init_stage::
		; 敵出現タイミングカウンタをクリア
		ld		a, 1
		ld		[enemy_update_time], a
		; Y 座標を全て 212 にクリア
		ld		de, enemy_init_ret
		xor		a, a
		ld		b, 6 * 2 + SCA_SHOT_COUNT
		ld		c, 212
		ld		hl, enemy_info0
enemy_init_loop:
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], c					; SCA_INFO_YH ← 212
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], a
		inc		hl
		ld		[hl], e					; SCA_INFO_ENEMY_MOVE_L ← ダミー
		inc		hl
		ld		[hl], d					; SCA_INFO_ENEMY_MOVE_H ← ダミー
		inc		hl
		djnz	enemy_init_loop
		; 敵スプライトのスプライト番号情報を初期化
		ld		b, 6
		ld		a, 2
		ld		de, SCA_INFO_SIZE * 2
		ld		hl, enemy_info0 + SCA_INFO_ENEMY_SPRITE_NUM
enemy_init_loop2:
		ld		[hl], a
		add		a, 2
		add		hl, de
		djnz	enemy_init_loop2
		; 敵出現情報を新しいテーブルに変更
		ld		a, [stage_number]
		and		a, 7
		rlca
		ld		h, 0
		ld		l, a
		ld		de, enemy_map_table
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ld		[enemy_map_index], de
		; 敵の出現状態を初期化
		xor		a, a
		ld		[enemy_map_state], a
		ld		[enemy_map_enemy_count], a
		ld		[enemy_map_wait_count], a
		ld		[enemy_map_enemy_start_entry], a
		ld		[enemy_map_enemy_start_entry+1], a
		ld		[enemy_boss_state], a
		inc		a
		ld		[enemy_update_time], a
		ld		hl, SCA_BOSS_TIME
		ld		[enemy_boss_count], hl
		; 敵の当たり判定をリセット
		xor		a, a
		call	change_crash_check_routine
enemy_init_ret:
		ret

; -----------------------------------------------------------------------------
;	敵の登場処理
;	input:
;		ix	... 自機情報のアドレス
;		iy	... 敵情報のアドレス[先頭, 6個分続いている必要がある]
;	output
;		なし
;	break
;		a,b,d,e,f,h,l,iy
; -----------------------------------------------------------------------------
enemy_start::
		; 敵出現タイミングかどうか判断する
		ld		a, [enemy_update_time]
		dec		a
		jr		z, enemy_start_skip1
		; 出現タイミングではないので、カウントだけ進めて抜ける
		ld		[enemy_update_time], a
		ret
enemy_start_skip1:
		; 出現タイミングカウンタをリセットする
		ld		a, 10
		ld		[enemy_update_time], a
		; ボス登場/出現中か？
		ld		hl, [enemy_boss_count]
		ld		a, l
		or		a, h
		jp		z, enemy_boss
		; ボス登場までのカウントダウン
		dec		hl
		ld		[enemy_boss_count], hl
		; 待機時間が設定されていれば何もしないで抜ける
		ld		a, [enemy_map_wait_count]
		or		a, a
		jr		z, enemy_start_check_map
		dec		a
		ld		[enemy_map_wait_count], a
		ret
enemy_start_check_map:
		; 敵出現状態を確認する
		ld		a, [enemy_map_state]
		cp		a, 1
		jr		c, enemy_start_read_map				; 新しいコマンド受付中なら enemy_start_read_map へ
		jr		z, enemy_start_one_enemy			; 敵出現中なら enemy_start_one_enemy へ

enemy_start_wait_all_destroy:
		; 敵全滅待機中
		ld		b, 6		; 全6機から探索
		ld		de, SCA_INFO_SIZE + SCA_INFO_SIZE
enmemy_start_destroy_check_loop:
		ld		a, [iy + SCA_INFO_YH]
		cp		a, 212
		ret		nz									; 生存中の敵が居るので何もせずに脱ける
		add		iy, de
		djnz	enmemy_start_destroy_check_loop
		xor		a, a
		ld		[enemy_map_state], a				; 新しいコマンド受付中 の状態へ遷移
		ret

enemy_start_one_enemy:
		; 出現すべき敵の数をカウント
		ld		a, [enemy_map_enemy_count]
		dec		a
		ld		[enemy_map_enemy_count], a
		jr		nz, enemy_start_one_enemy_skip1
		ld		[enemy_map_state], a				; 新しいコマンド受付中 の状態へ遷移 [ここは必ず a = 0]
enemy_start_one_enemy_skip1:
		; 出現できる敵があるか探索する
		ld		b, 6		; 全6機から探索
		ld		de, SCA_INFO_SIZE + SCA_INFO_SIZE
enmemy_start_loop1:
		ld		a, [iy + SCA_INFO_YH]
		cp		a, 212
		jr		z, enemy_start_found_enemy
		add		iy, de
		djnz	enmemy_start_loop1
		ret
enemy_start_found_enemy:
		ld		a, 3
		ld		[enemy_map_wait_count], a			; 連続して出現しないように少し待ちを挿入
		ld		hl, [enemy_map_enemy_start_entry]
		jp		hl

enemy_start_read_map:
		; 敵出現データを読み取る
		ld		hl, [enemy_map_index]
		ld		a, [hl]
		inc		hl
		; 敵出現コマンドか？
		cp		a, 0x40
		jr		c, enemy_start_ok					; 0x3F以下 敵出現
		jr		z, enemy_start_enter_wait_destroy	; 0x40     敵全滅待機
		cp		a, 0x42
		jr		c, enemy_start_entrt_wait_time		; 0x41     単純待機
		jr		z, enemy_start_jump					; 0x42     ジャンプ

enemt_start_delete_stagex:
		; 背景 STAGE* 表示の消去					  0x43
		ld		[enemy_map_index], hl
		jp		background_delete_stage_message

enemy_start_jump:
		; データジャンプコマンド
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		ld		[enemy_map_index], hl
		ret

enemy_start_ok:
		; 敵出現中モードへ遷移
		ld		e, a
		ld		a, 1
		ld		[enemy_map_state], a
		ld		a, [hl]								; 出現数
		ld		[enemy_map_enemy_count], a
		inc		hl
		ld		[enemy_map_index], hl
		ld		a, e
		rlca
		ld		l, a
		ld		h, 0
		ld		de, enemy_start_table
		add		hl, de
		ld		a, [hl]
		ld		[enemy_map_enemy_start_entry+0], a
		inc		hl
		ld		a, [hl]
		ld		[enemy_map_enemy_start_entry+1], a
		ret

enemy_start_enter_wait_destroy:
		; 敵全滅待機中モードに遷移
		ld		a, 2
		ld		[enemy_map_state], a
		ld		[enemy_map_index], hl
		ret

enemy_start_entrt_wait_time:
		; 単純待機
		ld		a, [hl]
		ld		[enemy_map_wait_count], a
		inc		hl
		ld		[enemy_map_index], hl
		ret

enemy_start_table:
		dw		enemy1_start
		dw		enemy2_start
		dw		enemy3_start
		dw		enemy4_start
		dw		enemy5_start

; -----------------------------------------------------------------------------
;	ボスの処理
;	input:
;		iy	... 敵情報のアドレス[先頭, 6個分続いている必要がある]
;	output
;		なし
;	break
;		全て
; -----------------------------------------------------------------------------
enemy_boss:
		ld		a, [enemy_boss_state]
		cp		a, 1
		jr		c, enemy_boss_bgm_fadeout		; 0 なら BGM をフェードアウト開始
		jr		z, enemy_boss_bgm_stop_wait1	; 1 なら BGM 停止待ち
		cp		a, 3
		jr		c, enemy_boss_bgm_stop_wait2	; 2 なら BGM 停止待ち
		jr		z, enemy_boss_start				; 3 なら ボス出現
		cp		a, 5
		jr		c, enemy_boss_dummy				; 4 なら 何もしない
		jr		enemy_boss_destroy				; 5 なら ステージクリア処理

		; state 0: BGMフェードアウト
enemy_boss_bgm_fadeout:
		inc		a
		ld		[enemy_boss_state], a
		ld		a, 30							; 10 * 16 * 1/60秒
		jp	bgmdriver_fadeout

		; state 1: BGM停止待ち
enemy_boss_bgm_stop_wait1:
		call	bgmdriver_check_playing
		ret		nz
		ld		a, 2
		ld		[enemy_boss_state], a
		ld		hl, [bgm_boss_buz]				; boss の 警告音 を演奏開始
		call	bgmdriver_play
		call	background_show_warning			; WARNING!! を表示
		ret

		; state 2: 警告音停止待ち
enemy_boss_bgm_stop_wait2:
		call	bgmdriver_check_playing
		ret		nz
		ld		a, 3
		ld		[enemy_boss_state], a
		call	background_delete_stage_message	; WARNING!! を消去
		ret

		; state 3: ボス出現
enemy_boss_start::
		ld		a, 4
		ld		[enemy_boss_state], a
		ld		a, [stage_number]
		and		a, 7
		ld		hl, [bgm_boss1]					; boss1 の BGM を演奏開始
		cp		a, 7
		jp		nz, enemy_boss_start_skip1
		ld		hl, [bgm_finalboss]				; finalboss の BGM を演奏開始
enemy_boss_start_skip1:
		push	ix
		call	bgmdriver_play
		pop		ix
		ld		a, 6 * 5						; ボスを倒した後の待機時間を初期化[5秒]
		ld		[enemy_boss_destroy_wait], a

		ld		a, [stage_number]
		and		a, 7
		rlca
		ld		l, a
		ld		h, 0
		ld		de, enemy_boss_start_table
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		jp		hl								; ボス開始ルーチンへジャンプ

		; state 4: なにもしない
enemy_boss_dummy:
		ret

		; state 5: ボスがやられた後にステージクリア画面まで待機
enemy_boss_destroy:
		ld		a, [enemy_boss_destroy_wait]
		dec		a
		ld		[enemy_boss_destroy_wait], a
		ret		nz
		call	goto_next_stage
		ret

; -----------------------------------------------------------------------------
;	ボスの破壊処理
;	input:
;		なし
;	output
;		なし
;	break
;
; -----------------------------------------------------------------------------
enemy_boss_destroy_request::
		ld		a, 5
		ld		[enemy_boss_state], a
		ret

; -----------------------------------------------------------------------------
;	敵の移動処理
;	input:
;		ix	...	敵1情報のアドレス
;	output
;		なし
;	break
;		全て
; -----------------------------------------------------------------------------
enemy_move::
		ld		ix, enemy_info0
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info1
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info2
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info3
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info4
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl

		ld		ix, enemy_info5
		ld		l, [ix + SCA_INFO_ENEMY_MOVE_L]
		ld		h, [ix + SCA_INFO_ENEMY_MOVE_H]
		call	enemy_move_call_hl
		ret
enemy_move_call_hl:
		jp		hl

; -----------------------------------------------------------------------------
;	cosθ
;	input:
;		hl	... θ [0 = 0[rad], 512 = 2π[rad]]
;	output
;		c	... cosθ
;		b	... sinθ
;	break
;		a,b,c,d,e,f,h,l
; -----------------------------------------------------------------------------
enemy_get_cos::
		push	hl
		xor		a, a
		bit		7, l
		jr		z, enemy_get_cos_skip1
		dec		a						; 第2象限 or 第4象限 なら、b = 255, それ以外は b = 0
enemy_get_cos_skip1:
		ld		b, a
		ld		a, l
		xor		a, b
		and		a, 127					; 0～π/2[rad] に変換された cos角度
		ld		de, enemy_cos_table
		ld		l, a					; 待避
		add		a, e
		ld		e, a
		ld		a, 0					; フラグを変えたくないので xor a は使えない
		adc		a, d
		ld		d, a
		ex		de, hl
		ld		c, [hl]					; cosθ
		ex		de, hl
		ld		de, enemy_cos_table
		ld		a, l
		xor		a, 127					; sin を得るための cos角度 を a に格納
		ld		l, a
		ld		h, 0
		add		hl, de
		ld		b, [hl]					; sinθ
		pop		hl
		; 符号
		bit		7, l					; 第2象限 or 第4象限 なら cos符号反転
		jr		z, enemy_get_cos_skip2
		ld		a, c
		neg
		ld		c, a
enemy_get_cos_skip2:
		bit		0, h					; 第3象限 or 第4象限 なら cos, sin符号反転
		jr		z, enemy_get_cos_skip3
		ld		a, b
		neg
		ld		b, a
		ld		a, c
		neg
		ld		c, a
enemy_get_cos_skip3:
		ret

; -----------------------------------------------------------------------------
;	敵弾発射処理[１つ分]
;	input:
;		ix	... 弾の発射点
;		iy	... 弾の到達点
;		hl	... 弾の情報
;	output
;		なし
;	break
;		a,b,c,h,l
; -----------------------------------------------------------------------------
enemy_shot_start_one::
		; DX を求める
		ld		a, [iy + SCA_INFO_XH]		; 到達点X: 値域は 0～175
		ld		b, [ix + SCA_INFO_XH]		; 発射点X: 値域は 0～175
		ld		[hl], 1						; 暫定的に 到達点X - 発射点X は、正であることを示すマーク を付ける
		sub		a, b
		jr		nc, enemy_shot_skip1
		ld		[hl], -1					; 到達点X - 発射点X は、負であることを示すマークで更新
		neg									; 符号反転
enemy_shot_skip1:
		inc		hl
		ld		[hl], b						; 発射点X
		inc		hl
		ld		c, a						; c = DX
		; DY を求める
		ld		a, [iy + SCA_INFO_YH]		; 到達点Y: 値域は 0～175
		ld		b, [ix + SCA_INFO_YH]		; 発射点Y: 値域は 0～175
		ld		[hl], 1						; 暫定的に 到達点Y - 発射点Y は、正であることを示すマーク を付ける
		sub		a, b
		jr		nc, enemy_shot_skip2
		ld		[hl], -1					; 到達点Y - 発射点Y は、負であることを示すマークで更新
		neg									; 符号反転
enemy_shot_skip2:
		inc		hl
		ld		[hl], b					; 発射点Y
		inc		hl
		; DX と DY の大きさを比較
		cp		a, c						; DX の方が大きければキャリーフラグが立つ
		jr		c, enemy_shot_dx_den
enemy_shot_dy_den:						; 分母が DY の場合
		ld		[hl], 0				; 分母が DY であることを示すマーク
		inc		hl
		ld		[hl], a					; 分母に DY を代入
		inc		hl
		ld		[hl], c					; 分子に DX を代入
		inc		hl
		ld		[hl], 0				; カウンタをクリア
		ret
enemy_shot_dx_den:						; 分母が DX の場合
		ld		[hl], 1				; 分母が DX であることを示すマーク
		inc		hl
		ld		[hl], c					; 分母に DX を代入
		inc		hl
		ld		[hl], a					; 分子に DY を代入
		inc		hl
		ld		[hl], 0				; カウンタをクリア
		ret

; -----------------------------------------------------------------------------
;	敵弾発射処理[１つ分]
;	input:
;		c	... 弾の発射点X
;		b	... 弾の発射点Y
;		e	... 弾の方向X
;		d	...	弾の方向Y
;		hl	... 弾の情報
;	output
;		なし
;	break
;		a,b,c,h,l
; -----------------------------------------------------------------------------
enemy_shot_start_one2::
		; DX を求める
		ld		[hl], 1					; 暫定的に 到達点X - 発射点X は、正であることを示すマーク を付ける
		ld		a, e
		or		a, a
		jp		p, enemy_shot2_skip1
		ld		[hl], -1				; 到達点X - 発射点X は、負であることを示すマークで更新
		neg								; 符号反転
enemy_shot2_skip1:
		inc		hl
		ld		[hl], c					; 発射点X
		inc		hl
		ld		c, a					; c = DX
		; DY を求める
		ld		[hl], 1					; 暫定的に 到達点Y - 発射点Y は、正であることを示すマーク を付ける
		ld		a, d
		or		a, a
		jp		p, enemy_shot_skip2
		ld		[hl], -1				; 到達点Y - 発射点Y は、負であることを示すマークで更新
		neg								; 符号反転
		jp		enemy_shot_skip2

; -----------------------------------------------------------------------------
;	敵弾発射処理
;	input:
;		ix	... 弾の発射点
;		iy	... 弾の到達点
;	output
;		なし
;	break
;		a,b,c,d,e,h,l,f
; -----------------------------------------------------------------------------
enemy_shot_start::
		call	enemy_shot_search
		jp		nz, enemy_shot_start_one
		ret

; -----------------------------------------------------------------------------
;	発射可能な敵弾を検索する
;	input:
;		なし
;	output
;		なし
;	break
;		a,b,c,d,e,h,l,f
; -----------------------------------------------------------------------------
enemy_shot_search::
		ld		hl, eshot_info + SCA_INFO_YH
		ld		de, SCA_INFO_SIZE
		; 空いてる弾情報を探索するループ
		ld		b, SCA_SHOT_COUNT		; 弾情報は SCA_SHOT_COUNTセットある
enemy_shot_search_loop:
		ld		a, [hl]					; a = YH
		cp		a, 212
		jr		z, enemy_shot_found
		add		hl, de
		djnz	enemy_shot_search_loop
		xor		a, a
		ret								; 空きがないので諦める, xor a の後なので必ず z になる
enemy_shot_found:
		dec		hl
		dec		hl
		dec		hl
		or		a, a						; a は 212 なので、必ず nz になる
		ret

; -----------------------------------------------------------------------------
;	敵弾動作処理[1つ分]
;	input:
;		ix	... 弾の情報
;	output
;		なし
;	break
;		すべて
; -----------------------------------------------------------------------------
enemy_shot_move_one::
		; 発射中か？
		ld		a, [ix + SCA_INFO_YH]
		cp		a, 212
		ret		z							; 発射中でなければ何もしないで抜ける
		; 傾きの分母が DX か DY かによって処理を変える
		ld		a, [ix + SCA_INFO_ESHOT_DEN_IS_DX]
		or		a, a							; 分母は DX か？
		jr		z, enemy_shot_den_is_dy

		; 分母が DX の場合
enemy_shot_den_is_dx:
		; X方向に移動
		ld		a, [ix + SCA_INFO_XH]
		ld		b, [ix + SCA_INFO_ESHOT_X_SIG]
		add		a, b
		ld		[ix + SCA_INFO_XH], a
		; 画面外判定
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192-8
		jr		z, enemy_shot_end
		; Y方向に移動するタイミングか判断
		ld		a, [ix + SCA_INFO_ESHOT_CNT]
		add		a, [ix + SCA_INFO_ESHOT_NUM]
		jr		c, enemy_shot_dx_cnt_end	; 8bit をオーバーフローした場合は移動確定
		cp		a, [ix + SCA_INFO_ESHOT_DEN]
		jr		nc, enemy_shot_dx_cnt_end	; 8bit におさまってるけども分母を超えた場合
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; 今回のタイミングは Y方向に移動しない
		ret
enemy_shot_dx_cnt_end:
		; カウンタを更新
		sub		a, [ix + SCA_INFO_ESHOT_DEN]		; 分母を引く
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; 今回のタイミングは Y方向に移動しない
		; Y方向に移動
		ld		a, [ix + SCA_INFO_YH]
		ld		b, [ix + SCA_INFO_ESHOT_Y_SIG]
		add		a, b
		ld		[ix + SCA_INFO_YH], a
		; 画面外判定
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192
		jr		z, enemy_shot_end
		ret

		; 分母が DY の場合
enemy_shot_den_is_dy:
		; Y方向に移動
		ld		a, [ix + SCA_INFO_YH]
		ld		b, [ix + SCA_INFO_ESHOT_Y_SIG]
		add		a, b
		ld		[ix + SCA_INFO_YH], a
		; 画面外判定
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192
		jr		z, enemy_shot_end
		; X方向に移動するタイミングか判断
		ld		a, [ix + SCA_INFO_ESHOT_CNT]
		add		a, [ix + SCA_INFO_ESHOT_NUM]
		jr		c, enemy_shot_dy_cnt_end	; 8bit をオーバーフローした場合は移動確定
		cp		a, [ix + SCA_INFO_ESHOT_DEN]
		jr		nc, enemy_shot_dy_cnt_end	; 8bit におさまってるけども分母を超えた場合
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; 今回のタイミングは Y方向に移動しない
		ret
enemy_shot_dy_cnt_end:
		; カウンタを更新
		sub		a, [ix + SCA_INFO_ESHOT_DEN]		; 分母を引く
		ld		[ix + SCA_INFO_ESHOT_CNT], a	; 今回のタイミングは Y方向に移動しない
		; X方向に移動
		ld		a, [ix + SCA_INFO_XH]
		ld		b, [ix + SCA_INFO_ESHOT_X_SIG]
		add		a, b
		ld		[ix + SCA_INFO_XH], a
		; 画面外判定
		cp		a, 255
		jr		z, enemy_shot_end
		cp		a, 192-8
		jr		z, enemy_shot_end
		ret
		; 画面外にでた場合
enemy_shot_end:
		ld		[ix + SCA_INFO_YH], 212
		ret

; -----------------------------------------------------------------------------
;	敵弾動作処理
;	input:
;		ix	... 弾の情報
;	output
;		なし
;	break
;		すべて
; -----------------------------------------------------------------------------
enemy_shot_move::
		ld		b, SCA_SHOT_COUNT			; 敵弾情報は SCA_SHOT_COUNTセットある
enemy_shot_move_loop:
		push	bc
		call	enemy_shot_move_one
		pop		bc
		ld		de, SCA_INFO_SIZE
		add		ix, de
		djnz	enemy_shot_move_loop
		ret

; -----------------------------------------------------------------------------
;	次のステージへ移るための処理
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
; -----------------------------------------------------------------------------
enemy_next_stage::
		; ステージ番号をインクリメント
		ld		a, [stage_number]
		inc		a
		ld		[stage_number], a
		; ザコ敵の硬さをインクリメント
		ld		a, [enemy_shield_base]
		cp		a, SCA_MAX_ENEMY_POWER
		jr		z, enemy_next_stage_skip1
		inc		a
		ld		[enemy_shield_base], a
enemy_next_stage_skip1:
		; ザコ敵が弾を撃ってくる周期をデクリメント
		ld		a, [enemy_shot_speed]
		cp		a, SCA_MIN_ENEMY_SHOT_INTERVAL
		jr		z, enemy_next_stage_skip2
		dec		a
		dec		a
		dec		a
		dec		a
		ld		[enemy_shot_speed], a
enemy_next_stage_skip2:
		ret

; -----------------------------------------------------------------------------
;	ボス開始テーブル
; -----------------------------------------------------------------------------
enemy_boss_start_table:
		dw		enemy_boss1_start
		dw		enemy_boss2_start
		dw		enemy_boss3_start
		dw		enemy_boss4_start
		dw		enemy_boss5_start
		dw		enemy_boss6_start
		dw		enemy_boss7_start
		dw		enemy_boss8_start

; -----------------------------------------------------------------------------
;	cosθテーブル
; -----------------------------------------------------------------------------
enemy_cos_table:
		db		72, 72, 72, 72, 72, 72, 72, 72
		db		72, 72, 72, 72, 72, 72, 71, 71
		db		71, 71, 71, 71, 70, 70, 70, 70
		db		69, 69, 69, 69, 68, 68, 68, 67
		db		67, 67, 66, 66, 66, 65, 65, 64
		db		64, 64, 63, 63, 62, 62, 61, 61
		db		60, 60, 59, 59, 58, 58, 57, 57
		db		56, 56, 55, 54, 54, 53, 53, 52
		db		51, 51, 50, 50, 49, 48, 48, 47
		db		46, 45, 45, 44, 43, 43, 42, 41
		db		41, 40, 39, 38, 38, 37, 36, 35
		db		34, 34, 33, 32, 31, 30, 30, 29
		db		28, 27, 26, 26, 25, 24, 23, 22
		db		21, 21, 20, 19, 18, 17, 16, 15
		db		15, 14, 13, 12, 11, 10, 9 , 8 
		db		8 , 7 , 6 , 5 , 4 , 3 , 2 , 1 

; -----------------------------------------------------------------------------
;	ステージ情報
stage_number::
		db		0					; 通算ステージ番号[0 が STAGE1]
enemy_shield_base::
		db		0					; ザコ敵の硬さ
enemy_shot_speed::
		db		0					; ザコ敵が弾を撃ってくる周期

; -----------------------------------------------------------------------------
;	敵出現処理の状態
;		0	...	新しいコマンド受付中
;		1	...	敵出現中
;		2	...	敵全滅待機中
enemy_map_state:
		db		0

enemy_map_enemy_count:
		db		0

enemy_map_wait_count:
		db		0

enemy_map_enemy_start_entry:
		dw		0

enemy_map_index::
		dw		0

enemy_update_time:
		db		0

enemy_boss_count:
		dw		0					; ボス登場までのダウンカウンタ

enemy_boss_state:
		db		0					; ボスの状態

enemy_boss_destroy_wait:
		db		0

; -----------------------------------------------------------------------------
;	敵出現パターンデータ
;		0x00～0x03	...	出現敵番号、続けて出現数[1～6]
;		0x04～0x3F	... 予約[未定義]
;		0x40		...	敵全滅待機
;		0x41		...	単純待機、続けて待機時間[1/6sec]
;		0x42		...	データジャンプ、続けて新しいアドレス[2byte]
;		0x43		...	背景の STAGE* の表示を消去する
;		0x44～0xFF	...	予約[未定義]
; -----------------------------------------------------------------------------
enemy_map_table::
		dw		enemy_map_stage1
		dw		enemy_map_stage2
		dw		enemy_map_stage3
		dw		enemy_map_stage4
		dw		enemy_map_stage5
		dw		enemy_map_stage6
		dw		enemy_map_stage7
		dw		enemy_map_stage8

enemy_map_stage1::
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; STAGE1 を消去
enemy_map_stage1_loop:
		db		0x01, 6			; 敵2が6機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x40				; 敵全滅待ち
		db		0x00, 4			; 敵1が4機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x40				; 敵全滅待ち
		db		0x01, 6			; 敵2が6機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x40				; 敵全滅待ち
		db		0x00, 4			; 敵1が4機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x40				; 敵全滅待ち
		db		0x03, 6			; 敵4が6機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x40				; 敵全滅待ち
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 12			; 単純待機 2秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage1_loop

enemy_map_stage2:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage2 を消去
enemy_map_stage2_loop:
		db		0x03, 6			; 敵4が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x00, 6			; 敵1が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x01, 6			; 敵2が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x00, 6			; 敵1が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x03, 6			; 敵4が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage2_loop

enemy_map_stage3:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage3 を消去
enemy_map_stage3_loop:
		db		0x03, 12			; 敵4が12機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x00, 12			; 敵1が12機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x01, 12			; 敵2が12機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x00, 12			; 敵1が12機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x03, 12			; 敵4が12機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x02, 6			; 敵3が6機出現
		db		0x41, 6			; 単純待機 1秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage3_loop

enemy_map_stage4:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage4 を消去
enemy_map_stage4_loop:
		db		0x04, 12			; 敵5が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x00, 12			; 敵1が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x01, 12			; 敵2が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x00, 12			; 敵1が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x03, 12			; 敵4が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x02, 12			; 敵3が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x02, 12			; 敵3が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x02, 12			; 敵3が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage4_loop

enemy_map_stage5:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage5 を消去
enemy_map_stage5_loop:
		db		0x01, 12			; 敵2が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x00, 12			; 敵1が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x01, 12			; 敵2が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x00, 12			; 敵1が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x03, 12			; 敵4が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x02, 12			; 敵3が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x02, 12			; 敵3が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x02, 12			; 敵3が12機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage5_loop

enemy_map_stage6:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage6 を消去
enemy_map_stage6_loop:
		db		0x01, 18			; 敵2が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x00, 18			; 敵1が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x01, 18			; 敵2が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x00, 18			; 敵1が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x03, 18			; 敵4が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x02, 18			; 敵3が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x02, 18			; 敵3が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x02, 18			; 敵3が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage6_loop

enemy_map_stage7:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage7 を消去
enemy_map_stage7_loop:
		db		0x01, 18			; 敵2が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x00, 18			; 敵1が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x01, 18			; 敵2が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x00, 18			; 敵1が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x03, 18			; 敵4が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x02, 18			; 敵3が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x02, 18			; 敵3が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x02, 18			; 敵3が18機出現
		db		0x41, 1			; 単純待機 0.16秒
		db		0x40				; 敵全滅待ち
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x04, 1			; 敵5が1機出現
		db		0x41, 3			; 単純待機 0.5秒
		db		0x42				; ジャンプ
		dw		enemy_map_stage7_loop

enemy_map_stage8:
		db		0x41, 18			; 単純待機 3秒
		db		0x43				; stage8 を消去
enemy_map_stage8_loop:
		db		0x01, 18			; 敵2が18機出現
		db		0x00, 18			; 敵1が18機出現
		db		0x01, 18			; 敵2が18機出現
		db		0x00, 18			; 敵1が18機出現
		db		0x03, 18			; 敵4が18機出現
		db		0x02, 18			; 敵3が18機出現
		db		0x02, 18			; 敵3が18機出現
		db		0x02, 18			; 敵3が18機出現
		db		0x04, 18			; 敵5が1機出現
		db		0x02, 18			; 敵3が1機出現
		db		0x01, 18			; 敵2が1機出現
		db		0x00, 18			; 敵1が1機出現
		db		0x03, 18			; 敵4が1機出現
		db		0x02, 18			; 敵3が1機出現
		db		0x42				; ジャンプ
		dw		enemy_map_stage8_loop
