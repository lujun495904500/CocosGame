--[[
	旅店
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

local Hostel = class("Hostel", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Hostel:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行
function Hostel:execute()
	local costs = gameMgr:getHostelCost() * majorTeam:getRoleCount()
	uiMgr:openUI("select",{
		messages = gameMgr:getStrings("HOSTEL_MSG1",{ costs = costs }),
		selects = {
			{
				label = gameMgr:getStrings("YES")[1],
				type = "Y",
			},{
				label = gameMgr:getStrings("NO")[1],
				type = "N",
			}
		},
		appendEnd = function ()
			uiMgr:openUI("golds")
			uiMgr:setFrontByName("select")
		end,
		onComplete = function (result,item)
			if result and item.type == "Y" then
				if majorTeam:tryCostGolds(costs) then
					uiMgr:openUI("message",{
						texts = gameMgr:getStrings("GOODNIGHT"),
						showconfig = {
							ctrl_complete = false,
						},
						onComplete = function ()
							uiMgr:openUI("shadelight",{
								shadetime = 0.5,
								lighttime = 0.5,
								switch = function (onComplete_)
									uiMgr:closeAll("shadelight")

									majorTeam:recoverSP()
									majorTeam:recoverSoldiers()
									
									local lastbgm = audioMgr:getCurrentBGM()
									audioMgr:listenFinish(audioMgr:playBGM(gameMgr:getRestBGM(),false),function ()
										if lastbgm then audioMgr:playBGM(lastbgm) end
										if onComplete_ then onComplete_() end
									end)
								end,
								onComplete = function ()
									uiMgr:openUI("message",{
										autoclose = true,
										texts = gameMgr:getStrings("HOSTEL_MSG2")
									})
								end
							})
						end
					})
				else
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("HOSTEL_MSG3"),
						onComplete = function ()
							uiMgr:closeAll()
						end
					})
				end
			else
				uiMgr:openUI("message",{
					autoclose = true,
					texts = gameMgr:getStrings("WELCOMEAGAIN"),
					onComplete = function ()
						uiMgr:closeAll()
					end
				})
			end
		end
	})
end

return Hostel
