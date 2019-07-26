/**
 *	@file	lua_cocos2dx_L_manual.cpp
 *	@date	2018/02/12
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	手动绑定L库函数
 */

#include "lua_cocos2dx_L_manual.h"
#include "lua_L_tmxmap.h"
#include "lua_L_scene.h"
#include "lua_L_filemanager.h"

TOLUA_API int register_L_module(lua_State* L) {

	lua_getglobal(L, "_G");
	if (lua_istable(L, -1))//stack:...,_G,
	{
		register_L_tmxmap(L);
		register_L_scene(L);
		register_L_filemanager(L);
	}
	lua_pop(L, 1);

	return 1;
}
