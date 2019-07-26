--[[
	策略 心乱计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 策略命中
local C_TEAMSTY_HIT = "TEAMSTY_HIT"

local Confusion = class("Confusion", import("._StrategyBase"))

-- 构造函数
function Confusion:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function Confusion:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function Confusion:executeInBattle(onComplete)
	self:effectInBattle(onComplete,function (onComplete_,isgatking,msgui,extvars,showconfig)
		
		-- 统计
		local function doStatistics()
			self.role:doStatistics("styuse")
			self.role:doStatistics("tstyuse")
		end

		local ishit = formulaMgr:calculate(C_TEAMSTY_HIT,{
			attrmax = gameMgr:getAttributeMax(),
		},{
			intellect = self.role:getEntity():getIntellect(),
		})
		local enemyteam = self.role:getTeam():getEnemyTeam():getEntity()
		if isgatking then
			local function useEnd()
				if onComplete_ then onComplete_(true) end
			end
			if ishit then
				enemyteam:lostSP(math.random(self.param.smin,self.param.smax), function ()
					doStatistics()
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
					if onComplete_ then onComplete_(true) end
				end,C_SHOW_DELAY)
			end

			local function useResult()
				if ishit then
					extvars.team = enemyteam:getName()
					enemyteam:lostSP(math.random(self.param.smin,self.param.smax), function ()
						doStatistics()
						msgwin:appendMessage({
							texts = gameMgr:getStrings("SKILL_CONFUSION",extvars),
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
	end)
end

-- 地图上
function Confusion:executeInMap(onComplete)
	self:invalidInMap(onComplete)
end

return Confusion
