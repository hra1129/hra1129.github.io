; -----------------------------------------------------------------------------
;	BSAVEƒwƒbƒ_
; -----------------------------------------------------------------------------
		db		0xFE
		dw		sca_main
		dw		sca_end_of_program - 1
		dw		sca_main

	include	"sca_info.asm"
	include	"bgmdriver_d.asm"
	include	"sca_graph_def_main.asm"
sca_end_of_program:
