; -----------------------------------------------------------------------------
;	SCA グラフィック/BGMデータ定義プログラム
; -----------------------------------------------------------------------------

		org		0x8400

; -----------------------------------------------------------------------------
;	初期化処理
; -----------------------------------------------------------------------------
sca_main::
		; COLOR 15,0,0
		ld		a, 15
		ld		[FORCLR], a
		xor		a, a
		ld		[BAKCLR], a
		ld		[BDRCLR], a
		; キークリックスイッチOFF
		ld		[CLIKSW], a
		; SCREEN 4
		ld		a, [RG1SAV]		; VDP[1] = [VDP[1] AND &HFC] OR 0x02		※スプライトサイズ 16x16, ２倍拡大無し
		and		a, 0xFC
		or		a, 0x02
		ld		[RG1SAV], a
		ld		a, 4			; SCREEN 4
		call	CHGMOD
		; スプライトを初期化
		call	sprite_init
		call	sprite_pattern_init
		; 背景を初期化
		call	background_init
		; BGM/SEを裏RAMへ転送
		call	bgm_transfer
		ret

; -----------------------------------------------------------------------------
;	スプライトカラーテーブルを初期化
;	input:
;		なし
;	output
;		なし
;	break
;		a,b,c,d,e,f
;	comment
;		なし
; -----------------------------------------------------------------------------
sprite_init::
		; スプライトカラーを初期化
		ld		b, 32						; 32枚分
		xor		a, a						; スプライト番号初期値は 0
		ld		hl, sprite_color_data
sprite_init_loop2:
		push	hl
		push	bc
		push	af
		ld		c, [hl]						; c = 色データ
		call	sprite_set_color			; COLOR SPRITE[a] = c
		pop		af
		pop		bc
		pop		hl
		inc		hl							; 次の色データ
		inc		a							; 次のスプライト
		djnz	sprite_init_loop2
		ret

; -----------------------------------------------------------------------------
;	スプライトカラーをセットする
;	input
;		a ...	スプライト番号[0～31]
;		c ...	色データ
;	output
;		なし
;	break
;		全て
;	comment
;		COLOR SPRITE[a] = c に相当
; -----------------------------------------------------------------------------
sprite_set_color::
		; hl = SPRITE_COLOR + a * 16
		ld		hl, SPRITE_COLOR
		rlca			; cフラグは必ず 0
		rlca			; cフラグは必ず 0
		rlca			; cフラグは必ず 0
		rlca
		jr		nc, sprite_set_color_skip1
		inc		h
sprite_set_color_skip1:
		ld		l, a	; SPRITE_COLOR の下位8bit は 0x00 なので a+l は a と同じ。なので代入だけで良い。
		; a = 色データ
		ld		a, c
		; bc = 16
		ld		bc, 16
		jp		FILVRM

; -----------------------------------------------------------------------------
;	スプライト形状を初期化
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
sprite_pattern_init::
		ld		hl, sprite_pattern
		ld		de, SPRITE_GENERATOR
		ld		bc, 8*4*24
		jp		LDIRVM

; -----------------------------------------------------------------------------
;	グラフィックパターンを定義する
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
background_init::
		; パターンネームテーブルをクリアする
		ld		hl, PATTERN_NAME1
		ld		bc, 768
		xor		a, a
		call	FILVRM
		; パターンジェネレーターテーブルにパターンを転送する[文字]
		ld		hl, background_pattern
		ld		de, PATTERN_GENERATOR1
		ld		bc, background_pattern_end - background_pattern
		call	LDIRVM
		ld		hl, background_pattern
		ld		de, PATTERN_GENERATOR2
		ld		bc, background_pattern_end - background_pattern
		call	LDIRVM
		ld		hl, background_pattern
		ld		de, PATTERN_GENERATOR3
		ld		bc, background_pattern_end - background_pattern
		call	LDIRVM
		; カラーテーブルにカラーを転送する[文字]
		ld		de, COLOR_TABLE1
		call	background_set_color
		ld		de, COLOR_TABLE2
		call	background_set_color
		ld		de, COLOR_TABLE3
		call	background_set_color
		; パターンジェネレーターテーブルにパターンを転送する[背景]
		ld		hl, background_graphic_pattern
		ld		de, PATTERN_GENERATOR1 + 64 * 8
		ld		bc, background_graphic_pattern_end - background_graphic_pattern
		call	LDIRVM
		ld		hl, background_graphic_pattern
		ld		de, PATTERN_GENERATOR2 + 64 * 8
		ld		bc, background_graphic_pattern_end - background_graphic_pattern
		call	LDIRVM
		ld		hl, background_graphic_pattern
		ld		de, PATTERN_GENERATOR3 + 64 * 8
		ld		bc, background_graphic_pattern_end - background_graphic_pattern
		call	LDIRVM
		; カラーテーブルにカラーを転送する[背景]
		ld		hl, background_graphic_color
		ld		de, COLOR_TABLE1 + 64 * 8
		ld		bc, background_graphic_color_end - background_graphic_color
		call	LDIRVM
		ld		hl, background_graphic_color
		ld		de, COLOR_TABLE2 + 64 * 8
		ld		bc, background_graphic_color_end - background_graphic_color
		call	LDIRVM
		ld		hl, background_graphic_color
		ld		de, COLOR_TABLE3 + 64 * 8
		ld		bc, background_graphic_color_end - background_graphic_color
		call	LDIRVM
		ret
		; カラーテーブル初期化 [文字]
background_set_color:
		xor		a, a
		ld		bc, 8
background_set_color_loop:
		push	af
		push	de
		push	bc
		ld		hl, background_color
		call	LDIRVM
		pop		bc
		pop		de
		pop		af
		ex		de, hl
		add		hl, bc
		ex		de, hl
		dec		a
		jr		nz, background_set_color_loop
		ret

; -----------------------------------------------------------------------------
;	BGM/SEデータを裏RAM [4000h-7FFFh] へ転送する
;	input:
;		なし
;	output
;		なし
;	break
;		全て
;	comment
;		なし
; -----------------------------------------------------------------------------
bgm_transfer:
		; page1 を RAM に切り替える
		ld		a, [RAMAD1]
		ld		h, 0x40				; page1
		call	ENASLT					; 割禁になって帰ってくる
		; BGM/SEデータを転送
		ld		hl, bgm_data_transfer_start
		ld		de, 0x4000
		ld		bc, bgm_data_transfer_end - bgm_data_transfer_start
		ldir
		; page1 を MAIN-ROM に戻す
		ld		a, [EXPTBL]
		ld		h, 0x40				; page1
		call	ENASLT					; 割禁になって帰ってくる
		ei								; 割禁解除
		; アドレス情報テーブルを転送する
		ld		hl, bgm_table
		ld		de, SCA_BGM_TABLE_ADR
		ld		bc, bgm_table_end - bgm_table
		ldir
		ret

; -----------------------------------------------------------------------------
;	グラフィックデータ
; -----------------------------------------------------------------------------
sprite_pattern:
		db		0x00, 0x01, 0x00, 0x03, 0x03, 0x03, 0x03, 0x07	; 自機-1	0
		db		0x67, 0x7F, 0x6F, 0x6F, 0x63, 0x3D, 0xC4, 0x03
		db		0x00, 0x80, 0x80, 0x40, 0x40, 0xC0, 0xC0, 0xE0
		db		0x6A, 0x72, 0x7A, 0x7A, 0x42, 0x7A, 0x46, 0x80

		db		0x01, 0x03, 0x03, 0x06, 0x06, 0x04, 0x04, 0x4C	; 自機-2	1
		db		0xCE, 0xCF, 0xDF, 0xDF, 0xDF, 0xC3, 0x03, 0x00
		db		0x00, 0x00, 0x00, 0x80, 0x80, 0x00, 0x00, 0x04
		db		0x84, 0xAC, 0xBC, 0xBC, 0xBC, 0x84, 0x80, 0x00

		db		0x00, 0x20, 0x70, 0x70, 0x70, 0x70, 0x70, 0x70	; 自機弾	2
		db		0x70, 0x30, 0x60, 0x20, 0x40, 0x20, 0x00, 0x00
		db		0x00, 0x08, 0x1C, 0x1C, 0x1C, 0x1C, 0x1C, 0x1C
		db		0x1C, 0x0C, 0x18, 0x08, 0x10, 0x08, 0x00, 0x00

		db		0x03, 0x0D, 0x17, 0x3F, 0x5F, 0x7F, 0xBF, 0xFF	; 敵1-1		3
		db		0xBF, 0x7F, 0x54, 0x3F, 0x1D, 0x0E, 0x03, 0x00
		db		0x80, 0x60, 0xD0, 0xF8, 0xDC, 0xFC, 0xD6, 0xDA
		db		0xA2, 0x0C, 0x94, 0x28, 0x50, 0x60, 0x80, 0x00

		db		0x00, 0x03, 0x0F, 0x1F, 0x3F, 0x3F, 0x7F, 0x7F	; 敵1-2		4
		db		0x7F, 0x3F, 0x3F, 0x00, 0x02, 0x01, 0x00, 0x00
		db		0x00, 0x80, 0xE0, 0xE0, 0xE0, 0xE0, 0xE8, 0xE4
		db		0xDC, 0xF8, 0x78, 0xF0, 0xE0, 0x80, 0x00, 0x00

		db		0x00, 0x00, 0x00, 0x00, 0x03, 0x07, 0x0F, 0x0F	; 敵弾		5
		db		0x0F, 0x0F, 0x07, 0x03, 0x00, 0x00, 0x00, 0x00
		db		0x00, 0x00, 0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF0
		db		0xF0, 0xF0, 0xE0, 0xC0, 0x00, 0x00, 0x00, 0x00

		db		0x60, 0xF0, 0xFC, 0xFF, 0x7F, 0x3B, 0x35, 0x1A	; 敵2A-1	6
		db		0x1C, 0x3A, 0x34, 0x78, 0x7C, 0x3F, 0x18, 0x00
		db		0x00, 0x00, 0x1C, 0xFE, 0xFD, 0xEA, 0x4C, 0x10
		db		0x20, 0x20, 0x10, 0x98, 0x08, 0x0C, 0x9C, 0x78

		db		0x00, 0x60, 0x70, 0x7C, 0x3F, 0x1F, 0x1F, 0x0F	; 敵2A-2	7
		db		0x0F, 0x1F, 0x1F, 0x3F, 0x3F, 0x18, 0x00, 0x00
		db		0x00, 0x00, 0x00, 0x1C, 0xFE, 0xFC, 0xF0, 0xE0
		db		0xC0, 0xC0, 0xE0, 0xF0, 0xF0, 0xF8, 0x78, 0x00

		db		0x00, 0x30, 0x7C, 0x7F, 0x7F, 0x35, 0x3A, 0x34	; 敵2B-1	8
		db		0x38, 0x34, 0x78, 0xF9, 0xF8, 0xF3, 0x4C, 0x30
		db		0x0E, 0x1F, 0x7F, 0xF5, 0xEA, 0xC4, 0x88, 0x10
		db		0x20, 0xA0, 0x10, 0x10, 0x08, 0x88, 0x70, 0x00

		db		0x00, 0x00, 0x30, 0x3C, 0x3F, 0x1F, 0x1F, 0x1F	; 敵2B-2	9
		db		0x1F, 0x1F, 0x3F, 0x7F, 0x7F, 0x7C, 0x30, 0x00
		db		0x00, 0x0E, 0x1E, 0x7E, 0xFC, 0xF8, 0xF0, 0xE0
		db		0xC0, 0xC0, 0xE0, 0xE0, 0xF0, 0x70, 0x00, 0x00

		db		0x7F, 0xFF, 0xC5, 0x40, 0x60, 0x20, 0x31, 0x17	; 敵3-1		10
		db		0x1F, 0x0E, 0x0F, 0x06, 0x06, 0x02, 0x03, 0x01
		db		0xFE, 0xFF, 0xFF, 0xFE, 0x6A, 0xD4, 0x84, 0x08
		db		0x08, 0x10, 0x10, 0x20, 0x20, 0x40, 0x40, 0x80

		db		0x00, 0x7F, 0x7F, 0x3F, 0x3F, 0x1F, 0x1F, 0x0F	; 敵3-2		11
		db		0x0F, 0x07, 0x07, 0x03, 0x03, 0x01, 0x01, 0x00
		db		0x00, 0xFE, 0xFE, 0xFC, 0xFC, 0xF8, 0xF8, 0xF0
		db		0xF0, 0xE0, 0xE0, 0xC0, 0xC0, 0x80, 0x80, 0x00

		db		0x00, 0x00, 0x13, 0x37, 0x0E, 0x1B, 0x93, 0x1E	; 爆発A-1	12
		db		0x2F, 0x1A, 0x3D, 0x3F, 0x47, 0x0E, 0x31, 0x00
		db		0x40, 0x10, 0x74, 0xCC, 0xFE, 0xD8, 0xB8, 0xF8
		db		0x70, 0xF4, 0xCC, 0xF8, 0xB8, 0x30, 0xC4, 0x00

		db		0x00, 0x00, 0x1B, 0x39, 0x31, 0x0C, 0xEC, 0x03	; 爆発A-2	13
		db		0x37, 0x27, 0x02, 0x30, 0x79, 0x71, 0x04, 0x00
		db		0x40, 0x58, 0x38, 0x30, 0x02, 0x64, 0x40, 0x10
		db		0x98, 0x38, 0x30, 0xC0, 0xC0, 0xC8, 0x04, 0x00

		db		0x20, 0x7D, 0x5B, 0xE7, 0xCE, 0x74, 0xDF, 0xFF	; 爆発B-1	14
		db		0x6F, 0x5A, 0x74, 0x49, 0xC7, 0xAE, 0x56, 0x38
		db		0x48, 0xFC, 0xD4, 0x4F, 0xBE, 0xF2, 0xBC, 0x7C
		db		0x36, 0x7A, 0xE6, 0xCE, 0xB6, 0x1C, 0xBA, 0xE7

		db		0xA1, 0x7F, 0x7F, 0xFF, 0xF1, 0xEF, 0xEF, 0xEF	; 爆発B-2	15
		db		0xFF, 0x6F, 0x4F, 0xF6, 0xF9, 0xF9, 0xFF, 0x7B
		db		0xCC, 0xFE, 0xFF, 0xBB, 0x7B, 0x7E, 0xF4, 0xB6
		db		0xFE, 0xBF, 0x7B, 0xF6, 0xCE, 0xFE, 0xFE, 0xEF

		db		0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05	; ボス1-左上1
		db		0x07, 0x06, 0x0D, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F
		db		0x07, 0x3A, 0xDF, 0x7F, 0xFF, 0xFF, 0xFF, 0x5F
		db		0xFB, 0xFC, 0xFE, 0xC7, 0xA7, 0xBF, 0x9F, 0xFF

		db		0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x03, 0x02	; ボス1-左上2
		db		0x01, 0x03, 0x06, 0x04, 0x04, 0x04, 0x06, 0x07
		db		0x00, 0x07, 0x3F, 0xFF, 0xFF, 0xFF, 0xFF, 0xA3
		db		0xFD, 0x07, 0x03, 0x3B, 0x7B, 0x77, 0x6F, 0x1F

		db		0xE0, 0x9C, 0x43, 0xE1, 0xD0, 0xE9, 0xD0, 0xEB	; ボス1-右上1
		db		0x45, 0x9F, 0xBF, 0xA3, 0x65, 0xBD, 0x39, 0x9F
		db		0x00, 0x00, 0x00, 0x80, 0xC0, 0x40, 0xE0, 0xE0
		db		0x60, 0xA0, 0xD0, 0xD0, 0xD0, 0xD0, 0xD0, 0x90

		db		0x00, 0xE0, 0xFC, 0xFE, 0xFF, 0xFE, 0xFF, 0xF4	; ボス1-右上2
		db		0xFF, 0xE0, 0xC0, 0xDC, 0xDA, 0xE2, 0xF6, 0xF8
		db		0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
		db		0x80, 0xC0, 0x60, 0x20, 0x20, 0x20, 0x60, 0xE0

		db		0x0B, 0x04, 0x03, 0x01, 0x01, 0x01, 0x01, 0x00	; ボス1-左下1
		db		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		db		0xFF, 0x1F, 0xCF, 0x2F, 0xEF, 0xFE, 0xFF, 0xFF
		db		0xFF, 0xFF, 0x6F, 0x7D, 0x3E, 0x15, 0x0C, 0x03

		db		0x07, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; ボス1-左下2
		db		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		db		0xFD, 0xF9, 0x39, 0xDB, 0xDF, 0xC7, 0xD0, 0x4A
		db		0x50, 0x4A, 0x30, 0x3F, 0x1F, 0x0F, 0x03, 0x00

		db		0x4F, 0xE0, 0x63, 0xA5, 0x46, 0x9D, 0xF6, 0xDD	; ボス1-右下1
		db		0xF7, 0xDD, 0xF6, 0x06, 0x8C, 0x18, 0x70, 0xC0
		db		0x30, 0x60, 0xC0, 0x80, 0x80, 0x80, 0x80, 0x00
		db		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

		db		0xBF, 0x9F, 0x9C, 0xDA, 0xF9, 0xE2, 0x09, 0xA2	; ボス1-右下2
		db		0x08, 0xA2, 0x08, 0xF8, 0xF0, 0xE0, 0x80, 0x00
		db		0xC0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		db		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

sprite_color_data:
		db		0x01, 0x4E, 0x01, 0x44, 0x01, 0x44, 0x01, 0x44
		db		0x01, 0x44, 0x01, 0x44, 0x01, 0x44, 0x04, 0x04
		db		0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04
		db		0x04, 0x04, 0x04, 0x04, 0x04, 0x06, 0x06, 0x06

		; 文字フォント、グラフィック、ステージ背景マップデータ
		include	"sca_font.asm"
		include	"sca_graphic.asm"

; -----------------------------------------------------------------------------
;	BGM/SEデータ
; -----------------------------------------------------------------------------
bgm_data_transfer_start:
_bgm_stage1:
		include	"stage1_bgm.asm"
_bgm_stage2:
		include	"stage2_bgm.asm"
_bgm_stage3:
		include	"stage3_bgm.asm"
_bgm_stage4:
		include	"stage4_bgm.asm"
_bgm_stage5:
		include	"stage5_bgm.asm"
_bgm_stage6:
		include	"stage6_bgm.asm"
_bgm_stage7:
		include	"stage7_bgm.asm"
_bgm_stage8:
		include	"stage8_bgm.asm"
_bgm_boss_buz:
		include	"warning_bgm.asm"
_bgm_boss1:
		include	"boss_bgm.asm"
_bgm_clear:
		include	"clear_bgm.asm"
_bgm_gameover:
		include	"gameover_bgm.asm"
_bgm_finalboss:
		include	"finalboss_bgm.asm"
_bgm_nameentry:
		include	"nameentry_bgm.asm"
_se_damage:
		db		64					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		30
		db		BGM_SE_NOISE_FREQ
		db		0 + 0x80
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_VOL
		db		8
		db		BGM_SE_FREQ
		dw		28
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_VOL
		db		4
		db		BGM_SE_FREQ
		dw		26
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_VOL
		db		2
		db		BGM_SE_FREQ
		dw		24
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_END

_se_bomb:
		db		128				; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		32768				; 32768 にすると TONE OFF
		db		BGM_SE_NOISE_FREQ
		db		20 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		8 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		28 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		12 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		31 + 0x80
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_NOISE_FREQ
		db		15 + 0x80
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_END

_se_get_item:
		db		32					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		30
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		25
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		20
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		10
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		30
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		25
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		20
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		10
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_END

_se_no_damage:
		db		192					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		15
		db		BGM_SE_NOISE_FREQ
		db		0 + 0x80
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_VOL
		db		8
		db		BGM_SE_FREQ
		dw		14
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_VOL
		db		4
		db		BGM_SE_FREQ
		dw		13
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_END

_se_shot:
		db		255					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		50
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		60
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		70
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		80
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_END

_se_start:
		db		240					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		500
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_FREQ
		dw		400
		db		BGM_SE_WAIT
		db		7
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_FREQ
		dw		200
		db		BGM_SE_WAIT
		db		15
		db		BGM_SE_VOL
		db		8
		db		BGM_SE_FREQ
		dw		400
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_WAIT
		db		7
		db		BGM_SE_FREQ
		dw		200
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_FREQ
		dw		100
		db		BGM_SE_WAIT
		db		15
		db		BGM_SE_VOL
		db		4
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_FREQ
		dw		200
		db		BGM_SE_WAIT
		db		7
		db		BGM_SE_FREQ
		dw		100
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_FREQ
		dw		50
		db		BGM_SE_WAIT
		db		15
		db		BGM_SE_END

_se_name:
		db		255					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		500
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		250
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		500
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		250
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		500
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		250
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		150
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		150
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_FREQ
		dw		150
		db		BGM_SE_WAIT
		db		1
		db		BGM_SE_END

_se_laser:
		db		1						; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		15
		db		BGM_SE_FREQ
		dw		300
		db		BGM_SE_NOISE_FREQ
		db		0 + 0x80
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_FREQ
		dw		30
		db		BGM_SE_NOISE_FREQ
		db		5 + 0x80
		db		BGM_SE_WAIT
		dw		30000
		db		BGM_SE_END

_se_stop:
		db		0
		db		BGM_SE_END

_se_pre_laser:
		db		1						; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		15
		db		BGM_SE_FREQ
		dw		1500
		db		BGM_SE_NOISE_FREQ
		db		31 + 0x80
		db		BGM_SE_WAIT
		db		20
		db		BGM_SE_FREQ
		dw		1200
		db		BGM_SE_NOISE_FREQ
		db		20 + 0x80
		db		BGM_SE_WAIT
		db		20
		db		BGM_SE_FREQ
		dw		900
		db		BGM_SE_NOISE_FREQ
		db		15 + 0x80
		db		BGM_SE_WAIT
		db		20
		db		BGM_SE_FREQ
		dw		600
		db		BGM_SE_NOISE_FREQ
		db		10 + 0x80
		db		BGM_SE_WAIT
		db		300
		db		BGM_SE_END

_se_bomb2:
		db		32					; priority [小さい方が優先]
		db		BGM_SE_VOL
		db		12
		db		BGM_SE_FREQ
		dw		32768				; 32768 にすると TONE OFF
		db		BGM_SE_NOISE_FREQ
		db		20 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		8 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		28 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		12 + 0x80
		db		BGM_SE_WAIT
		db		5
		db		BGM_SE_NOISE_FREQ
		db		31 + 0x80
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_NOISE_FREQ
		db		15 + 0x80
		db		BGM_SE_WAIT
		db		10
		db		BGM_SE_END

bgm_data_transfer_end:

bgm_table:
		dw		_bgm_stage1		- bgm_data_transfer_start + 0x4000	; stage1 の BGM
		dw		_bgm_stage2		- bgm_data_transfer_start + 0x4000	; stage2 の BGM
		dw		_bgm_stage3		- bgm_data_transfer_start + 0x4000	; stage3 の BGM
		dw		_bgm_stage4		- bgm_data_transfer_start + 0x4000	; stage4 の BGM
		dw		_bgm_stage5		- bgm_data_transfer_start + 0x4000	; stage5 の BGM
		dw		_bgm_stage6		- bgm_data_transfer_start + 0x4000	; stage6 の BGM
		dw		_bgm_stage7		- bgm_data_transfer_start + 0x4000	; stage7 の BGM
		dw		_bgm_stage8		- bgm_data_transfer_start + 0x4000	; stage8 の BGM
		dw		_bgm_boss_buz	- bgm_data_transfer_start + 0x4000	; warning の BGM
		dw		_bgm_boss1		- bgm_data_transfer_start + 0x4000	; boss1 の BGM
		dw		_bgm_clear		- bgm_data_transfer_start + 0x4000	; stage clear の BGM
		dw		_bgm_gameover	- bgm_data_transfer_start + 0x4000	; game over の BGM
		dw		_bgm_finalboss	- bgm_data_transfer_start + 0x4000	; stage clear の BGM
		dw		_bgm_nameentry	- bgm_data_transfer_start + 0x4000	; game over の BGM
se_table:
		dw		_se_damage		- bgm_data_transfer_start + 0x4000	; 敵にダメージを与えた音
		dw		_se_bomb		- bgm_data_transfer_start + 0x4000	; 破壊音
		dw		_se_get_item	- bgm_data_transfer_start + 0x4000	; アイテム取得音
		dw		_se_no_damage	- bgm_data_transfer_start + 0x4000	; ダメージを与えられないときの音
		dw		_se_shot		- bgm_data_transfer_start + 0x4000	; ショットを撃った音
		dw		_se_start		- bgm_data_transfer_start + 0x4000	; ゲーム開始音
		dw		_se_name		- bgm_data_transfer_start + 0x4000	; ネームエントリ時のキー入力音
		dw		_se_laser		- bgm_data_transfer_start + 0x4000	; レーザーの音
		dw		_se_stop		- bgm_data_transfer_start + 0x4000	; 効果音停止
		dw		_se_pre_laser	- bgm_data_transfer_start + 0x4000	; レーザー発射準備の音
		dw		_se_bomb2		- bgm_data_transfer_start + 0x4000	; 破壊音[高priority]
bgm_table_end:
