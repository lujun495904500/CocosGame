--[[
	地图场景
]]

local THIS_MODULE = ...
local C_LOGTAG = "SceneManager"

-- 地图切换特效
local C_MAP_TRANSITION = {
	method = "FADE",
	time = 0.4,
}
local C_RAND_COUNT = 5
local S_MOVEKEYS = bit.bor(ctrlMgr.KEY_UP,ctrlMgr.KEY_DOWN,ctrlMgr.KEY_LEFT,ctrlMgr.KEY_RIGHT)
local MapTeam = require("app.main.logics.games.map.MapTeam")
local AStart = require("app.main.modules.common.AStart")
local AsynchNotifier = require("app.main.modules.common.AsynchNotifier")

local MapScene = class("MapScene", require("app.main.modules.scene.SceneBase"),
	AsynchNotifier)

--[[
	构造场景
	onComplete		初始化完成回调
	config:
		mapname		地图名
		inpos		进入位置
		inmethod	方式(POINT,LINE)
		inface		方向(UP,DOWN,LEFT,RIGHT)
		infaces		多个角色方向
		inse		进入音效，可选
]]
function MapScene:ctor(onComplete,config)
	self._onInitialized = onComplete
	if config then
		table.merge(self,config)
	end
	self:setup()
	self:setupMap()
end

-- 析构场景
function MapScene:dtor(onComplete)
	self._onDestroyed = onComplete
	self:delete()
	self:deleteMap()
end

-- 安装地图
function MapScene:setupMap()
	self:initNotifier()

	-- 安装瓦片地图
	self._map = mapMgr:createObject(self.mapname)
	self:addChild(self._map)
	table.merge(self,self._map:getParams())

	self._blocklist = {}		-- 阻挡表
	self._talklist = {}			-- 对话传递表
	self._terrainlist = {}		-- 地形表
	self._stepslist = {}		-- 阶数表
	self._teleins = {}			-- 传入表
	self._teleouts = {}			-- 传出表

	self._teams = {}			-- 地图队伍
	self._ais = {}				-- AI表
	self._events = {}			-- 事件表
	self._stepsize = self._map:getStepSize()
	self._mvoffest = cc.p(unpack(self.moveoffest or {0,0}))
	self._itemlayer = cc.Layer:create()		-- 物件层
	self._map:addLayer(self._itemlayer,self.moveorder)

	-- 配置脱出类型
	if self.maptype == "cave" then
		local lasttype = gameMgr:getMapEnv("lasttype")
		if lasttype ~= "cave" then
			gameMgr:setMapEnv("outtype",lasttype)
		end
	else
		gameMgr:setMapEnv("outtype",nil)
	end

	-- 设置宫殿地图
	if self.maptype == "town" then
		local palacemap = gameMgr:getPalaceMap(self.mapname)
		if palacemap then
			gameMgr:setMapEnv("palacemap",palacemap)
		end
	end

	-- 设置地图环境
	gameMgr:setMapEnv(self.maptype,self.mapname)

	-- 设置地图位置
	if type(self.inpos) == "string" then
		self.inpos = self:getTeleportIn(self.inpos)
	end
	self._map:setPosition(cc.p(display.cx-self.inpos.x, display.cy-self.inpos.y))
	self:updateMapRegion(self.inpos)

	-- 异步加载
	table.asyn_walk_sequence(function ()
		-- 添加UI层
		uiMgr:attach(self)

		-- 添加控制层
		if not device.IS_DESKTOP then
			ctrlMgr:attachGamePad(self)
		end

		-- 播放BGM
		audioMgr:playBGM(self.bgm)

		if self._onInitialized then 
			self._onInitialized(self)
		end
	end,{
		-- 添加主角队伍
		function (onComplete)
			self:addTeam(function (mapteam)
				self._majorteam = mapteam
				self._majorMoveEnd = handler(self,MapScene.onMajorMoveEnd)
				-- 移动结束监听器
				self._onMoveEnded = function (move)
					if move then self:tryMoveKey() end
				end
				onComplete(true)
			end,"__major__", majorTeam, {
				major = true,
				pos = self.inpos,
				face = self.inface,
				faces = self.infaces,
				method = self.inmethod
			})
		end

		-- 地图队伍
		,function (onComplete)
			table.asyn_walk_together(onComplete,self._map:getNPCList(),function (_onComplete,npc,name)
				self:addNPC(function (mapteam)
					_onComplete(mapteam ~= nil)
				end,name,npc)
			end)
		end

		-- 地图事件
		,function (onComplete)
			table.asyn_walk_together(onComplete,self._map:getEventList(),function (_onComplete,event,name)
				self:addEvent(function (result)
					_onComplete(result)
				end,event.trigger,name,event)
			end)
		end

		-- 脚本安装
		,function (onComplete)
			local function _doPlayScript()
				playMgr:doCurrentPlay(onComplete,"SETUPMAP",self)
			end

			if self.mapscript then
				self._script = scriptMgr:createObject(self.mapscript,self)
				if self._script then
					return self._script:execute(function ()
						_doPlayScript()
					end,"SETUP")
				end
			end
			_doPlayScript()
		end
	},function (_onComplete,fn)
		fn(_onComplete)
	end)
end

-- 删除地图
function MapScene:deleteMap()
	-- 异步卸载
	table.asyn_walk_sequence(function ()
		-- 注销AI定时器
		if self._aitimer then
			scheduler:unscheduleScriptEntry(self._aitimer)
			self._aitimer = nil
		end

		-- 停止背景音乐
		audioMgr:stopBGM()

		-- 移除UI
		uiMgr:detach()

		if self._onDestroyed then 
			self._onDestroyed(self)
		end
	end,{
		-- 删除剧本
		function (onComplete_)
			local function _doMapScript()
				if self._script then
					return self._script:execute(onComplete_,"DELETE")
				end
				onComplete_(true)
			end
			playMgr:doCurrentPlay(_doMapScript,"DELETEMAP",self)
		end

		-- 移除队伍
		,function (onComplete_)
			table.asyn_walk_together(onComplete_,self._teams,function (onComplete,mapteam)
				mapteam:release(false,onComplete)
			end)
		end
	},function (onComplete_,fn)
		fn(onComplete_)
	end)
end

-- 移动地图到指定偏移
function MapScene:moveToOffest(onComplete, offest, movetime, movestep, stepwait)
	local maction
	if movestep > 0 then
		maction = cc.Repeat:create(cc.Sequence:create(
			cc.MoveBy:create(movetime/movestep,
				cc.p(offest.x / movestep,offest.y / movestep)),
			cc.DelayTime:create(stepwait)),movestep)
	else
		maction = cc.MoveBy:create(movetime,offest)
	end
	local mx,my = self._map:getPosition()
	self._map:runAction(cc.Sequence:create(
		maction,
		cc.Place:create(cc.p(mx + offest.x,my + offest.y)),
		cc.CallFunc:create(function()
			if onComplete then onComplete(true) end
		end)
	))
end

-- 当主角队伍移动结束
function MapScene:onMajorMoveEnd(move)
	if move then
		local destpos = self._majorteam:getPosition()

		-- 更新地图区域
		self:updateMapRegion(destpos)

		-- 尝试传送
		local teleout = self:getTeleportOut(destpos.x,destpos.y)
		if teleout and (not teleout.enable or archMgr:checkEventPoint(unpack(teleout.enable))) and 
			(not teleout.disable or not archMgr:checkEventPoint(unpack(teleout.disable)))then
			return self:teleportMap(clone(teleout))
		end
	end
	if self._onMoveEnded then self._onMoveEnded(move) end
end

-- 更新地图区域
function MapScene:updateMapRegion(pos)
	self._map:showRegion(cc.rect(pos.x - display.cx, pos.y - display.cy, display.width, display.height))
end

-- 获得地图名
function MapScene:getMapName()
	return self.mapname
end

-- 获得地图类型
function MapScene:getMapType()
	return self.maptype
end

-- 坐标边界转换为位置边界
function MapScene:toPositionBounds(bounds)
	return self._map:toPositionBounds(bounds)
end

-- 通过配置获得坐标边界
function MapScene:getCoordBounds(pos)
	return self._map:toCoordBounds(cc.rect(pos.x-self._stepsize.width/2,pos.y,self._stepsize.width,self._stepsize.height))
end

-- 获得主角队伍
function MapScene:getMajorTeam()
	return self._majorteam
end

-- 获得物件层
function MapScene:getItemLayer()
	return self._itemlayer
end

-- 获得移动偏移
function MapScene:getMoveOffest()
	return self._mvoffest
end

-- 设置阻挡点
function MapScene:setBlock(cx,cy,block)
	self._blocklist[self._map:coordToIndex(cx,cy)] = block
end

-- 测试阻挡点
function MapScene:testBlock(x,y)
	local index = self._map:positionToIndex(x,y)
	local block = self._blocklist[index]
	if block ~= nil then
		return block
	else
		return self._map:testBlockByIndex(index)
	end
end

-- 设置对话穿透
function MapScene:setTalk(cx,cy,talk)
	self._talklist[self._map:coordToIndex(cx,cy)] = talk
end

-- 测试对话穿透
function MapScene:testTalk(x,y)
	local index = self._map:positionToIndex(x,y)
	local talk = self._talklist[index]
	if talk ~= nil then
		return talk
	else
		return self._map:testTalkByIndex(index)
	end
end

-- 设置地形值
function MapScene:setTerrain(cx,cy,terrain)
	self._terrainlist[self._map:coordToIndex(cx,cy)] = terrain
end

-- 获得地形值
function MapScene:getTerrain(x,y)
	local index = self._map:positionToIndex(x,y)
	local terrain = self._terrainlist[index]
	if terrain ~= nil then
		return terrain
	else
		return self._map:getTerrainByIndex(index)
	end
end

-- 设置阶数
function MapScene:setSteps(cx,cy,steps)
	self._stepslist[self._map:coordToIndex(cx,cy)] = steps
end

-- 获得阶数
function MapScene:getSteps(x,y)
	local index = self._map:positionToIndex(x,y)
	local steps = self._stepslist[index]
	if steps ~= nil then
		return steps
	else
		return self._map:getStepsByIndex(index)
	end
end

-- 添加传入点
function MapScene:addTeleportIn(inp,cx,cy)
	self._teleins[inp] = cc.p(self._map:coordToPosition(cx,cy))
end

-- 获得传入点
function MapScene:getTeleportIn(inp)
	return self._teleins[inp] or self._map:getTeleportIn(inp)
end

-- 添加传出点
function MapScene:addTeleportOut(bounds,teleout)
	self._teleouts[bounds] = teleout
end

-- 添加TMX传出点
function MapScene:addTMXTeleportOut(bounds,teleout)
	bounds = self._map:convertTMXCrdBounds(bounds)
	self._teleouts[bounds] = teleout
end

-- 获得传出点
function MapScene:getTeleportOut(x,y)
	local cx,cy = self._map:positionToCoord(x,y)
	for bounds,teleout in pairs(self._teleouts) do
		if tools:testInBounds(cx,cy,bounds) and
			(not teleout.enable or archMgr:checkEventPoint(unpack(teleout.enable))) and 
			(not teleout.disable or not archMgr:checkEventPoint(unpack(teleout.disable))) then
			return teleout
		end
	end
	return self._map:getTeleportOutByCoord(cx,cy)
end

-- 添加队伍
function MapScene:addTeam(onComplete,key,team,config)
	MapTeam:create(function (mapteam)
		self._map:addLayer(mapteam,self.moveorder)
		self._teams[key] = mapteam
		if onComplete then onComplete(mapteam) end
	end,team,table.merge({
		map = self,
		key = key
	},config))
end

-- 移除队伍
function MapScene:removeTeam(onComplete,key)
	local mapteam = self._teams[key]
	if not mapteam then
		if onComplete then onComplete(true) end
	else
		mapteam:release(true,function (result)
			if result then self._teams[key] = nil end
			if onComplete then onComplete(result) end
		end)
	end
end

-- 添加AI定时器
function MapScene:addAITimer(key,aifun)
	self._ais[key] = aifun
	if self._aitimer == nil then
		self._aitimer = scheduler:scheduleScriptFunc(function(dt)
			if self:isActive() then
				for _,ai in pairs(self._ais) do ai() end
			end
		end, gameMgr:getTimeTick(), false)
	end
end

-- 移除AI定时器
function MapScene:removeAITimer(key)
	self._ais[key] = nil
	if next(self._ais) == nil and self._aitimer then
		scheduler:unscheduleScriptEntry(self._aitimer)
		self._aitimer = nil
	end
end

-- 添加NPC
function MapScene:addNPC(onComplete,key,npc)
	if (not npc.show or archMgr:checkEventPoint(unpack(npc.show))) and
		(not npc.hide or not archMgr:checkEventPoint(unpack(npc.hide))) then
		if not npc.bounds and npc.tmxbounds then
			npc.bounds = self._map:convertTMXCrdBounds(npc.tmxbounds)
		end
		local npcpos = self:randomReachPos(npc.bounds,gameMgr:getNPCTerrain(),C_RAND_COUNT)
		if npcpos then
			local team = tools:createTeam()
			local role = tools:createRole(npc.id)
			role:setData("TALK",npc.talk)
			role:setData("LOOK",npc.look)
			team:joinRole(role)

			return self:addTeam(function (mapteam)
				if npc.move then
					local movescript = scriptMgr:createObject(npc.move.script,{
						map = self,
						name = key,
						param = npc.move.config,
						team = mapteam,
						bounds = self._map:toPositionBounds(npc.bounds),
						stepsize = self._stepsize,
					})
					if movescript then
						self:addAITimer(key,function() 
							movescript:execute()
						end)
					end
				end
				if onComplete then onComplete(mapteam) end
			end,key, team, {
				pos = npcpos,
				face = "DOWN",
				method = "POINT"
			})
		else
			logMgr:warn(C_LOGTAG, "NPC(%s) can't find reachable position", key)
		end
	end
	if onComplete then onComplete() end
end

-- 移除NPC
function MapScene:removeNPC(onComplete,key)
	self:removeAITimer(key)
	self:removeTeam(onComplete,key)
end

-- 添加事件
function MapScene:addEvent(onComplete,trigger,key,event)
	local events = self._events[trigger]
	if not events then
		events = {}
		self._events[trigger] = events
	end
	if (not event.enable or archMgr:checkEventPoint(unpack(event.enable))) and
		(not event.disable or not archMgr:checkEventPoint(unpack(event.disable))) then
		if not event.bounds and event.tmxbounds then
			event.bounds = self._map:convertTMXCrdBounds(event.tmxbounds)
		end
		event.escript = event.escript or scriptMgr:createObject(event.script.script,event.script.config)
		if event.escript then
			return event.escript:execute(function (result)
				if result then
					events[key] = event
				end
				if onComplete then onComplete(result) end
			end,"SETUP", self, event)
		end
	end
	if onComplete then onComplete(false) end
end

-- 移除事件
function MapScene:removeEvent(onComplete,trigger,key)
	local events = self._events[trigger]
	if events then 
		local event = events[key]
		if event and event.escript then
			return event.escript:execute(function (result)
				if result then
					events[key] = nil 
				end
				if onComplete then onComplete(result) end
			end,"DELETE")
		end
	end
	if onComplete then onComplete(false) end
end

-- 触发事件
function MapScene:triggerEvents(onComplete,trigger,pos,...)
	local events = self._events[trigger]
	if not events then
		if onComplete then onComplete(false) end
	else
		local args = { ... }
		local cpos = pos and cc.p(self._map:positionToCoord(pos.x,pos.y))
		local keys = table.keys(events)

		table.asyn_walk_sequence(function ()
			if onComplete then onComplete(false) end
		end,keys,function (_onComplete,key)
			local event = events[key]
			if event and event.escript and 
				(not event.bounds or not cpos or tools:testInBounds(cpos.x,cpos.y,event.bounds)) and
				(not event.enable or archMgr:checkEventPoint(unpack(event.enable))) and
				(not event.disable or not archMgr:checkEventPoint(unpack(event.disable))) then
				return event.escript:execute(function (result)
					if not result then
						_onComplete(false)
					else
						if not event.single then
							if onComplete then onComplete(true) end
						else
							self:removeEvent(function ()
								if onComplete then onComplete(true) end
							end,trigger,key)
						end
					end
				end,"TRIGGER",unpack(args))
			end
			_onComplete(false)
		end)
	end
end

-- 通知消息
function MapScene:notify(onComplete, order, ...)
	local args = { ... }
	AsynchNotifier.notify(self, function ()
		self:triggerEvents(onComplete,unpack(args))
	end, order, ...)
end

-- 触发地形
function MapScene:triggerTerrain(onComplete,pos,mapteam)
	local terrain = self:getTerrain(pos.x,pos.y)
	local script = terrain and terrainMgr:getScriptByValue(terrain)
	if script then
		return script:execute(onComplete,mapteam)
	end
	if onComplete then onComplete() end
end

-- 随机指定区域可达到位置
function MapScene:randomReachPos(bounds,terrain,count)
	-- 单点
	if bounds.width == 1 and bounds.height == 1 then
		return cc.p(self._map:coordToPosition(bounds.x,bounds.y))
	end

	-- 随机测试
	for i = 1,count do
		local pos = cc.p(self._map:coordToPosition(bounds.x + math.random(0,bounds.width-1),
			bounds.y + math.random(0,bounds.height-1)))
		if self:testReach(pos, terrain, true) and not self:getTeleportOut(pos.x,pos.y) then
			return pos
		end
	end

	-- 依次查找
	for h=0,bounds.height-1 do 
		for w=0,bounds.width-1 do
			local pos = cc.p(self._map:coordToPosition(bounds.x + w,bounds.y + h))
			if self:testReach(pos, terrain, true) and not self:getTeleportOut(pos.x,pos.y) then
				return pos
			end
		end
	end
end

-- 测试某点可以到达
function MapScene:testReach(pos,terrain,mapteam)
	-- 阻挡点
	if self:testBlock(pos.x,pos.y) then
		return false
	end

	-- 地形
	if terrain ~= nil then
		local mapterrain = self:getTerrain(pos.x,pos.y)
		if mapterrain ~= nil and bit.band(mapterrain,terrain) ~= mapterrain then
			return false
		end
	end

	-- 其他队伍
	if mapteam then
		for _,_mapteam in pairs(self._teams) do 
			if _mapteam ~= mapteam and _mapteam:testPosition(pos.x,pos.y) then
				return false
			end
		end
	end
	
	return true
end

-- 构建地图归档
function MapScene:buildMapArchive()
	return {
		mapname = self.mapname,
		inpos = clone(self._majorteam:getPosition()),
		infaces = self._majorteam:getFaces(),
	}
end

--[[
	传送到指定地图
	mapname  : 地图名
	inpos	: 位置
	inmethod : 方式(LINE,POINT)
	inface   : 方向(UP,DOWN,LEFT,RIGHT)
]]
function MapScene:teleportMap(config)
	for key,value in pairs(config) do
		if type(value) == "string" and value:byte(1) == 0x23 then -- #
			config[key] = gameMgr:getMapEnv(value:sub(2))
		end
	end
	gameMgr:setMapEnv(self.maptype .. "_in",clone(self._majorteam:getPosition()))
	gameMgr:setMapEnv("lasttype",self.maptype)
	sceneMgr:setTransition(C_MAP_TRANSITION)
	sceneMgr:switchScene(self:getMetaType(),config)
end

--[[
	获得方向偏移
]]
function MapScene:getDirectOffest(direct)
	if direct == "UP" then
		return cc.p(0,self._stepsize.height)
	elseif direct == "DOWN" then
		return cc.p(0,-self._stepsize.height)
	elseif direct == "LEFT" then
		return cc.p(-self._stepsize.width,0)
	elseif direct == "RIGHT" then
		return cc.p(self._stepsize.width,0)
	end
end

--[[
	获得指定点，方向阶数
]]
function MapScene:getDirectSteps(pos,direct)
	local step = self:getSteps(pos.x,pos.y)
	if step then
		if step.y and step.y > 0 and (direct == "UP" or direct == "DOWN") then
			return step.y
		elseif step.x and step.x > 0 and (direct == "LEFT" or direct == "RIGHT") then
			return step.x
		end
	end
	return 0
end

--[[
	尝试对话操作
	onComplete		完成回调
	pos				对话位置
	direct			对话方向
	role			对话角色
]]
function MapScene:tryTalk(onComplete,pos,direct,mapteam,role,...)
	local args = { ... }
	local offest = self:getDirectOffest(direct)
	local face = tools:getOppositeDirect(direct)
	
	table.asyn_loop(function ()
		-- 未找到对话对象
		uiMgr:openUI("message", {
			texts = gameMgr:getStrings("NOBODY_HERE"),
			autoclose = true,
			onComplete = function ()
				if onComplete then onComplete(false) end
			end
		})
	end,function (onComplete_)
		pos.x = pos.x + offest.x
		pos.y = pos.y + offest.y
		onComplete_(true)
	end,function (onComplete_)
		table.asyn_walk_sequence(function ()
			onComplete_(true)
		end,table.keys(self._teams),function (onComplete__,key)
			local mapteam_ = self._teams[key]
			if mapteam_ == mapteam then
				onComplete__(true)
			else
				mapteam_:tryDoTalk(function (result)
					if result then
						if onComplete then onComplete(true) end
					else
						onComplete__(true)
					end
				end,clone(pos),face,role,unpack(args))
			end
		end)
	end,function (onComplete_)
		onComplete_(self:testTalk(pos.x,pos.y))
	end)
end

-- 尝试调查操作
--[[
	onComplete	完成回调
	pos			位置
	direct		方向
]]
function MapScene:tryResearch(onComplete,pos,direct,...)
	self:notify(function (result)
		if not result then
			return uiMgr:openUI("message", {
				texts = gameMgr:getStrings({"DO_RESEARCH","FIND_NONE"}),
				autoclose = true,
				onComplete = function ()
					if onComplete then onComplete(false) end
				end
			})
		end
		if onComplete then onComplete(result) end
	end, true, "RESEARCH", pos, ...)
end

-- 尝试使用物品
function MapScene:tryUseItem(onComplete,pos,direct,mapteam,role,item,...)
	local args = { ... }
	self:notify(function (result)
		if not result then
			local offest = self:getDirectOffest(direct)
			local face = tools:getOppositeDirect(direct)
			
			return table.asyn_loop(function ()
				if onComplete then onComplete(false) end
			end,function (onComplete_)
				pos.x = pos.x + offest.x
				pos.y = pos.y + offest.y
				onComplete_(true)
			end,function (onComplete_)
				table.asyn_walk_sequence(function ()
					onComplete_(true)
				end,table.keys(self._teams),function (onComplete__,key) 
					local mapteam_ = self._teams[key]
					if mapteam_ == mapteam then
						onComplete__(true)
					else
						mapteam_:tryDoLook(function (result)
							if result then
								if onComplete then onComplete(true) end
							else
								onComplete__(true)
							end
						end,clone(pos),face,role,item,unpack(args))
					end
				end)
			end,function (onComplete_)
				onComplete_(self:testTalk(pos.x,pos.y))
			end)
		end
		if onComplete then onComplete(result) end
	end, true, "USEITEM", clone(pos), role, item, ...)
end

-- 尝试检查按键移动
function MapScene:tryMoveKey()
	if self._lastmovekey then
		if ctrlMgr:testPressed(self._lastmovekey) then
			return self:OnMoveKey(self._lastmovekey)
		end
		self._lastmovekey = nil
	end
	
	if ctrlMgr:testPressed(ctrlMgr.KEY_UP) then
		self:OnMoveKey(ctrlMgr.KEY_UP)
	elseif ctrlMgr:testPressed(ctrlMgr.KEY_DOWN) then
		self:OnMoveKey(ctrlMgr.KEY_DOWN)
	elseif ctrlMgr:testPressed(ctrlMgr.KEY_LEFT) then
		self:OnMoveKey(ctrlMgr.KEY_LEFT)
	elseif ctrlMgr:testPressed(ctrlMgr.KEY_RIGHT) then
		self:OnMoveKey(ctrlMgr.KEY_RIGHT)
	end
end

-- 控制移动
function MapScene:OnMoveKey(keycode)
	self._lastmovekey = keycode
	if keycode == ctrlMgr.KEY_UP then
		self._majorteam:tryMove("UP",self._majorMoveEnd)
	elseif keycode == ctrlMgr.KEY_DOWN then
		self._majorteam:tryMove("DOWN",self._majorMoveEnd)
	elseif keycode == ctrlMgr.KEY_LEFT then
		self._majorteam:tryMove("LEFT",self._majorMoveEnd)
	else
		self._majorteam:tryMove("RIGHT",self._majorMoveEnd)
	end
end

-- 控制按键
function MapScene:onControlKey(keycode)
	if not self._autoctrl then
		if ctrlMgr:testPressed(ctrlMgr.KEY_START) then
			if ctrlMgr:testPressed(ctrlMgr.KEY_SELECT) then
				if not self._majorteam:getMoveState() then
					uiMgr:openUI("gamemenu")
				end
				return ctrlMgr:clearPressed()
			end

			-- 开发调试
			if FLAG.DEVELOPMENT then	
				if ctrlMgr:testPressed(ctrlMgr.KEY_UP) then
					----[[
					majorTeam:addExps(1200000)
					majorTeam:addGolds(100000)
					majorTeam:recoverSoldiers()
					majorTeam:recoverSP()
					--]]

					--[[
					netServer:addServer("server", "127.0.0.1", 8000, {
						server = {
							encrypt = { "aes", "xor" }
						}
					},{
						newConnect = function (netline)
							dump(netline:getAddress() .. "," .. tostring(netline:getPort()),"new connect")
							netline:regProtHandle("test",function (netline, name, data)
								dump(data.arg9,"server 1")
								dump(data.arg10[1],"server 2")
								dump(data.arg11.low,"server 3")
								dump(data.arg11.high,"server 4")
							end)
							netline:writeProtocol("test", { arg9 = "server test!!!", arg10 = {1,2,3}, arg11 = {low = 10,high = 20} })
							netline:writeProtocol("test_welcome", { text = "welcome test!!!" })
						end,
						onError = function (netline, etype,  error)
							dump(error)
						end
					},true)
					--]]
					
					return ctrlMgr:clearPressed()
				elseif ctrlMgr:testPressed(ctrlMgr.KEY_DOWN) then
					----[[
					majorTeam:upgradeMajorLevel()
					--]]

					--[[
						if not self.blackboard then
							self.blackboard = require("app.main.modules.behavior3.core.Blackboard"):create()
						end
						b3Mgr:getB3Tree("test"):tick(nil, self.blackboard)
					--]]

					--[[
					netClient:addClient("client", "127.0.0.1", 8000,{
						client = {
							encrypt = { "xor","aes", }
						}
					},{
						onOpen = function (netline, result)
							if result then
								netline:writeProtocol("test", { arg11 = { low = 10 } })
								netline:writeProtocol("test", { arg9 = "client test!!!" })
							end
						end,
						onError = function (netline, etype, error)
							dump(error)
						end
					},true):regProtHandle("test_welcome",function (netline, name, data)
						dump(data.text,"client 1")
					end):regProtHandle("test",function (netline, name, data)
						dump(data.arg9,"client 2")
						dump(data.arg10[1],"client 3")
						dump(data.arg11.low,"client 4")
						dump(data.arg11.high,"client 5")
					end)
					--]]

					return ctrlMgr:clearPressed()
				end
			end
		end
	
		if bit.band(keycode,S_MOVEKEYS) ~= 0 then
			self:OnMoveKey(keycode)
		elseif keycode == ctrlMgr.KEY_A then
			if not self._majorteam:getMoveState() then
				uiMgr:openUI("mapfunction",self)
			end
		elseif keycode == ctrlMgr.KEY_SELECT then
			if not self._majorteam:getMoveState() then
				uiMgr:openUI("teamattribute",majorTeam)
			end
		elseif keycode == ctrlMgr.KEY_EXIT then
			if not self._majorteam:getMoveState() then
				gameMgr:ensureExitGame()
			end
		end
	end
end

-- 设置自动控制
function MapScene:setAutoControl(autoctrl)
	self._autoctrl = autoctrl
end

-- 获得从开始点到结束点的移动路径
function MapScene:getMovePath(spos,epos,terrain,team)
	local paths = AStart:create(spos,epos,self._stepsize,function (pos)
		return self:testReach(pos,terrain,team)
	end):calculatePath()
	if paths then
		local moves = {}
		local ldirect = nil
		local lpos = nil
		for _,ppos in ipairs(paths) do
			if lpos then
				local direct = tools:getDirect(lpos,ppos)
				if ldirect == direct then
					moves[#moves].step = moves[#moves].step + 1
				else
					table.insert(moves,{
						direct = direct,
						step = 1
					})
				end
				ldirect = direct
			end
			lpos = ppos
		end
		return moves
	end
end

-- 自动移动
function MapScene:onAutoMove(moves,onComplete)
	self:setAutoControl(true)
	local oldmoveend = self._onMoveEnded

	local function _autoMoveEnd(result)
		self._onMoveEnded = oldmoveend
		self:setAutoControl(false)
		if onComplete then onComplete(result) end
	end

	table.asyn_walk_sequence(function ()
		_autoMoveEnd(true)
	end,moves,function (onComplete_,move)
		table.asyn_walk_sequence(onComplete_,table.range(move.step) ,function (onComplete__,i)
			self._onMoveEnded = function (move)
				if move then
					onComplete__(true)
				else
					_autoMoveEnd(false)
				end
			end
			self._majorteam:tryMove(move.direct,self._majorMoveEnd)
		end)
	end)
end

return MapScene
