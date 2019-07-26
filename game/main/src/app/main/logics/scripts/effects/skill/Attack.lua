--[[
	技能 攻击
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 命中判断延时
local C_HITJUDGE_DELAY = 0.3

-- 技能命中
local C_SKILL_HIT = "SKILL_HIT"

-- 公式 技能伤害
local C_SKILL_DAMAGE = "SKILL_DAMAGE"

-- 恢复波动
local C_ATTACK_SWING = 0.1

local Attack = class("Attack", import("._SkillBase"))

-- 构造函数
function Attack:ctor(config)
	table.merge(self,config)
end

--[[
	执行函数
	battle	战场
	role	使用角色
	skill	技能
	sp		消耗SP
	targets	选择目标
]]
function Attack:execute(onComplete) 
	local targets = table.filter_array(self.targets,function(v) return not v:isDead() end)
	self:effectTargetsInBattle(onComplete,targets,
		function (onComplete__,target,isgatking,msgui,extvars,showconfig)
			if target:isDead() then
				if onComplete__ then onComplete__() end
			else
				local ishit = nil
				local damages = 0
			
				ishit = formulaMgr:calculate(C_SKILL_HIT,{
											
				},{
					intellect = self.role:getEntity():getIntellect(),
					speed = self.role:getSpeed(),
					stydodge = self.role:getStrategyDodge(),
				},{
					intellect = target:getEntity():getIntellect(),
					speed = target:getSpeed(),
					stydodge = target:getStrategyDodge(),
				})
				if ishit then
					damages = math.floor(formulaMgr:calculate(C_SKILL_DAMAGE,{
						base = skillMgr:getPower(self.skill),
						attribute = skillMgr:getType(self.skill),
						attrmax = gameMgr:getAttributeMax(),
					},{
						intellect = self.role:getEntity():getIntellect(),
						styresist = self.role:getStrategyResistance(),
					},{
						intellect = target:getEntity():getIntellect(),
						styresist = target:getStrategyResistance(),
					}) / #targets)
					damages = damages > 0 and damages or 0
				end
				
				-- 统计
				local function doStatistics(losses,isdead)
					self.role:doStatistics("damage",losses)
					self.role:doStatistics("s_damage",losses)
					target:doStatistics("hurt",losses)
					target:doStatistics("s_hurt",losses)
					target:doStatistics("hatred",self.role)
					if isdead then
						self.role:doStatistics("kill")
						target:doStatistics("dead")
					end
				end

				if isgatking then
					local function useEnd()
						if onComplete__ then onComplete__() end
					end
					local function onUsed()
						target:getEntity():lostSoldiers(tools:getSwingRand(damages,C_ATTACK_SWING),function (losses,isdead)
							doStatistics(losses,isdead)
							useEnd()
						end)
					end
					if ishit then
						audioMgr:playSE(skillMgr:getSE(self.skill,"use"))
						local useeffect = skillMgr:getEffect(self.skill,"use")
						if useeffect then
							target:playEffect(useeffect,onUsed)
						else
							onUsed()
						end
					else
						useEnd()
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
					local function onUsed()
						target:getEntity():lostSoldiers(tools:getSwingRand(damages,C_ATTACK_SWING),function (losses,isdead)
							doStatistics(losses,isdead)
							extvars.losses = losses
							msgwin:appendMessage({
								texts = gameMgr:getStrings("TARGET_LOSSES",extvars),
								showconfig = showconfig,
								onComplete = function ()
									if isdead then
										performWithDelay(msgwin,function ()
											msgwin:showMessage({
												texts = gameMgr:getStrings("TARGET_BEATED",extvars),
												showconfig = showconfig,
												onComplete = useEnd,
											})
										end,C_SHOW_DELAY)
									else
										useEnd()
									end
								end,
							})
						end)
					end

					msgwin:appendMessage({
						texts = gameMgr:getStrings("USE_SKILL",extvars),
						showconfig = showconfig,
						onComplete = function ()
							if ishit then
								performWithDelay(msgwin,function ()
									msgwin:appendMessage({
										texts = gameMgr:getStrings("SUCCESS",extvars),
										showconfig = showconfig,
										onComplete = function ()
											audioMgr:playSE(skillMgr:getSE(self.skill,"use"))
											local useeffect = skillMgr:getEffect(self.skill,"use")
											if useeffect then
												target:playEffect(useeffect,onUsed)
											else
												onUsed()
											end
										end,
									})
								end,C_HITJUDGE_DELAY)
							else
								performWithDelay(msgwin,function ()
									msgwin:appendMessage({
										texts = gameMgr:getStrings("FAILURE",extvars),
										showconfig = showconfig,
										onComplete = useEnd,
									})
								end,C_HITJUDGE_DELAY)
							end
						end,
					})
				end
			end
		end)
end

return Attack
