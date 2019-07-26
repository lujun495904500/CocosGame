--[[
	装备店
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

local EquipShop = class("EquipShop", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function EquipShop:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行
function EquipShop:execute()
	uiMgr:openUI("tradeselect",{
		autoclose = true,
		messages = gameMgr:getStrings("ESHOP_MSG"),
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
					uiMgr:openUI("itemtrade",majorTeam,"B",gameMgr:getShopEquips())
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

return EquipShop
