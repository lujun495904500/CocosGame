/**
 *	@file	LUtils.h
 *	@date	2018/12/17
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	工具类
 */

#ifndef __LUTILS_20181217045610_H
#define __LUTILS_20181217045610_H

#include "cocos2d.h"

USING_NS_CC;

namespace L {

/**
*	@brief 路径分割
*	@details 用linux路径格式,字符'/'或者'\'都可以作为路径分隔符，
*		并且在路径分割中可以存在多个路径分隔符
*/
class PathSplit {
protected:

	/**
	*	绝对路径
	*/
	bool			m_isabsolute;

	/*
	 *	结束分隔符
	 */
	bool			m_isendsepa;

	/**
	*	分割保存的路径
	*	这个路径仅做内部参数
	*/
	std::string		m_path;

	/**
	*	分割当前光标位置
	*/
	const char*		m_cursor;

	/**
	*	分割结束位置
	*/
	const char*		m_endpos;

public:

	/**
	*	@brief 以指定路径创建路径分割
	*	@param[in]	path	指定的路径(可以为NULL，对应路径为"")
	*/
	PathSplit(const char *path);

	/**
	*	@brief 虚析构路径分割
	*/
	virtual ~PathSplit() {}

	/**
	*	@brief 测试当前路径分割中是否是绝对路径
	*	@return 测试是否成功
	*/
	bool is_absolute_path();

	/*
	 *	结束分隔符
	 */
	bool is_end_separate();

	/**
	*	@brief 重置路径分割当前光标
	*/
	void reset_cursor();

	/**
	*	@brief 根据路径分割当前光标，获取下一个路径节点
	*	@return 路径节点
	*	@retval	NULL 路径分割结束
	*/
	const char* get_next();
};

CC_DLL std::string standardPath(const std::string &path);

CC_DLL void XOR_encrypt(std::string &data, const std::string &xorkey);

CC_DLL bool AES_encrypt(const unsigned char* aeskey, const unsigned char* aesiv, const unsigned char *inbuff, size_t insize, unsigned char *outbuff, size_t &outsize);

CC_DLL bool AES_decrypt(const unsigned char* aeskey, const unsigned char* aesiv, const unsigned char *inbuff, size_t insize, unsigned char *outbuff, size_t &outsize);

CC_DLL bool RSA_publicEncrypt(const unsigned char* data, int dlen, std::string &encdata, const std::string &pubfile);

CC_DLL bool RSA_publicDecrypt(const unsigned char* data, int dlen, std::string &encdata, const std::string &pubfile);

CC_DLL bool RSA_privateEncrypt(const unsigned char* data, int dlen, std::string &decdata, const std::string &prifile);

CC_DLL bool RSA_privateDecrypt(const unsigned char* data, int dlen, std::string &decdata, const std::string &prifile);

CC_DLL bool Zlib_compress(const char *uncdata, size_t unclen, std::string &cmpdata);

CC_DLL bool Zlib_uncompress(const char *cmpdata, size_t cmplen, size_t unclen, std::string &uncdata);

CC_DLL void mergeFile(const std::string &indir, const std::string &outfile, const std::string &infmt, bool iszlib);

CC_DLL bool patchH(const std::string &newfile, const std::string &oldfile, const std::string &difffile,int bufsize = 10240);

CC_DLL bool unzip(const std::string &zipPath, const std::string &filePath, const std::string &outPath);

}

#endif //!__LUTILS_20181217045610_H
