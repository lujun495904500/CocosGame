/**
 *	@file	FileReader.cpp
 *	@date	2018/12/15
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	ÎÄ¼þ ¶ÁÈ¡Æ÷
 */

#include "FileReader.h"

using namespace L;

bool FileReader::skip(size_t len) {
	return !fseek(m_file, len, SEEK_CUR);
}

size_t FileReader::getOffest() {
	return ftell(m_file);
}

bool FileReader::readBlock(char *buff, size_t size) {
	return fread(buff, 1, size, m_file) == size;
}

char FileReader::readByte() {
	unsigned char byte[1];
	readBlock((char *)byte, 1);
	return byte[0];
}

short FileReader::readShort() {
	unsigned char byte[2];
	readBlock((char *)byte, 2);
	return byte[1] << 8 | byte[0];
}

long FileReader::readLong() {
	unsigned char byte[4];
	readBlock((char *)byte, 4);
	return byte[3] << 24 | byte[2] << 16 | byte[1] << 8 | byte[0];
}

