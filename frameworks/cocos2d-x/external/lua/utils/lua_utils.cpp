#include "lua_utils.h"
#include "platform/CCFileUtils.h"
#include "cocos/L/LUtils.h"
#include "L/aeskeys.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

USING_NS_CC;

/*
 *	判断文件是否存在
 */
static int utils_isFileExist(lua_State *L) {
	lua_pushboolean(L, FileUtils::getInstance()->isFileExist(luaL_checkstring(L, 1)));
	return 1;
}

/*
*	标准化路径
*/
static int utils_standardPath(lua_State *L) {
	size_t len1 = 0;
	const char *path = luaL_checklstring(L, 1, &len1);
	std::string out = L::standardPath(std::string(path, len1));
	lua_pushlstring(L, out.c_str(), out.size());
	return 1;
}

/*
*	获得AES密钥
*/
static int utils_getAESKey(lua_State *L) {
	int index = luaL_checkint(L, 1);
	const unsigned char* aeskey = nullptr;
	const unsigned char* aesiv = nullptr;
	if (L::getAESKey(index, aeskey, aesiv)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)aeskey, 16);
		lua_pushlstring(L, (const char*)aesiv, 16);
		return 3;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	获得配置AES密钥
*/
static int utils_getConfAESKey(lua_State *L) {
	const unsigned char* aeskey = nullptr;
	const unsigned char* aesiv = nullptr;
	if (L::getConfAESKey(aeskey, aesiv)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)aeskey, 16);
		lua_pushlstring(L, (const char*)aesiv, 16);
		return 3;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	XOR加密算法
*/
static int utils_XOR_encrypt(lua_State *L) {
	size_t len1 = 0, len2 = 0;
	const char *arg1 = luaL_checklstring(L, 1, &len1);
	const char *arg2 = luaL_checklstring(L, 2, &len2);
	std::string data(arg1, len1);
	L::XOR_encrypt(data, std::string(arg2, len2));
	lua_pushlstring(L, data.c_str(), data.size());
	return 1;
}

/*
*	AES加密算法
*/
static int utils_AES_encrypt(lua_State *L) {
	size_t len1 = 0, len2 = 0, len3 = 0;
	const char *arg1 = luaL_checklstring(L, 1, &len1);
	const char *arg2 = luaL_checklstring(L, 2, &len2);
	const char *arg3 = luaL_checklstring(L, 3, &len3);

	size_t outsize = len3 + 16;
	std::string out(outsize, 0);
	if (L::AES_encrypt((unsigned char*)arg1, (unsigned char*)arg2, (const unsigned char *)arg3, len3,
		(unsigned char *)out.c_str(), outsize)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)out.c_str(), outsize);
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	AES解密算法
*/
static int utils_AES_decrypt(lua_State *L) {
	size_t len1 = 0, len2 = 0, len3 = 0;
	const char *arg1 = luaL_checklstring(L, 1, &len1);
	const char *arg2 = luaL_checklstring(L, 2, &len2);
	const char *arg3 = luaL_checklstring(L, 3, &len3);

	size_t outsize = len3;
	std::string out(outsize, 0);
	if (L::AES_decrypt((unsigned char*)arg1, (unsigned char*)arg2, (const unsigned char *)arg3, len3,
		(unsigned char *)out.c_str(), outsize)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)out.c_str(), outsize);
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	RSA公钥加密算法
*/
static int utils_RSA_publicEncrypt(lua_State *L) {
	size_t dlen = 0;
	const char *data = luaL_checklstring(L, 1, &dlen);
	const char *pubfile = luaL_checkstring(L, 2);

	std::string encdata;
	if (L::RSA_publicEncrypt((const unsigned char *)data, dlen, encdata, pubfile)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)encdata.c_str(), encdata.size());
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	RSA公钥解密算法
*/
static int utils_RSA_publicDecrypt(lua_State *L) {
	size_t dlen = 0;
	const char *data = luaL_checklstring(L, 1, &dlen);
	const char *pubfile = luaL_checkstring(L, 2);

	std::string encdata;
	if (L::RSA_publicDecrypt((const unsigned char *)data, dlen, encdata, pubfile)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)encdata.c_str(), encdata.size());
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	RSA私钥加密算法
*/
static int utils_RSA_privateEncrypt(lua_State *L) {
	size_t dlen = 0;
	const char *data = luaL_checklstring(L, 1, &dlen);
	const char *prifile = luaL_checkstring(L, 2);

	std::string decdata;
	if (L::RSA_privateEncrypt((const unsigned char *)data, dlen, decdata, prifile)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)decdata.c_str(), decdata.size());
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	RSA私钥解密算法
*/
static int utils_RSA_privateDecrypt(lua_State *L) {
	size_t dlen = 0;
	const char *data = luaL_checklstring(L, 1, &dlen);
	const char *prifile = luaL_checkstring(L, 2);

	std::string decdata;
	if (L::RSA_privateDecrypt((const unsigned char *)data, dlen, decdata, prifile)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)decdata.c_str(), decdata.size());
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	ZLIB compress
*/
static int utils_Zlib_compress(lua_State *L) {
	size_t len1 = 0;
	const char *arg1 = luaL_checklstring(L, 1, &len1);

	std::string cmpdata;
	if (L::Zlib_compress(arg1, len1, cmpdata)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)cmpdata.c_str(), cmpdata.size());
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	ZLIB uncompress
*/
static int utils_Zlib_uncompress(lua_State *L) {
	size_t len2 = 0;
	size_t arg1 = (size_t)luaL_checkinteger(L, 1);
	const char *arg2 = luaL_checklstring(L, 2, &len2);

	std::string uncdata;
	if (L::Zlib_uncompress(arg2, len2, arg1, uncdata)) {
		lua_pushboolean(L, true);
		lua_pushlstring(L, (const char*)uncdata.c_str(), uncdata.size());
		return 2;
	} else {
		lua_pushboolean(L, false);
		return 1;
	}
}

/*
*	合并zlib文件
*/
static int utils_mergeFile(lua_State *L) {
	const char *indir = luaL_checkstring(L, 1);
	const char *outpath = luaL_checkstring(L, 2);
	const char *infmt = luaL_checkstring(L, 3);
	bool iszlib = lua_toboolean(L, 4);
	L::mergeFile(indir, outpath, infmt, iszlib);
	return 0;
}

/*
*	打补丁文件
*/
static int utils_patchH(lua_State *L) {
	const char *newpath = luaL_checkstring(L, 1);
	const char *oldpath = luaL_checkstring(L, 2);
	const char *diffpath = luaL_checkstring(L, 3);
	int bufsize = luaL_optint(L, 4, 10240);
	lua_pushboolean(L, L::patchH(newpath, oldpath, diffpath, bufsize));
	return 1;
}

/*
*	解压文件或者文件夹
*/
static int utils_unzip(lua_State *L) {
	const char *zipPath = luaL_checkstring(L, 1);
	const char *filePath = luaL_checkstring(L, 2);
	const char *outPath = luaL_checkstring(L, 3);
	lua_pushboolean(L, L::unzip(zipPath, filePath, outPath));
	return 1;
}

/*
*	解压文件或者文件夹
*/
static int utils_isDebug(lua_State *L) {
#if defined(COCOS2D_DEBUG) && COCOS2D_DEBUG > 0
	lua_pushboolean(L, true);
#else
	lua_pushboolean(L, false);
#endif
	return 1;
}

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

/*
*	获得资源路径
*/
static int utils_getAssetsPath(lua_State *L) {
	std::string assetpath = "~/";
	assetpath += getApkPath();
	lua_pushlstring(L, (const char*)assetpath.c_str(), assetpath.size());
	return 1;
}
#endif

static const struct luaL_Reg utils_lib[] = {
	{ "isFileExist", utils_isFileExist },
	{ "standardPath", utils_standardPath },
	{ "getAESKey", utils_getAESKey },
	{ "getConfAESKey", utils_getConfAESKey },
	{ "XOR_encrypt", utils_XOR_encrypt },
	{ "AES_encrypt", utils_AES_encrypt },
	{ "AES_decrypt", utils_AES_decrypt },
	{ "RSA_publicEncrypt", utils_RSA_publicEncrypt },
	{ "RSA_publicDecrypt", utils_RSA_publicDecrypt },
	{ "RSA_privateEncrypt", utils_RSA_privateEncrypt },
	{ "RSA_privateDecrypt", utils_RSA_privateDecrypt },
	{ "Zlib_compress", utils_Zlib_compress },
	{ "Zlib_uncompress", utils_Zlib_uncompress },
	{ "mergeFile", utils_mergeFile },
	{ "patchH", utils_patchH },
	{ "unzip", utils_unzip },
	{ "isDebug", utils_isDebug },
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	{ "getAssetsPath", utils_getAssetsPath },
#endif
	{ NULL, NULL }
};

void require_utils(lua_State* L) {
	luaL_register(L, "utils", utils_lib);
}
