// --------------------------------------------------------------------
//	Frontend of CS5 codec
// ====================================================================
//	2019/09/23	t.hara
// --------------------------------------------------------------------
#include <iostream>
#include <algorithm>
#include <string>
#include "cs5codec.hpp"

// --------------------------------------------------------------------
static void usage( const char *p_name ) {
	std::cout << "Usage1> " << p_name << " [options] <input.sc5> <output.cs5>" << std::endl;
	std::cout << "Usage2> " << p_name << " -decode <input.cs5> <output.sc5>" << std::endl;
	std::cout << std::endl;
	std::cout << "options" << std::endl;
	std::cout << "  -help ....... Display this message." << std::endl;
	std::cout << "  -sc5 ........ Target screen mode is SCREEN5 (default: SCREEN5)." << std::endl;
	std::cout << "  -sc7 ........ Target screen mode is SCREEN7 (default: SCREEN5)." << std::endl;
	std::cout << "  -width n .... Set target width (default: 256)." << std::endl;
	std::cout << "  -height n ... Set target height (default: 212)." << std::endl;
	std::cout << "  -left n ..... Set target left position (default: 0)." << std::endl;
	std::cout << "  -top n ...... Set target top position (default: 0)." << std::endl;
	std::cout << "  -palette .... Output palette data (default: without palette data)." << std::endl;
	std::cout << "  -log ........ Output information (default: without log)." << std::endl;
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int i, c, screen, width, height;
	bool with_palette, has_log;
	std::string arg;
	cs5encoder encoder;
	cs5decoder decoder;
	bool is_encode = true;

	std::cout << "CS5 Codec" << std::endl;
	std::cout << "=====================================================" << std::endl;
	std::cout << "Programmed by (C)2019 t.hara" << std::endl;

	if( argc < 1 ) {
		usage( argv[0] );
		return 1;
	}

	try {
		c = 0;
		screen = 5;
		width = -1;
		height = 212;
		with_palette = false;
		has_log = false;
		for( i = 1; i < argc; i++ ) {
			arg = argv[i];
			if( arg == "-help" ) {
				usage( argv[0] );
				return 1;
			}
			else if( arg == "-sc5" ) {
				encoder.set_target_screen_mode( 5 );
				decoder.set_target_screen_mode( 5 );
				screen = 5;
			}
			else if( arg == "-sc7" ) {
				encoder.set_target_screen_mode( 7 );
				decoder.set_target_screen_mode( 7 );
				screen = 7;
			}
			else if( arg == "-left" ) {
				i++;
				if( i >= argc ) {
					throw std::invalid_argument( "Missing arguments." );
				}
				arg = argv[i];
				encoder.set_left( std::stoi(arg) );
			}
			else if( arg == "-top" ) {
				i++;
				if( i >= argc ) {
					throw std::invalid_argument( "Missing arguments." );
				}
				arg = argv[i];
				encoder.set_top( std::stoi( arg ) );
			}
			else if( arg == "-width" ) {
				i++;
				if( i >= argc ) {
					throw std::invalid_argument( "Missing arguments." );
				}
				arg = argv[i];
				width = std::stoi( arg );
				encoder.set_width( width );
			}
			else if( arg == "-height" ) {
				i++;
				if( i >= argc ) {
					throw std::invalid_argument( "Missing arguments." );
				}
				arg = argv[i];
				height = std::stoi( arg );
				encoder.set_height( height );
			}
			else if( arg == "-palette" ) {
				encoder.set_with_palette( true );
				with_palette = true;
			}
			else if( arg == "-decode" ) {
				is_encode = false;
			}
			else if( arg == "-log" ) {
				encoder.set_output_log( true );
				decoder.set_output_log( true );
				has_log = true;
			}
			else {
				if( c == 0 ) {
					encoder.set_input_file_name( arg.c_str() );
					decoder.set_input_file_name( arg.c_str() );
					c++;
				}
				else if( c == 1 ) {
					encoder.set_output_file_name( arg.c_str() );
					decoder.set_output_file_name( arg.c_str() );
					c++;
				}
				else {
					throw std::invalid_argument( "Too many arguments" );
				}
			}
		}
		if( c < 2 ) {
			usage( argv[0] );
			return 1;
		}
	}
	catch( std::invalid_argument& e ) {
		std::cerr << e.what() << std::endl;
		return 1;
	}
	if( width <= 0 ) {
		if( screen == 5 ) {
			width = 256;
		}
		else {
			width = 512;
		}
	}
	std::cout << std::endl;
	std::cout << "Screen  = " << screen << std::endl;
	std::cout << "Width   = " << width << std::endl;
	std::cout << "Height  = " << height << std::endl;
	std::cout << "Palette = " << (with_palette ? "Attached" : "None") << std::endl;
	std::cout << "Log     = " << (has_log ? "Enable" : "Disable") << std::endl;
	std::cout << std::endl;

	try {
		if( is_encode ) {
			encoder.run();
		}
		else {
			decoder.run();
		}
	}
	catch( std::runtime_error& e ) {
		std::cerr << e.what() << std::endl;
		return 1;
	}
	return 0;
}
