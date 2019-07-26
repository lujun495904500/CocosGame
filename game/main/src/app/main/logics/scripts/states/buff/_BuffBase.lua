--[[
	Buff 基类
]]

-- 显示延时
local C_SHOW_DELAY = 0.8

-- 显示配置
local C_SHOW_CONFIG = {
	usecursor		= false, 
	usesound		= false,
	quickshow		= true,
	linefeed		= true,
	ctrl_quick		= false,
	ctrl_complete	= false,
}

local _BuffBase = class("_BuffBase", require("app.main.modules.script.ScriptBase"))

-- 地图Buff丢失
function _BuffBase:onMapBuffLost(onComplete,msg)
	return uiMgr:openUI("message", {
		texts = msg,
		autoclose = true,
		onComplete = function ()
			self.target:getEntity():removeBuff(self.bid)
			if onComplete then onComplete(true) end
		end
	})
end

-- 战场Buff丢失
function _BuffBase:onBattleBuffLost(onComplete,msg)
	if self.target:getScene():isGeneralAttack() then
		return self.target:getEntity():removeBuff(self.bid,function ()
			if onComplete then onComplete(true) end
		end)
	else
		local msgui = self.target:isEnemy() and "message" or "ourmessage"
		local msgwin = uiMgr:openUI(msgui)
		return msgwin:showMessage({
			texts = msg,
			showconfig = C_SHOW_CONFIG,
			onComplete = function ()
				performWithDelay(msgwin,function ()
					self.target:getEntity():removeBuff(self.bid,function ()
						uiMgr:closeUI(msgui)
						if onComplete then onComplete(true) end
					end)
				end,C_SHOW_DELAY)
			end
		})
	end
end

return _BuffBase
