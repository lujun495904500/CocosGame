/**
 *	@file	LUtils.cpp
 *	@date	2018/12/17
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	工具类
 */

#include "LUtils.h"
#include <openssl/aes.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>  
#include <openssl/err.h>  
#include <openssl/bio.h> 
#include "HPatch/patch.h"
#include "FileManager.h"
#include <memory>
#include <zlib.h>
#include <unzip.h>

using namespace L;

#define BUFFSIZE 1024*10

static long stream_read(hpatch_TStreamInputHandle streamHandle,
	const hpatch_StreamPos_t readFromPos,
	unsigned char* out_data, unsigned char* out_data_end) {
	FILE *file = (FILE*)streamHandle;
	fseek(file, readFromPos, SEEK_SET);
	return fread(out_data, 1, out_data_end - out_data, file);
}

static long stream_write(hpatch_TStreamOutputHandle streamHandle,
	const hpatch_StreamPos_t writeToPos,
	const unsigned char* data, const unsigned char* data_end) {
	FILE *file = (FILE*)streamHandle;
	fseek(file, writeToPos, SEEK_SET);
	return fwrite(data, 1, data_end - data, file);
}

static int zlib_inflate(FILE *source, FILE *dest) {
	int ret;
	unsigned have;
	z_stream strm;
	unsigned char in[BUFFSIZE];
	unsigned char out[BUFFSIZE];

	/* allocate inflate state */
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.avail_in = 0;
	strm.next_in = Z_NULL;
	ret = inflateInit(&strm);
	if (ret != Z_OK)
		return ret;

	/* decompress until deflate stream ends or end of file */
	do {
		strm.avail_in = fread(in, 1, BUFFSIZE, source);
		if (ferror(source)) {
			(void)inflateEnd(&strm);
			return Z_ERRNO;
		}
		if (strm.avail_in == 0)
			break;
		strm.next_in = in;

		/* run inflate() on input until output buffer not full */
		do {
			strm.avail_out = BUFFSIZE;
			strm.next_out = out;
			ret = inflate(&strm, Z_NO_FLUSH);
			assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
			switch (ret) {
			case Z_NEED_DICT:
				ret = Z_DATA_ERROR;     /* and fall through */
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				(void)inflateEnd(&strm);
				return ret;
			}
			have = BUFFSIZE - strm.avail_out;
			if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
				(void)inflateEnd(&strm);
				return Z_ERRNO;
			}
		} while (strm.avail_out == 0);

		/* done when inflate() says it's done */
	} while (ret != Z_STREAM_END);

	/* clean up and return */
	(void)inflateEnd(&strm);
	return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

PathSplit::PathSplit(const char *path) :
	m_isabsolute(false),
	m_isendsepa(false),
	m_path(path != nullptr ? path : ""),
	m_cursor(m_path.c_str()) {
	m_endpos = m_path.c_str() + m_path.size();
	if (*m_cursor == '\\' || *m_cursor == '/')
		m_isabsolute = true;
	if (*(m_endpos-1) == '\\' || *(m_endpos - 1) == '/')
		m_isendsepa = true;
	std::replace(m_path.begin(), m_path.end(), '\\', '\0');		// 替换分割符
	std::replace(m_path.begin(), m_path.end(), '/', '\0');
}

bool PathSplit::is_absolute_path() {
	return m_isabsolute;
}

bool PathSplit::is_end_separate() {
	return m_isendsepa;
}

void PathSplit::reset_cursor() {
	m_cursor = m_path.c_str();
}

const char* PathSplit::get_next() {
	const char *curch = nullptr;

	while (m_cursor < m_endpos && *m_cursor == '\0')++m_cursor;
	if (*m_cursor != '\0') curch = m_cursor;
	while (m_cursor < m_endpos && *m_cursor != '\0')++m_cursor;

	return curch;
}

std::string L::standardPath(const std::string &path) {
	bool should = false;
	bool issplit = false;
	for (const char &ch : path) {
		if (ch == '\\' || ch == '.') {
			should = true;
			break;
		}else if (ch == '/'){
			if (issplit) {
				should = true;
				break;
			}
			issplit = true;
		} else {
			issplit = false;
		}
	}

	if (should) {
		std::vector<const char *> splits;
		const char *spname = nullptr;
		PathSplit pathsplit(path.c_str());

		while (spname = pathsplit.get_next()) {
			if (!strcmp(spname,"..")) {
				splits.pop_back();
			}else if (strcmp(spname, ".")){
				splits.push_back(spname);
			}
		}

		std::string newpath;
		if (pathsplit.is_absolute_path()){
			newpath += '/';
		}
		for (int i = 0; i < splits.size(); ++i) {
			if (i != 0) {
				newpath += '/';
			}
			newpath += splits[i];
		}
		if (pathsplit.is_end_separate()){
			newpath += '/';
		}

		return newpath;
	} else {
		return path;
	}
}

void L::XOR_encrypt(std::string &data, const std::string &xorkey) {
	int ki = 0;
	for (int i = 0; i < data.size(); i++) {
		data[i] ^= xorkey[ki];
		++ki;
		if (ki >= xorkey.size()){
			ki = 0;
		}
	}
}

bool L::AES_encrypt(const unsigned char* aeskey, const unsigned char* aesiv, const unsigned char *inbuff, size_t insize, unsigned char *outbuff, size_t &outsize) {
	int rsize = (0 == (insize & 15)) ? (insize + 16) : (insize + 15) & ~15;
	if (outsize < rsize) return false;

	outsize = rsize;
	int padsize = rsize - insize;
	std::string indata((char*)inbuff, insize);
	indata.append(padsize, padsize);

	AES_KEY key;
	if (AES_set_encrypt_key(aeskey, 128, &key)) return false;
	std::string iv((char*)aesiv, 16);

	AES_cbc_encrypt((const unsigned char *)indata.c_str(), outbuff, rsize, &key, (unsigned char *)iv.c_str(), AES_ENCRYPT);

	return true;
}

bool L::AES_decrypt(const unsigned char* aeskey, const unsigned char* aesiv, const unsigned char *inbuff, size_t insize, unsigned char *outbuff, size_t &outsize) {
	if (outsize < insize) return false;

	AES_KEY key;
	if (AES_set_decrypt_key(aeskey, 128, &key)) return false;
	std::string iv((char*)aesiv, 16);
	
	AES_cbc_encrypt(inbuff, outbuff, insize, &key, (unsigned char *)iv.c_str(), AES_DECRYPT);

	// 处理padding
	outsize = insize - (outbuff)[insize - 1];

	return true;
}

static std::string pkcs1_header = "-----BEGIN RSA ";
static std::string pkcs8_header = "-----BEGIN ";

bool L::RSA_publicEncrypt(const unsigned char* data, int dlen, std::string &encdata, const std::string &pubfile) {
	Data pubdata = FileManager::getInstance()->getDataFromFile(pubfile);
	BIO* bp = BIO_new(BIO_s_mem());
	BIO_puts(bp, (const char *)(pubdata.getBytes()));
	RSA* rsaK = NULL;
	if (0 == strncmp(pkcs1_header.c_str(), (const char *)pubdata.getBytes(), pkcs1_header.size())){
		rsaK = PEM_read_bio_RSAPublicKey(bp, NULL, NULL, NULL);
	}else if(0 == strncmp(pkcs8_header.c_str(), (const char *)pubdata.getBytes(), pkcs8_header.size())) {
		rsaK = PEM_read_bio_RSA_PUBKEY(bp, NULL, NULL, NULL);
	}
	if (NULL == rsaK){
		CCLOG("read rsa public key file [%s] fail", pubfile.c_str());
		return false;
	}
	int nLen = RSA_size(rsaK);
	encdata.resize(nLen + 1);
	int ret = RSA_public_encrypt(dlen, data, (unsigned char *)encdata.c_str(), rsaK, RSA_PKCS1_PADDING);
	if (ret == -1){
		CCLOG("rsa public encrypt fail");
		return false;
	}
	encdata.resize(ret);
	BIO_free_all(bp);
	RSA_free(rsaK);
	return true;
}

bool L::RSA_publicDecrypt(const unsigned char* data, int dlen, std::string &decdata, const std::string &pubfile) {
	Data pubdata = FileManager::getInstance()->getDataFromFile(pubfile);
	BIO* bp = BIO_new(BIO_s_mem());
	BIO_puts(bp, (const char *)(pubdata.getBytes()));
	RSA* rsaK = NULL;
	if (0 == strncmp(pkcs1_header.c_str(), (const char *)pubdata.getBytes(), pkcs1_header.size())) {
		rsaK = PEM_read_bio_RSAPublicKey(bp, NULL, NULL, NULL);
	} else if (0 == strncmp(pkcs8_header.c_str(), (const char *)pubdata.getBytes(), pkcs8_header.size())) {
		rsaK = PEM_read_bio_RSA_PUBKEY(bp, NULL, NULL, NULL);
	}
	if (NULL == rsaK) {
		CCLOG("read rsa public key file [%s] fail", pubfile.c_str());
		return false;
	}
	int nLen = RSA_size(rsaK);
	decdata.resize(nLen + 1);
	int ret = RSA_public_decrypt(dlen, data, (unsigned char *)decdata.c_str(), rsaK, RSA_PKCS1_PADDING);
	if (ret == -1) {
		CCLOG("rsa public decrypt fail");
		return false;
	}
	decdata.resize(ret);
	BIO_free_all(bp);
	RSA_free(rsaK);
	return true;
}

bool L::RSA_privateEncrypt(const unsigned char* data, int dlen, std::string &encdata, const std::string &prifile) {
	Data pridata = FileManager::getInstance()->getDataFromFile(prifile);
	BIO* bp = BIO_new(BIO_s_mem());
	BIO_puts(bp, (const char *)(pridata.getBytes()));
	RSA* rsaK = rsaK = PEM_read_bio_RSAPrivateKey(bp, NULL, NULL, NULL);
	if (NULL == rsaK) {
		CCLOG("read rsa private key file [%s] fail", prifile.c_str());
		return false;
	}
	int nLen = RSA_size(rsaK);
	encdata.resize(nLen + 1);
	int ret = RSA_private_encrypt(dlen, data, (unsigned char *)encdata.c_str(), rsaK, RSA_PKCS1_PADDING);
	if (ret == -1) {
		CCLOG("rsa private encrypt fail");
		return false;
	}
	encdata.resize(ret);
	BIO_free_all(bp);
	RSA_free(rsaK);
	return true;
}

bool L::RSA_privateDecrypt(const unsigned char* data, int dlen, std::string &decdata, const std::string &prifile) {
	Data pridata = FileManager::getInstance()->getDataFromFile(prifile);
	BIO* bp = BIO_new(BIO_s_mem());
	BIO_puts(bp, (const char *)(pridata.getBytes()));
	RSA* rsaK = rsaK = PEM_read_bio_RSAPrivateKey(bp, NULL, NULL, NULL);
	if (NULL == rsaK) {
		CCLOG("read rsa private key file [%s] fail", prifile.c_str());
		return false;
	}
	int nLen = RSA_size(rsaK);
	decdata.resize(nLen + 1);
	int ret = RSA_private_decrypt(dlen, data, (unsigned char *)decdata.c_str(), rsaK, RSA_PKCS1_PADDING);
	if (ret == -1) {
		CCLOG("rsa private decrypt fail");
		return false;
	}
	decdata.resize(ret);
	BIO_free_all(bp);
	RSA_free(rsaK);
	return true;
}

bool L::Zlib_compress(const char *uncdata, size_t unclen, std::string &cmpdata) {
	uLong blen = compressBound(unclen);
	cmpdata.resize(blen);
	return compress((Bytef *)cmpdata.c_str(), &blen, (const Bytef *)uncdata, unclen) == Z_OK;
}

bool L::Zlib_uncompress(const char *cmpdata, size_t cmplen, size_t unclen, std::string &uncdata) {
	uncdata.resize(unclen);
	uLong slen = unclen;
	return uncompress((Bytef *)uncdata.c_str(), &slen, (const Bytef *)cmpdata, cmplen) == Z_OK;
}

void L::mergeFile(const std::string &indir_, const std::string &outpath_, const std::string &infmt, bool iszlib) {
	std::string indir = FileManager::getInstance()->removeNativeFlag(indir_);
	std::string outpath = FileManager::getInstance()->removeNativeFlag(outpath_);
	size_t filecount = 0;
	FILE *outfile = fopen(outpath.c_str(),"wb");
	if (outfile){
		while (true) {
			char buff[BUFFSIZE];
			sprintf(buff, infmt.c_str(), filecount);
			std::string inpath = indir + "/" + buff;
			FILE *infile = fopen(inpath.c_str(), "rb");
			if (!infile) break;
			if (iszlib){
				zlib_inflate(infile, outfile);
			} else {
				int readsize = 0;
				do {
					readsize = fread(buff, 1, BUFFSIZE, infile);
					fwrite(buff, 1, readsize, outfile);
				} while (!feof(infile) && !readsize);
			}
			fclose(infile);
			++filecount;
		}
		fclose(outfile);
	}
}

bool L::patchH(const std::string &newpath_, const std::string &oldpath_, const std::string &diffpath_, int bufsize) {
	std::string newpath = FileManager::getInstance()->removeNativeFlag(newpath_);
	std::string oldpath = FileManager::getInstance()->removeNativeFlag(oldpath_);
	std::string diffpath = FileManager::getInstance()->removeNativeFlag(diffpath_);

	FILE *newfile = nullptr;
	FILE *oldfile = nullptr;
	FILE *difffile = nullptr;
	do {
		newfile = fopen(newpath.c_str(), "wb");
		oldfile = fopen(oldpath.c_str(), "rb");
		difffile = fopen(diffpath.c_str(), "rb");
		if (!newfile || !oldfile || !difffile) break;

		hpatch_TStreamOutput	out_new;
		hpatch_TStreamInput		oldData;
		hpatch_TStreamInput		diffData;

		diffData.streamHandle = difffile;
		fseek(difffile, 0, SEEK_END);
		diffData.streamSize = ftell(difffile);
		diffData.read = stream_read;

		hpatch_compressedDiffInfo diffInfo;
		if (!getCompressedDiffInfo(&diffInfo, &diffData)) break;

		oldData.streamHandle = oldfile;
		fseek(oldfile, 0, SEEK_END);
		oldData.streamSize = ftell(oldfile);
		oldData.read = stream_read;

		out_new.streamHandle = newfile;
		out_new.streamSize = diffInfo.newDataSize;
		out_new.write = stream_write;

		std::auto_ptr<char> patchbuff(new char[bufsize]);
		hpatch_BOOL retval = patch_decompress_with_cache(&out_new, &oldData, &diffData, 0,
			(unsigned char*)(patchbuff.get()), (unsigned char*)(patchbuff.get() + bufsize));

		fclose(newfile);
		fclose(oldfile);
		fclose(difffile);
		return retval;
	} while (0);

	if (newfile) fclose(newfile);
	if (oldfile) fclose(oldfile);
	if (difffile) fclose(difffile);
	return false;
}

static std::string _normalOpenPath(const std::string &path) {
	return FileUtils::getInstance()->getSuitableFOpen(FileManager::getInstance()->removeNativeFlag(path));
}

static bool unzipFile(const std::string &zipPath, const std::string &filePath, const std::string &outPath) {
	unzFile zfile = unzOpen64(_normalOpenPath(zipPath).c_str());
	if (!zfile) return false;

	if (UNZ_OK != unzLocateFile(zfile, filePath.c_str(), 0)) {
		unzClose(zfile);
		return false;
	}

	if (UNZ_OK != unzOpenCurrentFile(zfile)){
		unzClose(zfile);
		return false;
	}

	FileUtils::getInstance()->createDirectory(FileManager::getInstance()->getFileDirectory(outPath));
	FILE *ofile = fopen(_normalOpenPath(outPath).c_str(), "wb");
	if (!ofile){
		unzCloseCurrentFile(zfile);
		unzClose(zfile);
		return false;
	}

	bool result = true;
	char buff[BUFFSIZE];
	while (true) {
		int size = unzReadCurrentFile(zfile, buff, BUFFSIZE);
		if (size < 0) {
			result = false;
			break;
		} else if(size == 0) {
			break;
		} else {
			if (size != fwrite(buff, 1, size, ofile)) {
				result = false;
				break;
			}
		}
	}

	fclose(ofile);
	unzCloseCurrentFile(zfile);
	unzClose(zfile);
	return result;
}

static bool unzipDirectory(const std::string &zipPath, const std::string &filePath, const std::string &outPath) {
	unzFile zfile = unzOpen64(_normalOpenPath(zipPath).c_str());
	if (!zfile) return false;

	if (UNZ_OK == unzGoToFirstFile(zfile)) {
		do {
			char filename[256];
			unz_file_info64 fileinfo;
			if (unzGetCurrentFileInfo64(zfile, &fileinfo, filename, sizeof(filename), 0, 0, 0, 0) != UNZ_OK) {
				unzClose(zfile);
				return false;
			}
			if (!strncmp(filename, filePath.c_str(), filePath.size())){
				if (filename[strlen(filename)-1] == '/') {
					FileUtils::getInstance()->createDirectory(outPath + "/" + std::string(filename + filePath.size()));
				} else {
					if (!unzipFile(zipPath, filename, outPath + "/" + std::string(filename + filePath.size()))){
						unzClose(zfile);
						return false;
					}
				}
			}
		} while (UNZ_OK == unzGoToNextFile(zfile));
	}

	unzClose(zfile);
	return true;
}

bool L::unzip(const std::string &zipPath, const std::string &filePath, const std::string &outPath) {
	if (filePath[filePath.size() - 1] == '/'){
		return unzipDirectory(zipPath, filePath, outPath);
	} else {
		return unzipFile(zipPath, filePath, outPath);
	}
}
