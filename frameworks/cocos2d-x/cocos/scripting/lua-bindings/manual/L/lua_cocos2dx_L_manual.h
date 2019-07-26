/**
 *	@file	lua_cocos2dx_L_manual.h
 *	@date	2018/02/12
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	手动绑定L库函数
 */

#ifndef __LUA_COCOS2DX_L_MANUAL_20180212154017_H
#define __LUA_COCOS2DX_L_MANUAL_20180212154017_H

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

TOLUA_API int register_L_module(lua_State* L);

#endif //!__LUA_COCOS2DX_L_MANUAL_20180212154017_H
