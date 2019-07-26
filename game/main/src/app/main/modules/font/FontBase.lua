--[[
	字体基类
--]]

local FontBase = class("FontBase", require("app.main.modules.meta.MetaBase"))

-- 获得当前字体尺寸
function FontBase:getLabelSize()
	return cc.size(0,0)
end

-- 获得字体的高度
function FontBase:getFontHeight()
	return 0
end

-- 获得字符的宽度(UTF字符)
function FontBase:getCharWidth(uch)
	return 0
end

-- 获得字符的最大宽度
function FontBase:getCharMaxWidth()
	return 0
end

-- 获得字体名称
function FontBase:getName()
	return ""
end

return FontBase
