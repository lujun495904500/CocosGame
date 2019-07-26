--[[
	策略 解阵计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 策略命中
local C_TEAMSTY_HIT = "TEAMSTY_HIT"

local DissolveFormation = class("DissolveFormation", import("._StrategyBase"))

-- 构造函数
function DissolveFormation:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function DissolveFormation:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function DissolveFormation:executeInBattle(onComplete)
	self:effectInBattle(onComplete,function (onComplete_,isgatking,msgui,extvars,showconfig)
		
		-- 统计
		local function doStatistics()
			self.role:doStatistics("styuse")
			self.role:doStatistics("tstyuse")
		end

		local enemyteam = self.role:getTeam():getEnemyTeam()
		local ishit = nil ~= enemyteam:getEntity():getFormation() and 
			formulaMgr:calculate(C_TEAMSTY_HIT,{
				attrmax = gameMgr:getAttributeMax(),
			},{
				intellect = self.role:getEntity():getIntellect(),
			}) 
		if isgatking then
			local function useEnd()
				if onComplete_ then onComplete_(true) end
			end
			if ishit then
				enemyteam:getEntity():setFormation(nil,function ()
					enemyteam:showUnsetFormation(function ()
						doStatistics()
						useEnd()
					end, true)
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
					enemyteam:getEntity():setFormation(nil, function ()
						enemyteam:showUnsetFormation(function ()
							doStatistics()
							msgwin:appendMessage({
								texts = gameMgr:getStrings("UNSET_FORMATION",{
									team = enemyteam:getEntity():getName()
								}),
								showconfig = showconfig,
								onComplete = useEnd,
							})
						end,true)
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
function DissolveFormation:executeInMap(onComplete)
	self:invalidInMap(onComplete)
end

return DissolveFormation
