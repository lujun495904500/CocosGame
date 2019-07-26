/**
*	@file	lua_tmxmap.h
*	@date	2018/02/12
*
* 	@author lujun
*	Contact:(QQ:495904500)
*
*	@brief	TMXµØÍ¼
*/

#include <string>
#include "lua_L_tmxmap.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "L/TMXTiledMap.h"

/* function to regType */
static void lua_reg_tmxmap(lua_State* L) {
	tolua_usertype(L, "L.TMXLayer");
	tolua_usertype(L, "L.TMXObject");
	tolua_usertype(L, "L.TMXObjectGroup");
	tolua_usertype(L, "L.TMXTiledMap");
	tolua_usertype(L, "L.TMXTileSet");
}

//-------------------------------------------------------------
// TMXTiledMap
//-------------------------------------------------------------

static int lua_L_TMXTiledMap_create(lua_State* tolua_S) {
	int argc = 0;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertable(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (argc >= 1 && argc <= 2) {
		std::string arg0;
		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXTiledMap:create");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_create'", nullptr);
			return 0;
		}
		bool arg1 = false;
		if (argc > 1){
			ok &= luaval_to_boolean(tolua_S, 3, &arg1, "L.TMXTiledMap:create");
			if (!ok) {
				tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_create'", nullptr);
				return 0;
			}
		}
		
		L::TMXTiledMap* ret = L::TMXTiledMap::create(arg0, arg1);
		object_to_luaval<L::TMXTiledMap>(tolua_S, "L.TMXTiledMap", (L::TMXTiledMap*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting (%d,%d)\n ", "L.TMXTiledMap:create", argc, 1,2);
	return 0;
#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_create'.", &tolua_err);
#endif
	return 0;
}

static int lua_L_TMXTiledMap_getTileSize(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getTileSize'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getTileSize'", nullptr);
			return 0;
		}
		const cocos2d::Size& ret = cobj->getTileSize();
		size_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getTileSize", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getTileSize'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getMapSize(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getMapSize'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getMapSize'", nullptr);
			return 0;
		}
		const cocos2d::Size& ret = cobj->getMapSize();
		size_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getMapSize", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getMapSize'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getLayerCount(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getLayerCount'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getLayerCount'", nullptr);
			return 0;
		}
		int ret = cobj->getLayerCount();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getLayerCount", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getLayerCount'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getOrientation(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getOrientation'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getOrientation'", nullptr);
			return 0;
		}
		int ret = cobj->getOrientation();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getOrientation", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getOrientation'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getStaggerAxis(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getStaggerAxis'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getStaggerAxis'", nullptr);
			return 0;
		}
		int ret = cobj->getStaggerAxis();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getStaggerAxis", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getStaggerAxis'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getStaggerIndex(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getStaggerIndex'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getStaggerIndex'", nullptr);
			return 0;
		}
		int ret = cobj->getStaggerIndex();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getStaggerIndex", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getStaggerIndex'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getHexSideLength(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getHexSideLength'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getHexSideLength'", nullptr);
			return 0;
		}
		int ret = cobj->getHexSideLength();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getHexSideLength", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getHexSideLength'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getProperties(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getProperties'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getProperties'", nullptr);
			return 0;
		}
		const cocos2d::ValueMap& ret = cobj->getProperties();
		ccvaluemap_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getProperties", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getProperties'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getProperty(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getProperty'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXTiledMap:getProperty");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getProperty'", nullptr);
			return 0;
		}
		const cocos2d::Value ret = cobj->getProperty(arg0);
		ccvalue_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getProperty", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getProperty'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getTileSets(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getTileSets'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getTileSets'", nullptr);
			return 0;
		}
		const Vector<L::TMXTileSet*>& ret = cobj->getTileSets();
		ccvector_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getTileSets", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getTileSets'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getLayers(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getLayers'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getLayers'", nullptr);
			return 0;
		}
		const Vector<L::TMXLayer*>& ret = cobj->getLayers();
		ccvector_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getLayers", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getLayers'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getObjectGroups(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getObjectGroups'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getObjectGroups'", nullptr);
			return 0;
		}
		const Vector<L::TMXObjectGroup*>& ret = cobj->getObjectGroups();
		ccvector_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getObjectGroups", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getObjectGroups'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getTileSet(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getTileSet'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXTiledMap:getTileSet");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getTileSet'", nullptr);
			return 0;
		}
		L::TMXTileSet *ret = cobj->getTileSet(arg0);
		if (ret){
			object_to_luaval(tolua_S, "L.TMXTileSet", ret);
		} else {
			lua_pushnil(tolua_S);
		}
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getTileSet", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getTileSet'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getLayer(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getLayer'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXTiledMap:getLayer");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getLayer'", nullptr);
			return 0;
		}
		L::TMXLayer *ret = cobj->getLayer(arg0);
		if (ret){
			object_to_luaval(tolua_S, "L.TMXLayer", ret);
		} else {
			lua_pushnil(tolua_S);
		}
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getLayer", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getLayer'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_getObjectGroup(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_getObjectGroup'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXTiledMap:getObjectGroup");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_getObjectGroup'", nullptr);
			return 0;
		}
		L::TMXObjectGroup *ret = cobj->getTMXObjectGroup(arg0);
		if (ret){
			object_to_luaval(tolua_S, "L.TMXObjectGroup", ret);
		} else {
			lua_pushnil(tolua_S);
		}
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:getObjectGroup", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_getObjectGroup'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTiledMap_showRegion(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTiledMap* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTiledMap", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTiledMap*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTiledMap_showRegion'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		Rect arg0;

		ok &= luaval_to_rect(tolua_S, 2, &arg0, "L.TMXTiledMap:showRegion");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTiledMap_showRegion'", nullptr);
			return 0;
		}
		cobj->showRegion(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTiledMap:showRegion", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTiledMap_showRegion'.", &tolua_err);
#endif

	return 0;
}

//-------------------------------------------------------------
// TMXLayer
//-------------------------------------------------------------

static int lua_L_TMXLayer_getName(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getName'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getName'", nullptr);
			return 0;
		}
		const std::string& ret = cobj->getName();
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getName", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getName'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_getLayerSize(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getLayerSize'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getLayerSize'", nullptr);
			return 0;
		}
		const Size& ret = cobj->getLayerSize();
		size_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getLayerSize", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getLayerSize'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_getProperties(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getProperties'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getProperties'", nullptr);
			return 0;
		}
		const cocos2d::ValueMap& ret = cobj->getProperties();
		ccvaluemap_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getProperties", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getProperties'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_getProperty(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getProperty'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXLayer:getProperty");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getProperty'", nullptr);
			return 0;
		}
		const cocos2d::Value ret = cobj->getProperty(arg0);
		ccvalue_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getProperty", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getProperty'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_getTiles(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getTiles'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getTiles'", nullptr);
			return 0;
		}
		const std::vector<int>& ret = cobj->getTiles();
		ccvector_int_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getTiles", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getTiles'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_getTileSize(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getTileSize'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getTileSize'", nullptr);
			return 0;
		}
		const Size& ret = cobj->getTileSize();
		size_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getTileSize", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getTileSize'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_getTileSet(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_getTileSet'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_getTileSet'", nullptr);
			return 0;
		}
		L::TMXTileSet *ret = cobj->getTileSet();
		object_to_luaval<L::TMXTileSet>(tolua_S, "L.TMXTileSet", (L::TMXTileSet*)ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:getTileSet", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_getTileSet'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXLayer_isVisible(lua_State* tolua_S) {
	int argc = 0;
	L::TMXLayer* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXLayer", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXLayer*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXLayer_isVisible'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXLayer_isVisible'", nullptr);
			return 0;
		}
		lua_pushboolean(tolua_S, cobj->isVisible());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXLayer:isVisible", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXLayer_isVisible'.", &tolua_err);
#endif

	return 0;
}
//-------------------------------------------------------------
// TMXTileSet
//-------------------------------------------------------------

static int lua_L_TMXTileSet_getName(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_getName'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_getName'", nullptr);
			return 0;
		}
		const std::string& ret = cobj->getName();
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:getName", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_getName'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTileSet_getTileSize(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_getTileSize'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_getTileSize'", nullptr);
			return 0;
		}
		const Size& ret = cobj->getTileSize();
		size_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:getTileSize", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_getTileSize'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTileSet_getSourceImage(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_getSourceImage'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_getSourceImage'", nullptr);
			return 0;
		}
		const std::string& ret = cobj->getSourceImage();
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:getSourceImage", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_getSourceImage'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTileSet_getImageSize(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_getImageSize'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_getImageSize'", nullptr);
			return 0;
		}
		const Size& ret = cobj->getImageSize();
		size_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:getImageSize", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_getImageSize'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTileSet_getProperties(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_getProperties'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		int arg0;

		ok &= luaval_to_int32(tolua_S, 2, &arg0, "L.TMXTileSet:getProperties");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_getProperties'", nullptr);
			return 0;
		}
		const ValueMap& ret = cobj->getProperties(arg0);
		ccvaluemap_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:getProperties", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_getProperties'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTileSet_getProperty(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_getProperty'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 2) {
		int arg0;
		std::string arg1;

		ok &= luaval_to_int32(tolua_S, 2, &arg0, "L.TMXTileSet:getProperty");
		ok &= luaval_to_std_string(tolua_S, 3, &arg1, "L.TMXTileSet:getProperty");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_getProperty'", nullptr);
			return 0;
		}
		const Value& ret = cobj->getProperty(arg0, arg1);
		ccvalue_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:getProperty", argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_getProperty'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXTileSet_isAnimeTile(lua_State* tolua_S) {
	int argc = 0;
	L::TMXTileSet* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXTileSet", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXTileSet*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXTileSet_isAnimeTile'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		int arg0;

		ok &= luaval_to_int32(tolua_S, 2, &arg0, "L.TMXTileSet:isAnimeTile");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXTileSet_isAnimeTile'", nullptr);
			return 0;
		}
		bool ret = cobj->isAnimeTile(arg0);
		lua_pushboolean(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXTileSet:isAnimeTile", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXTileSet_isAnimeTile'.", &tolua_err);
#endif

	return 0;
}

//-------------------------------------------------------------
// TMXObjectGroup
//-------------------------------------------------------------

static int lua_L_TMXObjectGroup_getName(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObjectGroup* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObjectGroup", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObjectGroup*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObjectGroup_getName'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObjectGroup_getName'", nullptr);
			return 0;
		}
		const std::string& ret = cobj->getName();
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObjectGroup:getName", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObjectGroup_getName'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObjectGroup_getProperties(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObjectGroup* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObjectGroup", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObjectGroup*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObjectGroup_getProperties'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObjectGroup_getProperties'", nullptr);
			return 0;
		}
		const cocos2d::ValueMap& ret = cobj->getProperties();
		ccvaluemap_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObjectGroup:getProperties", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObjectGroup_getProperties'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObjectGroup_getProperty(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObjectGroup* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObjectGroup", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObjectGroup*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObjectGroup_getProperty'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXObjectGroup:getProperty");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObjectGroup_getProperty'", nullptr);
			return 0;
		}
		const cocos2d::Value ret = cobj->getProperty(arg0);
		ccvalue_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObjectGroup:getProperty", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObjectGroup_getProperty'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObjectGroup_getObjects(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObjectGroup* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObjectGroup", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObjectGroup*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObjectGroup_getObjects'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObjectGroup_getObjects'", nullptr);
			return 0;
		}
		const Vector<L::TMXObject*>& ret = cobj->getObjects();
		ccvector_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObjectGroup:getObjects", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObjectGroup_getObjects'.", &tolua_err);
#endif

	return 0;
}

//-------------------------------------------------------------
// TMXObject
//-------------------------------------------------------------

static int lua_L_TMXObject_getId(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_getId'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_getId'", nullptr);
			return 0;
		}
		int ret = cobj->getId();
		lua_pushinteger(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:getId", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_getId'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_getType(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_getType'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_getType'", nullptr);
			return 0;
		}
		const std::string& ret = cobj->getType();
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:getType", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_getType'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_getName(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_getName'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_getName'", nullptr);
			return 0;
		}
		const std::string& ret = cobj->getName();
		lua_pushlstring(tolua_S, ret.c_str(), ret.length());
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:getName", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_getName'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_getProperties(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_getProperties'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_getProperties'", nullptr);
			return 0;
		}
		const cocos2d::ValueMap& ret = cobj->getProperties();
		ccvaluemap_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:getProperties", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_getProperties'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_getProperty(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_getProperty'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0, "L.TMXObject:getProperty");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_getProperty'", nullptr);
			return 0;
		}
		const cocos2d::Value ret = cobj->getProperty(arg0);
		ccvalue_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:getProperty", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_getProperty'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_getBounds(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_getBounds'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_getBounds'", nullptr);
			return 0;
		}
		cocos2d::Rect ret = cobj->getBounds();
		rect_to_luaval(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:getBounds", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_getBounds'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_isVisible(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_isVisible'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0) {
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_isVisible'", nullptr);
			return 0;
		}
		bool ret = cobj->isVisible();
		lua_pushboolean(tolua_S, ret);
		return 1;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:isVisible", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_isVisible'.", &tolua_err);
#endif

	return 0;
}

static int lua_L_TMXObject_setVisible(lua_State* tolua_S) {
	int argc = 0;
	L::TMXObject* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "L.TMXObject", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (L::TMXObject*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj) {
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_L_TMXObject_setVisible'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1) {
		bool arg0;

		ok &= luaval_to_boolean(tolua_S, 2, &arg0, "L.TMXObject:setVisible");
		if (!ok) {
			tolua_error(tolua_S, "invalid arguments in function 'lua_L_TMXObject_setVisible'", nullptr);
			return 0;
		}
		cobj->setVisible(arg0);
		return 0;
	}
	luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "L.TMXObject:setVisible", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
	tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_L_TMXObject_setVisible'.", &tolua_err);
#endif

	return 0;
}

//--------------------------------------------------------------
TOLUA_API int register_L_tmxmap(lua_State* L) {
	tolua_open(L);
	lua_reg_tmxmap(L);
	tolua_module(L, "L", 0);
	tolua_beginmodule(L, "L");

	  tolua_cclass(L, "TMXTiledMap", "L.TMXTiledMap", "cc.Node", nullptr);
	  tolua_beginmodule(L, "TMXTiledMap");
	    tolua_function(L, "create", lua_L_TMXTiledMap_create);
		tolua_function(L, "getMapSize", lua_L_TMXTiledMap_getMapSize);
		tolua_function(L, "getTileSize", lua_L_TMXTiledMap_getTileSize);
		tolua_function(L, "getProperties", lua_L_TMXTiledMap_getProperties);
		tolua_function(L, "getProperty", lua_L_TMXTiledMap_getProperty);
		tolua_function(L, "getLayerCount", lua_L_TMXTiledMap_getLayerCount);
		tolua_function(L, "getOrientation", lua_L_TMXTiledMap_getOrientation);
		tolua_function(L, "getStaggerAxis", lua_L_TMXTiledMap_getStaggerAxis);
		tolua_function(L, "getStaggerIndex", lua_L_TMXTiledMap_getStaggerIndex);
		tolua_function(L, "getHexSideLength", lua_L_TMXTiledMap_getHexSideLength);
		tolua_function(L, "getTileSets", lua_L_TMXTiledMap_getTileSets);
		tolua_function(L, "getLayers", lua_L_TMXTiledMap_getLayers);
		tolua_function(L, "getObjectGroups", lua_L_TMXTiledMap_getObjectGroups);
		tolua_function(L, "getTileSet", lua_L_TMXTiledMap_getTileSet);
		tolua_function(L, "getLayer", lua_L_TMXTiledMap_getLayer);
		tolua_function(L, "getObjectGroup", lua_L_TMXTiledMap_getObjectGroup);
		tolua_function(L, "showRegion", lua_L_TMXTiledMap_showRegion);
	  tolua_endmodule(L);
	  g_luaType[typeid(L::TMXTiledMap).name()] = "L.TMXTiledMap";

	  tolua_cclass(L, "TMXLayer", "L.TMXLayer", "cc.SpriteBatchNode", nullptr);
	  tolua_beginmodule(L, "TMXLayer");
	    tolua_function(L, "getName", lua_L_TMXLayer_getName);
		tolua_function(L, "getLayerSize", lua_L_TMXLayer_getLayerSize);
		tolua_function(L, "getProperties", lua_L_TMXLayer_getProperties);
		tolua_function(L, "getProperty", lua_L_TMXLayer_getProperty);
		tolua_function(L, "getTiles", lua_L_TMXLayer_getTiles);
		tolua_function(L, "getTileSize", lua_L_TMXLayer_getTileSize);
		tolua_function(L, "getTileSet", lua_L_TMXLayer_getTileSet);
		tolua_function(L, "isVisible", lua_L_TMXLayer_isVisible);
	  tolua_endmodule(L);
	  g_luaType[typeid(L::TMXLayer).name()] = "L.TMXLayer";

	  tolua_cclass(L, "TMXTileSet", "L.TMXTileSet", "cc.Ref", nullptr);
	  tolua_beginmodule(L, "TMXTileSet");
	    tolua_function(L, "getName", lua_L_TMXTileSet_getName);
		tolua_function(L, "getTileSize", lua_L_TMXTileSet_getTileSize);
		tolua_function(L, "getSourceImage", lua_L_TMXTileSet_getSourceImage);
		tolua_function(L, "getImageSize", lua_L_TMXTileSet_getImageSize);
		tolua_function(L, "getProperties", lua_L_TMXTileSet_getProperties);
		tolua_function(L, "getProperty", lua_L_TMXTileSet_getProperty);
		tolua_function(L, "isAnimeTile", lua_L_TMXTileSet_isAnimeTile);
	  tolua_endmodule(L);
	  g_luaType[typeid(L::TMXTileSet).name()] = "L.TMXTileSet";

	  tolua_cclass(L, "TMXObjectGroup", "L.TMXObjectGroup", "cc.Ref", nullptr);
	  tolua_beginmodule(L, "TMXObjectGroup");
	    tolua_function(L, "getName", lua_L_TMXObjectGroup_getName);
		tolua_function(L, "getProperties", lua_L_TMXObjectGroup_getProperties);
		tolua_function(L, "getProperty", lua_L_TMXObjectGroup_getProperty);
		tolua_function(L, "getObjects", lua_L_TMXObjectGroup_getObjects);
	  tolua_endmodule(L);
	  g_luaType[typeid(L::TMXObjectGroup).name()] = "L.TMXObjectGroup";

	  tolua_cclass(L, "TMXObject", "L.TMXObject", "cc.Ref", nullptr);
	  tolua_beginmodule(L, "TMXObject");
	    tolua_function(L, "getId", lua_L_TMXObject_getId);
		tolua_function(L, "getType", lua_L_TMXObject_getType);
	    tolua_function(L, "getName", lua_L_TMXObject_getName);
		tolua_function(L, "getProperties", lua_L_TMXObject_getProperties);
		tolua_function(L, "getProperty", lua_L_TMXObject_getProperty);
		tolua_function(L, "getBounds", lua_L_TMXObject_getBounds);
		tolua_function(L, "isVisible", lua_L_TMXObject_isVisible);
		tolua_function(L, "setVisible", lua_L_TMXObject_setVisible);
	  tolua_endmodule(L);
	  g_luaType[typeid(L::TMXObject).name()] = "L.TMXObject";

	tolua_endmodule(L);
	return 1;
}

