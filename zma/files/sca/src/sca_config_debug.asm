; -----------------------------------------------------------------------------
;	SCA 設定ファイル 
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	ステージ開始からボスが出現するまでの時間
;		0〜65535:	ボス出現までの時間 [1/6秒単位]
; -----------------------------------------------------------------------------
SCA_BOSS_TIME		= 90 * 6
;SCA_BOSS_TIME		= 5 * 6			; ボス動作確認用

; -----------------------------------------------------------------------------
;	ステージ開始時の無敵時間 [1/60秒単位]
;		0:		ステージ開始時の無敵時間無し [デフォルト]
;		1〜254:	ステージ開始時に一定時間無敵 [1/60秒単位]
;		255:	無敵モード
; -----------------------------------------------------------------------------
;SCA_INVINCIBILITY	= 0
SCA_INVINCIBILITY	= 255			; ステージ切り替え確認用

; -----------------------------------------------------------------------------
;	ゲーム開始時の自機の SHIELD値
;		1〜9:	SHIELD値
; -----------------------------------------------------------------------------
SCA_PLAYER_SHIELD	= 4
;SCA_PLAYER_SHIELD	= 9

; -----------------------------------------------------------------------------
;	ゲーム開始時の自機の SHOT値
;		0〜7:	SHOT値
; -----------------------------------------------------------------------------
SCA_PLAYER_SHOT		= 0
;SCA_PLAYER_SHOT		= 7

; -----------------------------------------------------------------------------
;	ゲーム開始時の自機の SPEED値
;		0〜7:	SPEED値
; -----------------------------------------------------------------------------
SCA_PLAYER_SPEED	= 0
;SCA_PLAYER_SPEED	= 7

; -----------------------------------------------------------------------------
;	ゲーム開始時のステージ番号
;		0: stage1
;		1: stage2
;		2: stage3
;		3: stage4
;		4: stage5
;		5: stage6
;		6: stage7
;		7: stage8
; -----------------------------------------------------------------------------
SCA_START_STAGE		= 0
;SCA_START_STAGE		= 7
