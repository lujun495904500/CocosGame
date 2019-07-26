--[[
	道具店
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

local ItemShop = class("ItemShop", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function ItemShop:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行
function ItemShop:execute()
	uiMgr:openUI("tradeselect",{
		autoclose = true,
		messages = gameMgr:getStrings("ISHOP_MSG"),
		selects = {
			{
				label = gameMgr:getStrings("PURCHASE")[1],
				type = "B",
			},{
				label = gameMgr:getStrings("SELLOUT")[1],
				type = "S",
			}
		},
		onComplete = function (result,item)
			if result then
				if item.type == "B" then
					uiMgr:openUI("itemtrade",majorTeam,"B",gameMgr:getShopItems())
				else	-- S
					uiMgr:openUI("itemtrade",majorTeam,"S")
				end
			else
				uiMgr:openUI("message",{
					autoclose = true,
					texts = gameMgr:getStrings("WELCOMEAGAIN")
				})
			end
		end
	})
end

return ItemShop
