--[[
	技能恢复
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 恢复公式
local C_FORMULA_RECOVER = "SKILL_RECOVERY"

-- 恢复波动
local C_RECV_SWING = 0.1

local Recovery = class("Recovery", import("._SkillBase"))

-- 构造函数
function Recovery:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function Recovery:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

--[[
	战场上恢复
	role	 使用角色
]]
function Recovery:executeInBattle(onComplete)
	local targets = table.filter_array(self.targets,function(v) return not v:isDead() end)
	self:effectTargetsInBattle(onComplete,targets,
		function (onComplete__,target,isgatking,msgui,extvars,showconfig)
			if target:isDead() then
				if onComplete__ then onComplete__() end
			else
				local recvpower = math.floor(formulaMgr:calculate(C_FORMULA_RECOVER,{
					base = skillMgr:getPower(self.skill),
					attrmax = gameMgr:getAttributeMax(),
				},{
					intellect = self.role:getEntity():getIntellect(),
				},{
					intellect = target:getEntity():getIntellect(),
				}) / #targets)

				-- 统计
				local function doStatistics(recvsolds)
					self.role:doStatistics("treatment",recvsolds)
					target:doStatistics("recovery",recvsolds)
				end

				if isgatking then
					local function useEnd()
						if onComplete__ then onComplete__() end
					end
					local function onUsing()
						target:getEntity():recoverSoldiers(tools:getSwingRand(recvpower,C_RECV_SWING),function (recvsolds)
							doStatistics(recvsolds)
							useEnd()
						end)
					end
					audioMgr:playSE(skillMgr:getSE(self.skill,"use"))
					local useeffect = skillMgr:getEffect(self.skill,"use")
					if useeffect then
						target:playEffect(useeffect,onUsing)
					else
						onUsing()
					end
				else
					extvars.target = target:getEntity():getName()
					local msgwin = uiMgr:openUI(msgui)
					msgwin:clearMessage()

					local function useEnd()
						performWithDelay(msgwin,function ()
							uiMgr:closeUI(msgui)
							if onComplete__ then onComplete__() end
						end,C_SHOW_DELAY)
					end
					local function onUsing()
						target:getEntity():recoverSoldiers(tools:getSwingRand(recvpower,C_RECV_SWING),function (recvsolds)
							doStatistics(recvsolds)
							if target:getEntity():isMaxSoldiers() then
								msgwin:appendMessage({
									texts = gameMgr:getStrings("RECOVER_SOLDIERS_ALL",extvars),
									showconfig = showconfig,
									onComplete = useEnd,
								})
							else
								extvars.soldiers = recvsolds
								msgwin:appendMessage({
									texts = gameMgr:getStrings("RECOVER_SOLDIERS",extvars),
									showconfig = showconfig,
									onComplete = useEnd,
								})
							end
						end)
					end
					msgwin:appendMessage({
						texts = gameMgr:getStrings("USE_SKILL",extvars),
						showconfig = showconfig,
						onComplete = function ()
							audioMgr:playSE(skillMgr:getSE(self.skill,"use"))
							local useeffect = skillMgr:getEffect(self.skill,"use")
							if useeffect then
								target:playEffect(useeffect,onUsing)
							else
								onUsing()
							end
						end,
					})
				end
			end
		end)
end

--[[
	地图上恢复
	map		 	地图
	ui		  	地图UI
	selectui	选择UI
	adviser	 	军师
	skill	   	恢复技能
]]
function Recovery:executeInMap(onComplete)
	local targets = table.filter_array(self.targets,function(v) return not v:isDead() end)
	self:effectTargetsInMap(onComplete,targets,
		function (onComplete_,target,extvars)
			if target:isDead() then
				onComplete_(true)
			else
				extvars.target = target:getName()
				local recvpower = math.floor(formulaMgr:calculate(C_FORMULA_RECOVER,{
					base = skillMgr:getPower(self.skill),
					attrmax = gameMgr:getAttributeMax(),
				},{
					intellect = self.role:getIntellect(),
				},{
					intellect = target:getIntellect(),
				}) / #targets)
				
				target:recoverSoldiers(tools:getSwingRand(recvpower,C_RECV_SWING),function (recvsolds)
					audioMgr:playSE(skillMgr:getSE(self.skill,"use"))
					if target:isMaxSoldiers() then
						uiMgr:openUI("message",{
							texts = gameMgr:getStrings({"USE_SKILL","RECOVER_SOLDIERS_ALL"},extvars),
							onComplete = onComplete_
						})
					else
						extvars.soldiers = recvsolds
						uiMgr:openUI("message",{
							texts = gameMgr:getStrings({"USE_SKILL","RECOVER_SOLDIERS"},extvars),
							onComplete = onComplete_
						})
					end
				end)
			end
		end)
end

return Recovery
