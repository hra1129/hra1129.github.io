; -----------------------------------------------------------------------------
;	SCA public definition
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	情報構造体
; -----------------------------------------------------------------------------
SCA_INFO_SIZE					= 8

SCA_INFO_XL						= 0
SCA_INFO_XH						= 1
SCA_INFO_YL						= 2
SCA_INFO_YH						= 3
SCA_INFO_PLAYER_MOVE_VEC_TBL_L	= 4
SCA_INFO_PLAYER_MOVE_VEC_TBL_H	= 5
SCA_INFO_PLAYER_SHOT_POWER		= 6

SCA_INFO_SHOT_POWER				= 4

SCA_INFO_ENEMY_REVERSE			= 0
SCA_INFO_ENEMY_SHOT_TIMING		= 2
SCA_INFO_ENEMY_POWER			= 4
SCA_INFO_ENEMY_STATE_L			= 5
SCA_INFO_ENEMY_STATE_H			= 6
SCA_INFO_ENEMY_STATE_L2			= 5 + SCA_INFO_SIZE * 2
SCA_INFO_ENEMY_STATE_H2			= 6 + SCA_INFO_SIZE * 2
SCA_INFO_ENEMY_STATE_L3			= 5 + SCA_INFO_SIZE * 4
SCA_INFO_ENEMY_STATE_H3			= 6 + SCA_INFO_SIZE * 4
SCA_INFO_ENEMY_SPRITE_NUM		= 7
SCA_INFO_ENEMY_MOVE_L			= 6 + SCA_INFO_SIZE
SCA_INFO_ENEMY_MOVE_H			= 7 + SCA_INFO_SIZE

SCA_INFO_ESHOT_X_SIG			= 0
SCA_INFO_ESHOT_Y_SIG			= 2
SCA_INFO_ESHOT_DEN_IS_DX		= 4
SCA_INFO_ESHOT_DEN				= 5
SCA_INFO_ESHOT_NUM				= 6
SCA_INFO_ESHOT_CNT				= 7

SCA_INFO_XL2					= 0 + SCA_INFO_SIZE
SCA_INFO_XH2					= 1 + SCA_INFO_SIZE
SCA_INFO_YL2					= 2 + SCA_INFO_SIZE
SCA_INFO_YH2					= 3 + SCA_INFO_SIZE

SCA_INFO_XL3					= 0 + SCA_INFO_SIZE * 2
SCA_INFO_XH3					= 1 + SCA_INFO_SIZE * 2
SCA_INFO_YL3					= 2 + SCA_INFO_SIZE * 2
SCA_INFO_YH3					= 3 + SCA_INFO_SIZE * 2
SCA_INFO_ENEMY_POWER3			= 4 + SCA_INFO_SIZE * 2

SCA_INFO_XL4					= 0 + SCA_INFO_SIZE * 3
SCA_INFO_XH4					= 1 + SCA_INFO_SIZE * 3
SCA_INFO_YL4					= 2 + SCA_INFO_SIZE * 3
SCA_INFO_YH4					= 3 + SCA_INFO_SIZE * 3

SCA_INFO_XL5					= 0 + SCA_INFO_SIZE * 4
SCA_INFO_XH5					= 1 + SCA_INFO_SIZE * 4
SCA_INFO_YL5					= 2 + SCA_INFO_SIZE * 4
SCA_INFO_YH5					= 3 + SCA_INFO_SIZE * 4
SCA_INFO_ENEMY_POWER5			= 4 + SCA_INFO_SIZE * 4

SCA_INFO_XL6					= 0 + SCA_INFO_SIZE * 5
SCA_INFO_XH6					= 1 + SCA_INFO_SIZE * 5
SCA_INFO_YL6					= 2 + SCA_INFO_SIZE * 5
SCA_INFO_YH6					= 3 + SCA_INFO_SIZE * 5

SCA_INFO_XL7					= 0 + SCA_INFO_SIZE * 6
SCA_INFO_XH7					= 1 + SCA_INFO_SIZE * 6
SCA_INFO_YL7					= 2 + SCA_INFO_SIZE * 6
SCA_INFO_YH7					= 3 + SCA_INFO_SIZE * 6
SCA_INFO_ENEMY_POWER7			= 4 + SCA_INFO_SIZE * 6

SCA_INFO_XL8					= 0 + SCA_INFO_SIZE * 7
SCA_INFO_XH8					= 1 + SCA_INFO_SIZE * 7
SCA_INFO_YL8					= 2 + SCA_INFO_SIZE * 7
SCA_INFO_YH8					= 3 + SCA_INFO_SIZE * 7

; -----------------------------------------------------------------------------
;	定数
; -----------------------------------------------------------------------------
SCA_SHOT_COUNT					= 15			; 敵の弾の最大出現数[15まで]
SCA_MAX_ENEMY_POWER				= 32			; ザコ敵の硬さの最大値
SCA_MIN_ENEMY_SHOT_INTERVAL		= 4				; ザコ敵の弾の撃つ間隔最小値

SCA_BGM_TABLE_ADR				= 0x8300

; -----------------------------------------------------------------------------
;	BIOS entry
; -----------------------------------------------------------------------------
ENASLT							= 0x0024
WRTVRM							= 0x004D
SETWRT							= 0x0053
FILVRM							= 0x0056
LDIRVM							= 0x005C
CHGMOD							= 0x005F
GTSTCK							= 0x00D5
GTTRIG							= 0x00D8
SNSMAT							= 0x0141
CHGCPU							= 0x0180		; CPUモード切り替え, turboR only

; -----------------------------------------------------------------------------
;	BIOS workarea
; -----------------------------------------------------------------------------
MSXVER							= 0x002D		; MSX-BASIC のバージョン [0:MSX1, 1:MSX2, 2:MSX2+, 3:MSXtR
RAMAD1							= 0xF342		; page1 の RAMスロット番号 [DiskBIOS work]
CLIKSW							= 0xF3DB		; キークリックスイッチ 0=OFF, 0以外=ON
RG1SAV							= 0xF3E0
STATFL							= 0xF3E7
FORCLR							= 0xF3E9
BAKCLR							= 0xF3EA
BDRCLR							= 0xF3EB
EXPTBL							= 0xFCC1		; MAIN-ROM の スロット番号

; -----------------------------------------------------------------------------
;	BIOS hook
; -----------------------------------------------------------------------------
H_TIMI							= 0xFD9F

; -----------------------------------------------------------------------------
;	I/O port
; -----------------------------------------------------------------------------
VDP_VRAM_IO						= 0x98
VDP_CMDREG_IO					= 0x99
VDP_PALREG_IO					= 0x9A
VDP_REG_IO						= 0x9B

; -----------------------------------------------------------------------------
;	VRAM map [SCREEN4]
; -----------------------------------------------------------------------------
PATTERN_GENERATOR1				= 0x0000
PATTERN_GENERATOR2				= 0x0800
PATTERN_GENERATOR3				= 0x1000
PATTERN_NAME1					= 0x1800
PATTERN_NAME2					= 0x1900
PATTERN_NAME3					= 0x1A00
SPRITE_COLOR					= 0x1C00
SPRITE_ATTRIBUTE				= 0x1E00
COLOR_TABLE1					= 0x2000
COLOR_TABLE2					= 0x2800
COLOR_TABLE3					= 0x3000
SPRITE_GENERATOR				= 0x3800

; -----------------------------------------------------------------------------
;	BGMデータのアドレスが格納されているアドレス
; -----------------------------------------------------------------------------
bgm_stage1						= SCA_BGM_TABLE_ADR + 0
bgm_stage2						= SCA_BGM_TABLE_ADR + 2
bgm_stage3						= SCA_BGM_TABLE_ADR + 4
bgm_stage4						= SCA_BGM_TABLE_ADR + 6
bgm_stage5						= SCA_BGM_TABLE_ADR + 8
bgm_stage6						= SCA_BGM_TABLE_ADR + 10
bgm_stage7						= SCA_BGM_TABLE_ADR + 12
bgm_stage8						= SCA_BGM_TABLE_ADR + 14
bgm_boss_buz					= SCA_BGM_TABLE_ADR + 16
bgm_boss1						= SCA_BGM_TABLE_ADR + 18
bgm_clear						= SCA_BGM_TABLE_ADR + 20
bgm_gameover					= SCA_BGM_TABLE_ADR + 22
bgm_finalboss					= SCA_BGM_TABLE_ADR + 24
bgm_nameentry					= SCA_BGM_TABLE_ADR + 26
se_damage						= SCA_BGM_TABLE_ADR + 28
se_bomb							= SCA_BGM_TABLE_ADR + 30
se_get_item						= SCA_BGM_TABLE_ADR + 32
se_no_damage					= SCA_BGM_TABLE_ADR + 34
se_shot							= SCA_BGM_TABLE_ADR + 36
se_start						= SCA_BGM_TABLE_ADR + 38
se_name							= SCA_BGM_TABLE_ADR + 40
se_laser						= SCA_BGM_TABLE_ADR + 42
se_stop							= SCA_BGM_TABLE_ADR + 44
se_pre_laser					= SCA_BGM_TABLE_ADR + 46
se_bomb2						= SCA_BGM_TABLE_ADR + 48
