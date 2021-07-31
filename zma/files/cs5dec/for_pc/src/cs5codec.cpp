// --------------------------------------------------------------------
//	CS5 codec
// ====================================================================
//	2019/09/23	t.hara
// --------------------------------------------------------------------

#include <iostream>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>
#include <algorithm>
#include "cs5codec.hpp"

static const int MAX_REPEAT = 128;
static const int MAX_LENGTH = 255;
static const int MIN_LENGTH = 3;

// --------------------------------------------------------------------
void cs5encoder::bload( const std::string p_name ) {
	std::ifstream file;
	std::vector< uint8_t > file_image;
	int x, y, px, py, w, d, i, palette_address;

	file_image.resize( 0x10000 );
	file.open( p_name, std::ios::binary );
	if( !file ) {
		throw std::runtime_error( std::string( "ERROR: Cannot open the '" ) + p_name + "'." );
	}
	file.read( (char*) &file_image[0], 7 );
	file.read( (char*) &file_image[0], (int) file_image.size() );
	file.close();

	int size = this->width * this->height;
	if( this->target_screen_mode == 5 ) {
		w = 128;
		palette_address = 0x7680;
	}
	else {
		w = 256;
		palette_address = 0xFA80;
	}
	i = 0;
	image.resize( size );
	for( y = 0; y < this->height; y++ ) {
		py = this->top + y;
		if( py > this->height ) {
			py = this->height - 1;
		}
		for( x = 0; x < this->width; x++ ) {
			px = this->left + x;
			if( px > this->width ) {
				px = this->width - 1;
			}
			d = file_image[(px >> 1) + py * w];
			if( (px & 1) == 0 ) {
				d = d >> 4;
			}
			else {
				d = d & 15;
			}
			image[i] = d;
			i++;
		}
	}
	if( this->with_palette ) {
		palette.clear();
		palette.resize( 16 );
		for( i = 0; i < 16; i++ ) {
			d = file_image[palette_address + i * 2 + 0];
			palette[i].red   = (d >> 4) & 7;
			palette[i].blue  = d & 7;
			d = file_image[palette_address + i * 2 + 1];
			palette[i].green = d & 7;
		}
	}
}

// --------------------------------------------------------------------
void cs5encoder::write_bits( std::ofstream &f, uint8_t d, int bits ) {
	int i;

	for( i = 0; i < bits; i++ ) {
		this->byte_buffer = (this->byte_buffer << 1) | (d >> 7);
		this->byte_buffer_bits++;
		if( this->byte_buffer_bits >= 8 ) {
			f.write( (char*) &(this->byte_buffer), 1 );
			this->byte_buffer = 0;
			this->byte_buffer_bits = 0;
		}
		d = (d << 1) & 255;
	}
}

// --------------------------------------------------------------------
void cs5encoder::flush_bits( std::ofstream& f ) {
	int i;

	if( this->byte_buffer_bits == 0 ) {
		return;
	}
	for( i = this->byte_buffer_bits; i < 8; i++ ) {
		this->byte_buffer = this->byte_buffer << 1;
	}
	f.write( (char*) & (this->byte_buffer), 1 );
	this->byte_buffer = 0;
	this->byte_buffer_bits = 0;
}

// --------------------------------------------------------------------
void cs5encoder::write_palette( std::ofstream& f ) {
	int i;

	this->write_bits( f, 0b10000000, 2 );
	for( i = 0; i < 16; i++ ) {
		this->write_bits( f, palette[i].red   << 5, 3 );
		this->write_bits( f, palette[i].blue  << 5, 3 );
		this->write_bits( f, palette[i].green << 5, 3 );
	}
}

// --------------------------------------------------------------------
void cs5encoder::initialize_last_data_pixels() {

	this->last_data_pixels.resize( 256 );
	this->last_data_index = 0;
	for( int i = 0; i < 256; i++ ) {
		this->last_data_pixels[i] = (uint8_t) (i >> 4);
	}
}

// --------------------------------------------------------------------
void cs5encoder::put_last_data( uint8_t d ) {
	this->last_data_pixels[this->last_data_index] = d;
	this->last_data_index = (this->last_data_index + 1) & 255;
}

// --------------------------------------------------------------------
int cs5encoder::search_last_data_pixels( int index, int end_index ) {
	int i, j, position, length, max_length, repeat, check_position;
	bool is_matched = false;
	cs5encode_item item;

	max_length = end_index - index;
	if( max_length > MAX_LENGTH ) {
		max_length = MAX_LENGTH;
	}
	//	List all possible positions in last_data_pixels.
	for( length = max_length; length >= MIN_LENGTH; length-- ) {
		is_matched = false;
		for( position = 0; position < (256 - length); position++ ) {
			for( i = 0; i < length; i++ ) {
				if( this->image[index + i] != this->last_data_pixels[(this->last_data_index + position + i) & 255] ) {
					break;
				}
			}
			if( i == length ) {
				is_matched = true;
				break;
			}
		}
		if( !is_matched ) {
			continue;
		}
		//	Count the number of repetitions
		check_position = index + length;
		for( repeat = 0; repeat < MAX_REPEAT; repeat++ ) {
			if( (check_position + length) > end_index ) {
				break;
			}
			for( i = 0; i < length; i++ ) {
				if( this->image[index + i] != this->image[check_position + i] ) {
					break;
				}
			}
			if( i < length ) {
				break;
			}
			check_position += length;
		}
		if( (length * repeat) > ( item.length * item.repeat ) ) {
			item.last_data_position = position;
			item.length = length;
			item.repeat = repeat;
		}
	}
	if( item.length == 0 ) {
		item.id = (int) this->image[index];
		this->collect_data.push_back( item );
		this->put_last_data( this->image[index] );
		return 1;
	}
	item.id = 16;
	//	Update last data
	length = item.length;
	repeat = item.repeat;
	for( i = 0; i <= repeat; i++ ) {
		for( j = 0; j < length; j++ ) {
			this->put_last_data( this->image[index + j] );
		}
	}
	this->collect_data.push_back( item );
	return length * (repeat + 1);
}

// --------------------------------------------------------------------
void cs5encoder::makeup_histgram() {
	int i;

	this->id_histgram.clear();

	this->id_histgram.resize( 17 );

	for( i = 0; i < 17; i++ ) {
		this->id_histgram[i].bin = i;
		this->id_histgram[i].histgram = 0;
	}
	for( auto& item : this->collect_data ) {
		this->id_histgram[item.id].histgram++;
	}
}

// --------------------------------------------------------------------
void cs5encoder::makeup_golomb( std::ofstream &f ) {
	int i;

	this->write_bits( f, 0b11000000, 2 );
	std::sort( this->id_histgram.begin(), this->id_histgram.end(), []( const cs5histgram& a, const cs5histgram& b ) {
		return a.histgram > b.histgram;
		} );
	for( i = 0; i < 17; i++ ) {
		this->write_bits( f, this->id_histgram[i].bin << 3, 5 );
		this->id_histgram[i].golomb = i;
	}
	std::sort( this->id_histgram.begin(), this->id_histgram.end(), []( const cs5histgram& a, const cs5histgram& b ) {
		return a.bin < b.bin;
		} );

	if( this->output_log ) {
		std::cout << "<< GOLOMB >>" << std::endl;
		for( i = 0; i < 17; i++ ) {
			std::cout << "  ID#" << i << ": hist = " << this->id_histgram[i].histgram << " --> golomb#" << this->id_histgram[i].golomb << std::endl;
		}
	}
}

// --------------------------------------------------------------------
void cs5encoder::write_golomb( std::ofstream& f, int d ) {
	int q, m;

	m = d % 3;
	q = d / 3;
	while( q > 0 ) {
		if( q > 8 ) {
			this->write_bits( f, 0, 8 );
			q -= 8;
		}
		else {
			this->write_bits( f, 0, q );
			q = 0;
		}
	}
	switch( m ) {
	case 0:
		this->write_bits( f, 0b10000000, 2 );
		break;
	case 1:
		this->write_bits( f, 0b11000000, 3 );
		break;
	default:
		this->write_bits( f, 0b11100000, 3 );
		break;
	}
}

// --------------------------------------------------------------------
void cs5encoder::run( void ) {
	std::ofstream file;
	int index, size, golomb;

	bload( this->input_file_name );

	this->byte_buffer = 0;
	this->byte_buffer_bits = 0;
	file.open( this->output_file_name, std::ios::binary );
	if( !file ) {
		throw std::runtime_error( std::string( "ERROR: Cannot create the '" ) + this->output_file_name + "'." );
	}

	this->write_bits( file, (this->width >> 1) - 1, 8 );
	this->write_bits( file,  this->height      - 1, 8 );
	if( this->with_palette ) {
		this->write_palette( file );
	}
	//	search pass
	size = (int) this->image.size();
	this->initialize_last_data_pixels();
	for( index = 0; index < size; ) {
		if( (index & 255) == 0 ) {
			std::cerr << index << "/" << size << "[pixel]\r";
		}
		index += this->search_last_data_pixels( index, size );
	}
	std::cerr << index << "/" << size << "[pixel]\r";
	//	makeup histgram
	this->makeup_histgram();
	//	makeup golomb code
	this->makeup_golomb( file );
	//	write image data
	if( this->output_log ) {
		std::cout << "<< BODY >>" << std::endl;
	}
	this->write_bits( file, 0b00000000, 1 );
	for( auto item : collect_data ) {
		if( this->output_log ) {
			std::cout << "ID# " << item.id << ": ";
		}
		golomb = this->id_histgram[item.id].golomb;
		if( this->output_log ) {
			std::cout << "Golomb#" << golomb;
		}
		this->write_golomb( file, golomb );
		if( item.id == 16 ) {
			this->write_bits( file, (uint8_t) item.last_data_position, 8 );
			this->write_golomb( file, item.length - MIN_LENGTH );
			this->write_golomb( file, item.repeat );
			if( this->output_log ) {
				std::cout << ": POS = " << item.last_data_position << ": LEN = " << item.length << ": REP = " << item.repeat;
			}
		}
		if( this->output_log ) {
			std::cout << std::endl;
		}
	}
	this->flush_bits( file );
}

// --------------------------------------------------------------------
void cs5decoder::bsave( const std::string p_name ) {
	std::vector< uint8_t > vram;
	std::ofstream file;
	int x, y, d, palette_address = 0, line_size, index, vram_address, end_address;

	if( this->target_screen_mode == 5 ) {
		if( this->with_palette ) {
			vram.resize( 7 + 0x76A0 );
			palette_address = 0x7680;
			end_address = 0x769F;
		}
		else {
			vram.resize( 7 + 0x6A00 );
			end_address = 0x69FF;
		}
		line_size = 128;
	}
	else {
		if( this->with_palette ) {
			vram.resize( 7 + 0xFAA0 );
			palette_address = 0xFA80;
			end_address = 0xFA9F;
		}
		else {
			vram.resize( 7 + 0xD400 );
			end_address = 0xD3FF;
		}
		line_size = 256;
	}
	vram[0] = 0xFE;
	vram[1] = 0;
	vram[2] = 0;
	vram[3] = end_address & 255;
	vram[4] = (uint8_t)(end_address >> 8);
	vram[5] = 0;
	vram[6] = 0;
	index = 0;
	x = 0;
	y = 0;
	while( index < (int)this->image.size() ) {
		d = ((int) this->image[index + 0] << 4) | (int) this->image[index + 1];
		vram_address = x >> 1;
		index += 2;
		if( vram_address < line_size ) {
			vram_address += line_size * y;
			vram[7 + vram_address] = (uint8_t) d;
		}
		x+=2;
		if( x >= this->width ) {
			x = 0;
			y++;
			if( y >= 212 ) {
				break;
			}
		}
	}
	if( this->with_palette && (this->palette.size() >= 16) ) {
		for( int i = 0; i < 16; i++ ) {
			vram[7 + (palette_address++)] = (this->palette[i].red << 4) | this->palette[i].blue;
			vram[7 + (palette_address++)] = this->palette[i].green;
		}
	}
	file.open( this->output_file_name, std::ios::binary );
	if( !file ) {
		throw std::runtime_error( std::string( "ERROR: Cannot create the '" ) + this->output_file_name + "'." );
	}
	file.write( ( char*) &vram[0], vram.size() );
	file.close();
}

// --------------------------------------------------------------------
int cs5decoder::read_bits( std::ifstream& f, int bits ) {
	int r = 0;

	if( this->byte_buffer_bits < bits ) {
		r = this->byte_buffer >> (8 - this->byte_buffer_bits);
		bits -= this->byte_buffer_bits;
		this->byte_buffer_bits = 0;
		r <<= bits;
	}
	if( this->byte_buffer_bits == 0 ) {
		f.read( (char*) & (this->byte_buffer), 1 );
		this->byte_buffer_bits = 8;
	}
	if( bits ) {
		r = r | (this->byte_buffer >> (8 - bits));
		this->byte_buffer_bits -= bits;
		this->byte_buffer = (this->byte_buffer << bits) & 255;
	}
	return r;
}

// --------------------------------------------------------------------
void cs5decoder::read_palette( std::ifstream& f ) {
	int i;

	this->palette.clear();
	this->palette.resize( 16 );
	if( this->output_log ) {
		std::cout << "<< PALETTE >>" << std::endl;
	}
	for( i = 0; i < 16; i++ ) {
		this->palette[i].red	= this->read_bits( f, 3 );
		this->palette[i].blue	= this->read_bits( f, 3 );
		this->palette[i].green	= this->read_bits( f, 3 );
		if( this->output_log ) {
			std::cout << "  Palette#" << i << " = ( " << this->palette[i].red << ", " << this->palette[i].green << ", " << this->palette[i].blue << " )" << std::endl;
		}
	}
	if( this->output_log ) {
		std::cout << std::endl;
	}
}

// --------------------------------------------------------------------
void cs5decoder::read_golomb_table( std::ifstream& f ) {
	int i;

	this->golomb_table.clear();
	this->golomb_table.resize( 17 );
	if( this->output_log ) {
		std::cout << "<< GOLOMB >>" << std::endl;
	}
	for( i = 0; i < 17; i++ ) {
		this->golomb_table[i] = this->read_bits( f, 5 );
		if( this->golomb_table[i] >= 17 ) {
			throw std::runtime_error( "Invalid data in golomb table." );
		}
		if( this->output_log ) {
			std::cout << "  Golomb#" << i << " --> Id#" << this->golomb_table[i] << std::endl;
		}
	}
}

// --------------------------------------------------------------------
void cs5decoder::read_body( std::ifstream& f, int size ) {
	int id, golomb, index, source_index, repeat, length, i, j;
	uint8_t d;

	index = 0;
	if( this->output_log ) {
		std::cout << "<< BODY >>" << std::endl;
	}
	while( size > 0 ) {
		golomb = this->read_golomb( f );
		id = this->golomb_table[ golomb ];
		if( this->output_log ) {
			std::cout << "  Golomb#" << golomb << " --> ID#" << id;
		}
		if( id < 16 ) {
			this->image[index++] = id;
			this->put_last_data( ( uint8_t) id );
			size--;
			if( this->output_log ) {
				std::cout << std::endl;
			}
			continue;
		}
		source_index	= this->read_bits( f, 8 );
		length			= this->read_golomb( f ) + MIN_LENGTH;
		repeat			= this->read_golomb( f );
		if( this->output_log ) {
			std::cout << ": POS = " << source_index << ": LEN = " << length << ": REP = " << repeat << std::endl;
		}
		source_index = (source_index + this->last_data_index) & 255;
		for( i = 0; i < length; i++ ) {
			if( index >= (int) this->image.size() ) {
				break;
			}
			d = this->last_data_pixels[source_index++];
			this->image[index++] = d;
			source_index &= 255;
			this->put_last_data( d );
			size--;
		}
		source_index = (this->last_data_index - length) & 255;
		for( j = 0; j < repeat; j++ ) {
			for( i = 0; i < length; i++ ) {
				if( index >= (int) this->image.size() ) {
					break;
				}
				d = this->last_data_pixels[source_index++];
				this->image[index++] = d;
				source_index &= 255;
				this->put_last_data( d );
				size--;
			}
		}
	}
}

// --------------------------------------------------------------------
void cs5decoder::initialize_last_data_pixels() {

	this->last_data_pixels.resize( 256 );
	this->last_data_index = 0;
	for( int i = 0; i < 256; i++ ) {
		this->last_data_pixels[i] = ( uint8_t) (i >> 4);
	}
}

// --------------------------------------------------------------------
void cs5decoder::put_last_data( uint8_t d ) {
	this->last_data_pixels[this->last_data_index] = d;
	this->last_data_index = (this->last_data_index + 1) & 255;
}

// --------------------------------------------------------------------
int cs5decoder::read_golomb( std::ifstream& f ) {
	int q, m;

	q = 0;
	while( this->read_bits( f, 1 ) == 0 ) {
		q++;
		if( q > (MAX_LENGTH / 3) ) {
			break;
		}
	}
	if( this->read_bits( f, 1 ) == 0 ) {
		m = 0;
	}
	else if( this->read_bits( f, 1 ) == 0 ) {
		m = 1;
	}
	else {
		m = 2;
	}
	return (q * 3) + m;
}

// --------------------------------------------------------------------
void cs5decoder::run( void ) {
	std::ifstream file;
	int i;

	file.open( this->input_file_name, std::ios::binary );
	if( !file ) {
		throw std::runtime_error( std::string( "ERROR: Cannot open the '" ) + this->output_file_name + "'." );
	}
	//	Initialize
	this->golomb_table.clear();
	this->golomb_table.resize( 17 );
	for( i = 0; i < 17; i++ ) {
		this->golomb_table[i] = i;
	}
	//	Get image size
	this->width = this->read_bits( file, 8 );
	this->width = (this->width + 1) << 1;
	this->height = this->read_bits( file, 8 );
	this->height = this->height + 1;
	this->image.clear();
	this->image.resize( this->width * this->height );

	this->initialize_last_data_pixels();
	for( ;; ) {
		if( this->read_bits( file, 1 ) == 1 ) {
			if( this->read_bits( file, 1 ) == 0 ) {
				this->read_palette( file );
			}
			else {
				this->read_golomb_table( file );
			}
		}
		else {
			this->read_body( file, this->width * this->height );
			break;
		}
	}
	file.close();

	this->bsave( this->output_file_name );
}
