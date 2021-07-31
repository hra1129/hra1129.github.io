// --------------------------------------------------------------------
//	RomDiskCreator
// ====================================================================
//	2020/07/02	t.hara
// --------------------------------------------------------------------

#pragma once

extern unsigned char boot_sector_image[];

static const unsigned int	BPB_BytePerSec	= 0x0200;	//	1[ sector ] = 512[ byte ]
static const unsigned int	BPB_SecPerClus	= 0x01;		//	1[ cluster ] = 1[ sector ]
static const unsigned int	BPB_RsvdSecCnt	= 0x0001;	//	1�Œ�B�\��̈�̃Z�N�����B
static const unsigned int	BPB_NumFATs		= 0x01;		//	FAT�� 1�̂݁B
static const unsigned int	BPB_RootEntCnt	= 0x0020;	//	���[�g�f�B���N�g���̃G���g�����B32�B
static const unsigned int	BPB_TotSec16	= 0x0800;	//	���Z�N�^���B1049600[ byte ]�̃f�B�X�N�̈����B
static const unsigned int	BPB_Media		= 0xFF;		//	���f�B�AID, ���Ӗ��Ȓl�H
static const unsigned int	BPB_FATSz16		= 0x0006;	//	FAT�� 6[ sector ] �ō\���B
static const unsigned int	BPB_SecPerTrk	= 0x0800;	//	1�g���b�N�̃Z�N�^���B���̃f�B�X�N�� 1�g���b�N�\���H
