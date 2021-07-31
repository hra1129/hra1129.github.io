; -----------------------------------------------------------------------------
;	�����������荞��
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�����������荞�ݏ����̏�����
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a,b,c,d,e,f
;	comment
;		���荞�ݏ�����������B���̊��荞�ݏ����͒x������̂ŌĂяo���Ȃ��B
;		BASIC �̓��͉�ʂ֖߂�O�� vsync_term �����s���Ȃ���΂Ȃ�Ȃ��B
; -----------------------------------------------------------------------------
vsync_init::
		; H_TIMI �����������Ă���Œ��Ɋ��荞�݂�����Ȃ��悤�Ɋ��ւɂ��Ă���
		di
		; H_TIMI ������������O�ɁA���̓��e��Ҕ����Ă���
		ld		hl, H_TIMI
		ld		de, h_timi_backup
		ld		bc, 5
		ldir
		; H_TIMI ������������
		ld		a, 0xC3						; jp xxxx ���߃R�[�h
		ld		[H_TIMI + 0], a
		ld		hl, vsync_interrupt_handler
		ld		[H_TIMI + 1], hl
		; ���։���
		ei
		ret

; -----------------------------------------------------------------------------
;	�����������荞�݂̌�n��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		���荞�ݏ��������ʂ�ɖ߂��B
; -----------------------------------------------------------------------------
vsync_term::
		; H_TIMI �����������Ă���Œ��Ɋ��荞�݂�����Ȃ��悤�Ɋ��ւɂ��Ă���
		di
		; H_TIMI �𕜌�����
		ld		hl, h_timi_backup
		ld		de, H_TIMI
		ld		bc, 5
		ldir
		; ���։���
		ei
		ret

; -----------------------------------------------------------------------------
;	���荞�ݏ������[�`��
;	input
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�Ȃ�
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
vsync_interrupt_handler::
		push	af
		; VDP �ɑ΂��āu���荞�ݐM���� CPU ���󂯎�������Ɓv��m�点�邽�߂ɁAVDP S0 ��ǂ�
		xor		a, a
		out		[VDP_CMDREG_IO], a
		ld		a, 0x80 + 15
		out		[VDP_CMDREG_IO], a		; VDP R15 �� 0
		in		a, [VDP_CMDREG_IO]		; a �� VDP S0
		ld		[STATFL], a				; ���[�N�G���A�ɕۑ��p���������p�ӂ���Ă�̂ŁA�����ɕۑ������ĖႤ

		; BGM�h���C�o�[�̊��荞�ݏ������[�`�����Ăяo��
		call	bgmdriver_interrupt_handler

		; �\�t�g�E�F�A�^�C�}�[�̏���
		ld		a, [software_timer]
		inc		a
		ld		[software_timer], a
		pop		af
		ei								; ���։���
		ret								; MSX �� Z80�p�ėp����LSI�͎g�p���Ă��Ȃ��̂� reti �͕K�v�Ȃ�

; -----------------------------------------------------------------------------
;	���ԑ҂�
;	input:
;		hl	...	�ҋ@���鎞�� [1/60[sec]�P��]
;	output
;		�Ȃ�
;	break
;		
;	comment
;		�덷 -1/60[sec] �` 0[sec]
;		hl = 0 �̏ꍇ�́A65536/60[sec] �Ƃ��ď��������B
; -----------------------------------------------------------------------------
vsync_wait_time::
		ld		a, [software_timer]
		ld		c, a
vsync_wait_time_loop:
		ld		a, [software_timer]
		cp		a, c
		jr		z, vsync_wait_time_loop
		dec		hl
		ld		a, l
		or		a, h
		jr		nz, vsync_wait_time
		ret

software_timer::
		db		0						; 1/60[sec] �P�ʂŃC���N�������g����\�t�g�E�F�A�^�C�}�[

h_timi_backup:
		db		0, 0, 0, 0, 0
