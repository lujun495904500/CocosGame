--[[
	战斗 物品使用
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

local UseItem = class("UseItem", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function UseItem:ctor(config)
	table.merge(self,config)
end

-- 执行脚本 
function UseItem:execute(onComplete)
	self._isgatking = self.role:getScene():isGeneralAttack()   -- 总攻

	local function useItem(onComplete_)
		self.role:getScene():tryUseItem(function (result)
			if (not result) and (not self._isgatking) then
				local msgui =  self.role:isEnemy() and "message" or "ourmessage" 
				local msgwin = uiMgr:openUI(msgui)
				return msgwin:showMessage({
					texts = gameMgr:getStrings({"USE_ITEM","NO_EFFECT"},{
						role = self.role:getEntity():getName(),
						item = self.item:getName(),
					},"\n"),
					showconfig = {
						usecursor	   = false, 
						usesound		= false,
						quickshow	   = true,
						linefeed		= true,
						ctrl_quick	  = false,
						ctrl_complete   = false,
					},
					onComplete = function ()
						performWithDelay(msgwin,function ()
							uiMgr:closeUI(msgui)
							if onComplete_ then onComplete_(false) end
						end,C_SHOW_DELAY)
					end
				})
			end
			if onComplete_ then onComplete_(result) end
		end,self.role,self.item,{
			removeItem = self.removeItem,
		})
	end

	if self._isgatking then
		useItem(onComplete)
	else
		self.role:selectForward(true,function ()
			useItem(function ()
				self.role:selectForward(false,onComplete)
			end)
		end)
	end
end

return UseItem
