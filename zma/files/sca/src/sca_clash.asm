; -----------------------------------------------------------------------------
;	あたり判定処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	自機あたり判定
;	input:
;		なし
;	output
;		cフラグ ... 0: 衝突していない, 1: 敵か敵弾に衝突している
;	break
;		a, f, b, d, e, ix, iy
;	comment
;		なし
; -----------------------------------------------------------------------------
check_player_clash::
		; 無敵状態か？
		ld		a, [player_invincibility]
		or		a, a
		ret		nz
		; 当たり判定
		call	check_player_clash_sub		 		; 敵・ボスとのあたり判定
		jp		c, check_player_clash_skip1
		call	check_player_clash_sub2				; ラスボスとのあたり判定
		ret		nc
check_player_clash_skip1:
		; ダメージ音を出す
		ld		hl, [se_bomb2]
		call	bgmdriver_play_sound_effect
		; 自機にダメージを与える
		ld		a, [player_shield]
		dec		a
		push	af
		ld		[player_shield], a
		call	background_update_player_info
		pop		af
		jp		z, goto_gameover
		ld		a, 240								; ダメージを受けると自機は 4秒間無敵になる
		ld		[player_invincibility], a
		ret

check_player_clash_sub:
		; 自機と敵の当たり判定
		ld		ix, player_info
		ld		iy, enemy_info0
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip1
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip1:

		ld		iy, enemy_info1
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip2
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip2:

		ld		iy, enemy_info2
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip3
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip3:

		ld		iy, enemy_info3
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip4
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip4:

		ld		iy, enemy_info4
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip5
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip5:

		ld		iy, enemy_info5
		ld		a, [iy + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_player_clash_sub_skip6
		call	check_clash_12x12
		ret		c
check_player_clash_sub_skip6:

		; 自機と敵弾の当たり判定
		ld		de, SCA_INFO_SIZE
		ld		b, 15
		ld		iy, eshot_info
check_player_clash_loop:
		call	check_clash_4x4
		ret		c
		add		iy, de							; 桁上がりしないから Cフラグ = 0
		djnz	check_player_clash_loop			; djnz は Cフラグ不変
		ret

		; 自機とラスボスのあたり判定
check_player_clash_sub2::
		ld		ix, player_info
		ld		a, 8
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		l, [ix + SCA_INFO_YH]
		; 座標位置のキャラクタ取得
		call	background_get_fore_char
		cp		a, 96								; ラスボスのパーツ 96以降 
		ccf
		ret

; -----------------------------------------------------------------------------
;	敵あたり判定
;	input:
;		なし
;	output
;		cフラグ ... 0: 衝突していない, 1: 自機弾に衝突している
;	break
;		a, f, b, d, e, h, l, ix, iy
;	comment
;		なし
; -----------------------------------------------------------------------------
check_enemy_clash::
		ld		hl, [crash_check_routine]
		jp		hl

check_enemy_normal_clash::
		ld		ix, enemy_info0
		ld		b, 6							; 敵は最大６機
check_enemy_clash_loop1:
		push	bc
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_enemy_clash_skip1		; 動作中でない敵情報とはあたり判定しない
		ld		iy, shot_info0
		call	check_clash_12x12
		call	c, enemy_clash
		ld		iy, shot_info1
		call	check_clash_12x12
		call	c, enemy_clash
		ld		iy, shot_info2
		call	check_clash_12x12
		call	c, enemy_clash
check_enemy_clash_skip1:
		ld		de, SCA_INFO_SIZE * 2
		add		ix, de
		pop		bc
		djnz	check_enemy_clash_loop1
		ret

; -----------------------------------------------------------------------------
;	ボス1あたり判定
;	input:
;		なし
;	output
;		cフラグ ... 0: 衝突していない, 1: 自機弾に衝突している
;	break
;		a, f, b, d, e, h, l, ix, iy
;	comment
;		なし
; -----------------------------------------------------------------------------
check_enemy_boss1_clash:
		ld		ix, enemy_info0
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		or		a, a
		jr		z, check_enemy_boss1_clash_skip1		; 動作中でない敵情報とはあたり判定しない
		ld		iy, shot_info0
		call	check_clash_boss1
		call	c, enemy_boss1_clash
		ld		iy, shot_info1
		call	check_clash_boss1
		call	c, enemy_boss1_clash
		ld		iy, shot_info2
		call	check_clash_boss1
		call	c, enemy_boss1_clash
check_enemy_boss1_clash_skip1:
		ret

; -----------------------------------------------------------------------------
;	ラスボスあたり判定
;	input:
;		なし
;	output
;		cフラグ ... 0: 衝突していない, 1: 自機弾に衝突している
;	break
;		a, f, b, d, e, h, l, ix, iy
;	comment
;		なし
; -----------------------------------------------------------------------------
check_enemy_boss8_clash:
		ld		ix, shot_info0
		call	boss8_clash_sub

		ld		ix, shot_info1
		call	boss8_clash_sub

		ld		ix, shot_info2
		call	boss8_clash_sub
		ret

; -----------------------------------------------------------------------------
;	自機弾とラスボスのあたり判定[１つ分]
;	input:
;		なし
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
boss8_clash_sub:
		; 弾の座標
		ld		a, 4
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		l, [ix + SCA_INFO_YH]
		ld		a, l
		cp		a, 212
		ret		z									; 発射中でなければ破壊できない
		; 座標位置のキャラクタ取得
		call	background_get_fore_char
		cp		a, 96							; ラスボスのパーツ 96以降 
		jp		c, boss8_clash_sub_skip1
		cp		a, 106							; ラスボスの弱点パーツ 106以降 であるか？
		jp		nc, boss8_clash_sub_skip2

boss8_clash_sub_skip1:
		inc		hl									; すぐ右隣も調べる
		ld		a, [hl]
		cp		a, 96								; ラスボスのパーツ 96以降 
		ret		c
		cp		a, 106								; ラスボスの弱点パーツ 106以降 であるか？
		jp		c, boss8_no_damage
boss8_clash_sub_skip2:
		ld		[ix + SCA_INFO_YH], 212				; 自機弾 非表示
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; 発射中でない
		; どのパーツにダメージを与えたのか調べる
		ld		a, [SCA_INFO_ENEMY_POWER + enemy_info0]
		ld		b, a
		ld		a, [SCA_INFO_ENEMY_POWER3 + enemy_info0]
		or		a, b								; 中央パーツは待機中か？
		jp		z, boss8_center_damage			; 待機中でなければ、中央パーツしか存在しない→中央パーツにダメージ
		ld		a, [ix + SCA_INFO_XH]
		cp		a, 192/2
		jp		nc, boss8_right_damage			; 中央より右側なら右パーツへダメージ
boss8_left_damage::
		ld		a, [SCA_INFO_ENEMY_POWER + enemy_info0]
		dec		a								; 左パーツにダメージを与える [自機の ShotPower に関わらず 1ダメージ]
		ld		[SCA_INFO_ENEMY_POWER + enemy_info0], a
		jp		nz, boss8_damage
		ld		a, [SCA_INFO_XL + enemy_info0]	; 左パーツの表示を消去
		ld		e, a
		ld		a, [SCA_INFO_YL + enemy_info0]
		ld		d, a
		call	draw_boss8_delete
		jp		boss8_destroy

boss8_right_damage::
		ld		a, [SCA_INFO_ENEMY_POWER3 + enemy_info0]
		dec		a								; 右パーツにダメージを与える [自機の ShotPower に関わらず 1ダメージ]
		ld		[SCA_INFO_ENEMY_POWER3 + enemy_info0], a
		jp		nz, boss8_damage
		ld		a, [SCA_INFO_XL2 + enemy_info0]	; 右パーツの表示を消去
		ld		e, a
		ld		a, [SCA_INFO_YL2 + enemy_info0]
		ld		d, a
		call	draw_boss8_delete
		jp		boss8_destroy

boss8_center_damage::							; 中央パーツにダメージを与えた場合
		ld		a, [SCA_INFO_ENEMY_POWER5 + enemy_info0]
		dec		a								; 中央パーツにダメージを与える [自機の ShotPower に関わらず 1ダメージ]
		ld		[SCA_INFO_ENEMY_POWER5 + enemy_info0], a
		jp		nz, boss8_damage
		ld		a, [SCA_INFO_XL3 + enemy_info0]	; 右パーツの表示を消去
		ld		e, a
		ld		a, [SCA_INFO_YL3 + enemy_info0]
		ld		d, a
		call	draw_boss8_center_delete
		ld		hl, [se_bomb2]							; ボス破壊音
		call	bgmdriver_play_sound_effect
		; 点数を追加
		ld		de, 0x9999								; 中央パーツ破壊は 9999点
		call	score_add
		call	top_score_check
		call	score_update
		; ボス破壊要求発行
		call	enemy_boss_destroy_request
		; BGM演奏停止
		call	bgmdriver_stop
		ret

boss8_destroy:
		ld		a, [SCA_INFO_ENEMY_POWER + enemy_info0]		; 左パーツ
		ld		b, a
		ld		a, [SCA_INFO_ENEMY_POWER3 + enemy_info0]	; 右パーツ
		or		a, b
		jp		nz, boss8_destroy_skip1
		; 中央パーツの状態を初期化
		xor		a, a
		ld		[SCA_INFO_ENEMY_STATE_L + enemy_info0], a
		ld		[SCA_INFO_ENEMY_STATE_H + enemy_info0], a
		ld		[SCA_INFO_ENEMY_STATE_L2 + enemy_info0], a
		ld		[SCA_INFO_ENEMY_STATE_H2 + enemy_info0], a
boss8_destroy_skip1:
		ld		hl, [se_bomb2]					; ボス破壊音
		call	bgmdriver_play_sound_effect
		; 点数を追加
		ld		de, 0x5000								; 左右パーツ破壊は 5000点
		call	score_add
		call	top_score_check
		call	score_update
		ret

boss8_damage:
		ld		hl, [se_damage]					; ダメージを与えた音を鳴らす
		call	bgmdriver_play_sound_effect
		; 点数を追加
		ld		de, 0x0003						; ボスダメージは 3点
		call	score_add
		call	top_score_check
		call	score_update
		ret

boss8_no_damage:								; ラスボスがダメージを食らわない部分に弾が当たった
		ld		[ix + SCA_INFO_YH], 212			; 自機弾 非表示
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; 発射中でない
		ld		hl, [se_no_damage]				; ダメージを与えられない音を鳴らす
		call	bgmdriver_play_sound_effect
		ret

; -----------------------------------------------------------------------------
;	敵と自機弾が衝突したときの処理
;	input:
;		ix	...	衝突した敵情報のアドレス
;		iy	...	衝突した弾情報のアドレス
;	output
;		なし
;	break
;		a, f, b, d, e, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
enemy_clash:
		; 敵にダメージを与える
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		sub		a, [iy + SCA_INFO_SHOT_POWER]
		; 敵が壊れたか判定
		jr		c, enemy_clash_enemy_destroy			; 壊れた場合、敵消去処理へ
		jr		z, enemy_clash_enemy_destroy			; 壊れた場合、敵消去処理へ
		ld		[ix + SCA_INFO_ENEMY_POWER], a				; 耐久力を更新
		; 敵にダメージを与えた音を発声
		ld		hl, [se_damage]
		call	bgmdriver_play_sound_effect
		; 点数を追加
		ld		de, 0x2									; 敵ダメージは 2点
		call	score_add
		call	top_score_check
		call	score_update
enemy_clash_shot_destroy:
		; 衝突した自機弾を消滅させる
		ld		[iy + SCA_INFO_YH], 212					; 非表示
		ld		[iy + SCA_INFO_SHOT_POWER], 0			; 発射中でない
		ret
		; 敵消去処理
enemy_clash_enemy_destroy:
		; 敵が爆発した音を発声
		ld		hl, [se_bomb]
		call	bgmdriver_play_sound_effect
		; 衝突した自機弾を消滅させる
		ld		[iy + SCA_INFO_YH], 212					; 非表示
		ld		[iy + SCA_INFO_SHOT_POWER], 0			; 発射中でない
		; 敵を爆発パターンに変更する
		call	enemy_bomb
		; 点数を追加
		ld		de, 0x100								; 敵破壊は 100点
		call	score_add
		call	top_score_check
		call	score_update
		ret

; -----------------------------------------------------------------------------
;	ボスと自機弾が衝突したときの処理
;	input:
;		iy	...	衝突した弾情報のアドレス
;	output
;		なし
;	break
;		a, f, b, d, e, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
enemy_boss1_clash:
		ld		ix, enemy_info0
		; 敵にダメージを与える
		ld		a, [ix + SCA_INFO_ENEMY_POWER]
		sub		a, [iy + SCA_INFO_SHOT_POWER]
		; 敵が壊れたか判定
		jr		c, enemy_boss1_clash_enemy_destroy			; 壊れた場合、敵消去処理へ
		jr		z, enemy_boss1_clash_enemy_destroy			; 壊れた場合、敵消去処理へ
		ld		[ix + SCA_INFO_ENEMY_POWER], a				; 耐久力を更新
		; 敵にダメージを与えた音を発声
		ld		hl, [se_damage]
		call	bgmdriver_play_sound_effect
enemy_boss1_clash_shot_destroy:
		; 衝突した自機弾を消滅させる
		ld		[iy + SCA_INFO_YH], 212					; 非表示
		ld		[iy + SCA_INFO_SHOT_POWER], 0				; 発射中でない
		; 点数を追加
		ld		de, 0x0003								; ボスダメージは 3点
		call	score_add
		call	top_score_check
		call	score_update
		ret
		; 敵消去処理
enemy_boss1_clash_enemy_destroy:
		; 敵が爆発した音を発声
		ld		hl, [se_bomb2]
		call	bgmdriver_play_sound_effect
		; 衝突した自機弾を消滅させる
		ld		[iy + SCA_INFO_YH], 212					; 非表示
		ld		[iy + SCA_INFO_SHOT_POWER], 0				; 発射中でない
		; 敵を爆発パターンに変更する
		call	enemy_bomb
		ld		ix, enemy_info1
		call	enemy_bomb
		ld		ix, enemy_info2
		call	enemy_bomb
		ld		ix, enemy_info3
		call	enemy_bomb
		; 点数を追加
		ld		de, 0x5000								; ボス破壊は 5000点
		call	score_add
		call	top_score_check
		call	score_update
		; ボス破壊要求発行
		call	enemy_boss_destroy_request
		; BGM演奏停止
		call	bgmdriver_stop
		ret

; -----------------------------------------------------------------------------
;	自機弾と地上物のあたり判定
;	input:
;		なし
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
plant_clash::
		ld		ix, shot_info0
		call	plant_clash_sub

		ld		ix, shot_info1
		call	plant_clash_sub

		ld		ix, shot_info2
		call	plant_clash_sub
		ret

; -----------------------------------------------------------------------------
;	自機弾と地上物のあたり判定[１つ分]
;	input:
;		なし
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
plant_clash_sub:
		; 弾の座標
		ld		a, 4
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		l, [ix + SCA_INFO_YH]
		ld		a, l
		cp		a, 8
		ret		c								; 上端に半分だけ見えている地上物は破壊できない
		cp		a, 212
		ret		z								; 発射中でなければ破壊できない
		; 座標位置のキャラクタ取得
		call	background_get_char
		and		a, 0xFC
		cp		a, 76
		jp		z, check_item					; 地上物ならパワーアップアイテム出現判定へ飛ぶ
		inc		hl								; すぐ右隣も調べる
		ld		a, [hl]
		and		a, 0xFC
		cp		a, 76
		ret		nz
check_item:
		; パワーアップアイテム判定
		ld		a, [item_timing]
		inc		a
		and		a, 31
		ld		[item_timing], a
		jr		nz, plant_clash_sub_skip1		; 地上物を 32個破壊するたびにアイテム出現
		; パワーアップアイテムを出現させる
		push	hl
		call	random
		ld		a, l
		pop		hl
		and		a, 8
		ld		a, 80							; スピードアップアイテム
		jr		z, plant_clash_sub_skip2
		ld		a, 84							; ショットパワーアップアイテム
		jr		plant_clash_sub_skip2
plant_clash_sub_skip1:
		; 地上物を破壊する
		ld		a, 72
plant_clash_sub_skip2:
		call	background_put_char
		; 敵が爆発した音を発声
		ld		hl, [se_bomb]
		call	bgmdriver_play_sound_effect
		; 衝突した自機弾を消滅させる
		ld		[ix + SCA_INFO_YH], 212			; 非表示
		ld		[ix + SCA_INFO_SHOT_POWER], 0		; 発射中でない
		; 点数を追加
		ld		de, 0x50						; 地上物破壊は 50点
		call	score_add
		call	top_score_check
		call	score_update
		ret

; -----------------------------------------------------------------------------
;	自機とアイテムのあたり判定
;	input:
;		なし
;	output
;		なし
;	break
;		
;	comment
;		なし
; -----------------------------------------------------------------------------
player_get_item_check::
		; 自機の座標
		ld		ix, player_info
		ld		a, 8
		add		a, [ix + SCA_INFO_XH]
		ld		h, a
		ld		a, 8
		add		a, [ix + SCA_INFO_YH]
		ld		l, a
		cp		a, 8
		ret		c								; 上端に半分だけ見えているアイテムは取れない
		cp		a, 192-8
		ret		nc								; 下端に半分だけ見えているアイテムは取れない
		; 座標位置のキャラクタ取得
		call	background_get_char
		and		a, 0xFC
		cp		a, 88
		ret		nc								; アイテムじゃない場合は抜ける
		cp		a, 80
		ret		c								; アイテムじゃない場合は抜ける
		; 地上物を破壊する
		push	af
		ld		a, 72
		call	background_put_char
		; アイテム取得の音を発声させる
		ld		hl, [se_get_item]
		call	bgmdriver_play_sound_effect
		; 点数を追加
		ld		de, 0x100						; アイテム取得は 100点
		call	score_add
		call	top_score_check
		call	score_update
		; スピードアップかショットパワーアップの判定
		pop		af
		cp		a, 80
		jp		z, player_speed_up
		jp		player_shot_power_up

; -----------------------------------------------------------------------------
;	12x12 あたり判定
;	input:
;		ix	...	判定対象１
;		iy	...	判定対象２
;	output
;		cフラグ ... 0: 衝突していない, 1: 衝突している
;	break
;		a, f
;	comment
;		なし
; -----------------------------------------------------------------------------
check_clash_12x12:
		; A ← ABS[ ix[SCA_INFO_XH] - iy[SCA_INFO_XH] ]
		ld		a, [ix + SCA_INFO_XH]
		sub		a, [iy + SCA_INFO_XH]
		jr		nc, check_clash_12x12_skip1
		neg
check_clash_12x12_skip1:
		; if a >= 12 then return
		cp		a, 12
		ret		nc
		; A ← ABS[ ix[SCA_INFO_YH] - iy[SCA_INFO_YH] ]
		ld		a, [ix + SCA_INFO_YH]
		sub		a, [iy + SCA_INFO_YH]
		jr		nc, check_clash_12x12_skip2
		neg
check_clash_12x12_skip2:
		; if a >= 12 then return
		cp		a, 12
		ret

; -----------------------------------------------------------------------------
;	ボス1 あたり判定
;	input:
;		ix	...	ボス
;		iy	...	ショット
;	output
;		cフラグ ... 0: 衝突していない, 1: 衝突している
;	break
;		a, f
;	comment
;		なし
; -----------------------------------------------------------------------------
check_clash_boss1:
		; A ← ix[SCA_INFO_XH] - iy[SCA_INFO_XH]
		ld		a, [iy + SCA_INFO_XH]
		sub		a, [ix + SCA_INFO_XH]
		cp		a, -10
		jp		m, check_clash_boss1_no_crash
		cp		a, 22
		jp		p, check_clash_boss1_no_crash
		; A ← ix[SCA_INFO_YH] - iy[SCA_INFO_YH]
		ld		a, [iy + SCA_INFO_YH]
		sub		a, [ix + SCA_INFO_YH]
		cp		a, -16
		jp		m, check_clash_boss1_no_crash
		cp		a, 32
		jp		p, check_clash_boss1_no_crash
		scf
		ret
check_clash_boss1_no_crash:
		or		a, a
		ret

; -----------------------------------------------------------------------------
;	4x4 あたり判定
;	input:
;		ix	...	判定対象１
;		iy	...	判定対象２
;	output
;		cフラグ ... 0: 衝突していない, 1: 衝突している
;	break
;		a, f
;	comment
;		なし
; -----------------------------------------------------------------------------
check_clash_4x4:
		; A ← ABS[ ix[SCA_INFO_XH] - iy[SCA_INFO_XH] ]
		ld		a, [ix + SCA_INFO_XH]
		sub		a, [iy + SCA_INFO_XH]
		jr		nc, check_clash_4x4_skip1
		neg
check_clash_4x4_skip1:
		; if a >= 4 then return
		cp		a, 4
		ret		nc
		; A ← ABS[ ix[SCA_INFO_YH] - iy[SCA_INFO_YH] ]
		ld		a, [ix + SCA_INFO_YH]
		sub		a, [iy + SCA_INFO_YH]
		jr		nc, check_clash_4x4_skip2
		neg
check_clash_4x4_skip2:
		; if a >= 4 then return
		cp		a, 4
		ret

; -----------------------------------------------------------------------------
;	敵当たり判定ルーチンのすり替え
;	input:
;		a	...	当たり判定ルーチンの番号
;				0: 通常の敵
;				1: ボス1
;	output
;		なし
;	break
;		a, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
change_crash_check_routine::
		cp		a, 1
		jp		c, change_crash_check_routine1
		jp		z, change_crash_check_routine2
		jp		change_crash_check_routine3

change_crash_check_routine1:
		ld		hl, check_enemy_normal_clash
		ld		[crash_check_routine], hl
		ret

change_crash_check_routine2:
		ld		hl, check_enemy_boss1_clash
		ld		[crash_check_routine], hl
		ret

change_crash_check_routine3:
		ld		hl, check_enemy_boss8_clash
		ld		[crash_check_routine], hl
		ret

; -----------------------------------------------------------------------------
;	当たり判定ルーチンのアドレス
; -----------------------------------------------------------------------------
crash_check_routine:
		dw		enemy_clash

; -----------------------------------------------------------------------------
;	パワーアップアイテム出現タイミング
; -----------------------------------------------------------------------------
item_timing::
		db		0
