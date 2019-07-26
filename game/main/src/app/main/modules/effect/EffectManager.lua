--[[
	特效管理器
--]]

local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Effect__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/effects/", "res/effects/")

local EffectManager = class("EffectManager")

-- 获得单例对象
local instance = nil
function EffectManager:getInstance()
	if instance == nil then
		instance = EffectManager:create()
	end
	return instance
end

-- 注册元数据
function EffectManager:registerMeta(type, meta)
	metaMgr:registerMeta(C_MODULE_NAME, type, meta)
end

-- 释放元数据
function EffectManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 释放特效
function EffectManager:releaseEffects(preload)
	metaMgr:releaseClasses(C_MODULE_NAME, preload)
end

-- 获得特效
function EffectManager:getEffect(ename)
	return metaMgr:getClass(C_MODULE_NAME, ename)
end

-- 创建特效对象
function EffectManager:createObject(ename,params)
	return metaMgr:createObject(C_MODULE_NAME, ename, params)
end

-- 预加载特效
function EffectManager:preloadEffect(ename)
	metaMgr:preloadClass(C_MODULE_NAME, ename)
end

-- 获取所有特效
function EffectManager:getAllEffects()
	return metaMgr:getAllClasses(C_MODULE_NAME)
end

-- 加载所有特效
function EffectManager:loadAllEffects()
	metaMgr:loadAllClasses(C_MODULE_NAME)
end

-- 输出管理器当前状态
function EffectManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return EffectManager
