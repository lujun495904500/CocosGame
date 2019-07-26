--[[
	模型管理器
--]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Model__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/models/", "res/models/")

local ModelManager = class("ModelManager")

-- 获得单例对象
local instance = nil
function ModelManager:getInstance()
	if instance == nil then
		instance = ModelManager:create()
	end
	return instance
end

-- 注册元数据
function ModelManager:registerMeta(type, meta)
	metaMgr:registerMeta(C_MODULE_NAME, type, meta)
end

-- 释放元数据
function ModelManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 释放模型
function ModelManager:releaseModels(preload)
	metaMgr:releaseClasses(C_MODULE_NAME, preload)
end

-- 获得模型
function ModelManager:getModel(mname)
	return metaMgr:getClass(C_MODULE_NAME, mname)
end

-- 创建模型对象
function ModelManager:createObject(mname, ...)
	return metaMgr:createObject(C_MODULE_NAME, mname, ...)
end

-- 预加载模型
function ModelManager:preloadModel(mname)
	metaMgr:preloadClass(C_MODULE_NAME, mname)
end

-- 获取所有模型
function ModelManager:getAllModels()
	return metaMgr:getAllClasses(C_MODULE_NAME)
end

-- 加载所有模型
function ModelManager:loadAllModels()
	metaMgr:loadAllClasses(C_MODULE_NAME)
end

-- 输出管理器当前状态
function ModelManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return ModelManager
