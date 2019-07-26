--[[
	宝箱物品
]]

-- 物品索引路径
local C_ITEM_IPATH = "res/items"

local ChestItem = class("ChestItem", require("app.main.modules.script.ScriptBase"))

-- 宝箱配置
local chestconf = nil
local function GetChest()
	if not chestconf then
		chestconf = indexMgr:readJsonConfig(indexMgr:getIndex(C_ITEM_IPATH .. "/chest"))
	end
	return chestconf
end

-- 构造函数
function ChestItem:ctor(config)
	if config then
		if type(config) == "table" then
			table.merge(self,config)
		else	-- string
			self:parse(config)
		end
	end
end

-- 执行脚本
function ChestItem:execute(onComplete, type, ...)
	local result = true
	if type == "TRIGGER" then
		if not archMgr:checkEventPoint(unpack(self.opened)) then
			local function openEnd()
				archMgr:setEventPoint(true,unpack(self.opened))
				if self.set then
					archMgr:setEventPoint(true,unpack(self.set))
				end
				if self.unset then
					archMgr:setEventPoint(false,unpack(self.unset))
				end
				if onComplete then onComplete(true) end
			end
			local function findChest()
				if self.chesttype == "I" then
					majorTeam:addItem(self.item)
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("GET_ITEM", {
							item = self.item:getName()
						}),
						onComplete = openEnd
					})
				else	-- G
					majorTeam:addGolds(self.golds)
					uiMgr:openUI("message",{
						autoclose = true,
						texts = gameMgr:getStrings("GET_GOLDS", {
							golds = self.golds
						}),
						onComplete = openEnd
					})
				end
			end
			return uiMgr:openUI("message",{
				autoclose = true,
				texts = gameMgr:getStrings({"DO_RESEARCH","FIND_CHEST"}),
				showconfig = {
					usecursor = true,
				},
				appendEnd = function ()
					self._chestsp:setTexture(GetChest().chest_opened)
				end,
				onComplete = findChest
			})
		end
		result = false
	elseif type == "SETUP" then
		self._scene, self._event = ...
		if not archMgr:checkEventPoint(unpack(self.opened)) then
			self._chestsp = display.newSprite(GetChest().chest)
		else
			self._chestsp = display.newSprite(GetChest().chest_opened)
		end
		self._scene:getItemLayer():addChild(self._chestsp)
		local bounds = self._scene:toPositionBounds(self._event.bounds)
		self._chestsp:setPosition(cc.p(
			bounds.x + bounds.width/2,
			bounds.y + bounds.height/2
		))
	elseif type == "DELETE" then
		if self._chestsp then
			self._chestsp:removeFromParent(true)
			self._chestsp = nil
		end
	end
	if onComplete then onComplete(result) end
end

-- 解析配置 ACTIONS/CHESTITEM>I,I75,1|,22,22   ACTIONS/CHESTITEM>G,500|,22,22
function ChestItem:parse(config)
	local params,epoints = unpack(string.split(config,"|"))
	epoints = epoints and string.split(epoints,",") or {}
	self.opened = tools:parseEPoint(epoints[1])
	if not archMgr:checkEventPoint(unpack(self.opened)) then
		self.set = tools:parseEPoint(epoints[2])
		self.unset = tools:parseEPoint(epoints[3])

		params = string.split(params,",")
		self.chesttype = params[1]
		if self.chesttype == "I" then
			self.item = tools:createItem(params[2],params[3] and tonumber(params[3]))
		else	-- G
			self.golds = tonumber(params[2])
		end
	end
end

return ChestItem
