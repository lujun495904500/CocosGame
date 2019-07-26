--[[
	地形 沼泽
]]

-- 公式 沼泽伤害
local C_SWAMP_DAMAGE = "SWAMP_DAMAGE"

local Swamp = class("Swamp", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Swamp:ctor(config)
	table.merge(self,config)
end

-- 执行函数
function Swamp:execute(doNext,team) 
	if team:isDisinfect() then
		doNext()
	else
		if self.se_hurt then 
			audioMgr:playSE(self.se_hurt) 
		end
		uiMgr:openUI("flashlight",{
			opacity = 64,
			duration = 0.02,
			blinks = 1,
			onComplete = function ()
				local teamentity = team:getEntity()
				for _,role in ipairs(teamentity:getAliveRoles()) do
					local damages = math.floor(formulaMgr:calculate(C_SWAMP_DAMAGE,{
						
					},{
						soldiers = role:getSoldiers(),
					}))
					damages = damages > 0 and damages or 1
					role:lostSoldiers(damages)
				end
				if teamentity:getAliveCount() <= 0 then
					team:removeFromMap()
					if teamentity == majorTeam then
						uiMgr:openUI("message", {
							texts = gameMgr:getStrings("TEAM_FAIL",{
								team = majorTeam:getName()
							}),
							autoclose = true,
							onComplete = function ()
								gameMgr:majorFailure()
							end
						})
					end
				else
					doNext()
				end
			end
		})
	end
end

return Swamp
