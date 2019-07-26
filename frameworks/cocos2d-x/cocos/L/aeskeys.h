/**
 *	@file	aeskeys.h
 *	@date	2018/12/21
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	AESÃÜÔ¿ÎÄ¼þ
 */

#ifndef __AESKEYS_20181221182528_H
#define __AESKEYS_20181221182528_H

#include "cocos2d.h"

namespace L {

CC_DLL bool getAESKey(int index, const unsigned char* &retkey, const unsigned char* &retiv);

CC_DLL bool getConfAESKey(const unsigned char* &retkey, const unsigned char* &retiv);

}

#endif //!__AESKEYS_20181221182528_H
