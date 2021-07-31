; -----------------------------------------------------------------------------
;	�_������
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;	�X�R�A��������������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		�S��
;	comment
;		�Q�[���X�^�[�g���ɌĂяo��
; -----------------------------------------------------------------------------
score_init::
		; �X�R�A�� 00000000 �ɂ���
		ld		hl, 0
		ld		[current_score + 0], hl
		ld		[current_score + 2], hl
		; �X�R�A�͂܂��g�b�v�X�R�A�ɂ͓��B���Ă��Ȃ�
		xor		a, a
		ld		[current_is_top], a
		; �X�R�A�̕\�����X�V����
		call	score_update
		ret

; -----------------------------------------------------------------------------
;	�X�R�A��\��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, f, h, l
;	comment
;		�_�����ω������Ƃ��ɌĂяo��
; -----------------------------------------------------------------------------
score_update::
		; �_����\������
		ld		hl, PATTERN_NAME1 + 24 + 32*6
		call	SETWRT
		ld		hl, current_score
		call	score_outport
		; ���݂̓_���̓g�b�v�X�R�A���H
		ld		a, [current_is_top]
		or		a, a
		ret		z						; �g�b�v�X�R�A�łȂ���Ζ߂�
		; �g�b�v�X�R�A�̕\�����X�V����
		ld		hl, PATTERN_NAME1 + 24 + 32*2
		call	SETWRT
		ld		hl, current_score
		jp		score_outport

; -----------------------------------------------------------------------------
;	�g�b�v�X�R�A��\��
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, f, h, l
;	comment
;		�_�����ω������Ƃ��ɌĂяo��
; -----------------------------------------------------------------------------
score_update_high_score::
		; �g�b�v�X�R�A�̕\�����X�V����
		ld		hl, PATTERN_NAME1 + 24 + 32*2
		call	SETWRT
		ld		hl, high_score
		jp		score_outport

; -----------------------------------------------------------------------------
;	�X�R�A�ɉ��Z
;	input:
;		de	...	���Z����X�R�A[BCD����]
;	output
;		c�t���O
;			0: ����ɉ��Z�ł���
;			1: �J���X�g����
;	break
;		a, f, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
score_add::
		ld		hl, current_score + 3		; ���ʂ���A�N�Z�X����̂� +3
		; �ŉ���2��
		ld		a, [hl]		; ���t���O�s��
		add		a, e
		daa					; BCD�����̉��Z�␳
		ld		[hl],a		; �X�V
		dec		hl			; ���t���O�s��
		; ����2��
		ld		a, [hl]		; ���t���O�s��
		adc		a, d		; �ŉ��ʂ���̌��オ����l������
		daa					; BCD�����̉��Z�␳
		ld		[hl],a		; �X�V
		dec		hl			; ���t���O�s��
		; ����2��
		ld		a, [hl]		; ���t���O�s��
		adc		a, 0		; �ŉ��ʂ���̌��オ����l������
		daa					; BCD�����̉��Z�␳
		ld		[hl],a		; �X�V
		dec		hl			; ���t���O�s��
		; ����2��
		ld		a, [hl]		; ���t���O�s��
		adc		a, 0		; �ŉ��ʂ���̌��オ����l������
		daa					; BCD�����̉��Z�␳
		ld		[hl],a		; �X�V
		ret		nc			; �I�[�o�[�t���[���Ă��Ȃ���Δ�����
		; �I�[�o�[�t���[�̏��� [99999999 �ɂ���]
		ld		hl, 0x9999
		ld		[current_score + 0], hl
		ld		[current_score + 2], hl
		ret

; -----------------------------------------------------------------------------
;	BCD�����̃X�R�A�� VDP �֓]��
;	input:
;		hl	...	BCD�`���̃X�R�A�f�[�^�̃A�h���X
;	output
;		�Ȃ�
;	break
;		a, f, b, h, l
;	comment
;		SETWR���ŁAVDP��VRAM�A�h���X�ݒ肵����ԂŌĂяo��
; -----------------------------------------------------------------------------
score_outport:
		xor		a, a
		ld		b, 4
score_outport_loop:
		rld
		inc		a
		out		[VDP_VRAM_IO], a
		dec		a
		rld
		inc		a
		out		[VDP_VRAM_IO], a
		dec		a
		rld
		inc		hl
		djnz	score_outport_loop
		ret

; -----------------------------------------------------------------------------
;	BCD�����̃X�R�A�� ������ �֓]��
;	input:
;		hl	...	BCD�`���̃X�R�A�f�[�^�̃A�h���X
;		de	... �]���惁����
;	output
;		�Ȃ�
;	break
;		a, f, b, d, e, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
score_memput::
		xor		a, a
		ld		b, 4
score_memput_loop:
		rld
		inc		a
		ld		[de], a
		inc		de
		dec		a
		rld
		inc		a
		ld		[de], a
		inc		de
		dec		a
		rld
		inc		hl
		djnz	score_memput_loop
		ret

; -----------------------------------------------------------------------------
;	�X�R�A�̑召��r
;	input:
;		hl	...	�X�R�A1�̃A�h���X
;		de	...	�X�R�A2�̃A�h���X
;	output
;		c�t���O
;			0: de �� hl, 1: de < hl
;		z�t���O
;			0: de �� hl, 1: de = hl
;	break
;		a, f, d, e, h, l
;	comment
;		cp [de], [hl] �݂����Ȃ���
; -----------------------------------------------------------------------------
score_compare::
		; ��ԏ�̂Q��
		ld		a, [de]
		cp		a, [hl]
		daa
		ret		nz			; �s��v�̏ꍇ�͂����Ŋm��
		inc		hl			; ���t���O�s��
		inc		de			; ���t���O�s��
		; ���̂Q��
		ld		a, [de]
		cp		a, [hl]
		daa
		ret		nz			; �s��v�̏ꍇ�͂����Ŋm��
		inc		hl			; ���t���O�s��
		inc		de			; ���t���O�s��
		; ���̂Q��
		ld		a, [de]
		cp		a, [hl]
		daa
		ret		nz			; �s��v�̏ꍇ�͂����Ŋm��
		inc		hl			; ���t���O�s��
		inc		de			; ���t���O�s��
		; ���̂Q��
		ld		a, [de]
		cp		a, [hl]
		daa
		ret

; -----------------------------------------------------------------------------
;	���݂̃X�R�A���g�b�v�X�R�A���ǂ�������
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, f, d, e, h, l
;	comment
;		�Ȃ�
; -----------------------------------------------------------------------------
top_score_check::
		; ���Ƀg�b�v�X�R�A�����Ȃ牽�����Ȃ�
		ld		a, [current_is_top]
		or		a, a
		ret		nz
		; ���݂̃X�R�A�ƃg�b�v�X�R�A���r����
		ld		de, current_score
		ld		hl, high_score
		call	score_compare
		ret		c
		; ���݂̃X�R�A���g�b�v�X�R�A�𒴂��Ă�����t���O�𗧂Ă�
		ld		a, 1
		ld		[current_is_top], a
		ret

; -----------------------------------------------------------------------------
;	���݂̃X�R�A���n�C�X�R�A�ɓo�^
;	input:
;		�Ȃ�
;	output
;		�Ȃ�
;	break
;		a, f, d, e, h, l
;	comment
;		�}���\�[�g�ɂ�胉���N���ʂ��ێ�����
; -----------------------------------------------------------------------------
update_score_ranking::
		; �����N�C���������ǂ�������
		ld		hl, high_score
		ld		b, 10
update_score_ranking_check_loop:
		; ���݂̃X�R�A�ƃn�C�X�R�A���r����
		push	hl
		ld		de, current_score
		ex		de, hl
		call	score_compare						; cp �n�C�X�R�A, ���݂̃X�R�A
		pop		hl
		jr		c, update_score_rankin				; ���݂̃X�R�A�̕����傫����΃����N�C���Ɣ���
		ld		de, 8								; �n�C�X�R�A�P���� 8byte
		add		hl, de								; ���̃n�C�X�R�A�A�h���X
		djnz	update_score_ranking_check_loop
		ld		a, 0								; �����N�C�����Ȃ�����
		ret

		; �����N�C������
update_score_rankin:
		push	bc									; �����N�C���������ʂ�ێ�
		push	hl									; ���݂̃X�R�A��}������A�h���X��ۑ�
		; ��10�ʂɃ����N�C�������̂��H
		ld		a, b
		dec		a
		jp		z, update_score_rankin_skip_shift	; �����N���������̏ꍇ�͂��炷�������X�L�b�v
		; �����N���������X�R�A�����炷
		rlca										; bc = a * 8
		rlca
		rlca
		ld		c, a
		ld		b, 0
		ld		hl, high_score + 8*8 + 7
		ld		de, high_score + 8*9 + 7
		lddr
update_score_rankin_skip_shift:
		; ���݂̃X�R�A��}������
		pop		de
		ld		hl, current_score
		ld		bc, 8
		ldir
		pop		bc									; b = �����N�C������[10=1��, 9=2�� ... 1=10��]
		ld		a, 11
		sub		a, b
		ret

; -----------------------------------------------------------------------------
current_is_top:
		db		0			; current_score �� high_score �̑�P�ʂ𒴂����ꍇ 1 �ɂ���

; -----------------------------------------------------------------------------
;	�_���e�[�u��[BCD����, �\���̓s���� BigEndian, 8��]
; -----------------------------------------------------------------------------
current_score:
		db		0x00, 0x00, 0x00, 0x00
current_score_name::
		db		29, 13, 11, 0

high_score::
		db		0x00, 0x00, 0x50, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x40, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x30, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x20, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x18, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x15, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x12, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x10, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x08, 0x00, 11, 11, 11, 0
		db		0x00, 0x00, 0x05, 0x00, 11, 11, 11, 0
