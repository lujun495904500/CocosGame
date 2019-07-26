--[[
	策略 陷阱计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 陷阱命中
local C_TRAP_HIT = "ROLESTY_HIT"

-- 陷阱伤害
local C_TRAP_DAMAGE = "TRAP_DAMAGE"

local Trap = class("Trap", import("._StrategyBase"))

-- 构造函数
function Trap:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function Trap:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function Trap:executeInBattle(onComplete)
	self:effectTargetsInBattle(onComplete,table.filter_array(self.targets,function(v) return not v:isDead() end),
		function (onComplete__,target,isgatking,msgui,extvars,showconfig)
			if target:isDead() then
				if onComplete__ then onComplete__() end
			else

				-- 统计
				local function doStatistics(losses,isdead)
					self.role:doStatistics("damage",losses)
					self.role:doStatistics("s_damage",losses)
					self.role:doStatistics("styuse")
					target:doStatistics("hurt",losses)
					target:doStatistics("s_hurt",losses)
					target:doStatistics("styhit")
					target:doStatistics("hatred",self.role)
					if isdead then
						self.role:doStatistics("kill")
						target:doStatistics("dead")
					end
				end
				
				local ishit,damage
				ishit = formulaMgr:calculate(C_TRAP_HIT,{
					attrmax = gameMgr:getAttributeMax(),
				},{
					intellect = self.role:getEntity():getIntellect(),
				},{
					intellect = target:getEntity():getIntellect(),
				})
				if ishit then
					damage = math.floor(formulaMgr:calculate(C_TRAP_DAMAGE,{

					},{

					},{
						soldiers = target:getEntity():getSoldiers(),
					}))
					damage = damage > 0 and damage or 1
				end
				if isgatking then
					local function useEnd()
						if onComplete__ then onComplete__(true) end
					end
					if ishit then
						target:getEntity():lostSoldiers(damage, function (losses, isdead)
							doStatistics(losses, isdead)
							useEnd()
						end)
					else
						useEnd()
					end
				else
					local msgwin = uiMgr:openUI(msgui)
					msgwin:clearMessage()

					local function useEnd()
						performWithDelay(msgwin,function ()
							uiMgr:closeUI(msgui)
							if onComplete__ then onComplete__(true) end
						end,C_SHOW_DELAY)
					end

					local function useResult()
						if ishit then
							target:getEntity():lostSoldiers(damage, function (losses, isdead)
								doStatistics(losses, isdead)
								msgwin:appendMessage({
									texts = gameMgr:getStrings("SKILL_TRAP",{
										target = target:getEntity():getName(),
										losses = losses
									}),
									showconfig = showconfig,
									onComplete = useEnd,
								})
							end)
						else
							useEnd()
						end
					end

					msgwin:appendMessage({
						texts = gameMgr:getStrings("USE_SKILL",extvars),
						showconfig = showconfig,
						onComplete = function ()
							performWithDelay(msgwin,function ()
								msgwin:appendMessage({
									texts = gameMgr:getStrings(ishit and "SUCCESS" or "FAILURE"),
									showconfig = showconfig,
									onComplete = useResult,
								})
							end,C_SHOW_DELAY)
						end
					})
				end
			end
		end)
end

-- 地图上
function Trap:executeInMap(onComplete)
	self:invalidInMap(onComplete)
end

return Trap
