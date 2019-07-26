--[[
	阵形 八卦阵
]]

local EightDiagrams = class("EightDiagrams", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function EightDiagrams:ctor(config)
	table.merge(self,config)
end

--[[
	执行函数
	fid					阵形ID
	front				正面角色
	team				队伍

	onComplete			完成回调
	optype				操作类型
	config
		immediately		立即完成
]]
function EightDiagrams:execute(onComplete,optype,config) 
	self._roles = self.team:getRoles()
	
	-- 设置阵形属性
	self.team:setFormationAddition(optype == "SETUP" and {
		speed = formationMgr:getAddition(self.fid,"speed"),
		stgydodge = formationMgr:getAddition(self.fid,"stgydodge"),
		atkdodge = formationMgr:getAddition(self.fid,"atkdodge"),
	} or nil)

	-- 设置角色状态
	local atkno = true
	for i,role in ipairs(self._roles) do
		if role:getEntity():getID() == self.front then
			atkno = false
		elseif i ~= #self._roles or not atkno then
			role:setState(atkno and "ATKNO" or "ATKBACK","F_BG",optype == "SETUP")
		end
	end

	if onComplete then onComplete() end
end

return EightDiagrams
