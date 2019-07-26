/**
 *	@file	FileReader.h
 *	@date	2018/12/15
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	ÎÄ¼þ ¶ÁÈ¡Æ÷
 */

#ifndef __FILEREADER_20181215234312_H
#define __FILEREADER_20181215234312_H

#include <cstddef>
#include <cstdio>
#include <cassert>

namespace L {

class FileReader {
public:
	FileReader(FILE *file) :
		m_file(file) {
		assert(file);
	}

	bool skip(size_t len);
	size_t getOffest();
	bool readBlock(char *buff, size_t size);
	char readByte();
	short readShort();
	long readLong();
private:
	FILE *m_file;
};

}

#endif //!__FILEREADER_20181215234312_H
