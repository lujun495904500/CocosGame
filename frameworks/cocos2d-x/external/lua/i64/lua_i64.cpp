#include "lua_i64.h"

#define I64_METATABLE	("__i64@meta")
typedef long long i64;
#if defined(_WIN32) && defined(_WINDOWS)
#define I64_FORMAT "%I64d"
#else
#define I64_FORMAT "%lld"
#endif

#define I64_CREATE(value)	*(i64*)lua_newuserdata(L, sizeof(i64)) = value;\
							luaL_getmetatable(L, I64_METATABLE);\
							lua_setmetatable(L, -2);\

#define I64_MATH(op)	i64 lvalue = 0, rvalue = 0;\
						if (lua_isnumber(L, 1)) {\
							lvalue = lua_tointeger(L, 1);\
						}\
						else if (lua_isuserdata(L, 1)) {\
							lvalue = *(i64*)luaL_checkudata(L, 1, I64_METATABLE);\
						}\
						else {\
							luaL_error(L, "param %d is not number!", 1);\
						}\
						if (lua_isnumber(L, 2)) {\
							rvalue = lua_tointeger(L, 2);\
						}\
						else if (lua_isuserdata(L, 2)) {\
							rvalue = *(i64*)luaL_checkudata(L, 2, I64_METATABLE);\
						}\
						else {\
							luaL_error(L, "param %d is not number!", 2);\
						}\
						I64_CREATE(lvalue op rvalue);\
						return 1;\

#define I64_COMP(op)	i64 lvalue = 0, rvalue = 0;\
						if (lua_isnumber(L, 1)) {\
							lvalue = lua_tointeger(L, 1);\
						}\
						else if (lua_isuserdata(L, 1)) {\
							lvalue = *(i64*)luaL_checkudata(L, 1, I64_METATABLE);\
						}\
						else {\
							luaL_error(L, "param %d is not number!", 1);\
						}\
						if (lua_isnumber(L, 2)) {\
							rvalue = lua_tointeger(L, 2);\
						}\
						else if (lua_isuserdata(L, 2)) {\
							rvalue = *(i64*)luaL_checkudata(L, 2, I64_METATABLE);\
						}\
						else {\
							luaL_error(L, "param %d is not number!", 2);\
						}\
						lua_pushboolean(L,lvalue op rvalue);\
						return 1;\

static int CI64_new(lua_State *L) {
	i64 initval = 0;
	if (lua_gettop(L) > 0) {
		if (lua_isnumber(L, 1)) {
			initval = lua_tointeger(L, 1);
		}
		else if (lua_isuserdata(L, 1)) {
			initval = *(i64*)luaL_checkudata(L, 1, I64_METATABLE);
		}
		if (lua_gettop(L) > 1) {
			initval |= int(lua_tointeger(L, 2)) << 32;
		}
	}
	I64_CREATE(initval);
	return 1;
}

static int CI64_add(lua_State *L) {
	I64_MATH(+)
}

static int CI64_sub(lua_State *L) {
	I64_MATH(-)
}

static int CI64_div(lua_State *L) {
	I64_MATH(/)
}

static int CI64_mul(lua_State *L) {
	I64_MATH(*)
}

static int CI64_mod(lua_State *L) {
	I64_MATH(%)
}

static int CI64_eq(lua_State *L) {
	I64_COMP(==)
}

static int CI64_lt(lua_State *L) {
	I64_COMP(<)
}

static int CI64_le(lua_State *L) {
	I64_COMP(<=)
}

static int CI64_tostring(lua_State *L) {
	char temp[64];
	sprintf(temp, I64_FORMAT, *(i64*)luaL_checkudata(L, 1, I64_METATABLE));
	lua_pushstring(L, temp);
	return 1;
}

// 元表函数
static const struct luaL_Reg i64meta_lib[] = {
	{ "__add", CI64_add },
	{ "__sub", CI64_sub },
	{ "__div", CI64_div },
	{ "__mul", CI64_mul },
	{ "__mod", CI64_mod },
	{ "__eq", CI64_eq },
	{ "__lt", CI64_lt },
	{ "__le", CI64_le },
	{ "__tostring", CI64_tostring },
	{ NULL, NULL }
};

// i64函数
static const struct luaL_Reg i64_lib[] = {
	{ "new", CI64_new },
	{ NULL, NULL }
};

void require_i64(lua_State* L) {

	luaL_newmetatable(L, I64_METATABLE);
	for (const luaL_Reg *reg = i64meta_lib; reg->name; reg++) {
		lua_pushstring(L, reg->name);
		lua_pushcfunction(L, reg->func);
		lua_rawset(L, -3);
	}

	luaL_register(L, "i64", i64_lib);
}

/**
	i64 库比较的时候必须都转换为 i64对象
*/
