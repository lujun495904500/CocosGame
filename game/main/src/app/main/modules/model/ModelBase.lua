--[[
	模型基类
--]]

local ModelBase = class("ModelBase", cc.Node)

-- 获得模型名称
function ModelBase:getName()
	return ""
end

return ModelBase
