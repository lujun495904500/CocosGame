--[[
	训练场
]]

-- 显示延时
local C_SHOW_DELAY = 0.5
local C_LOGTAG = "Training"

local Training = class("Training", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Training:ctor(config)
	if config then
		table.merge(self,config)
	end
end

-- 执行
function Training:execute()
	local costs = gameMgr:getTrainingCost()
	local level = gameMgr:getTrainingLevel()
	uiMgr:openUI("select",{
		autoclose = true,
		messages = gameMgr:getStrings("TRAINNING_MSG1",{ costs = costs }),
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
				if majorTeam:getLevel() >= level then
					uiMgr:closeUI("golds")
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("TRAINNING_MSG2"),
						onComplete = function ()
							uiMgr:closeAll()
						end
					})
				else
					if majorTeam:tryCostGolds(costs) then
						uiMgr:openUI("golds")
						uiMgr:openUI("message",{
							autoclose = true,
							texts = gameMgr:getStrings("TRAINNING_MSG3"),
							onComplete = function ()
								uiMgr:closeAll()
								self:doTraining(level,function ()
									uiMgr:openUI("message",{
										autoclose = true,
										texts = gameMgr:getStrings("HARDWORK")
									})
								end)
							end
						})
					else
						uiMgr:openUI("message",{
							autoclose = true,
							texts = gameMgr:getStrings("TRAINNING_MSG5"),
							onComplete = function ()
								uiMgr:closeAll()
							end
						})
					end
				end
			else
				uiMgr:closeUI("golds")
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

-- 执行训练
function Training:doTraining(level,onComplete)
	local map = sceneMgr:getCurrentScene()
	local mapteam = map:getMajorTeam()
	if mapteam and iskindof(map,"MapScene") then
		local moves = map:getMovePath(
			mapteam:getPosition(),
			map:getTeleportIn("p_training"),
			mapteam:getMoveTerrain(),
			mapteam)
		if moves then
			map:onAutoMove(moves,function (result)
				if result then
					uiMgr:openUI("shadelight",{
						shadetime = 1,
						lighttime = 1,
						switch = function (onComplete_)
							local team = map:getMajorTeam()
							team:updateTeam({
								pos = team:getPosition(),
								method = "POINT",
								face = "DOWN",
							})
							uiMgr:openUI("message",{
								autoclose = true,
								texts = gameMgr:getStrings("TRAINNING_MSG4"),
								showconfig = {
									usecursor = true,
								},
								onComplete = function ()
									local lvupmsgs = {}
									majorTeam:addExps(gameMgr:getLevelExps(level) - majorTeam:getExps(),lvupmsgs)
									uiMgr:openUI("levelup",{
										autoclose = true,
										lvupmsgs = lvupmsgs,
										onComplete = onComplete_
									})
								end
							})
						end,
						onComplete = function ()
							local rmoves = map:getMovePath(
								mapteam:getPosition(),
								map:getTeleportIn("p_talking"),
								mapteam:getMoveTerrain(),
								mapteam)
							if rmoves then
								map:onAutoMove(rmoves,function (result)
									if result then
										if onComplete then onComplete() end
									end
								end)
							end
						end
					})
				end
			end)
		end
	else
		error("map scene not found")
		uiMgr:openUI("message",{
			texts = gameMgr:getStrings("BUG",{
				bug = "map scene not found"
			})
		})
	end
end

return Training
