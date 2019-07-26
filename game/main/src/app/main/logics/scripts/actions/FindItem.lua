--[[
	找到物品
]]

local FindItem = class("FindItem", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function FindItem:ctor(config)
	if config then
		if type(config) == "table" then
			table.merge(self,config)
		else	-- string
			self:parse(config)
		end
	end
end

-- 执行脚本
function FindItem:execute(onComplete,type)
	local result = true
	if type == "TRIGGER" then
		for _,find in ipairs(self.finds) do
			if (not find.enable or archMgr:checkEventPoint(unpack(find.enable))) and
				(not find.disable or not archMgr:checkEventPoint(unpack(find.disable))) then
				majorTeam:addItem(find.item)
				if find.set then
					archMgr:setEventPoint(true,unpack(find.set))
				end
				if find.unset then
					archMgr:setEventPoint(false,unpack(find.unset))
				end
				return uiMgr:openUI("message",{
					autoclose = true,
					texts = gameMgr:getStrings({"DO_RESEARCH","FIND_ITEM"}, {
						item = find.item:getName()
					}),
					onComplete = function ()
						if onComplete then onComplete(true) end
					end
				})
			end
		end
		result = false
	end
	if onComplete then onComplete(result) end
end

-- 解析配置 ACTIONS/FINDITEM>I88,5|,20,20;I89,1|,21,21
function FindItem:parse(config)
	self.finds = self.finds or {}
	for _,itemconf in ipairs(string.split(config,";")) do 
		local itempas,itemeps = unpack(string.split(itemconf,"|"))
		local id,count = unpack(string.split(itempas,","))
		count = count and tonumber(count) or 1
		local epoints = itemeps and string.split(itemeps,",") or {}
		self.finds[#self.finds + 1] = {
			item = tools:createItem(id,count),
			enable = tools:parseEPoint(epoints[1]),
			disable = tools:parseEPoint(epoints[2]),
			set = tools:parseEPoint(epoints[3]),
			unset = tools:parseEPoint(epoints[4]),
		}
	end
end

return FindItem
