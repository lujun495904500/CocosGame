--[[
	可序列化接口
--]]
local THIS_MODULE = ...

local Serializable = class("Serializable", require("app.main.modules.meta.MetaBase"))

-- 保存序列
function Serializable:saveSerialize(serialize) end

-- 加载序列
function Serializable:loadSerialize(serialize) end

return Serializable
