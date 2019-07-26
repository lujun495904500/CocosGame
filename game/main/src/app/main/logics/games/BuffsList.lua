--[[
	增益列表
]]
local THIS_MODULE = ...

local BuffsList = class("BuffsList")

-- 初始化Buffs
function BuffsList:initBuffs(buffscene)
	self._buffs = {}
	self._buffscene = buffscene
end

-- 安装Buffs
function BuffsList:setupBuffs(onComplete,buffs)
	table.asyn_walk_sequence(onComplete,table.keys(buffs),function (onComplete_,bid)
		local state = buffs[bid]
		if not state then
			onComplete_(false)
		else
			self:setupBuff(onComplete_,bid,state)
		end
	end)
end

-- 安装指定Buff
function BuffsList:setupBuff(onComplete,bid,state)
	local config = buffMgr:getConfig(bid)
	if ((self._buffscene == "M") and config.map) or 
		((self._buffscene == "B") and config.battle) then
		local buff = scriptMgr:createObject(config.script,table.merge({
			bid = bid,
			state = state,
			target = self,
		},config))
		if buff then
			return buff:execute(function (result)
				if result then
					self._buffs[bid] = buff
				end
				if onComplete then onComplete(result) end
			end,"SETUP")
		end
	end
	if onComplete then onComplete(false) end
end

-- 删除指定Buff
function BuffsList:deleteBuff(onComplete,bid)
	local buff = self._buffs[bid]
	if buff then
		return buff:execute(function (result)
			if result then
				self._buffs[bid] = nil
			end
			if onComplete then onComplete(result) end
		end,"DELETE")
	end
	if onComplete then onComplete(true) end
end

-- 触发Buffs
function BuffsList:triggerBuffs(onComplete,...)
	local args = { ... }
	table.asyn_walk_sequence(onComplete,table.keys(self._buffs),function (_onComplete,bid)
		local buff = self._buffs[bid]
		if not buff then
			_onComplete(false)  
		else
			buff:execute(function (result)
				_onComplete(result)  
			end, unpack(args))
		end
	end)
end

-- 输出所有Buffs
function BuffsList:dumpBuffs()
	dump(self._buffs)
end

return BuffsList
