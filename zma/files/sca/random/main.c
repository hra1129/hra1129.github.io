/* ----------------------------------------------------- */
/*	—”¶¬ƒeƒXƒg										 */
/*	2009/09/17 t.hara									 */
/* ----------------------------------------------------- */

#include <stdio.h>

static int last_random = 0;

/* ----------------------------------------------------- */
static int random( void ) {

	last_random = (((last_random >> 1) | ((~last_random) << 15)) ^ (~last_random & 0x1529)) & 0xFFFF;
	return last_random;
}

/* ----------------------------------------------------- */
int main( int argc, char *argv[] ) {
	int i, r;

	for( i = 0; i < 1000; i++ ) {
		r = random();
		printf( "%d\t%d\n", r, r & 3 );
	}
	return 0;
}
