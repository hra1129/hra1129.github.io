#!/bin/perl -W
#------------------------------------------------------------------------------
#	Excelからテキストファイルに貼り付けたステージデータのラインを上下入れ替える	
#	ための perl スクリプト。ActivePerl 5.8.8 使用。 
#
#	usage> perl -w stage_conv.pl 入力ファイル名 出力ファイル名 
#------------------------------------------------------------------------------

# ファイルをすべて読み込む 
open( INFILE, $ARGV[0] ) or die( "${ARGV[0]} を開けない\n" );
@stage_data = <INFILE>;
close( INFILE );

# 上下逆さまに入れ替えて、行頭に \t\t.db\t\t# をつける 
@swap_stage_data = reverse( @stage_data );
for( $i = 0; $i < @swap_stage_data; $i++ ) {
	$swap_stage_data[$i] = "\t\t.db\t\t#". $swap_stage_data[$i];
}

# ファイルへ書き出す 
open( OUTFILE, ">${ARGV[1]}" ) or die( "${ARGV[1]} を書き出せない\n" );
print OUTFILE @swap_stage_data;
close( OUTFILE );

print "完了しました\n";
