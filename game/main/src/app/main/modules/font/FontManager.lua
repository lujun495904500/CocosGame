--[[
	字体管理器
--]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Font__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/fonts/", "res/fonts/")

local FontManager = class("FontManager")

-- 获得单例对象
local instance = nil
function FontManager:getInstance()
	if instance == nil then
		instance = FontManager:create()
	end
	return instance
end

-- 注册元数据
function FontManager:registerMeta(type, meta)
	metaMgr:registerMeta(C_MODULE_NAME, type, meta)
end

-- 释放元数据
function FontManager:releaseMetas()
	metaMgr:releaseMetas(C_MODULE_NAME)
end

-- 释放字体
function FontManager:releaseFonts(preload)
	metaMgr:releaseClasses(C_MODULE_NAME, preload)
end

-- 获得字体
function FontManager:getFont(fname)
	return metaMgr:getClass(C_MODULE_NAME, fname)
end

-- 根据字体创建标签
function FontManager:createLabel(fname, ftext, fparams)
	return metaMgr:createObject(C_MODULE_NAME, fname, ftext, fparams)
end

-- 预加载字体
function FontManager:preloadFont(fname)
	metaMgr:preloadClass(C_MODULE_NAME, fname)
end

-- 获取所有字体
function FontManager:getAllFonts()
	return metaMgr:getAllClasses(C_MODULE_NAME)
end

-- 加载所有字体
function FontManager:loadAllFonts()
	metaMgr:loadAllClasses(C_MODULE_NAME)
end

-- 输出管理器当前状态
function FontManager:dump()
	metaMgr:dumpModule(C_MODULE_NAME)
end

return FontManager
