--[[
	序列化管理器
]]
local THIS_MODULE = ...

-- 模块名
local C_MODULE_NAME = "__Serialize__"

-- 注册模块元数据配置
metaMgr:registerModule(C_MODULE_NAME, "src/serializes/")

local SerializeManager = class("SerializeManager")

-- 获得单例对象
local instance = nil
function SerializeManager:getInstance()
	if instance == nil then
		instance = SerializeManager:create()
	end
	return instance
end

-- 保存对象
function SerializeManager:save(object)
	if object then
		if iskindof(object,"Serializable") then
			return {
				type = object.__cname,
				data = object:saveSerialize()
			}
		else 
			return self:saveMap(object)
		end
	end
end

-- 加载序列数据
function SerializeManager:load(archive)
	if archive then
		if archive.type == "__Map__" then
			return self:loadMap(archive.data)
		else
			local meta = metaMgr:getMeta(C_MODULE_NAME, archive.type)
			if not meta then
				error("meta [" .. archive.type .. "] is't found !!!")
			end
			return meta:create("SERIALIZE",archive.data)
		end
	end
end

-- 保存Map
function SerializeManager:saveMap(map)
	local data = {}
	for key,object in pairs(map) do
		data[key] = self:save(object)
	end
	return {
		type = "__Map__",
		data = data
	}
end

-- 加载Map
function SerializeManager:loadMap(data)
	local map = {}
	for key,archive in pairs(data) do
		map[key] = self:load(archive)
	end
	return map
end

return SerializeManager
