--[[
	类布局接口
]]
local THIS_MODULE = ...

-- UI类索引路径
local C_UICLASS_IPATH = "res/uis/classes"

local ClassLayout = class("ClassLayout", require("app.main.modules.ui.UIBindable"))

-- 安装布局
function ClassLayout:setupLayout()
	local config = indexMgr:readJsonConfig(indexMgr:getIndex(C_UICLASS_IPATH .. "/" .. self.__cname))
	if config.params then
		table.merge(self,config.params)
	end
	local resnode = cc.CSLoader:createNode(config.csb)
	self:addChild(resnode)
	self:bindUI(resnode,config.widgets,config.bindings,true)
end

return ClassLayout
