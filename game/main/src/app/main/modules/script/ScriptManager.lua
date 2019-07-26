--[[
	脚本管理器
]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Script__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/scripts/")

local ScriptManager = class("ScriptManager")

-- 获得单例对象
local instance = nil
function ScriptManager:getInstance()
	if instance == nil then
		instance = ScriptManager:create()
	end
	return instance
end

-- 注册脚本
function ScriptManager:registerScript(sname, script)
	metaMgr:registerMeta(C_MODULE_NAME, sname, script)
end

-- 释放脚本
function ScriptManager:releaseScripts()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 获得脚本
function ScriptManager:getScript(sname)
	return metaMgr:getMeta(C_MODULE_NAME, sname)
end

-- 脚本调用
local function callScript(instance, ...)
	instance:execute(...)
end

-- 创建脚本对象
function ScriptManager:createObject(sname, ...)
	local scriptobj = metaMgr:createObject(C_MODULE_NAME, sname, ...)
	if scriptobj then
		getmetatable(scriptobj).__call = callScript
	end
	return scriptobj
end

-- 输出管理器当前状态
function ScriptManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return ScriptManager
