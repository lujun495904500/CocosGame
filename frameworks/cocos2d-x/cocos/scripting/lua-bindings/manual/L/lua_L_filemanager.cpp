/**
 *	@file	lua_filemanager.cpp
 *	@date	2018/12/17
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	文件管理器绑定
 */

#include "lua_L_filemanager.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "L/FileManager.h"

 /* function to regType */
static void lua_reg_filemanager(lua_State* L) {
	tolua_usertype(L, "L.FileManager");
}

//-------------------------------------------------------------
//	FileManager
//-------------------------------------------------------------

int lua_L_FileManager_getInstance(lua_State* tolua_S) {
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_getInstance'", nullptr);
			return 0;
		}
		L::FileManager* ret = L::FileManager::getInstance();
		object_to_luaval<L::FileManager>(tolua_S, "L.FileManager", (L::FileManager*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "L.FileManager:getInstance", argc, 0);
	return 0;
#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_getInstance'.", &tolua_err);
#endif
	return 0;
}

int lua_L_FileManager_loadFilePack(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_loadFilePack'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.FileManager:loadFilePack");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_loadFilePack'", nullptr);
			return 0;
		}
		bool ret = cobj->loadFilePack(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:loadFilePack", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_loadFilePack'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_releaseFilePack(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_releaseFilePack'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.FileManager:releaseFilePack");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_releaseFilePack'", nullptr);
			return 0;
		}
		cobj->releaseFilePack(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:releaseFilePack", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_releaseFilePack'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_isNativePath(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_isNativePath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.FileManager:isNativePath");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_isNativePath'", nullptr);
			return 0;
		}
		bool ret = cobj->isNativePath(arg0);
		tolua_pushboolean(tolua_S, (bool)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:isNativePath", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_isNativePath'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_removeNativeFlag(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_removeNativeFlag'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.FileManager:removeNativeFlag");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_removeNativeFlag'", nullptr);
			return 0;
		}
		std::string ret = cobj->removeNativeFlag(arg0);
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:removeNativeFlag", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_removeNativeFlag'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_getNativeFileUtils(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_getNativeFileUtils'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		cocos2d::FileUtils *ret = cobj->getNativeFileUtils();
		object_to_luaval<cocos2d::FileUtils>(tolua_S, "cc.FileUtils", (cocos2d::FileUtils*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:getNativeFileUtils", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_getNativeFileUtils'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_getNativeRootPath(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_getNativeRootPath'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		cocos2d::FileUtils *ret = cobj->getNativeFileUtils();
		object_to_luaval<cocos2d::FileUtils>(tolua_S, "cc.FileUtils", (cocos2d::FileUtils*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:getNativeRootPath", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_getNativeRootPath'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_getPackVersion(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_getPackVersion'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.FileManager:getPackVersion");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_getPackVersion'", nullptr);
			return 0;
		}
		unsigned long version = cobj->getPackVersion(arg0);
		lua_pushinteger(tolua_S, version);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:getPackVersion", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_getPackVersion'.", &tolua_err);
#endif

	return 0;
}

int lua_L_FileManager_lookPackVersion(lua_State* tolua_S) {
	int argc = 0;
	L::FileManager* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.FileManager", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::FileManager*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_FileManager_lookPackVersion'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.FileManager:lookPackVersion");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_FileManager_lookPackVersion'", nullptr);
			return 0;
		}
		unsigned long version = cobj->lookPackVersion(arg0);
		lua_pushinteger(tolua_S, version);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.FileManager:lookPackVersion", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_FileManager_lookPackVersion'.", &tolua_err);
#endif

	return 0;
}

//--------------------------------------------------------------
TOLUA_API int register_L_filemanager(lua_State* L) {
	tolua_open(L);
	lua_reg_filemanager(L);
	tolua_module(L, "L", 0);
	tolua_beginmodule(L, "L");

		tolua_cclass(L, "FileManager", "L.FileManager", "cc.FileUtils", nullptr);
		tolua_beginmodule(L, "FileManager");

		tolua_function(L, "getInstance", lua_L_FileManager_getInstance);
		tolua_function(L, "loadFilePack", lua_L_FileManager_loadFilePack);
		tolua_function(L, "releaseFilePack", lua_L_FileManager_releaseFilePack);
		tolua_function(L, "isNativePath", lua_L_FileManager_isNativePath);
		tolua_function(L, "removeNativeFlag", lua_L_FileManager_removeNativeFlag);
		tolua_function(L, "getNativeFileUtils", lua_L_FileManager_getNativeFileUtils);
		tolua_function(L, "getNativeRootPath", lua_L_FileManager_getNativeRootPath);
		tolua_function(L, "getPackVersion", lua_L_FileManager_getPackVersion);
		tolua_function(L, "lookPackVersion", lua_L_FileManager_lookPackVersion);

		tolua_endmodule(L);
		g_luaType[typeid(L::FileManager).name()] = "L.FileManager";

	tolua_endmodule(L);
	return 1;
}
