--[[
	战斗 防御
]]

-- 显示延时
local C_SHOW_DELAY = 1

local Defense = class("Defense", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Defense:ctor(config)
	table.merge(self,config)
end

-- 执行脚本 
function Defense:execute(onComplete)
	self._isallatking = self.role:getScene():isGeneralAttack()   -- 总攻

	-- 统计
	local function doStatistics()
		self.role:doStatistics("defense")
	end

	local function doDefense()
		self.role:setRoundDefense(true)
		doStatistics()
		if onComplete then onComplete(true) end
	end

	if self._isallatking then
		doDefense()
	else
		local msgui =  self.role:isEnemy() and "message" or "ourmessage" 
		local msgwin = uiMgr:openUI(msgui)
		msgwin:clearMessage()

		audioMgr:playSE(gameMgr:getDefenseSE())
		msgwin:showMessage({
			texts = gameMgr:getStrings("ROLE_DEFENSE",{ role = self.role:getEntity():getName() }),
			showconfig = {
				usecursor		= false, 
				usesound		= false,
				quickshow		= true,
				ctrl_quick		= false,
				ctrl_complete	= false,
			},
			onComplete = function ()
				performWithDelay(msgwin,function ()
					uiMgr:closeUI(msgui)
					doDefense()
				end,C_SHOW_DELAY)
			end,
		})
	end
end

return Defense
