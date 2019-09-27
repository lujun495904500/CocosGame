/**
 *	@file	BufferReader.cpp
 *	@date	2018/12/15
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	缓冲读取器
 */

#include "BufferReader.h"

using namespace L;

char BufferReader::readByte() {
	assert(m_cursor + 1 <= m_size);
	char value = m_buff[m_cursor];
	m_cursor += 1;
	return value;
}

short BufferReader::readShort() {
	assert(m_cursor + 2 <= m_size);
	short value = m_buff[m_cursor + 1] << 8 | m_buff[m_cursor];
	m_cursor += 2;
	return value;
}

long BufferReader::readLong() {
	assert(m_cursor + 4 <= m_size);
	long value = m_buff[m_cursor + 3] << 24 | m_buff[m_cursor + 2] << 16 | m_buff[m_cursor + 1] << 8 | m_buff[m_cursor];
	m_cursor += 4;
	return value;
}

std::string BufferReader::readString() {
	std::string str;
	for (;m_cursor < m_size;++m_cursor) {
		if (m_buff[m_cursor]){
			str += m_buff[m_cursor];
		} else {
			++m_cursor;
			break;
		}
	}
	return str;
}

