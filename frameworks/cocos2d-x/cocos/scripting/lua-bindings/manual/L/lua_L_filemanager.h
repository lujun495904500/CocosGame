/**
 *	@file	lua_filemanager.h
 *	@date	2018/12/17
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	文件管理器绑定
 */

#ifndef __LUA_FILEMANAGER_20181217012318_H
#define __LUA_FILEMANAGER_20181217012318_H

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

TOLUA_API int register_L_filemanager(lua_State* L);

#endif //!__LUA_FILEMANAGER_20181217012318_H
