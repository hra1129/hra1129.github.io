; -----------------------------------------------------------------------------
;	SCA main program
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	エントリーポイント
; -----------------------------------------------------------------------------
		org		0x8400

sca_main::
		ld		sp, 0x8300						; スタックポインタを初期化[BASICには戻らない]
		call	game_init						; 各種初期化
sca_main_loop:
		call	sca_title						; タイトル画面
		call	state_init						; ゲーム開始時の初期化
		call	game_start						; メインループ
		call	update_score_ranking			; ハイスコア更新
		or		a, a
		call	nz, name_entry					; ハイスコア登録記念名前入力
		call	bgmdriver_stop
		jr		sca_main_loop

; -----------------------------------------------------------------------------
;	初期化処理
; -----------------------------------------------------------------------------
game_init:
		; MSX turboR の場合は Z80 モードに切り替える
		ld		a, [MSXVER]
		cp		a, 3
		jp		c, game_init_skip
		ld		a, 0x80						; 高速モードLEDを消灯し、Z80モードに切り替える
		call	CHGCPU
game_init_skip:
		; スプライトを初期化
		call	sprite_init
		; BGM Driver 初期化
		call	bgmdriver_initialize
		; 割り込み処理を初期化
		call	vsync_init
		ret

; -----------------------------------------------------------------------------
;	ゲーム状態の初期化
; -----------------------------------------------------------------------------
state_init:
		; 点数を初期化
		call	score_init
		; 自機を初期化
		ld		ix, player_info
		call	player_init
		; 敵を初期化
		call	enemy_init
		; アイテム発生タイミング初期化
		xor		a, a
		ld		[item_timing], a
		ret

; -----------------------------------------------------------------------------
;	ステージ状態の初期化
; -----------------------------------------------------------------------------
stage_init:
		; 自機を初期化
		ld		ix, player_info
		call	player_stage_init
		; 自機弾を初期化
		ld		ix, shot_info0
		call	shot_init
		ld		ix, shot_info1
		call	shot_init
		ld		ix, shot_info2
		call	shot_init
		; 敵を初期化
		call	enemy_init_stage
		; パレットを設定
		ld		a, [stage_number]
		and		a, 7
		call	change_palette
		xor		a, a
		call	fade_palette
		ret

; -----------------------------------------------------------------------------
;	メインループ
; -----------------------------------------------------------------------------
game_start::
		; 各種初期化
		call	stage_init							; ゲームの内部状態を初期化
		call	background_init_game_screen			; ゲーム中の背景を初期化
		ld		a, [stage_number]
		call	background_draw_stage_x				; "STAGEx" を表示
		xor		a, a
		ld		[stage_clear_flag], a				; ステージクリアフラグ
		; ゲームBGM演奏開始
		ld		a, [stage_number]
		and		a, 7
		rlca
		ld		l, a
		ld		h, 0
		ld		de, SCA_BGM_TABLE_ADR					; stage の BGM を演奏開始
		add		hl, de
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		call	bgmdriver_play
game_loop:
		; ゲームクリアしたか？
		ld		a, [stage_clear_flag]
		or		a, a
		jp		nz, game_stage_clear				; ステージクリアかゲームオーバー
		; 現在のタイマー値を保存しておく
		ld		a, [software_timer]
		ld		[last_timer], a
		; 自機弾と地上物のあたり判定処理
		call	plant_clash
		; 自機とアイテムのあたり判定処理
		call	player_get_item_check
		; 背景スクロール処理
		call	background_scroll
		call	background_transfer
		; 自機の移動処理
		ld		ix, player_info
		call	player_move
		; 自機弾の発射処理
		ld		ix, player_info
		ld		iy, shot_info0
		call	shot_fire
		; 自機弾の移動処理
		ld		ix, shot_info0
		call	shot_move
		ld		ix, shot_info1
		call	shot_move
		ld		ix, shot_info2
		call	shot_move
		; 自機の当たり判定処理
		call	check_player_clash
		; 敵の当たり判定処理
		call	check_enemy_clash
		; 敵の移動処理
		ld		ix, enemy_info0
		call	enemy_move
		; 敵の出現処理
		ld		ix, player_info
		ld		iy, enemy_info0
		call	enemy_start
		; 敵弾の移動処理
		ld		ix, eshot_info
		call	enemy_shot_move
		; スプライトの表示更新処理
		ld		ix, player_info
		call	sprite_update
		; タイマー値が変化するまで待機する
		ld		a, [last_timer]
		ld		hl, software_timer
game_wait_loop:
		cp		a, [hl]
		jp		nz, game_loop
		jr		game_wait_loop

; -----------------------------------------------------------------------------
;	ステージクリア処理
; -----------------------------------------------------------------------------
game_stage_clear:
		; ゲームオーバーか判断
		dec		a
		jp		nz, game_gameover					; フラグがゲームオーバーを示している場合
		ld		a, [player_shield]					; 自機とボスが同時に壊れた場合もゲームオーバー
		or		a, a
		jp		z, game_gameover
		; ボス破壊BGM
		ld		hl, [bgm_clear]
		call	bgmdriver_play
		; ボス破壊BGM停止待ち
game_stage_clear_loop:
		call	bgmdriver_check_playing
		jr		nz, game_stage_clear_loop
		; 画面をクリア
		call	background_init_stage_clear_screen	; 画面左側をクリア
		call	sprite_all_clear					; スプライトをクリア
		; 時間待ち
		ld		hl, 30								; 0.5秒
		call	vsync_wait_time
		; ステージクリアボーナス 10000点加算
		ld		b, 10
game_stage_clear_score_loop:
		push	bc
		; 1000点加算
		ld		de, 0x1000
		call	score_add
		call	top_score_check
		call	score_update
		; 効果音
		ld		hl, [se_damage]
		call	bgmdriver_play_sound_effect
		; 時間待ち
		ld		hl, 10								; 0.1秒
		call	vsync_wait_time
		pop		bc
		djnz	game_stage_clear_score_loop
		; シールドも１加算
		ld		a, [player_shield]
		cp		a, 9
		jr		z, game_shield_max
		inc		a
		ld		[player_shield], a
		call	background_update_player_info
game_shield_max:
		; 時間待ち
		ld		hl, 60*3							; 3秒
		call	vsync_wait_time
		; 敵を進化させる
		call	enemy_next_stage
		; 次のステージ開始
		jp		game_start

; -----------------------------------------------------------------------------
;	ゲームオーバー処理
; -----------------------------------------------------------------------------
game_gameover:
		; 画面をクリア
		call	background_init_gameover_screen
		call	sprite_all_clear					; スプライトをクリア
		; ゲームオーバーＢＧＭ
		ld		hl, [bgm_gameover]
		call	bgmdriver_play
		; BGM演奏終了待ち
game_gameover_loop:
		call	bgmdriver_check_playing
		jr		nz, game_gameover_loop
		; 時間待ち
		ld		hl, 60*1							; 1秒
		call	vsync_wait_time
		ret

; -----------------------------------------------------------------------------
;	ステージクリアへ遷移
; -----------------------------------------------------------------------------
goto_next_stage::
		ld		a, 1
		ld		[stage_clear_flag], a
		ret

; -----------------------------------------------------------------------------
;	ゲームオーバーへ遷移
; -----------------------------------------------------------------------------
goto_gameover::
		ld		a, 2
		ld		[stage_clear_flag], a
		ret

; -----------------------------------------------------------------------------
;	ワークエリア
; -----------------------------------------------------------------------------
last_timer:
		db		0

stage_clear_flag:
		db		0					; 0: 通常, 1: ステージクリア, 2: ゲームオーバー

; -----------------------------------------------------------------------------
;	自機情報
; -----------------------------------------------------------------------------
player_info::
		repeat i, SCA_INFO_SIZE
			db	0		; 0
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 1
		endr
enemy_info0::
		repeat i, SCA_INFO_SIZE
			db	0		; 2
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 3
		endr
enemy_info1::
		repeat i, SCA_INFO_SIZE
			db	0		; 4
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 5
		endr
enemy_info2::
		repeat i, SCA_INFO_SIZE
			db	0		; 6
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 7
		endr
enemy_info3::
		repeat i, SCA_INFO_SIZE
			db	0		; 8
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 9
		endr
enemy_info4::
		repeat i, SCA_INFO_SIZE
			db	0		; 10
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 11
		endr
enemy_info5::
		repeat i, SCA_INFO_SIZE
			db	0		; 12
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 13
		endr
eshot_info::
		repeat i, SCA_INFO_SIZE
			db	0		; 14	0
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 15	1
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 16	2
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 17	3
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 18	4
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 19	5
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 20	6
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 21	7
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 22	8
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 23	9
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 24	10
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 25	11
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 26	12
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 27	13
		endr
		repeat i, SCA_INFO_SIZE
			db	0		; 28	14
		endr
shot_info0::
		repeat i, SCA_INFO_SIZE
			db	0		; 29
		endr
shot_info1::
		repeat i, SCA_INFO_SIZE
			db	0		; 30
		endr
shot_info2::
		repeat i, SCA_INFO_SIZE
			db	0		; 31
		endr
