; -----------------------------------------------------------------------------
;	タイトル画面処理
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	タイトル画面
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_title::
		call	bgmdriver_stop
		call	sca_title_screen
		call	sca_title_fade_in
		call	sca_title_main
		jp		sca_title_fade_out

; -----------------------------------------------------------------------------
;	タイトル画面のメインループ
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_title_main:
		; VDP R18 = 0
		xor		a, a
		call	sca_vdp_r18
		; ソフトウェアタイマーをクリア
		xor		a, a
		ld		[sca_title_scroll_pos], a				; スクロール位置を初期化
		ld		[sca_title_wait_counter], a				; 秒カウンタ
		ld		[software_timer], a
sca_title_main_loop:
		ld		[sca_title_last_counter], a
		; 'M'キーの押下確認
		ld		a, 4									; キーマトリクス番号
		call	SNSMAT
		and		a, 4										; Mキーが押されているか？
		jp		z, sca_enter_music_mode					; Mキーが押されたのなら MUSIC MODE へ突入
		; ボタンの押下確認
		call	get_trigger
		jr		nz, sca_title_exit_effect				; ボタンが押されていればループを脱ける
		; PUSH SPACE BAR の点滅処理
		ld		a, [software_timer]
		bit		5, a			; 32/60[秒] ごとに反転するビットを調べる
		ld		hl, sca_title_push_space_bar			; そのビットが 0 なら sca_title_push_space_bar を選択
		jr		z, sca_title_main_skip1
		ld		hl, sca_title_push_space_bar_delete	; そのビットが 1 なら sca_title_push_space_bar_delete を選択
sca_title_main_skip1:
		ld		de, PATTERN_NAME1 + 9 + 32*16
		ld		bc, 14
		call	LDIRVM									; 描画
		; 1/60[秒]経過するのを待つ
		ld		hl, [sca_title_last_counter]
sca_title_main_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_main_wait_loop				; 変化していなければ待機する
		cp		a, 60
		jr		c, sca_title_main_loop
		; 秒カウンタをインクリメントする
		ld		a, [sca_title_wait_counter]
		inc		a
		ld		[sca_title_wait_counter], a
		cp		a, 10
		jr		z, sca_title_left_scroll				; 10秒経過したならスクロールを開始する
		xor		a, a
		ld		[software_timer], a
		jr		sca_title_main_loop

		; PUSH SPACE BAR を1秒間高速に点滅させるエフェクト処理
sca_title_exit_effect:
		; ゲーム開始効果音
		ld		hl, [se_start]
		call	bgmdriver_play_sound_effect
		; ソフトウェアタイマーをクリア
		xor		a, a
		ld		[software_timer], a
sca_title_exit_effect_loop:
		ld		[sca_title_last_counter], a
		; PUSH SPACE BAR の点滅処理
		ld		a, [software_timer]
		bit		1, a			; 2/60[秒] ごとに反転するビットを調べる
		ld		hl, sca_title_push_space_bar			; そのビットが 0 なら sca_title_push_space_bar を選択
		jr		z, sca_title_exit_effect_skip1
		ld		hl, sca_title_push_space_bar_delete	; そのビットが 1 なら sca_title_push_space_bar_delete を選択
sca_title_exit_effect_skip1:
		ld		de, PATTERN_NAME1 + 9 + 32*16
		ld		bc, 14
		call	LDIRVM									; 描画
		; 1/60[秒]経過するのを待つ
		ld		hl, [sca_title_last_counter]
sca_title_exit_effect_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_exit_effect_wait_loop		; 変化していなければ待機する
		; exit_effect 開始から 1秒経過したら脱ける
		cp		a, 60
		ret		nc
		jr		sca_title_exit_effect_loop

		; 左にスクロールする処理
sca_title_left_scroll:
		xor		a, a
		ld		[sca_title_wait_counter], a				; 10秒待ちカウンタをリセット
sca_title_left_scroll_loop:
		; ドット単位横スクロール
		ld		a, [sca_title_scroll_pos]
		ld		b, a
		and		a, 7
		call	sca_vdp_r18
		; 8ドットスクロールしたか？
		ld		a, b
		and		a, 7
		call	z, sca_title_scroll_update				; 下位3bit が 0 のときに画面全体が書き換わる
		; スクロールさせる
		ld		a, [sca_title_scroll_pos]
		add		a, 1									; inc a は Cフラグが変化しないので add を使う
		ld		[sca_title_scroll_pos], a
		jr		c, sca_title_high_score_mode
		; ボタンの押下確認
		call	get_trigger
		jp		nz, sca_return_title_main				; ボタンが押されていればループを脱ける
		; 1/60[秒]経過するのを待つ
		ld		hl, sca_title_last_counter
sca_title_left_scroll_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_left_scroll_wait_loop		; 変化していなければ待機する
		ld		[sca_title_last_counter], a
		jr		sca_title_left_scroll_loop

		; HIGH SCORE LIST 表示モード [10秒単純待機]
sca_title_high_score_mode:
		call	sca_update_highscore_list
sca_title_high_score_loop:
		; ボタンの押下確認
		call	get_trigger
		jp		nz, sca_return_title_main				; ボタンが押されていればループを脱ける
		; 1/60[秒]経過するのを待つ
		ld		hl, [sca_title_last_counter]
sca_title_high_score_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_high_score_wait_loop		; 変化していなければ待機する
		cp		a, 60
		jr		c, sca_title_high_score_loop
		; 秒カウンタをインクリメントする
		ld		a, [sca_title_wait_counter]
		inc		a
		ld		[sca_title_wait_counter], a
		cp		a, 10
		jr		z, sca_title_right_scroll				; 10秒経過したならスクロールを開始する
		xor		a, a
		ld		[software_timer], a
		jr		sca_title_high_score_loop

		; 右にスクロールする処理
sca_title_right_scroll:
		xor		a, a
		ld		[sca_title_wait_counter], a				; 10秒待ちカウンタをリセット
		dec		a
		ld		[sca_title_scroll_pos], a
sca_title_right_scroll_loop:
		; ドット単位横スクロール
		ld		a, [sca_title_scroll_pos]
		ld		b, a
		and		a, 7
		call	sca_vdp_r18
		; 8ドットスクロールしたか？
		ld		a, b
		inc		a
		and		a, 7
		call	z, sca_title_scroll_update				; 下位3bit が 7 のときに画面全体が書き換わる
		; スクロールさせる
		ld		a, [sca_title_scroll_pos]
		sub		a, 1										; dec a は Cフラグが変化しないので sub を使う
		ld		[sca_title_scroll_pos], a
		jr		c, sca_return_title_main
		; ボタンの押下確認
		call	get_trigger
		jr		nz, sca_return_title_main				; ボタンが押されていればループを脱ける
		; 1/60[秒]経過するのを待つ
		ld		hl, sca_title_last_counter
sca_title_right_scroll_wait_loop:
		ld		a, [software_timer]
		cp		a, [hl]
		jr		z, sca_title_right_scroll_wait_loop		; 変化していなければ待機する
		ld		[sca_title_last_counter], a
		jr		sca_title_right_scroll_loop

		; 8ドット単位のスクロール処理
sca_title_scroll_update:
		ld		hl, PATTERN_NAME1
		call	SETWRT
		; hl ← [sca_title_scroll_pos] / 8 + sca_screen_buffer
		ld		a, [sca_title_scroll_pos]
		rrca
		rrca
		rrca
		and		a, 0x1F
		ld		l, a
		ld		h, 0
		ld		de, sca_screen_buffer
		add		hl, de
		ld		c, VDP_VRAM_IO
		ld		de, 32
		ld		a, 24
sca_title_scroll_update_loop:
		ld		b, 32
		otir
		add		hl, de
		dec		a
		jp		nz, sca_title_scroll_update_loop
		ret

		; タイトル画面表示を戻してゲーム開始待ちに戻る
sca_return_title_main:
		xor		a, a
		ld		[sca_title_scroll_pos], a
		call	sca_title_scroll_update
		jp		sca_title_main

sca_enter_music_mode:
		call	sca_music_mode
		pop		hl					; 戻りアドレスを 1つ捨てる
		jp		sca_title

; -----------------------------------------------------------------------------
;	タイトル画面用仮想画面初期化
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_title_memory:
		; メモリ上の仮想画面を初期化する
		ld		hl, sca_screen_buffer
		ld		de, sca_screen_buffer + 1
		ld		bc, 768*2-1
		xor		a, a
		ld		[hl], a
		ldir
		; タイトル文字 SCA の描画
		ld		hl, sca_title_background
		ld		de, sca_screen_buffer + 6 + 64*4
		ld		b, 9		; 9ライン
sca_title_screen_loop1:
		push	bc
		ld		bc, 19
		ldir
		ex		de, hl
		ld		bc, 64-19
		add		hl, bc
		ex		de, hl
		pop		bc
		djnz	sca_title_screen_loop1
		; タイトル文字 PUSH SPACE BAR の描画
		ld		hl, sca_title_push_space_bar
		ld		de, sca_screen_buffer + 9 + 64*16
		ld		bc, 14
		ldir
		; copyright の描画
		ld		hl, sca_programmed_by
		ld		de, sca_screen_buffer + 6 + 64*18
		ld		bc, 17
		ldir
		ld		hl, sca_music_composed_by
		ld		de, sca_screen_buffer + 4 + 64*19
		ld		bc, 23
		ldir
		; high score list の描画
		ld		hl, sca_high_score_list
		ld		de, sca_screen_buffer + 41 + 64*1
		ld		bc, 15
		ldir
		ld		de, 64*2
		ld		hl, sca_screen_buffer + 41 + 64*3
		ld		[hl], 2	; '1'
		add		hl, de
		ld		[hl], 3	; '2'
		add		hl, de
		ld		[hl], 4	; '3'
		add		hl, de
		ld		[hl], 5	; '4'
		add		hl, de
		ld		[hl], 6	; '5'
		add		hl, de
		ld		[hl], 7	; '6'
		add		hl, de
		ld		[hl], 8	; '7'
		add		hl, de
		ld		[hl], 9	; '8'
		add		hl, de
		ld		[hl], 10	; '9'
		add		hl, de
		ld		[hl], 1	; '0'
		dec		hl
		ld		[hl], 2	; '1'
		; 名前と点数を描画
		ld		de, sca_screen_buffer + 43 + 64*3
		ld		hl, high_score + 4 + 8*0
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*0
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*5
		ld		hl, high_score + 4 + 8*1
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*1
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*7
		ld		hl, high_score + 4 + 8*2
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*2
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*9
		ld		hl, high_score + 4 + 8*3
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*3
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*11
		ld		hl, high_score + 4 + 8*4
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*4
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*13
		ld		hl, high_score + 4 + 8*5
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*5
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*15
		ld		hl, high_score + 4 + 8*6
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*6
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*17
		ld		hl, high_score + 4 + 8*7
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*7
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*19
		ld		hl, high_score + 4 + 8*8
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*8
		call	score_memput

		ld		de, sca_screen_buffer + 43 + 64*21
		ld		hl, high_score + 4 + 8*9
		ld		bc, 3
		ldir
		inc		de
		ld		hl, high_score + 0 + 8*9
		call	score_memput
		ret

; -----------------------------------------------------------------------------
;	仮想画面のハイスコア画面を転送
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_update_highscore_list:
		; HIGH SCORE LIST 表示を更新する
		ld		hl, PATTERN_NAME1
		call	SETWRT
		ld		hl, sca_screen_buffer + 32
		ld		c, VDP_VRAM_IO
		ld		de, 32
		ld		a, 24
sca_title_high_score_update_loop:
		ld		b, 32
		otir
		add		hl, de
		dec		a
		jp		nz, sca_title_high_score_update_loop
		ret

; -----------------------------------------------------------------------------
;	タイトル画面表示
;	input:
;		なし
;	output
;		なし
;	break
;		すべて
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_title_screen:
		; パレットを真っ黒にする
		ld		a, 7
		call	fade_palette
		; タイトル用パレット設定
		xor		a, a
		call	change_palette
		; 仮想画面を初期化
		call	sca_title_memory
		; スクロール位置を初期化
		xor		a, a
		ld		[sca_title_scroll_pos], a
		; 仮想画面を VRAM に転送する
		call	sca_title_scroll_update
		ret

; -----------------------------------------------------------------------------
;	ネームエントリー画面
;	input:
;		a	...	入賞ランク [1～10]
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
name_entry::
		push	af
		push	af
		; ネームエントリーのBGM再生
		ld		hl, [bgm_nameentry]				; nameentry の BGM を演奏開始
		call	bgmdriver_play
		; 仮想画面を初期化
		call	sca_title_memory
		; 仮想画面を VRAM に転送する
		call	sca_update_highscore_list
		pop		af
		; カーソル位置を計算する
		dec		a							; hl = PATTERN_NAME1 + a * 32 * 2 + 32*3+11
		rlca								; a*32*2 → a*64 → a を 6bit左シフト
		rlca								; 
		rlca								; 
		rlca								; 
		ld		l, a						; これ以上 rlca すると 8bit をはみ出すので残りは add hl,hl で。
		ld		h, 0
		add		hl, hl
		add		hl, hl
		ld		de, PATTERN_NAME1 + 32*3 + 11
		add		hl, de
		ld		[cursor_pos], hl
		; 表示する文字[c] と 桁位置[b] を初期化
		xor		a, a
		ld		[sca_title_wait_counter], a
		ld		b, a
		ld		a, [current_score_name + 0]
		ld		c, a
		ld		a, [software_timer]
name_entry_loop:
		ld		[sca_title_last_counter], a
		; キーが開放されるのを待つ
		ld		a, [sca_title_wait_counter]
		or		a, a
		jr		nz, name_entry_loop_key_check_skip
		; キーが押されるのを待つ
		call	get_stick
		ld		[sca_title_wait_counter], a
		cp		a, 7							; 左キー判定
		jp		z, name_entry_move_left
		cp		a, 3							; 右キー判定
		jp		z, name_entry_move_right
		cp		a, 1							; 上キー判定
		jp		z, name_entry_change_next
		cp		a, 5							; 下キー判定
		jp		z, name_entry_change_prev
		jr		name_entry_loop_key_check_end2
name_entry_loop_key_check_skip:
		call	get_stick
		ld		[sca_title_wait_counter], a
name_entry_loop_key_check_end:
		; 効果音
		ld		hl, [se_name]
		call	bgmdriver_play_sound_effect
name_entry_loop_key_check_end2:
		; カーソルを点滅表示
		ld		a, [software_timer]
		and		a, 8
		ld		a, c						; ※フラグ不変
		jr		z, name_entry_cursor_blink
		ld		a, 38						; カーソル文字
name_entry_cursor_blink:
		ld		hl, [cursor_pos]
		call	WRTVRM
		; キー入力を受け付ける
		call	get_trigger
		jp		nz, name_entry_move_button
		; VSYNC待ち
name_entry_vsync_wait:
		ld		a, [sca_title_last_counter]
		ld		l, a
name_entry_vsync_wait_loop:
		ld		a, [software_timer]
		cp		a, l
		jr		z, name_entry_vsync_wait_loop
		jr		name_entry_loop

		; 方向キーの入力
get_stick:
		push	bc
		xor		a, a
		call	GTSTCK
		push	af
		ld		a, 1
		call	GTSTCK
		pop		bc
		or		a, b
		pop		bc
		ret

		; ボタンの入力
get_trigger:
		push	bc
		xor		a, a
		call	GTTRIG
		push	af
		ld		a, 1
		call	GTTRIG
		pop		bc
		or		a, b
		pop		bc
		ret

		; 左へ移動
name_entry_move_left:
		ld		a, b
		or		a, a
		jp		z, name_entry_loop_key_check_end	; これ以上左へ行けない場合は何もしないで戻る
		; 現在位置の文字の表示を更新する
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		a, [hl]
		push	hl
		ld		hl, [cursor_pos]
		call	WRTVRM
		pop		hl
		; 新しい文字を得る
		dec		hl
		ld		c, [hl]
		; カーソルを左へ移動する
		ld		hl, [cursor_pos]
		dec		hl
		ld		[cursor_pos], hl
		dec		b
		jp		name_entry_loop_key_check_end

		; 右へ移動
name_entry_move_right:
		ld		a, b
		cp		a, 3
		jp		z, name_entry_loop_key_check_end	; これ以上右へ行けない場合は何もしないで戻る
		; 現在位置の文字の表示を更新する
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		a, [hl]
		push	hl
		ld		hl, [cursor_pos]
		call	WRTVRM
		pop		hl
		; 新しい文字を得る
		inc		hl
		ld		c, [hl]
		; カーソルを左へ移動する
		ld		hl, [cursor_pos]
		inc		hl
		ld		[cursor_pos], hl
		inc		b
		jp		name_entry_loop_key_check_end

		; 下ボタン
name_entry_change_prev:
		ld		a, b
		cp		a, 3
		jp		z, name_entry_loop_key_check_end	; 右端は文字入力出来ないので何もしないで戻る
		dec		c
		jp		p, name_entry_change_prev_skip
		ld		c, 37
name_entry_change_prev_skip:
		; 現在位置の文字の記憶と表示を更新する
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		[hl], c
		ld		a, c
		ld		hl, [cursor_pos]
		call	WRTVRM
		jp		name_entry_loop_key_check_end

		; 上ボタン
name_entry_change_next:
		ld		a, b
		cp		a, 3
		jp		z, name_entry_loop_key_check_end	; 右端は文字入力出来ないので何もしないで戻る
		inc		c
		ld		a, c
		cp		a, 38
		jp		c, name_entry_change_next_skip
		ld		c, 0
name_entry_change_next_skip:
		; 現在位置の文字の記憶と表示を更新する
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		[hl], c
		ld		a, c
		ld		hl, [cursor_pos]
		call	WRTVRM
		jp		name_entry_loop_key_check_end

		; ボタン
name_entry_move_button:
		ld		a, b
		cp		a, 3
		jp		z, name_enter						; 名前入力完了
		; 現在位置の文字の表示を更新する
		ld		l, b
		ld		h, 0
		ld		de, current_score_name
		add		hl, de
		ld		a, [hl]
		push	hl
		ld		hl, [cursor_pos]
		call	WRTVRM
		pop		hl
		; 新しい文字を得る
		inc		hl
		ld		c, [hl]
		; カーソルを左へ移動する
		ld		hl, [cursor_pos]
		inc		hl
		ld		[cursor_pos], hl
		inc		b
		; 効果音
		ld		hl, [se_name]
		call	bgmdriver_play_sound_effect
		; ボタンを放すまで待機する
name_entry_move_button_wait:
		call	get_trigger
		jr		nz, name_entry_move_button_wait
		jp		name_entry_vsync_wait

name_enter:
		; BGMフェードアウト
		ld		a, 1
		call	bgmdriver_fadeout
		; 効果音
		ld		hl, [se_start]
		call	bgmdriver_play_sound_effect
		; ボタンを放すまで待機する
		call	get_trigger
		jr		nz, name_enter
		; 入力した名前を転送する
		pop		af
		dec		a
		rlca
		rlca
		rlca
		ld		l, a
		ld		h, 0
		ld		de, high_score + 4
		add		hl, de
		ex		de, hl
		ld		hl, current_score_name
		ld		bc, 3
		ldir
		jp		sca_title_fade_out

; -----------------------------------------------------------------------------
;	MUSIC MODE画面
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_music_mode:
		; 画面をクリアする
		xor		a, a
		ld		hl, PATTERN_NAME1
		ld		bc, 768
		call	FILVRM
		; MUSIC MODE を描画する
		ld		hl, PATTERN_NAME1 + 9 + 4*32
		ld		de, str_music_mode
		call	draw_str
		; SELECT を描画する
		ld		hl, PATTERN_NAME1 + 10 + 8*32
		ld		de, str_select
		call	draw_str
		; PLAYING を描画する
		ld		hl, PATTERN_NAME1 + 10 + 14*32
		ld		de, str_playing
		call	draw_str
		; BGM番号初期化
		xor		a, a
		ld		[cursor_pos], a
		ld		[playing_cursor_pos], a
		call	draw_selected_music_name
		; メインループ
sca_music_mode_loop:
		call	get_stick					; 左右キー入力判定
		cp		a, 3
		jp		z, sca_music_next
		cp		a, 7
		jp		z, sca_music_previous
		call	get_trigger					; ボタン入力判定
		jp		nz, sca_music_play
		jp		sca_music_mode_loop
		; 演奏開始
sca_music_play:
		call	delete_playing_music_name	; 再生中の曲名を消去
		ld		a, [cursor_pos]				; 選択中の曲を再生曲にする
		ld		[playing_cursor_pos], a
		cp		a, 14							; ただし EXIT なら終了する
		jp		z, sca_music_mode_exit
		call	draw_playing_music_name
		call	wait_release_trigger		; ボタンを放すまで待機
		jp		sca_music_mode_loop
		; 次の曲
sca_music_next:
		ld		hl, [se_shot]
		call	bgmdriver_play_sound_effect	; 効果音再生
		call	delete_selected_music_name	; 選択中の曲名を消去
		ld		a, [cursor_pos]				; 次の曲にする
		inc		a
		cp		a, 15
		jr		nz, sca_music_next_skip
		xor		a, a							; 循環
sca_music_next_skip:
		ld		[cursor_pos], a
		call	draw_selected_music_name	; 新しい選択中の曲名を表示
		call	wait_release_stick			; 方向キーを放すまで待機
		jp		sca_music_mode_loop
		; 前の曲
sca_music_previous:
		ld		hl, [se_shot]
		call	bgmdriver_play_sound_effect	; 効果音再生
		call	delete_selected_music_name	; 選択中の曲名を消去
		ld		a, [cursor_pos]				; 次の曲にする
		dec		a
		jp		p, sca_music_next_skip
		ld		a, 14						; 循環
		jp		sca_music_next_skip
		; 呼び出し元へ戻る
sca_music_mode_exit:
		call	sca_title_fade_out
		ret
wait_release_stick:
		call	get_stick
		or		a, a
		jr		nz, wait_release_stick
		ret
wait_release_trigger:
		call	get_trigger
		jr		nz, wait_release_trigger
		ret

; -----------------------------------------------------------------------------
;	選択中の曲名を表示する
;	input:
;		なし
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
draw_selected_music_name:
		; 選択中の番号から、曲名のアドレスを得る
		ld		a, [cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; 描画する
		ld		hl, PATTERN_NAME1 + 12 + 9*32
		jp		draw_str

; -----------------------------------------------------------------------------
;	選択中の曲名を消去する
;	input:
;		なし
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
delete_selected_music_name:
		; 選択中の番号から、曲名のアドレスを得る
		ld		a, [cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; 描画する
		ld		hl, PATTERN_NAME1 + 12 + 9*32
		jp		delete_str

; -----------------------------------------------------------------------------
;	再生中の曲名を表示/再生開始する
;	input:
;		なし
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
draw_playing_music_name:
		; 再生中の番号から、曲名のアドレスを得る
		ld		a, [playing_cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		push	bc
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; 描画する
		ld		hl, PATTERN_NAME1 + 12 + 15*32
		call	draw_str
		; 曲データのアドレスを得る
		pop		bc
		ld		hl, SCA_BGM_TABLE_ADR
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		ex		de, hl
		; 曲を再生する
		jp		bgmdriver_play

; -----------------------------------------------------------------------------
;	再生中の曲名を消去し演奏停止する
;	input:
;		なし
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
delete_playing_music_name:
		; 演奏停止
		call	bgmdriver_stop
		; 再生中の番号から、曲名のアドレスを得る
		ld		a, [playing_cursor_pos]
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, sca_bgm_name_table
		add		hl, bc
		ld		e, [hl]
		inc		hl
		ld		d, [hl]
		; 描画する
		ld		hl, PATTERN_NAME1 + 12 + 15*32
		jp		delete_str

; -----------------------------------------------------------------------------
;	文字列を描画する
;	input:
;		hl	...	VRAMアドレス
;		de	...	文字列のアドレス
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
draw_str:
		call	SETWRT
		; 文字列の長さを取得
		ex		de, hl
		ld		b, [hl]
		inc		hl
		; 描画
		ld		c, VDP_VRAM_IO
		otir
		ret

; -----------------------------------------------------------------------------
;	文字列を消去する
;	input:
;		hl	...	VRAMアドレス
;		de	...	文字列のアドレス
;	output
;		なし
;	break
;		a, b, c, d, e, f, h, l
;	comment
;		なし
; -----------------------------------------------------------------------------
delete_str:
		call	SETWRT
		; 文字列の長さを取得
		ex		de, hl
		ld		b, [hl]
		; 消去
		ld		c, VDP_VRAM_IO
		xor		a, a
delete_str_loop:
		out		[c], a
		djnz	delete_str_loop
		ret

; -----------------------------------------------------------------------------
;	パレットフェードイン
;	input:
;		なし
;	output
;		なし
;	break
;		a
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_title_fade_in:
		ld		b, 8
sca_title_fade_in_loop:
		ld		a, b
		dec		a
		push	bc
		call	fade_palette
		ld		hl, 6
		call	vsync_wait_time
		pop		bc
		djnz	sca_title_fade_in_loop
		ret

; -----------------------------------------------------------------------------
;	パレットフェードアウト
;	input:
;		なし
;	output
;		なし
;	break
;		a
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_title_fade_out:
		ld		b, 8
sca_title_fade_out_loop:
		ld		a, 8
		sub		a, b
		push	bc
		call	fade_palette
		ld		hl, 6
		call	vsync_wait_time
		pop		bc
		djnz	sca_title_fade_out_loop
		ret

; -----------------------------------------------------------------------------
;	VDP R18 への書き込み
;	input:
;		a	...	書き込む値
;	output
;		なし
;	break
;		a
;	comment
;		なし
; -----------------------------------------------------------------------------
sca_vdp_r18:
		di								; 割り込み処理の中で VDP R15 に書き込むので、割禁にしないと NG
		out		[VDP_CMDREG_IO], a
		ld		a, 0x80 + 18
		out		[VDP_CMDREG_IO], a
		ei								; 割禁は必要なところだけの最小限に抑える
		ret

; -----------------------------------------------------------------------------
;	タイトル画面データ
; -----------------------------------------------------------------------------
sca_title_last_counter:
		db		0

sca_title_wait_counter:
		db		0

sca_title_scroll_pos:
		db		0

cursor_pos:
		dw		0

playing_cursor_pos:
		db		0

sca_title_background:
		db		41, 38, 38, 38, 38, 00, 00, 41, 38, 38, 38, 38, 00, 00, 41, 38, 38, 38, 42	; 19文字
		db		38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		43, 38, 38, 38, 42, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		00, 00, 00, 38, 38, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 38, 38, 38
		db		00, 00, 00, 38, 38, 00, 00, 38, 38, 00, 00, 00, 00, 00, 38, 38, 00, 38, 38
		db		38, 38, 38, 38, 44, 00, 00, 43, 38, 38, 38, 38, 00, 00, 38, 38, 00, 38, 38
		db		00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
		db		00, 00, 00, 29, 13, 25, 28, 15, 00, 11, 30, 30, 11, 13, 21, 15, 28, 00, 00

sca_title_push_space_bar:
		db		26, 31, 29, 18, 00, 29, 26, 11, 13, 15, 00, 12, 11, 28					; 14文字
sca_title_push_space_bar_delete:
		db		00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00					; 14文字

sca_programmed_by:
		db		26, 28, 25, 17, 28, 23, 23, 15, 14, 00, 12, 35, 00, 18, 28, 11, 37		; 17文字

sca_music_composed_by:
		db		23, 31, 29, 19, 13, 00, 13, 25, 23, 26, 25, 29, 15, 14, 00, 12, 35
		db		00, 45, 46, 47, 48, 49															; 23文字

sca_high_score_list:
		db		18, 19, 17, 18, 00, 29, 13, 25, 28, 15, 00, 22, 19, 29, 30				; 15文字

sca_bgm_name_table:
		dw		sca_stage1_bgm_name
		dw		sca_stage2_bgm_name
		dw		sca_stage3_bgm_name
		dw		sca_stage4_bgm_name
		dw		sca_stage5_bgm_name
		dw		sca_stage6_bgm_name
		dw		sca_stage7_bgm_name
		dw		sca_stage8_bgm_name
		dw		sca_warning_name
		dw		sca_boss1_bgm_name
		dw		sca_clear_bgm_name
		dw		sca_gameover_bgm_name
		dw		sca_finalboss_bgm_name
		dw		sca_nameentry_bgm_name
		dw		str_exit

sca_stage1_bgm_name:
		; GO AHEAD
		db		8  , 17, 25, 0 , 11, 18, 15, 11, 14
sca_stage2_bgm_name:
		; SNOWMAN
		db		7  , 29, 24, 25, 33, 23, 11, 24
sca_stage3_bgm_name:
		; MIDNIGHT ASSASSIN
		db		17 , 23, 19, 14, 24, 19, 17, 18, 30, 0 , 11, 29, 29, 11, 29, 29, 19, 24
sca_stage4_bgm_name:
		; ESCAPE DANCE
		db		12 , 15, 29, 13, 11, 26, 15, 0 , 14, 11, 24, 13, 15
sca_stage5_bgm_name:
		; GENOSIDE 2XXX
		db		13 , 17, 15, 24, 25, 29, 19, 14, 15, 0 , 3 , 34, 34, 34
sca_stage6_bgm_name:
		; UNDERROAD
		db		9  , 31, 24, 14, 15, 28, 28, 25, 11, 14
sca_stage7_bgm_name:
		; SPOT OF CYCLONE
		db		15 , 29, 26, 25, 30, 0 , 25, 16, 0 , 13, 35, 13, 22, 25, 24, 15
sca_stage8_bgm_name:
		; MILLION SHOWER
		db		14 , 23, 19, 22, 22, 19, 25, 24, 0 , 29, 18, 25, 33, 15, 28
sca_warning_name:
		; WARNING!!
		db		9  , 33, 11, 28, 24, 19, 24, 17, 37, 37
sca_boss1_bgm_name:
		; FEAR..
		db		6  , 16, 15, 11, 28, 40, 40
sca_clear_bgm_name:
		; STAGE CLEAR
		db		11 , 29, 30, 11, 17, 15, 0 , 13, 22, 15, 11, 28
sca_gameover_bgm_name:
		; GAME OVER
		db		9  , 17, 11, 23, 15, 0 , 25, 32, 15, 28
sca_finalboss_bgm_name:
		; DOG SOLDIER
		db		11 , 14, 25, 17, 0 , 29, 25, 22, 14, 19, 15, 28
sca_nameentry_bgm_name:
		; 20MILES 
		db		8  , 3 , 1 , 23, 19, 22, 15, 29, 0 
str_music_mode:
		; MUSIC MODE
		db		10 , 23, 31, 29, 19, 13, 0 , 23, 25, 14, 15
str_select:
		; SELECT
		db		6  , 29, 15, 22, 15, 13, 30
str_playing:
		; PLAYING
		db		7  , 26, 22, 11, 35, 19, 24, 17
str_exit:
		; EXIT
		db		4  , 15, 34, 19, 30

sca_screen_buffer::
		repeat i, 768
			dw	0
		endr
