--[[
	CharMap字体
--]]

local CharMapFont = class("CharMapFont", cc.Label, require("app.main.modules.font.FontBase"))

-- 类扩展构造
function CharMapFont:clsctor(config)
	table.merge(self,config)
	self._alias = display.loadImage(self.image)
	self._alias:retain()
end

-- 类扩展析构
function CharMapFont:clsdtor(config)
	self._alias:release()
end

-- 构造函数
function CharMapFont:ctor(text,params)
	self:setCharMap(self._alias,self.size[1],self.size[2],self.start)
	self:setString(text)
end

-- 析构函数
function CharMapFont:dtor()
	
end

-- 获得当前字体尺寸
function CharMapFont:getLabelSize()
	return self:getContentSize()
end

-- 获得字体的高度
function CharMapFont:getFontHeight()
	return self.size[2]
end

-- 获得字符的宽度(UTF字符)
function CharMapFont:getCharWidth(uch)
	return self.size[1]
end

-- 获得字符的最大宽度
function CharMapFont:getCharMaxWidth()
	return self.size[1]
end

-- 获得字体名称
function CharMapFont:getName()
	return self.name
end

return CharMapFont
