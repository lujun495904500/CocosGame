/**
 *	@file	lua_scene.cpp
 *	@date	2018/04/01
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	³¡¾°
 */

#include <string>
#include "lua_L_scene.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "L/AntiAliasedScene.h"

 /* function to regType */
static void lua_reg_scene(lua_State* L) {
	tolua_usertype(L, "L.AntiAliasedScene");
}

//-------------------------------------------------------------
//	AntiAliasedScene
//-------------------------------------------------------------

static int lua_L_AntiAliasedScene_create(lua_State* tolua_S) {
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "L.AntiAliasedScene", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc == 0) {
		L::AntiAliasedScene* ret = L::AntiAliasedScene::create();
		object_to_luaval<L::AntiAliasedScene>(tolua_S, "L.AntiAliasedScene", (L::AntiAliasedScene*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "L.AntiAliasedScene:create", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_AntiAliasedScene_create'.", &tolua_err);
#endif
	return 0;
}

static int lua_L_AntiAliasedScene_createWithSize(lua_State* tolua_S) {
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "L.AntiAliasedScene", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc == 1) {
		Size arg0;
		ok &= luaval_to_size(tolua_S, 2, &arg0, "L.AntiAliasedScene:createWithSize");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_AntiAliasedScene_createWithSize'", nullptr);
			return 0;
		}

		L::AntiAliasedScene* ret = L::AntiAliasedScene::createWithSize(arg0);
		object_to_luaval<L::AntiAliasedScene>(tolua_S, "L.AntiAliasedScene", (L::AntiAliasedScene*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "L.AntiAliasedScene:createWithSize", argc, 1);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_AntiAliasedScene_createWithSize'.", &tolua_err);
#endif
	return 0;
}

#if (CC_USE_PHYSICS || (CC_USE_3D_PHYSICS && CC_ENABLE_BULLET_INTEGRATION))
static int lua_L_AntiAliasedScene_createWithPhysics(lua_State* tolua_S) {
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "L.AntiAliasedScene", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc == 0) {
		L::AntiAliasedScene* ret = L::AntiAliasedScene::createWithPhysics();
		object_to_luaval<L::AntiAliasedScene>(tolua_S, "L.AntiAliasedScene", (L::AntiAliasedScene*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "L.AntiAliasedScene:createWithPhysics", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_AntiAliasedScene_createWithPhysics'.", &tolua_err);
#endif
	return 0;
}
#endif

//--------------------------------------------------------------
TOLUA_API int register_L_scene(lua_State* L) {
	tolua_open(L);
	lua_reg_scene(L);
	tolua_module(L, "L", 0);
	tolua_beginmodule(L, "L");

	  tolua_cclass(L, "AntiAliasedScene", "L.AntiAliasedScene", "cc.Scene", nullptr);
	  tolua_beginmodule(L, "AntiAliasedScene");
	    tolua_function(L, "create", lua_L_AntiAliasedScene_create);
	    tolua_function(L, "createWithSize", lua_L_AntiAliasedScene_createWithSize);
#if (CC_USE_PHYSICS || (CC_USE_3D_PHYSICS && CC_ENABLE_BULLET_INTEGRATION))
	    tolua_function(L, "createWithPhysics", lua_L_AntiAliasedScene_createWithPhysics);
#endif
	  tolua_endmodule(L);
	  g_luaType[typeid(L::AntiAliasedScene).name()] = "L.AntiAliasedScene";

	tolua_endmodule(L);
	return 1;
}

