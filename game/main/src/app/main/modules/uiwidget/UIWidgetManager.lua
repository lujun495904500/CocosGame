--[[
	UI组件管理器
--]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__UIWidget__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/uiwidgets/", "res/uis/widgets/")

local UIWidgetManager = class("UIWidgetManager")

-- 获得单例对象
local instance = nil
function UIWidgetManager:getInstance()
	if instance == nil then
		instance = UIWidgetManager:create()
	end
	return instance
end

-- 注册元数据
function UIWidgetManager:registerMeta(type, meta)
	metaMgr:registerMeta(C_MODULE_NAME, type, meta)
end

-- 释放元数据
function UIWidgetManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 释放组件
function UIWidgetManager:releaseWidgets(preload)
	metaMgr:releaseClasses(C_MODULE_NAME, preload)
end

-- 获得组件
function UIWidgetManager:getWidget(wgtype)
	return metaMgr:getClass(C_MODULE_NAME, wgtype)
end

-- 创建组件对象
function UIWidgetManager:createObject(wgtype, ...)
	return metaMgr:createObject(C_MODULE_NAME, wgtype, ...)
end

-- 预加载组件
function UIWidgetManager:preloadWidget(wgtype)
	metaMgr:preloadClass(C_MODULE_NAME, wgtype)
end

-- 获取所有组件
function UIWidgetManager:getAllWidgets()
	return metaMgr:getAllClasses(C_MODULE_NAME)
end

-- 加载所有组件
function UIWidgetManager:loadAllWidgets()
	metaMgr:loadAllClasses(C_MODULE_NAME)
end

-- 输出管理器当前状态
function UIWidgetManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return UIWidgetManager
