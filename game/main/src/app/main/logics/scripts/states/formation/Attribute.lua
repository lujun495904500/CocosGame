--[[
	阵形 属性
]]

local Attribute = class("Attribute", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Attribute:ctor(config)
	if config then
		table.merge(self,config)
	end
end

--[[
	执行函数
	fid				阵形ID
	team			队伍

	onComplete		完成回调
	optype			操作类型
	config
		immediately	立即完成
]]
function Attribute:execute(onComplete,optype,config) 
	-- 设置阵形属性
	self.team:setFormationAddition(optype == "SETUP" and {
		speed = formationMgr:getAddition(self.fid,"speed"),
		stgydodge = formationMgr:getAddition(self.fid,"stgydodge"),
		atkdodge = formationMgr:getAddition(self.fid,"atkdodge"),
	} or nil)
	if onComplete then onComplete() end
end

return Attribute
