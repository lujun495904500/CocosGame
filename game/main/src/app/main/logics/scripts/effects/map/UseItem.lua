--[[
	地图 物品使用
]]

local UseItem = class("UseItem", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function UseItem:ctor(config)
	table.merge(self,config)
end

-- 执行脚本 
function UseItem:execute(onComplete)
	self.mapteam:tryUseItem(function (result)
		if not result then
			return uiMgr:openUI("message",{
				autoclose = true,
				texts = gameMgr:getStrings("NOT_USE_HERE"),
				onComplete = function ()
					if onComplete then onComplete(false) end
				end
			})
		end
		if onComplete then onComplete(result) end
	end,self.role,self.item,{
		removeItem = self.removeItem,
	})
end

return UseItem
