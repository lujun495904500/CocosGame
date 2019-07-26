/**
 *	@file	aeskeys.cpp
 *	@date	2018/12/14
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	AESÃÜÔ¿ÎÄ¼þ
 */
 
#include "aeskeys.h"
 
bool L::getAESKey(int index, const unsigned char* &retkey, const unsigned char* &retiv) {
	switch (index) {
	case 0:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x9F';
			key[1] = '\xB2';
			key[2] = '\x8B';
			key[3] = '\x75';
			key[4] = '\xDB';
			key[5] = '\x73';
			key[6] = '\x57';
			key[7] = '\x41';
			key[8] = '\x59';
			key[9] = '\xA5';
			key[10] = '\x08';
			key[11] = '\xFD';
			key[12] = '\xB2';
			key[13] = '\x91';
			key[14] = '\x89';
			key[15] = '\x40';
			
			// IV
			iv[0] = '\xFB';
			iv[1] = '\xEF';
			iv[2] = '\x8A';
			iv[3] = '\xBE';
			iv[4] = '\xD4';
			iv[5] = '\x13';
			iv[6] = '\xCF';
			iv[7] = '\xA0';
			iv[8] = '\xE6';
			iv[9] = '\x74';
			iv[10] = '\xEF';
			iv[11] = '\x9B';
			iv[12] = '\x71';
			iv[13] = '\x00';
			iv[14] = '\x30';
			iv[15] = '\xA0';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 1:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x11';
			key[1] = '\x34';
			key[2] = '\xFD';
			key[3] = '\x09';
			key[4] = '\x29';
			key[5] = '\xF1';
			key[6] = '\x51';
			key[7] = '\xD8';
			key[8] = '\x5D';
			key[9] = '\xA7';
			key[10] = '\x7E';
			key[11] = '\x33';
			key[12] = '\x34';
			key[13] = '\x95';
			key[14] = '\x00';
			key[15] = '\x7F';
			
			// IV
			iv[0] = '\xE7';
			iv[1] = '\x1A';
			iv[2] = '\x75';
			iv[3] = '\x82';
			iv[4] = '\xA7';
			iv[5] = '\x84';
			iv[6] = '\x9D';
			iv[7] = '\xB1';
			iv[8] = '\xB8';
			iv[9] = '\x28';
			iv[10] = '\xAF';
			iv[11] = '\x3B';
			iv[12] = '\x5B';
			iv[13] = '\xFB';
			iv[14] = '\x67';
			iv[15] = '\xEA';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 2:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x6B';
			key[1] = '\xFE';
			key[2] = '\xBB';
			key[3] = '\x93';
			key[4] = '\xF2';
			key[5] = '\x6B';
			key[6] = '\x6C';
			key[7] = '\x04';
			key[8] = '\x97';
			key[9] = '\x40';
			key[10] = '\x2C';
			key[11] = '\x54';
			key[12] = '\xAD';
			key[13] = '\x0C';
			key[14] = '\x2C';
			key[15] = '\xE3';
			
			// IV
			iv[0] = '\x8E';
			iv[1] = '\x39';
			iv[2] = '\x42';
			iv[3] = '\xBE';
			iv[4] = '\x4E';
			iv[5] = '\xEF';
			iv[6] = '\x4B';
			iv[7] = '\x3D';
			iv[8] = '\xD2';
			iv[9] = '\x44';
			iv[10] = '\x51';
			iv[11] = '\xBA';
			iv[12] = '\x77';
			iv[13] = '\xB0';
			iv[14] = '\xCE';
			iv[15] = '\x59';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 3:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x43';
			key[1] = '\xD8';
			key[2] = '\xE4';
			key[3] = '\xD7';
			key[4] = '\x7E';
			key[5] = '\x60';
			key[6] = '\xB7';
			key[7] = '\x68';
			key[8] = '\xBB';
			key[9] = '\x16';
			key[10] = '\x5C';
			key[11] = '\x39';
			key[12] = '\x9C';
			key[13] = '\x8A';
			key[14] = '\xC1';
			key[15] = '\x4B';
			
			// IV
			iv[0] = '\x33';
			iv[1] = '\xF7';
			iv[2] = '\x2F';
			iv[3] = '\xA5';
			iv[4] = '\xB3';
			iv[5] = '\x3B';
			iv[6] = '\x3D';
			iv[7] = '\xFC';
			iv[8] = '\x50';
			iv[9] = '\x28';
			iv[10] = '\xFD';
			iv[11] = '\xA7';
			iv[12] = '\x0D';
			iv[13] = '\x34';
			iv[14] = '\x18';
			iv[15] = '\x65';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 4:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x83';
			key[1] = '\x41';
			key[2] = '\x22';
			key[3] = '\x96';
			key[4] = '\x66';
			key[5] = '\x6B';
			key[6] = '\xE2';
			key[7] = '\x0E';
			key[8] = '\xDD';
			key[9] = '\x6E';
			key[10] = '\x97';
			key[11] = '\xFD';
			key[12] = '\x8F';
			key[13] = '\x86';
			key[14] = '\x48';
			key[15] = '\xC5';
			
			// IV
			iv[0] = '\x89';
			iv[1] = '\x8C';
			iv[2] = '\xBF';
			iv[3] = '\x3E';
			iv[4] = '\xE3';
			iv[5] = '\x0D';
			iv[6] = '\xB6';
			iv[7] = '\x0E';
			iv[8] = '\xC3';
			iv[9] = '\x1A';
			iv[10] = '\xAD';
			iv[11] = '\x66';
			iv[12] = '\xDD';
			iv[13] = '\xC2';
			iv[14] = '\x0D';
			iv[15] = '\xC1';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 5:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xCA';
			key[1] = '\xE9';
			key[2] = '\xDD';
			key[3] = '\xE9';
			key[4] = '\xE3';
			key[5] = '\xF7';
			key[6] = '\x12';
			key[7] = '\xE4';
			key[8] = '\x93';
			key[9] = '\x02';
			key[10] = '\xF3';
			key[11] = '\xC9';
			key[12] = '\xE5';
			key[13] = '\x44';
			key[14] = '\xF2';
			key[15] = '\xB1';
			
			// IV
			iv[0] = '\x34';
			iv[1] = '\x00';
			iv[2] = '\xA5';
			iv[3] = '\xE1';
			iv[4] = '\x68';
			iv[5] = '\xF6';
			iv[6] = '\xBE';
			iv[7] = '\xC4';
			iv[8] = '\x17';
			iv[9] = '\xEE';
			iv[10] = '\xAC';
			iv[11] = '\x2F';
			iv[12] = '\x4E';
			iv[13] = '\x59';
			iv[14] = '\xA9';
			iv[15] = '\x73';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 6:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x16';
			key[1] = '\xC3';
			key[2] = '\xE8';
			key[3] = '\x23';
			key[4] = '\x08';
			key[5] = '\xE9';
			key[6] = '\x05';
			key[7] = '\xEF';
			key[8] = '\x53';
			key[9] = '\xFA';
			key[10] = '\x82';
			key[11] = '\xCC';
			key[12] = '\x1B';
			key[13] = '\x14';
			key[14] = '\xFD';
			key[15] = '\x90';
			
			// IV
			iv[0] = '\x44';
			iv[1] = '\xB9';
			iv[2] = '\x3E';
			iv[3] = '\x5B';
			iv[4] = '\x97';
			iv[5] = '\xBE';
			iv[6] = '\xDA';
			iv[7] = '\xFF';
			iv[8] = '\x82';
			iv[9] = '\xF5';
			iv[10] = '\x54';
			iv[11] = '\x54';
			iv[12] = '\xFE';
			iv[13] = '\xC6';
			iv[14] = '\x3A';
			iv[15] = '\x0F';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 7:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x13';
			key[1] = '\x6A';
			key[2] = '\x2B';
			key[3] = '\x77';
			key[4] = '\xB8';
			key[5] = '\x3B';
			key[6] = '\x54';
			key[7] = '\xA7';
			key[8] = '\x69';
			key[9] = '\xCD';
			key[10] = '\x51';
			key[11] = '\xC3';
			key[12] = '\x65';
			key[13] = '\x5E';
			key[14] = '\x02';
			key[15] = '\x35';
			
			// IV
			iv[0] = '\xA9';
			iv[1] = '\xB8';
			iv[2] = '\x43';
			iv[3] = '\xB9';
			iv[4] = '\x14';
			iv[5] = '\xC2';
			iv[6] = '\x7E';
			iv[7] = '\x6F';
			iv[8] = '\xDD';
			iv[9] = '\xF5';
			iv[10] = '\x53';
			iv[11] = '\xC8';
			iv[12] = '\x4B';
			iv[13] = '\xE8';
			iv[14] = '\x8C';
			iv[15] = '\xA7';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 8:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x24';
			key[1] = '\x48';
			key[2] = '\xC5';
			key[3] = '\xC7';
			key[4] = '\x16';
			key[5] = '\xEA';
			key[6] = '\x2D';
			key[7] = '\x03';
			key[8] = '\xFE';
			key[9] = '\xD1';
			key[10] = '\xD7';
			key[11] = '\x4E';
			key[12] = '\xEF';
			key[13] = '\x37';
			key[14] = '\xA3';
			key[15] = '\xFE';
			
			// IV
			iv[0] = '\x96';
			iv[1] = '\x9F';
			iv[2] = '\xBC';
			iv[3] = '\x8C';
			iv[4] = '\x5E';
			iv[5] = '\x88';
			iv[6] = '\x18';
			iv[7] = '\xD1';
			iv[8] = '\xA9';
			iv[9] = '\x3D';
			iv[10] = '\x36';
			iv[11] = '\x2B';
			iv[12] = '\x38';
			iv[13] = '\x50';
			iv[14] = '\xB8';
			iv[15] = '\x85';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 9:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x48';
			key[1] = '\x48';
			key[2] = '\xE2';
			key[3] = '\xD5';
			key[4] = '\x6C';
			key[5] = '\x13';
			key[6] = '\x2C';
			key[7] = '\x24';
			key[8] = '\x5A';
			key[9] = '\x40';
			key[10] = '\xA1';
			key[11] = '\x55';
			key[12] = '\x9F';
			key[13] = '\x4C';
			key[14] = '\xF5';
			key[15] = '\x73';
			
			// IV
			iv[0] = '\x99';
			iv[1] = '\x2A';
			iv[2] = '\xEA';
			iv[3] = '\x52';
			iv[4] = '\xFA';
			iv[5] = '\x90';
			iv[6] = '\x8D';
			iv[7] = '\x4F';
			iv[8] = '\x0D';
			iv[9] = '\x7D';
			iv[10] = '\x9E';
			iv[11] = '\xA0';
			iv[12] = '\x27';
			iv[13] = '\x02';
			iv[14] = '\xD3';
			iv[15] = '\x7F';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 10:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xC9';
			key[1] = '\x94';
			key[2] = '\x74';
			key[3] = '\x89';
			key[4] = '\x34';
			key[5] = '\x37';
			key[6] = '\xBF';
			key[7] = '\x4C';
			key[8] = '\xC8';
			key[9] = '\x40';
			key[10] = '\x75';
			key[11] = '\x19';
			key[12] = '\x41';
			key[13] = '\xA1';
			key[14] = '\x60';
			key[15] = '\x88';
			
			// IV
			iv[0] = '\x67';
			iv[1] = '\x5F';
			iv[2] = '\xF3';
			iv[3] = '\x46';
			iv[4] = '\xBC';
			iv[5] = '\x44';
			iv[6] = '\x31';
			iv[7] = '\x37';
			iv[8] = '\x9A';
			iv[9] = '\x75';
			iv[10] = '\x00';
			iv[11] = '\xC9';
			iv[12] = '\x0A';
			iv[13] = '\x00';
			iv[14] = '\xF8';
			iv[15] = '\x5A';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 11:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x87';
			key[1] = '\x2E';
			key[2] = '\x31';
			key[3] = '\x4B';
			key[4] = '\x09';
			key[5] = '\x72';
			key[6] = '\xCC';
			key[7] = '\x5E';
			key[8] = '\x65';
			key[9] = '\xD3';
			key[10] = '\xA0';
			key[11] = '\x92';
			key[12] = '\x3F';
			key[13] = '\xEE';
			key[14] = '\xE9';
			key[15] = '\x2F';
			
			// IV
			iv[0] = '\x14';
			iv[1] = '\x35';
			iv[2] = '\x92';
			iv[3] = '\xA8';
			iv[4] = '\x28';
			iv[5] = '\x98';
			iv[6] = '\xE5';
			iv[7] = '\x96';
			iv[8] = '\x87';
			iv[9] = '\x55';
			iv[10] = '\x35';
			iv[11] = '\x04';
			iv[12] = '\x39';
			iv[13] = '\xF4';
			iv[14] = '\xAA';
			iv[15] = '\xCD';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 12:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xA4';
			key[1] = '\xDE';
			key[2] = '\x6C';
			key[3] = '\x47';
			key[4] = '\x3E';
			key[5] = '\x53';
			key[6] = '\xCE';
			key[7] = '\xE6';
			key[8] = '\x97';
			key[9] = '\x1D';
			key[10] = '\x98';
			key[11] = '\x2B';
			key[12] = '\xCA';
			key[13] = '\x48';
			key[14] = '\x31';
			key[15] = '\xF3';
			
			// IV
			iv[0] = '\x9C';
			iv[1] = '\x6B';
			iv[2] = '\xFB';
			iv[3] = '\x0E';
			iv[4] = '\x92';
			iv[5] = '\xFD';
			iv[6] = '\x36';
			iv[7] = '\x1C';
			iv[8] = '\x54';
			iv[9] = '\xF7';
			iv[10] = '\x94';
			iv[11] = '\x90';
			iv[12] = '\xDB';
			iv[13] = '\x03';
			iv[14] = '\x04';
			iv[15] = '\x17';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 13:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x9A';
			key[1] = '\x97';
			key[2] = '\x4A';
			key[3] = '\xBF';
			key[4] = '\x4B';
			key[5] = '\xDC';
			key[6] = '\x1A';
			key[7] = '\x11';
			key[8] = '\x56';
			key[9] = '\x8F';
			key[10] = '\x45';
			key[11] = '\x0F';
			key[12] = '\x65';
			key[13] = '\x63';
			key[14] = '\xEF';
			key[15] = '\x79';
			
			// IV
			iv[0] = '\xE4';
			iv[1] = '\xFC';
			iv[2] = '\x74';
			iv[3] = '\xE5';
			iv[4] = '\x55';
			iv[5] = '\x9D';
			iv[6] = '\xF7';
			iv[7] = '\x6A';
			iv[8] = '\xDE';
			iv[9] = '\x48';
			iv[10] = '\x9E';
			iv[11] = '\x6F';
			iv[12] = '\x8D';
			iv[13] = '\xC4';
			iv[14] = '\x50';
			iv[15] = '\x7A';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 14:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x88';
			key[1] = '\xB7';
			key[2] = '\x88';
			key[3] = '\xB4';
			key[4] = '\xA2';
			key[5] = '\x2D';
			key[6] = '\x7A';
			key[7] = '\x98';
			key[8] = '\xBD';
			key[9] = '\xE1';
			key[10] = '\x4D';
			key[11] = '\x61';
			key[12] = '\x03';
			key[13] = '\x95';
			key[14] = '\xF1';
			key[15] = '\x25';
			
			// IV
			iv[0] = '\xB1';
			iv[1] = '\x7A';
			iv[2] = '\x3F';
			iv[3] = '\x82';
			iv[4] = '\x57';
			iv[5] = '\x30';
			iv[6] = '\x60';
			iv[7] = '\xA2';
			iv[8] = '\xD3';
			iv[9] = '\x43';
			iv[10] = '\x40';
			iv[11] = '\x0D';
			iv[12] = '\xD3';
			iv[13] = '\x06';
			iv[14] = '\xE4';
			iv[15] = '\x97';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 15:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x81';
			key[1] = '\x7F';
			key[2] = '\xA8';
			key[3] = '\xD2';
			key[4] = '\x6C';
			key[5] = '\x17';
			key[6] = '\x0B';
			key[7] = '\x24';
			key[8] = '\xBC';
			key[9] = '\xD2';
			key[10] = '\x77';
			key[11] = '\x45';
			key[12] = '\x81';
			key[13] = '\x4A';
			key[14] = '\x13';
			key[15] = '\x39';
			
			// IV
			iv[0] = '\x27';
			iv[1] = '\xA1';
			iv[2] = '\x6E';
			iv[3] = '\x38';
			iv[4] = '\xEC';
			iv[5] = '\x57';
			iv[6] = '\xE3';
			iv[7] = '\x0B';
			iv[8] = '\x4B';
			iv[9] = '\x25';
			iv[10] = '\x6C';
			iv[11] = '\x89';
			iv[12] = '\xEB';
			iv[13] = '\xEB';
			iv[14] = '\x0F';
			iv[15] = '\x90';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 16:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xD4';
			key[1] = '\x17';
			key[2] = '\xBB';
			key[3] = '\xB1';
			key[4] = '\x12';
			key[5] = '\x41';
			key[6] = '\x3F';
			key[7] = '\x12';
			key[8] = '\x36';
			key[9] = '\x00';
			key[10] = '\x1C';
			key[11] = '\xD9';
			key[12] = '\xF0';
			key[13] = '\x47';
			key[14] = '\x5C';
			key[15] = '\xF5';
			
			// IV
			iv[0] = '\x40';
			iv[1] = '\xE0';
			iv[2] = '\xE9';
			iv[3] = '\x1A';
			iv[4] = '\x4C';
			iv[5] = '\xC9';
			iv[6] = '\xCA';
			iv[7] = '\x7C';
			iv[8] = '\x4A';
			iv[9] = '\xAF';
			iv[10] = '\x4B';
			iv[11] = '\x1F';
			iv[12] = '\x56';
			iv[13] = '\x4F';
			iv[14] = '\x19';
			iv[15] = '\x7F';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 17:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x87';
			key[1] = '\xCF';
			key[2] = '\x1C';
			key[3] = '\x44';
			key[4] = '\x84';
			key[5] = '\x7D';
			key[6] = '\x56';
			key[7] = '\x81';
			key[8] = '\x83';
			key[9] = '\xC1';
			key[10] = '\x3F';
			key[11] = '\xE7';
			key[12] = '\x4D';
			key[13] = '\xEB';
			key[14] = '\xA0';
			key[15] = '\x1C';
			
			// IV
			iv[0] = '\xFC';
			iv[1] = '\x08';
			iv[2] = '\x5C';
			iv[3] = '\x53';
			iv[4] = '\xB9';
			iv[5] = '\xC0';
			iv[6] = '\x9E';
			iv[7] = '\x90';
			iv[8] = '\x1F';
			iv[9] = '\x0B';
			iv[10] = '\x95';
			iv[11] = '\x95';
			iv[12] = '\x2E';
			iv[13] = '\xB0';
			iv[14] = '\x51';
			iv[15] = '\x93';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 18:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xEE';
			key[1] = '\x87';
			key[2] = '\xB3';
			key[3] = '\x44';
			key[4] = '\x03';
			key[5] = '\x62';
			key[6] = '\x9F';
			key[7] = '\xF7';
			key[8] = '\x31';
			key[9] = '\x85';
			key[10] = '\x4E';
			key[11] = '\x5D';
			key[12] = '\x4A';
			key[13] = '\x77';
			key[14] = '\x48';
			key[15] = '\xF3';
			
			// IV
			iv[0] = '\xDE';
			iv[1] = '\xB6';
			iv[2] = '\x03';
			iv[3] = '\x38';
			iv[4] = '\xB8';
			iv[5] = '\x93';
			iv[6] = '\xD2';
			iv[7] = '\xCD';
			iv[8] = '\x1E';
			iv[9] = '\x20';
			iv[10] = '\xFF';
			iv[11] = '\xC5';
			iv[12] = '\x23';
			iv[13] = '\xFC';
			iv[14] = '\x41';
			iv[15] = '\xDA';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 19:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x6F';
			key[1] = '\x22';
			key[2] = '\xB4';
			key[3] = '\xF1';
			key[4] = '\x2C';
			key[5] = '\xCC';
			key[6] = '\x46';
			key[7] = '\x9B';
			key[8] = '\x37';
			key[9] = '\xF3';
			key[10] = '\x3F';
			key[11] = '\x2D';
			key[12] = '\xF8';
			key[13] = '\x1C';
			key[14] = '\xC1';
			key[15] = '\xBB';
			
			// IV
			iv[0] = '\xAB';
			iv[1] = '\x12';
			iv[2] = '\x9E';
			iv[3] = '\x7F';
			iv[4] = '\xDA';
			iv[5] = '\xF0';
			iv[6] = '\x53';
			iv[7] = '\x56';
			iv[8] = '\x48';
			iv[9] = '\x59';
			iv[10] = '\xE5';
			iv[11] = '\x27';
			iv[12] = '\xBE';
			iv[13] = '\x9A';
			iv[14] = '\xC2';
			iv[15] = '\x6F';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 20:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xF8';
			key[1] = '\xF4';
			key[2] = '\x55';
			key[3] = '\x96';
			key[4] = '\xF2';
			key[5] = '\x5A';
			key[6] = '\x91';
			key[7] = '\x0B';
			key[8] = '\x25';
			key[9] = '\x86';
			key[10] = '\x04';
			key[11] = '\x43';
			key[12] = '\x5A';
			key[13] = '\x76';
			key[14] = '\x23';
			key[15] = '\xB7';
			
			// IV
			iv[0] = '\xE9';
			iv[1] = '\xA3';
			iv[2] = '\x76';
			iv[3] = '\x65';
			iv[4] = '\x08';
			iv[5] = '\x24';
			iv[6] = '\x58';
			iv[7] = '\x64';
			iv[8] = '\x7A';
			iv[9] = '\xAE';
			iv[10] = '\x38';
			iv[11] = '\x6D';
			iv[12] = '\x68';
			iv[13] = '\xD3';
			iv[14] = '\xF4';
			iv[15] = '\x30';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 21:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x1D';
			key[1] = '\x32';
			key[2] = '\x51';
			key[3] = '\x37';
			key[4] = '\x88';
			key[5] = '\xBC';
			key[6] = '\x3E';
			key[7] = '\x69';
			key[8] = '\xEC';
			key[9] = '\x42';
			key[10] = '\xF1';
			key[11] = '\x58';
			key[12] = '\xA3';
			key[13] = '\x2D';
			key[14] = '\x9F';
			key[15] = '\x92';
			
			// IV
			iv[0] = '\x0C';
			iv[1] = '\x83';
			iv[2] = '\x7B';
			iv[3] = '\x77';
			iv[4] = '\x58';
			iv[5] = '\xA2';
			iv[6] = '\x12';
			iv[7] = '\x82';
			iv[8] = '\xA3';
			iv[9] = '\x0A';
			iv[10] = '\x17';
			iv[11] = '\xF8';
			iv[12] = '\xAC';
			iv[13] = '\x79';
			iv[14] = '\x37';
			iv[15] = '\xEC';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 22:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x6A';
			key[1] = '\x47';
			key[2] = '\x6D';
			key[3] = '\xF0';
			key[4] = '\xCC';
			key[5] = '\xF1';
			key[6] = '\x00';
			key[7] = '\x92';
			key[8] = '\x87';
			key[9] = '\x40';
			key[10] = '\x9C';
			key[11] = '\x9A';
			key[12] = '\x8E';
			key[13] = '\xE9';
			key[14] = '\xC8';
			key[15] = '\x85';
			
			// IV
			iv[0] = '\xD3';
			iv[1] = '\x99';
			iv[2] = '\x3F';
			iv[3] = '\x76';
			iv[4] = '\x5F';
			iv[5] = '\x49';
			iv[6] = '\xF3';
			iv[7] = '\x6F';
			iv[8] = '\x88';
			iv[9] = '\x17';
			iv[10] = '\x2C';
			iv[11] = '\x59';
			iv[12] = '\xBA';
			iv[13] = '\xCB';
			iv[14] = '\x35';
			iv[15] = '\x9D';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 23:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x0E';
			key[1] = '\x17';
			key[2] = '\x5B';
			key[3] = '\x36';
			key[4] = '\x56';
			key[5] = '\x3D';
			key[6] = '\x64';
			key[7] = '\xF8';
			key[8] = '\xAC';
			key[9] = '\xA0';
			key[10] = '\x87';
			key[11] = '\x3F';
			key[12] = '\x58';
			key[13] = '\xF8';
			key[14] = '\x02';
			key[15] = '\xE1';
			
			// IV
			iv[0] = '\xAD';
			iv[1] = '\x01';
			iv[2] = '\x1F';
			iv[3] = '\x9C';
			iv[4] = '\xBA';
			iv[5] = '\xD3';
			iv[6] = '\x59';
			iv[7] = '\x82';
			iv[8] = '\xBD';
			iv[9] = '\x6B';
			iv[10] = '\x1F';
			iv[11] = '\xE4';
			iv[12] = '\x4F';
			iv[13] = '\xC2';
			iv[14] = '\xF4';
			iv[15] = '\x9E';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 24:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x41';
			key[1] = '\xC6';
			key[2] = '\x1E';
			key[3] = '\xD9';
			key[4] = '\xF6';
			key[5] = '\xEA';
			key[6] = '\x3B';
			key[7] = '\x49';
			key[8] = '\xB7';
			key[9] = '\x13';
			key[10] = '\xFD';
			key[11] = '\x9B';
			key[12] = '\xBB';
			key[13] = '\x54';
			key[14] = '\x2D';
			key[15] = '\x0E';
			
			// IV
			iv[0] = '\xD0';
			iv[1] = '\x5B';
			iv[2] = '\x40';
			iv[3] = '\xEF';
			iv[4] = '\x5F';
			iv[5] = '\x65';
			iv[6] = '\x50';
			iv[7] = '\x87';
			iv[8] = '\xFE';
			iv[9] = '\xFD';
			iv[10] = '\xB7';
			iv[11] = '\x40';
			iv[12] = '\x28';
			iv[13] = '\x76';
			iv[14] = '\xCC';
			iv[15] = '\x62';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 25:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xFB';
			key[1] = '\x59';
			key[2] = '\x51';
			key[3] = '\xC0';
			key[4] = '\x6C';
			key[5] = '\x2E';
			key[6] = '\xC8';
			key[7] = '\x6A';
			key[8] = '\x60';
			key[9] = '\x2E';
			key[10] = '\x2D';
			key[11] = '\x01';
			key[12] = '\x25';
			key[13] = '\x61';
			key[14] = '\x93';
			key[15] = '\xD9';
			
			// IV
			iv[0] = '\x26';
			iv[1] = '\x08';
			iv[2] = '\x0D';
			iv[3] = '\x17';
			iv[4] = '\xF5';
			iv[5] = '\x80';
			iv[6] = '\x3C';
			iv[7] = '\xD5';
			iv[8] = '\xDA';
			iv[9] = '\x69';
			iv[10] = '\xCE';
			iv[11] = '\xD7';
			iv[12] = '\xD0';
			iv[13] = '\xC7';
			iv[14] = '\x57';
			iv[15] = '\x53';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 26:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x4E';
			key[1] = '\x42';
			key[2] = '\x1D';
			key[3] = '\x26';
			key[4] = '\xCB';
			key[5] = '\x0F';
			key[6] = '\x9B';
			key[7] = '\x73';
			key[8] = '\x8A';
			key[9] = '\x8F';
			key[10] = '\xFC';
			key[11] = '\x20';
			key[12] = '\x8F';
			key[13] = '\x09';
			key[14] = '\x69';
			key[15] = '\xEE';
			
			// IV
			iv[0] = '\x67';
			iv[1] = '\x02';
			iv[2] = '\x87';
			iv[3] = '\xFF';
			iv[4] = '\xE7';
			iv[5] = '\x9D';
			iv[6] = '\xF9';
			iv[7] = '\x08';
			iv[8] = '\x11';
			iv[9] = '\x44';
			iv[10] = '\xA6';
			iv[11] = '\x73';
			iv[12] = '\x70';
			iv[13] = '\x67';
			iv[14] = '\xF6';
			iv[15] = '\x91';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 27:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x72';
			key[1] = '\xC6';
			key[2] = '\x97';
			key[3] = '\xB1';
			key[4] = '\x86';
			key[5] = '\x72';
			key[6] = '\xC7';
			key[7] = '\xC1';
			key[8] = '\xDB';
			key[9] = '\x12';
			key[10] = '\xFA';
			key[11] = '\x4C';
			key[12] = '\xC9';
			key[13] = '\xA0';
			key[14] = '\x11';
			key[15] = '\xF5';
			
			// IV
			iv[0] = '\xB1';
			iv[1] = '\xD6';
			iv[2] = '\x5F';
			iv[3] = '\xE3';
			iv[4] = '\x4B';
			iv[5] = '\x13';
			iv[6] = '\xAC';
			iv[7] = '\x33';
			iv[8] = '\xE4';
			iv[9] = '\x51';
			iv[10] = '\x98';
			iv[11] = '\x8E';
			iv[12] = '\xCE';
			iv[13] = '\xE4';
			iv[14] = '\x62';
			iv[15] = '\x45';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 28:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x18';
			key[1] = '\x7F';
			key[2] = '\xCE';
			key[3] = '\x22';
			key[4] = '\xAC';
			key[5] = '\x03';
			key[6] = '\xE6';
			key[7] = '\x4B';
			key[8] = '\x8D';
			key[9] = '\x48';
			key[10] = '\x8F';
			key[11] = '\xD4';
			key[12] = '\xEB';
			key[13] = '\x4D';
			key[14] = '\x02';
			key[15] = '\x47';
			
			// IV
			iv[0] = '\xE9';
			iv[1] = '\xD0';
			iv[2] = '\x39';
			iv[3] = '\x38';
			iv[4] = '\x36';
			iv[5] = '\xAD';
			iv[6] = '\x12';
			iv[7] = '\x78';
			iv[8] = '\xCE';
			iv[9] = '\x27';
			iv[10] = '\x90';
			iv[11] = '\x85';
			iv[12] = '\x73';
			iv[13] = '\x2F';
			iv[14] = '\xC1';
			iv[15] = '\x40';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 29:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xAF';
			key[1] = '\x50';
			key[2] = '\x5C';
			key[3] = '\x78';
			key[4] = '\xE6';
			key[5] = '\x18';
			key[6] = '\x30';
			key[7] = '\x54';
			key[8] = '\xCF';
			key[9] = '\x7D';
			key[10] = '\x47';
			key[11] = '\x34';
			key[12] = '\xFB';
			key[13] = '\x34';
			key[14] = '\x05';
			key[15] = '\x24';
			
			// IV
			iv[0] = '\x0C';
			iv[1] = '\xE8';
			iv[2] = '\x8E';
			iv[3] = '\x12';
			iv[4] = '\xB2';
			iv[5] = '\xAA';
			iv[6] = '\x95';
			iv[7] = '\xB2';
			iv[8] = '\x1F';
			iv[9] = '\x89';
			iv[10] = '\x1A';
			iv[11] = '\xA7';
			iv[12] = '\x01';
			iv[13] = '\x2A';
			iv[14] = '\x04';
			iv[15] = '\x22';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 30:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xD9';
			key[1] = '\xDB';
			key[2] = '\x6D';
			key[3] = '\x2E';
			key[4] = '\xEF';
			key[5] = '\xF9';
			key[6] = '\x19';
			key[7] = '\x1E';
			key[8] = '\x35';
			key[9] = '\xD9';
			key[10] = '\x9E';
			key[11] = '\x5A';
			key[12] = '\x2C';
			key[13] = '\x3D';
			key[14] = '\xA9';
			key[15] = '\xEA';
			
			// IV
			iv[0] = '\x33';
			iv[1] = '\x61';
			iv[2] = '\x8C';
			iv[3] = '\x6A';
			iv[4] = '\xB3';
			iv[5] = '\x35';
			iv[6] = '\x2E';
			iv[7] = '\x12';
			iv[8] = '\x9B';
			iv[9] = '\xEC';
			iv[10] = '\xF6';
			iv[11] = '\x42';
			iv[12] = '\x40';
			iv[13] = '\x02';
			iv[14] = '\x71';
			iv[15] = '\x32';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 31:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x10';
			key[1] = '\x5F';
			key[2] = '\x12';
			key[3] = '\xE9';
			key[4] = '\xBA';
			key[5] = '\x09';
			key[6] = '\x68';
			key[7] = '\xB9';
			key[8] = '\x1D';
			key[9] = '\x31';
			key[10] = '\x7F';
			key[11] = '\xC7';
			key[12] = '\xBF';
			key[13] = '\x1E';
			key[14] = '\xDD';
			key[15] = '\x00';
			
			// IV
			iv[0] = '\xDC';
			iv[1] = '\xDA';
			iv[2] = '\xB7';
			iv[3] = '\x66';
			iv[4] = '\xD6';
			iv[5] = '\x6F';
			iv[6] = '\x61';
			iv[7] = '\x96';
			iv[8] = '\xEB';
			iv[9] = '\x21';
			iv[10] = '\x76';
			iv[11] = '\x66';
			iv[12] = '\xB0';
			iv[13] = '\xA4';
			iv[14] = '\x5A';
			iv[15] = '\xE1';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 32:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xD3';
			key[1] = '\xD2';
			key[2] = '\xAF';
			key[3] = '\x6D';
			key[4] = '\xFD';
			key[5] = '\xDE';
			key[6] = '\x02';
			key[7] = '\x49';
			key[8] = '\x2D';
			key[9] = '\xEA';
			key[10] = '\xDC';
			key[11] = '\x5F';
			key[12] = '\x96';
			key[13] = '\x7F';
			key[14] = '\x81';
			key[15] = '\x87';
			
			// IV
			iv[0] = '\x50';
			iv[1] = '\x54';
			iv[2] = '\x94';
			iv[3] = '\x45';
			iv[4] = '\xD7';
			iv[5] = '\x59';
			iv[6] = '\x54';
			iv[7] = '\xAD';
			iv[8] = '\x4A';
			iv[9] = '\xA6';
			iv[10] = '\x79';
			iv[11] = '\xFA';
			iv[12] = '\xA0';
			iv[13] = '\xC1';
			iv[14] = '\x98';
			iv[15] = '\x73';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 33:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x41';
			key[1] = '\xA4';
			key[2] = '\x5C';
			key[3] = '\x57';
			key[4] = '\xDD';
			key[5] = '\x47';
			key[6] = '\xCE';
			key[7] = '\x2F';
			key[8] = '\x65';
			key[9] = '\x64';
			key[10] = '\x50';
			key[11] = '\xD8';
			key[12] = '\x2E';
			key[13] = '\x76';
			key[14] = '\x4A';
			key[15] = '\xEB';
			
			// IV
			iv[0] = '\xC6';
			iv[1] = '\x60';
			iv[2] = '\x08';
			iv[3] = '\x7B';
			iv[4] = '\x29';
			iv[5] = '\x10';
			iv[6] = '\xFE';
			iv[7] = '\xA8';
			iv[8] = '\x3D';
			iv[9] = '\x1C';
			iv[10] = '\xBC';
			iv[11] = '\x2B';
			iv[12] = '\xFB';
			iv[13] = '\xAC';
			iv[14] = '\xF5';
			iv[15] = '\xD7';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 34:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x42';
			key[1] = '\x0E';
			key[2] = '\xD3';
			key[3] = '\x77';
			key[4] = '\x93';
			key[5] = '\xEC';
			key[6] = '\x4A';
			key[7] = '\xB2';
			key[8] = '\xAE';
			key[9] = '\x66';
			key[10] = '\xE7';
			key[11] = '\x63';
			key[12] = '\xE8';
			key[13] = '\x3C';
			key[14] = '\xE4';
			key[15] = '\x0C';
			
			// IV
			iv[0] = '\x14';
			iv[1] = '\xD8';
			iv[2] = '\x94';
			iv[3] = '\xD5';
			iv[4] = '\x3D';
			iv[5] = '\xA1';
			iv[6] = '\x71';
			iv[7] = '\x4E';
			iv[8] = '\xD6';
			iv[9] = '\x7F';
			iv[10] = '\xFD';
			iv[11] = '\xED';
			iv[12] = '\x86';
			iv[13] = '\xF7';
			iv[14] = '\x42';
			iv[15] = '\x36';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 35:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x97';
			key[1] = '\x7F';
			key[2] = '\x7C';
			key[3] = '\x77';
			key[4] = '\x4F';
			key[5] = '\x5E';
			key[6] = '\x20';
			key[7] = '\xB2';
			key[8] = '\x8E';
			key[9] = '\x5A';
			key[10] = '\x0F';
			key[11] = '\x41';
			key[12] = '\x13';
			key[13] = '\xF1';
			key[14] = '\x00';
			key[15] = '\x55';
			
			// IV
			iv[0] = '\xFE';
			iv[1] = '\x58';
			iv[2] = '\x8C';
			iv[3] = '\x50';
			iv[4] = '\x60';
			iv[5] = '\x1E';
			iv[6] = '\x1D';
			iv[7] = '\x65';
			iv[8] = '\x95';
			iv[9] = '\x34';
			iv[10] = '\x91';
			iv[11] = '\xA1';
			iv[12] = '\xDC';
			iv[13] = '\x00';
			iv[14] = '\x25';
			iv[15] = '\x33';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 36:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xC5';
			key[1] = '\xC5';
			key[2] = '\x31';
			key[3] = '\xC0';
			key[4] = '\xCA';
			key[5] = '\x29';
			key[6] = '\x34';
			key[7] = '\xA0';
			key[8] = '\xAB';
			key[9] = '\xA5';
			key[10] = '\x3A';
			key[11] = '\x85';
			key[12] = '\x68';
			key[13] = '\x41';
			key[14] = '\x0B';
			key[15] = '\x4B';
			
			// IV
			iv[0] = '\x34';
			iv[1] = '\x19';
			iv[2] = '\xAE';
			iv[3] = '\xCE';
			iv[4] = '\x5A';
			iv[5] = '\x66';
			iv[6] = '\xE8';
			iv[7] = '\x43';
			iv[8] = '\xA3';
			iv[9] = '\x75';
			iv[10] = '\x06';
			iv[11] = '\x2D';
			iv[12] = '\x7C';
			iv[13] = '\x79';
			iv[14] = '\x25';
			iv[15] = '\x50';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 37:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x6E';
			key[1] = '\xF1';
			key[2] = '\xE5';
			key[3] = '\x55';
			key[4] = '\xE2';
			key[5] = '\xC6';
			key[6] = '\x44';
			key[7] = '\xAB';
			key[8] = '\x1F';
			key[9] = '\x9B';
			key[10] = '\xD6';
			key[11] = '\xD2';
			key[12] = '\x91';
			key[13] = '\x9B';
			key[14] = '\x02';
			key[15] = '\xBB';
			
			// IV
			iv[0] = '\x05';
			iv[1] = '\x5A';
			iv[2] = '\xA6';
			iv[3] = '\x00';
			iv[4] = '\xCD';
			iv[5] = '\x86';
			iv[6] = '\x77';
			iv[7] = '\xE0';
			iv[8] = '\xF4';
			iv[9] = '\x4B';
			iv[10] = '\xF8';
			iv[11] = '\xF2';
			iv[12] = '\x52';
			iv[13] = '\xD6';
			iv[14] = '\xF6';
			iv[15] = '\x12';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 38:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x96';
			key[1] = '\x2B';
			key[2] = '\x24';
			key[3] = '\x10';
			key[4] = '\xD2';
			key[5] = '\xF7';
			key[6] = '\xC0';
			key[7] = '\x16';
			key[8] = '\x3E';
			key[9] = '\xC6';
			key[10] = '\x67';
			key[11] = '\xF3';
			key[12] = '\x3D';
			key[13] = '\xBC';
			key[14] = '\x34';
			key[15] = '\x11';
			
			// IV
			iv[0] = '\x32';
			iv[1] = '\x6F';
			iv[2] = '\x26';
			iv[3] = '\xFE';
			iv[4] = '\x06';
			iv[5] = '\x38';
			iv[6] = '\xF4';
			iv[7] = '\xEB';
			iv[8] = '\x03';
			iv[9] = '\x22';
			iv[10] = '\xFF';
			iv[11] = '\xAE';
			iv[12] = '\xCB';
			iv[13] = '\xEF';
			iv[14] = '\x4E';
			iv[15] = '\xF6';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 39:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xA0';
			key[1] = '\xE0';
			key[2] = '\x78';
			key[3] = '\x61';
			key[4] = '\x0A';
			key[5] = '\x29';
			key[6] = '\x53';
			key[7] = '\x3F';
			key[8] = '\x0F';
			key[9] = '\xC4';
			key[10] = '\xDD';
			key[11] = '\xD1';
			key[12] = '\x8B';
			key[13] = '\x2D';
			key[14] = '\xBF';
			key[15] = '\x6D';
			
			// IV
			iv[0] = '\x1D';
			iv[1] = '\x29';
			iv[2] = '\xB1';
			iv[3] = '\xDD';
			iv[4] = '\x0F';
			iv[5] = '\x10';
			iv[6] = '\xD9';
			iv[7] = '\x4E';
			iv[8] = '\x8A';
			iv[9] = '\xBF';
			iv[10] = '\x3F';
			iv[11] = '\xD1';
			iv[12] = '\x05';
			iv[13] = '\xE5';
			iv[14] = '\x47';
			iv[15] = '\xEB';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 40:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xB8';
			key[1] = '\x33';
			key[2] = '\x86';
			key[3] = '\x33';
			key[4] = '\xD8';
			key[5] = '\x96';
			key[6] = '\x81';
			key[7] = '\x38';
			key[8] = '\x3A';
			key[9] = '\x34';
			key[10] = '\xB1';
			key[11] = '\x7A';
			key[12] = '\x2D';
			key[13] = '\x04';
			key[14] = '\x94';
			key[15] = '\x50';
			
			// IV
			iv[0] = '\xEA';
			iv[1] = '\xD2';
			iv[2] = '\x24';
			iv[3] = '\x07';
			iv[4] = '\x9B';
			iv[5] = '\x87';
			iv[6] = '\x06';
			iv[7] = '\x17';
			iv[8] = '\x2D';
			iv[9] = '\xE7';
			iv[10] = '\x4E';
			iv[11] = '\xE7';
			iv[12] = '\xC4';
			iv[13] = '\x05';
			iv[14] = '\x2B';
			iv[15] = '\xC0';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 41:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xCC';
			key[1] = '\xAB';
			key[2] = '\x6F';
			key[3] = '\xA3';
			key[4] = '\x01';
			key[5] = '\xB8';
			key[6] = '\x16';
			key[7] = '\xB5';
			key[8] = '\xE1';
			key[9] = '\x1D';
			key[10] = '\x4C';
			key[11] = '\x0F';
			key[12] = '\x06';
			key[13] = '\x16';
			key[14] = '\xEE';
			key[15] = '\x62';
			
			// IV
			iv[0] = '\x49';
			iv[1] = '\x00';
			iv[2] = '\x48';
			iv[3] = '\x3D';
			iv[4] = '\x60';
			iv[5] = '\xE9';
			iv[6] = '\x56';
			iv[7] = '\x33';
			iv[8] = '\x12';
			iv[9] = '\x30';
			iv[10] = '\x8E';
			iv[11] = '\x0E';
			iv[12] = '\x63';
			iv[13] = '\x95';
			iv[14] = '\x50';
			iv[15] = '\x12';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 42:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x86';
			key[1] = '\xF6';
			key[2] = '\x0E';
			key[3] = '\xD7';
			key[4] = '\x1C';
			key[5] = '\x7B';
			key[6] = '\x61';
			key[7] = '\x52';
			key[8] = '\x89';
			key[9] = '\x84';
			key[10] = '\xD4';
			key[11] = '\x27';
			key[12] = '\x97';
			key[13] = '\x55';
			key[14] = '\xD1';
			key[15] = '\xE5';
			
			// IV
			iv[0] = '\xD1';
			iv[1] = '\x44';
			iv[2] = '\x31';
			iv[3] = '\x55';
			iv[4] = '\x4B';
			iv[5] = '\xEB';
			iv[6] = '\x0C';
			iv[7] = '\x3D';
			iv[8] = '\xD9';
			iv[9] = '\x03';
			iv[10] = '\x59';
			iv[11] = '\x38';
			iv[12] = '\xAA';
			iv[13] = '\x0E';
			iv[14] = '\xCD';
			iv[15] = '\xB8';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 43:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x6F';
			key[1] = '\x77';
			key[2] = '\x72';
			key[3] = '\xDC';
			key[4] = '\x0B';
			key[5] = '\x01';
			key[6] = '\x3A';
			key[7] = '\xD2';
			key[8] = '\x52';
			key[9] = '\x5C';
			key[10] = '\x3E';
			key[11] = '\x02';
			key[12] = '\x2A';
			key[13] = '\x3F';
			key[14] = '\xEC';
			key[15] = '\x51';
			
			// IV
			iv[0] = '\xE7';
			iv[1] = '\x0D';
			iv[2] = '\xC4';
			iv[3] = '\x88';
			iv[4] = '\x62';
			iv[5] = '\xD6';
			iv[6] = '\x58';
			iv[7] = '\x78';
			iv[8] = '\x2F';
			iv[9] = '\xDB';
			iv[10] = '\x6C';
			iv[11] = '\xFF';
			iv[12] = '\xFD';
			iv[13] = '\xDC';
			iv[14] = '\x71';
			iv[15] = '\x62';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 44:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xF6';
			key[1] = '\xB9';
			key[2] = '\x17';
			key[3] = '\x2A';
			key[4] = '\x62';
			key[5] = '\xA1';
			key[6] = '\x6B';
			key[7] = '\xA6';
			key[8] = '\x11';
			key[9] = '\x6D';
			key[10] = '\x4C';
			key[11] = '\x4D';
			key[12] = '\x85';
			key[13] = '\x40';
			key[14] = '\xBB';
			key[15] = '\x21';
			
			// IV
			iv[0] = '\x5A';
			iv[1] = '\x9C';
			iv[2] = '\x80';
			iv[3] = '\x7A';
			iv[4] = '\x4E';
			iv[5] = '\xA0';
			iv[6] = '\x57';
			iv[7] = '\x02';
			iv[8] = '\xFF';
			iv[9] = '\x1C';
			iv[10] = '\x86';
			iv[11] = '\x88';
			iv[12] = '\x3E';
			iv[13] = '\x69';
			iv[14] = '\x55';
			iv[15] = '\x44';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 45:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\xF7';
			key[1] = '\x99';
			key[2] = '\xA2';
			key[3] = '\x90';
			key[4] = '\x5F';
			key[5] = '\xFD';
			key[6] = '\xDF';
			key[7] = '\x3C';
			key[8] = '\x8E';
			key[9] = '\xF0';
			key[10] = '\xF4';
			key[11] = '\xE5';
			key[12] = '\x3F';
			key[13] = '\x93';
			key[14] = '\x89';
			key[15] = '\xCE';
			
			// IV
			iv[0] = '\xA3';
			iv[1] = '\x3F';
			iv[2] = '\xEA';
			iv[3] = '\x08';
			iv[4] = '\x7C';
			iv[5] = '\x9E';
			iv[6] = '\x9C';
			iv[7] = '\x27';
			iv[8] = '\xCC';
			iv[9] = '\xCC';
			iv[10] = '\xDB';
			iv[11] = '\x8C';
			iv[12] = '\x85';
			iv[13] = '\x68';
			iv[14] = '\x06';
			iv[15] = '\x4F';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 46:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x55';
			key[1] = '\x0D';
			key[2] = '\x6E';
			key[3] = '\xB7';
			key[4] = '\xE4';
			key[5] = '\x5D';
			key[6] = '\xCE';
			key[7] = '\x6C';
			key[8] = '\x60';
			key[9] = '\x6E';
			key[10] = '\x6E';
			key[11] = '\xB5';
			key[12] = '\xAD';
			key[13] = '\x63';
			key[14] = '\x9F';
			key[15] = '\x0D';
			
			// IV
			iv[0] = '\x82';
			iv[1] = '\xF3';
			iv[2] = '\xD2';
			iv[3] = '\xA6';
			iv[4] = '\xAE';
			iv[5] = '\xCF';
			iv[6] = '\xF1';
			iv[7] = '\x77';
			iv[8] = '\xE6';
			iv[9] = '\x9A';
			iv[10] = '\x99';
			iv[11] = '\x03';
			iv[12] = '\xC1';
			iv[13] = '\x5A';
			iv[14] = '\xF3';
			iv[15] = '\xC7';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 47:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x30';
			key[1] = '\x72';
			key[2] = '\x90';
			key[3] = '\x55';
			key[4] = '\x80';
			key[5] = '\x9E';
			key[6] = '\x0A';
			key[7] = '\x89';
			key[8] = '\xB7';
			key[9] = '\x44';
			key[10] = '\x8F';
			key[11] = '\xDC';
			key[12] = '\x37';
			key[13] = '\x94';
			key[14] = '\x87';
			key[15] = '\x7B';
			
			// IV
			iv[0] = '\x52';
			iv[1] = '\x15';
			iv[2] = '\x69';
			iv[3] = '\x2C';
			iv[4] = '\xA3';
			iv[5] = '\xB5';
			iv[6] = '\xAD';
			iv[7] = '\xE7';
			iv[8] = '\x39';
			iv[9] = '\xCC';
			iv[10] = '\x37';
			iv[11] = '\x4F';
			iv[12] = '\xC3';
			iv[13] = '\x86';
			iv[14] = '\xA4';
			iv[15] = '\xED';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 48:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x1C';
			key[1] = '\x8C';
			key[2] = '\x25';
			key[3] = '\x6D';
			key[4] = '\x47';
			key[5] = '\xFE';
			key[6] = '\x0C';
			key[7] = '\x04';
			key[8] = '\x4C';
			key[9] = '\x82';
			key[10] = '\x60';
			key[11] = '\x28';
			key[12] = '\xD6';
			key[13] = '\x97';
			key[14] = '\x5D';
			key[15] = '\x51';
			
			// IV
			iv[0] = '\xE7';
			iv[1] = '\x4B';
			iv[2] = '\xCA';
			iv[3] = '\x87';
			iv[4] = '\xEE';
			iv[5] = '\xA3';
			iv[6] = '\xE9';
			iv[7] = '\xD6';
			iv[8] = '\x4A';
			iv[9] = '\x9B';
			iv[10] = '\x04';
			iv[11] = '\xF1';
			iv[12] = '\xA8';
			iv[13] = '\x43';
			iv[14] = '\x54';
			iv[15] = '\x5B';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	case 49:
	{
		static bool build = false;
		static unsigned char key[16];
		static unsigned char iv[16];
		if (!build) {
			// KEY
			key[0] = '\x66';
			key[1] = '\xF0';
			key[2] = '\x77';
			key[3] = '\x05';
			key[4] = '\x37';
			key[5] = '\x43';
			key[6] = '\x5E';
			key[7] = '\x20';
			key[8] = '\x91';
			key[9] = '\xAF';
			key[10] = '\x6F';
			key[11] = '\x35';
			key[12] = '\xF6';
			key[13] = '\xB8';
			key[14] = '\xBC';
			key[15] = '\x95';
			
			// IV
			iv[0] = '\xF3';
			iv[1] = '\x70';
			iv[2] = '\x4F';
			iv[3] = '\xF3';
			iv[4] = '\x0A';
			iv[5] = '\x19';
			iv[6] = '\x7A';
			iv[7] = '\x31';
			iv[8] = '\xF9';
			iv[9] = '\x5D';
			iv[10] = '\xA9';
			iv[11] = '\x92';
			iv[12] = '\x81';
			iv[13] = '\xA0';
			iv[14] = '\xE4';
			iv[15] = '\x73';
				
			build = true;
		}
		retkey = key;
		retiv = iv;
		return true;
	}
	}
	return false;
}

bool L::getConfAESKey(const unsigned char* &retkey, const unsigned char* &retiv){
	return getAESKey(24,retkey,retiv);
}

