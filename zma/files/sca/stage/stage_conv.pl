#!/bin/perl -W
#------------------------------------------------------------------------------
#	Excel����e�L�X�g�t�@�C���ɓ\��t�����X�e�[�W�f�[�^�̃��C�����㉺����ւ���	
#	���߂� perl �X�N���v�g�BActivePerl 5.8.8 �g�p�B 
#
#	usage> perl -w stage_conv.pl ���̓t�@�C���� �o�̓t�@�C���� 
#------------------------------------------------------------------------------

# �t�@�C�������ׂēǂݍ��� 
open( INFILE, $ARGV[0] ) or die( "${ARGV[0]} ���J���Ȃ�\n" );
@stage_data = <INFILE>;
close( INFILE );

# �㉺�t���܂ɓ���ւ��āA�s���� \t\t.db\t\t# ������ 
@swap_stage_data = reverse( @stage_data );
for( $i = 0; $i < @swap_stage_data; $i++ ) {
	$swap_stage_data[$i] = "\t\t.db\t\t#". $swap_stage_data[$i];
}

# �t�@�C���֏����o�� 
open( OUTFILE, ">${ARGV[1]}" ) or die( "${ARGV[1]} �������o���Ȃ�\n" );
print OUTFILE @swap_stage_data;
close( OUTFILE );

print "�������܂���\n";
