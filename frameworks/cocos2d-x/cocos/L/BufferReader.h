/**
 *	@file	BufferReader.h
 *	@date	2018/12/15
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	缓冲读取器
 */

#ifndef __BUFFERREADER_20181215214456_H
#define __BUFFERREADER_20181215214456_H

#include <cstddef>
#include <string>

namespace L {

class BufferReader {
public:
	BufferReader(void *buff,size_t size):
		m_buff((unsigned char*)buff), 
		m_size(size), 
		m_cursor(0){}
	char readByte();
	short readShort();
	long readLong();
	std::string readString();
private:
	unsigned char	*m_buff;
	size_t			m_cursor;
	size_t			m_size;
};

}

#endif //!__BUFFERREADER_20181215214456_H
