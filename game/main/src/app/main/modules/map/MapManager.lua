--[[
	地图管理器
--]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Map__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/maps/", "res/maps/")

local MapManager = class("MapManager")

-- 获得单例对象
local instance = nil
function MapManager:getInstance()
	if instance == nil then
		instance = MapManager:create()
	end
	return instance
end

-- 注册元数据
function MapManager:registerMeta(type,meta)
	metaMgr:registerMeta(C_MODULE_NAME,type,meta)
end

-- 释放元数据
function MapManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 释放未使用的地图
function MapManager:releaseMaps(preload)
	metaMgr:releaseClasses(C_MODULE_NAME, preload)
end

-- 获得地图（名称）
function MapManager:getMap(mname)
	return metaMgr:getClass(C_MODULE_NAME, mname)
end

-- 创建地图对象
function MapManager:createObject(mname)
	return metaMgr:createObject(C_MODULE_NAME, mname)
end

-- 预加载地图
function MapManager:preloadMap(mname)
	metaMgr:preloadClass(C_MODULE_NAME, mname)
end

-- 获取所有地图
function MapManager:getAllMaps()
	return metaMgr:getAllClasses(C_MODULE_NAME)
end

-- 加载所有地图
function MapManager:loadAllMaps()
	metaMgr:loadAllClasses(C_MODULE_NAME)
end

-- 输出管理器当前状态
function MapManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return MapManager
