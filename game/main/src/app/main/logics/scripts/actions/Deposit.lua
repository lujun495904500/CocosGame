--[[
	寄存
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

local Deposit = class("Deposit", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Deposit:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行
function Deposit:execute()
	uiMgr:openUI("select",{
		autoclose = true,
		messages = gameMgr:getStrings("DEPOSIT_MSG1"),
		selects = {
			{
				label = gameMgr:getStrings("DEPOSIT")[1],
				type = "D",
			},{
				label = gameMgr:getStrings("RECEIVE")[1],
				type = "G",
			}
		},
		onComplete = function (result,item)
			if result then
				if item.type == "D" then
					uiMgr:openUI("itemdeposit",majorTeam,"D")
				else
					if majorTeam:getDepositCount() <= 0 then
						uiMgr:openUI("message",{
							autoclose = true,
							texts = gameMgr:getStrings("DEPOSIT_MSG2")
						})
					else
						uiMgr:openUI("itemdeposit",majorTeam,"G")
					end
				end
			else
				uiMgr:openUI("message",{
					autoclose = true,
					texts = gameMgr:getStrings("HARDWORK")
				})
			end
		end
	})
end

return Deposit
