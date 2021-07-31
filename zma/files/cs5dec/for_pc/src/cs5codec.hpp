// --------------------------------------------------------------------
//	CS5 codec
// ====================================================================
//	2019/09/23	t.hara
// --------------------------------------------------------------------

#pragma once

#include <stdexcept>
#include <string>
#include <vector>

// --------------------------------------------------------------------
class cs5palette {
public:
	int				red;
	int				green;
	int				blue;

	cs5palette(): red( 0 ), green( 0 ), blue( 0 ) {
	}
	cs5palette( int _red, int _green, int _blue ): red( _red ), green( _green ), blue( _blue ) {
	}
};

// --------------------------------------------------------------------
class cs5encode_item {
public:
	int								id;						//	0...15: pixcel, 16: copy from last data
	int								last_data_position;		//	copy position in last data
	int								length;					//	copy length
	int								repeat;					//	repeat count

	cs5encode_item(): id( 0 ), last_data_position( 0 ), length( 0 ), repeat( 0 ) {
	}
};

// --------------------------------------------------------------------
class cs5histgram {
public:
	int		bin;
	int		histgram;
	int		golomb;
	cs5histgram(): bin( 0 ), histgram( 0 ), golomb( 0 ) {
	}
};

// --------------------------------------------------------------------
class cs5encoder {
private:
	int								target_screen_mode;
	int								left;
	int								top;
	int								width;
	int								height;
	bool							with_palette;
	bool							output_log;
	std::string						input_file_name;
	std::string						output_file_name;
	std::vector< uint8_t >			image;
	std::vector< cs5palette >		palette = {
		{ 0, 0, 0 }, { 0, 0, 0 }, { 1, 6, 1 }, { 3, 7, 3 },
		{ 1, 1, 7 }, { 2, 3, 7 }, { 5, 1, 1 }, { 2, 6, 7 },
		{ 7, 1, 1 }, { 7, 3, 3 }, { 6, 6, 1 }, { 6, 6, 3 },
		{ 1, 4, 1 }, { 6, 2, 5 }, { 5, 5, 5 }, { 7, 7, 7 }
	};
	std::vector< uint8_t >			last_data_pixels;
	std::vector< cs5encode_item >	collect_data;
	std::vector< cs5histgram >		id_histgram;

	uint8_t							byte_buffer;
	int								byte_buffer_bits;

	int								last_data_index;

	void bload( const std::string p_name );
	void write_bits( std::ofstream &f, uint8_t d, int bits );
	void flush_bits( std::ofstream& f );
	void write_palette( std::ofstream& f );
	void initialize_last_data_pixels();
	int search_last_data_pixels( int index, int end_index );
	void put_last_data( uint8_t d );
	void makeup_histgram();
	void makeup_golomb( std::ofstream& f );
	void write_golomb( std::ofstream& f, int d );
public:

	// ----------------------------------------------------------------
	//	Constructor
	// ----------------------------------------------------------------
	cs5encoder(): target_screen_mode( 5 ), left( 0 ), top( 0 ), width( 256 ), height( 212 ), with_palette( true ), output_log( false ),
		input_file_name( "input.sc5" ), output_file_name( "output.cs5" ), byte_buffer(0), byte_buffer_bits(0), last_data_index(0) {
	}

	// ----------------------------------------------------------------
	//	Set methods
	// ----------------------------------------------------------------
	void set_target_screen_mode( int screen_mode ) {
		if( screen_mode != 5 && screen_mode != 7 ) {
			throw std::invalid_argument( "An invalid value was specified for the argument of cs5encoder::set_target_screen_mode()." );
		}
		target_screen_mode = screen_mode;
	}

	// --------------------------------------------------------------------
	void set_width( int w ) {
		if( w < 2 || w > 512 || (w & 1) != 0 ) {
			throw std::invalid_argument( "An invalid value was specified for the argument of cs5encoder::set_width()." );
		}
		width = w;
	}

	// --------------------------------------------------------------------
	void set_height( int h ) {
		if( h < 1 || h > 212 ) {
			throw std::invalid_argument( "An invalid value was specified for the argument of cs5encoder::set_height()." );
		}
		height = h;
	}

	// --------------------------------------------------------------------
	void set_left( int l ) {
		if( l < 0 || l > 512 ) {
			throw std::invalid_argument( "An invalid value was specified for the argument of cs5encoder::set_left()." );
		}
		left = l;
	}

	// --------------------------------------------------------------------
	void set_top( int t ) {
		if( t < 0 || t > 212 ) {
			throw std::invalid_argument( "An invalid value was specified for the argument of cs5encoder::set_top()." );
		}
		top = t;
	}

	// --------------------------------------------------------------------
	void set_with_palette( bool p ) {
		with_palette = p;
	}

	// --------------------------------------------------------------------
	void set_input_file_name( const char* p_name ) {
		input_file_name = p_name;
	}

	// --------------------------------------------------------------------
	void set_output_file_name( const char* p_name ) {
		output_file_name = p_name;
	}

	// --------------------------------------------------------------------
	void set_output_log( bool o ) {
		output_log = o;
	}

	// --------------------------------------------------------------------
	//	run
	//	input)
	//		none
	//	output)
	//		none
	//	comment)
	//		Run encoding process.
	// --------------------------------------------------------------------
	void run( void );
};

// --------------------------------------------------------------------
class cs5decoder {
private:
	int								target_screen_mode;
	int								width;
	int								height;
	bool							with_palette;
	bool							output_log;
	std::string						input_file_name;
	std::string						output_file_name;
	std::vector< uint8_t >			image;
	std::vector< cs5palette >		palette = {
		{ 0, 0, 0 }, { 0, 0, 0 }, { 1, 6, 1 }, { 3, 7, 3 },
		{ 1, 1, 7 }, { 2, 3, 7 }, { 5, 1, 1 }, { 2, 6, 7 },
		{ 7, 1, 1 }, { 7, 3, 3 }, { 6, 6, 1 }, { 6, 6, 3 },
		{ 1, 4, 1 }, { 6, 2, 5 }, { 5, 5, 5 }, { 7, 7, 7 }
	};
	std::vector< uint8_t >			last_data_pixels;
	std::vector< int >				golomb_table;

	uint8_t							byte_buffer;
	int								byte_buffer_bits;

	int								last_data_index;

	void bsave( const std::string p_name );
	int read_bits( std::ifstream& f, int bits );
	void read_palette( std::ifstream& f );
	void read_golomb_table( std::ifstream& f );
	void read_body( std::ifstream& f, int size );
	void initialize_last_data_pixels();
	void put_last_data( uint8_t d );
	int read_golomb( std::ifstream& f );
public:

	// ----------------------------------------------------------------
	//	Constructor
	// ----------------------------------------------------------------
	cs5decoder(): target_screen_mode( 5 ), width( 0 ), height( 0 ), with_palette( true ), output_log( false ), 
		input_file_name( "input.sc5" ), output_file_name( "output.cs5" ), byte_buffer(0), byte_buffer_bits(0), last_data_index(0) {
	}

	// ----------------------------------------------------------------
	//	Set methods
	// ----------------------------------------------------------------
	void set_target_screen_mode( int screen_mode ) {
		if( screen_mode != 5 && screen_mode != 7 ) {
			throw std::invalid_argument( "An invalid value was specified for the argument of cs5decoder::set_target_screen_mode()." );
		}
		target_screen_mode = screen_mode;
	}

	// --------------------------------------------------------------------
	void set_with_palette( bool p ) {
		with_palette = p;
	}

	// --------------------------------------------------------------------
	void set_input_file_name( const char* p_name ) {
		input_file_name = p_name;
	}

	// --------------------------------------------------------------------
	void set_output_file_name( const char* p_name ) {
		output_file_name = p_name;
	}

	// --------------------------------------------------------------------
	void set_output_log( bool o ) {
		output_log = o;
	}

	// --------------------------------------------------------------------
	//	run
	//	input)
	//		none
	//	output)
	//		none
	//	comment)
	//		Run decoding process.
	// --------------------------------------------------------------------
	void run( void );
};