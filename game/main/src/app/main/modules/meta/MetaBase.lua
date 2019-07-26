--[[
	元数据基类
]]

local MetaBase = class("MetaBase")

-- 获得元数据类型
function MetaBase:getMetaType()
	return self._metatype or self:getClassName()
end

-- 设置元数据类型
function MetaBase:setMetaType(metatype)
	self._metatype = metatype
end

-- 获得类名
function MetaBase:getClassName()
	return self.clsname or self.__cname
end

-- 析构函数
function MetaBase:dtor() end

-- 类构造函数
function MetaBase:clsctor(config) end

-- 类析构函数
function MetaBase:clsdtor() end

return MetaBase
