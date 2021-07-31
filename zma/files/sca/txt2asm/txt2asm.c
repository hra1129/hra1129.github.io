/* ----------------------------------------------------- */
/*	ASCII文字をSCAのソースに変換する					 */
/* ===================================================== */
/*	2009/12/19	t.hara									 */
/* ----------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

/* ----------------------------------------------------- */
static void usage( const char *p_name ) {

	printf( "Usage> %s <in.txt> <out.asm>\n", p_name );
}

/* ----------------------------------------------------- */
static void txt_to_asm( FILE *p_out, FILE *p_in ) {
	char s_line[1024], *p;
	int i, len;

	while( !feof( p_in ) ) {
		if( fgets( s_line, sizeof(s_line), p_in ) == NULL ) {
			break;
		}
		fprintf( p_out, "\t\t; %s\n", s_line );
		fprintf( p_out, "\t\t.db\t\t" );
		p = s_line;
		len = strlen( p ) - 1;				/* \n の分をひとつ引く */
		fprintf( p_out, "#%-3d", len );
		for( i = 0; i < len; i++ ) {
			*p = toupper( *p & 255 );
			if( *p >= 'A' && *p <= 'Z' ) {
				*p = *p - 'A' + 11;
			}
			else if( *p >= '0' && *p <= '9' ) {
				*p = *p - '0' + 1;
			}
			else if( *p == ' ' ) {
				*p = 0;
			}
			else if( *p == '!' ) {
				*p = 37;
			}
			else if( *p == '.' ) {
				*p = 40;
			}
			else {
				printf( "使用不可能な文字 \'%c\' が使用されています\n", *p );
				*p = 0;
			}
			fprintf( p_out, ", #%-2d", *p );
			p++;
		}
		fprintf( p_out, "\n" );
	}
}

/* ----------------------------------------------------- */
int main( int argc, char *argv[] ) {
	FILE *p_in, *p_out;

	printf( "txt2asm\n" );
	printf( "===========================================\n" );
	printf( "2009/12/19 t.hara\n" );
	if( argc < 3 ) {
		usage( argv[0] );
		return 1;
	}

	p_in = fopen( argv[1], "r" );
	if( p_in == NULL ) {
		printf( "ERROR: %s を開けません\n", p_in );
		return 2;
	}
	p_out = fopen( argv[2], "w" );
	if( p_out == NULL ) {
		fclose( p_in );
		printf( "ERROR: %s を作れません\n", p_out );
		return 3;
	}
	txt_to_asm( p_out, p_in );
	fclose( p_out );
	fclose( p_in );
	return 0;
}
