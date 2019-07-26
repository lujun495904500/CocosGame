--[[
	策略 杀毒计
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

local AntiVirus = class("AntiVirus", import("._StrategyBase"))

-- 构造函数
function AntiVirus:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行函数
function AntiVirus:execute(...) 
	if self.scene == "BATTLE" then
		self:executeInBattle(...)
	elseif self.scene == "MAP" then
		self:executeInMap(...)
	end
end

-- 战场上
function AntiVirus:executeInBattle(onComplete)
	self:effectInBattle(onComplete,function (onComplete_,isgatking,msgui,extvars,showconfig)
		
		-- 统计
		local function doStatistics()
			self.role:doStatistics("styuse")
		end

		local function useEnd()
			self.role:getEntity():getTeam():addBuff(self.param.bid,{
				steps = buffMgr:getParam(self.param.bid).steps
			},function ()
				doStatistics()
				if onComplete_ then onComplete_(true) end
			end)
		end
		if isgatking then
			useEnd()
		else
			local msgwin = uiMgr:openUI(msgui)
			msgwin:showMessage({
				texts = gameMgr:getStrings("USE_SKILL",extvars),
				showconfig = showconfig,
				onComplete = function ()
					performWithDelay(msgwin,function ()
						uiMgr:closeUI(msgui)
						useEnd()
					end,C_SHOW_DELAY)
				end
			})
		end
	end)
end

-- 地图上
function AntiVirus:executeInMap(onComplete)
	self:effectInMap(onComplete,function (onComplete_,extvars)
		uiMgr:openUI("message",{
			texts = gameMgr:getStrings("USE_SKILL",extvars),
			onComplete = function ()
				self.role:getTeam():addBuff(self.param.bid,{
					steps = buffMgr:getParam(self.param.bid).steps
				},function ()
					if onComplete_ then onComplete_(true) end
				end)
			end
		})
	end)
end

return AntiVirus
