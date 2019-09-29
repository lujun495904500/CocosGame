--[[	包管理器
]]
local THIS_MODULE = ...
local C_LOGTAG = "PackManager"

local utils = cc.safe_require("utils")
local PackLoader = import(".PackLoader")
local PackManager = class("PackManager")

-- 获得单例对象
local instance = nil
function PackManager:getInstance()
    if instance == nil then
        instance = PackManager:create()
    end
    return instance
end

-- 构造函数
function PackManager:ctor()
    self._identify = 0
end

-- 创建指定包名的包加载器
function PackManager:createPackLoader(packname)
	local plua = utils.get_real_luafile("app/" .. packname .. "/loader.lua")
	local loadcls = plua and dofile(plua) or PackLoader
	return loadcls:create(packname)
end

-- 加载指定包
function PackManager:loadPack(packname)
    local pack = PACK.LOADED[packname]
    if not pack then
        local packpath = PACKSPATH .. packname .. PACK.FORMAT
        if fileMgr:loadFilePack(packpath) then
            pack = {
                name = packname,
                file = packname .. PACK.FORMAT,
				path = packpath,
				version = fileMgr:getPackVersion(packname),
				loader = self:createPackLoader(packname)
            }
			PACK.LOADED[packname] = pack
			pack.loader:onLoad()
			logMgr:info(C_LOGTAG, "LOADED PACK { name=%s, version=%s }", pack.name, utils.get_version_name(pack.version))
            self._identify = os.time()
        end
    end
    return pack
end

-- 释放指定包
function PackManager:releasePack(packname)
    local pack = PACK.LOADED[packname]
	if pack then
		pack.loader:onRelease()
        fileMgr:releaseFilePack(packname)
		PACK.LOADED[packname] = nil
		utils.remove_module("^app[.]" .. packname .. "[.].*$")
		logMgr:info(C_LOGTAG, "RELEASED PACK { name=%s, version=%s }", pack.name, utils.get_version_name(pack.version))
        self._identify = os.time()
    end
end

-- 获得加载的包
function PackManager:getPacks()
    return PACK.LOADED
end

-- 获得指定加载的包
function PackManager:getPack(packname)
    return PACK.LOADED[packname]
end

-- 获得启动包
function PackManager:getBootPack()
    return PACK.BOOT
end

-- 检查是否是基础包
function PackManager:isBasePack(packname)
    for _, pname in ipairs(PACK.BASES) do
        if packname == pname then
            return true
        end
    end
end

-- 获得当前包识别ID
function PackManager:getIdentify()
    return self._identify
end

return PackManager
