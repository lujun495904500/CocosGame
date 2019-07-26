--[[
	状态列表
]]
local THIS_MODULE = ...

local StatesList = class("StatesList")

--[[
	初始化状态列表
	template 状态模板
	例如;
	{
		-- 战斗(状态类型)
		BATTLE = {
			LOSECTRL = false,   -- 失控(初始状态)
		},
		-- 回合(状态类型)
		ROUND = {
			DEFENSE = false,	-- 防御(初始状态)
		}
	}
]]
function StatesList:initStates(template)
	self._structs = {}		-- 状态结构
	self._initvals = {}		-- 初始值

	for stype,svalues in pairs(template) do
		local struct = {}
		local initval = 0

		local index = 1
		for sname,svalue in pairs(svalues) do
			local state = bit.lshift(1,index-1)
			struct[sname] = state
			if svalue then
				initval = initval + state
			end
			index = index + 1
		end

		self._structs[stype] = struct
		self._initvals[stype] = initval
	end

	self:clearStates()
end

-- 状态改变回调
function StatesList:onStatesChange(stype,state) end

--[[
	设置状态
	stype	   类型名
	sname	   状态名
	state	   值
]] 
function StatesList:setState(stype,sname,state)
	local oldstate = self._states[stype]
	if state then
		self._states[stype] = bit.bor(self._states[stype],self._structs[stype][sname])
	else
		self._states[stype] = bit.band(self._states[stype],bit.bnot(self._structs[stype][sname]))
	end
	local nowstate = self._states[stype]
	if oldstate ~= nowstate then
		self:onStatesChange(stype, nowstate)
	end
end

--[[
	检查状态
	stype	   类型名
	sname	   状态名
]] 
function StatesList:checkState(stype,sname)
	return (bit.band(self._states[stype],self._structs[stype][sname]) ~= 0)
end

--[[
	检查某一类型的状态
	stype	   类型名
]]
function StatesList:checkStates(stype)
	return self._states[stype] ~= 0
end

--[[
	清空状态
	stype	   类型名,如果为nil则清空所有状态
]]
function StatesList:clearStates(stype)
	if not stype then
		self._states = {}
		for stype,_ in pairs(self._structs) do
			self._states[stype] = self._initvals[stype]
		end
	elseif type(stype) == "table" then
		for _,_stype in ipairs(stype) do
			self._states[_stype] = self._initvals[_stype]
		end
	else
		self._states[stype] = self._initvals[stype]
	end
end

-- 输出所有状态
function StatesList:dumpStates()
	dump(self._states)
end

return StatesList
