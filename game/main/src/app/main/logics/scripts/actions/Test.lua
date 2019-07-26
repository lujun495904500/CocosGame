--[[
	对话动作
--]]

local Test = class("Test", require("app.main.modules.script.ScriptBase"))

-- 执行
--[[
function Test:execute(complete,type,param)
	if type == "BGM" then
		audioMgr:listenFinish(audioMgr:playBGM(param),complete)
	elseif type == "SE" then
		audioMgr:listenFinish(audioMgr:playSE(param),complete)
	end
end


function Test:execute(stype,trigger,sparams,eparam)
	local item = sparams[1].id
	print("test event")
	if type(item) == "string" then
		local iid,count = unpack(string.split(item,","))
		item = tools:createItem(iid,count and tonumber(count))
	end
	if item.id == eparam.item.id then
		eparam.operator("MESSAGE",{"物品(id:" .. item.id .. ")触发事件"},true)
		return true
	end
end
--]]

function Test:execute(config)
	uiMgr:openUI("message",{
		autoclose = true,
		texts = {string.format("display item %s successful",config.item:getName())},
		onComplete = function ()
			if config.onComplete then config.onComplete(true) end
		end 
	})
	return true
end


return Test
