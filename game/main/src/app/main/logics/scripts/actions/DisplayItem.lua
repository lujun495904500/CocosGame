--[[
	展示物品
]]

local DisplayItem = class("DisplayItem", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function DisplayItem:ctor(config)
	if config then
		if type(config) == "table" then
			table.merge(self,config)
		else	-- string
			self:parse(config)
		end
	end
end

-- 执行脚本
function DisplayItem:execute(onComplete,type,config)
	local result = true
	if type == "TRIGGER" then
		for _,item in ipairs(self.items) do
			if item.dataid == config.item:getDataID() and item.count <= config.item:getCount() and 
				(not item.enable or archMgr:checkEventPoint(unpack(item.enable))) and
				(not item.disable or not archMgr:checkEventPoint(unpack(item.disable))) then
				local script = scriptMgr:createObject(item.script.script,item.script.config)
				if script then
					return script:execute(function (_result)
						if _result then
							if item.set then
								archMgr:setEventPoint(true,unpack(item.set))
							end
							if item.unset then
								archMgr:setEventPoint(false,unpack(item.unset))
							end
						end
						if onComplete then onComplete(_result) end
					end,config)
				end
			end
		end
		result = false
	end
	if onComplete then onComplete(result) end
end

-- 解析配置 eg：ACTIONS/DISPLAYITEM>I100,1|,22,22|ACTIONS/TEST
function DisplayItem:parse(config)
	self.items = self.items or {}
	for _,itemconf in ipairs(string.split(config,";")) do 
		local itempas,itemeps,itemspt = unpack(string.split(itemconf,"|"))
		local id,count = unpack(string.split(itempas,","))
		count = count and tonumber(count) or 1
		local epoints = itemeps and string.split(itemeps,",") or {}
		local scripts = itemspt and string.split(itemspt,":") or {}
		self.items[#self.items + 1] = {
			dataid = id,
			count = count,
			enable = tools:parseEPoint(epoints[1]),
			disable = tools:parseEPoint(epoints[2]),
			set = tools:parseEPoint(epoints[3]),
			unset = tools:parseEPoint(epoints[4]),
			script = {
				script = scripts[1],
				config = scripts[2]
			}
		}
	end
end

return DisplayItem
