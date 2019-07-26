--[[
	阵形 静寂
]]

local Silence = class("Silence", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Silence:ctor(config)
	table.merge(self,config)
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
function Silence:execute(onComplete,optype,config) 
	-- 设置阵形属性
	self.team:setFormationAddition(optype == "SETUP" and {
		speed = formationMgr:getAddition(self.fid,"speed"),
		stgydodge = formationMgr:getAddition(self.fid,"stgydodge"),
		atkdodge = formationMgr:getAddition(self.fid,"atkdodge"),
	} or nil)

	table.asyn_walk_together(onComplete,self.team:getRoles(),function (onComplete_,role)
		role:setRoleHide(onComplete_,
			optype == "SETUP",
			{ immediately = config.immediately })
	end)
end

return Silence
