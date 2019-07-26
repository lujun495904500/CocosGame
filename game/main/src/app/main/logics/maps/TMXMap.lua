--[[
	游戏地图
--]]
local THIS_MODULE = ...

local TMXMap = class("TMXMap",cc.Node, require("app.main.modules.map.MapBase"))

-- 类构造函数
function TMXMap:clsctor(config)
	if config then
		table.merge(self,config)
	end
	self:prepareMap()
end

-- 准备地图
function TMXMap:prepareMap()
	local tilemap = L.TMXTiledMap:create(self.tmx)
	self._mapsize = tilemap:getMapSize()
	self._tilesize = tilemap:getTileSize()
	self._tileoffest = cc.p(self._tilesize.width * 0.5, 0)
	self._tiletotal = self._mapsize.width * self._mapsize.height
	self._size = cc.size(self._mapsize.width * self._tilesize.width,
		self._mapsize.height * self._tilesize.height)
	self:loadMapProperties(tilemap)
	self:loadMapEvents(tilemap)
end

-- 加载地图属性(阻挡,地形,减速)
function TMXMap:loadMapProperties(tilemap)
	self._blockgroup = {}		-- 阻挡组
	self._talkgroup = {}		-- 对话传递组
	self._terraingroup = {}		-- 地形组
	self._stepgroup = {}		-- 阶数组

	local GidProps = {}
	for index,layer in ipairs(tilemap:getLayers()) do
		local blockmap = {}
		local talkmap = {}
		local terrainmap = {}
		local stepmap = {}
		local tileset = layer:getTileSet()
		for idx,gid in ipairs(layer:getTiles()) do 
			if gid ~= 0 then
				local gidprop = GidProps[gid]

				-- 读取GID属性
				if gidprop == nil then
					gidprop = {}

					local block = tileset:getProperty(gid, "block")
					if block ~= nil then
						gidprop.block = (block == "true")
					end
					
					local talk = tileset:getProperty(gid, "talk")
					if talk ~= nil then
						gidprop.talk = (talk == "true")
					end

					local terrain = tileset:getProperty(gid, "terrain")
					if terrain ~= nil then
						gidprop.terrain = terrainMgr:getValue(terrain)
					end

					local step = tileset:getProperty(gid, "step")
					if step ~= nil then
						local params = string.split(step,",")
						gidprop.step = {
							x = params[1] and tonumber(params[1]) or nil,
							y = params[2] and tonumber(params[2]) or nil
						}
					end

					GidProps[gid] = gidprop
				end

				-- 配置属性表
				if gidprop.block ~= nil then
					blockmap[idx] = gidprop.block
				end
				if gidprop.talk ~= nil then
					talkmap[idx] = gidprop.talk
				end
				if gidprop.terrain ~= nil then 
					terrainmap[idx] = gidprop.terrain
				end
				if gidprop.step ~= nil then
					stepmap[idx] = gidprop.step
				end
			end
		end
		self._blockgroup[index] = blockmap
		self._talkgroup[index] = talkmap
		self._terraingroup[index] = terrainmap
		self._stepgroup[index] = stepmap
	end

	--dump(GidProps)
	--dump(self._blockgroup)
	--dump(self._talkgroup)
	--dump(self._terraingroup)
	--dump(self._stepgroup)
end

-- 加载地图事件(传入,传出,NPC)
function TMXMap:loadMapEvents(tilemap)
	self._teleins = {}
	self._teleouts = {}
	self._npclist = {}
	self._eventlist = {}

	for _,group in ipairs(tilemap:getObjectGroups()) do
		for _,object in ipairs(group:getObjects()) do
			if object:isVisible() then
				local bounds = self:convertTMXPosBounds(object:getBounds())
				local props = object:getProperties()
				if object:getType() == "teleport" then
					
					local in_pos = props.in_pos
					local out_map = props.out_map
					local out_pos = props.out_pos
					if in_pos then
						self._teleins[in_pos] = { cx = bounds.x, cy = bounds.y }
					end
					if out_map and out_pos then
						self._teleouts[bounds] = { 
							mapname = out_map, 
							inpos = out_pos, 
							inmethod = props.out_method or "POINT", 
							inface = props.out_face or "DOWN",
							enable = tools:parseEPoint(props.out_enable),
							disable = tools:parseEPoint(props.out_disable)
						}
					end
				elseif object:getType() == "npc" then
					local params = table.merge({
						bounds = bounds
					},props)
					params.show = tools:parseEPoint(params.show)
					params.hide = tools:parseEPoint(params.hide)
					params.move = tools:parseScript(params.move)
					params.talk = tools:parseScript(params.talk)
					params.look = tools:parseScript(params.look)
					self._npclist[object:getName()] = params
				elseif object:getType() == "event" then
					local params = table.merge({
						bounds = bounds
					},props)
					params.enable = tools:parseEPoint(params.enable)
					params.disable = tools:parseEPoint(params.disable)
					params.script = tools:parseScript(params.script)
					params.single = params.single == "true"
					self._eventlist[object:getName()] = params
				end
			end
		end 
	end

	--dump(self._teleins)
	--dump(self._teleouts)
	--dump(self._npclist)
	--dump(self._eventlist)
end

-- 类析构函数
function TMXMap:clsdtor() end

-- 构造函数（路径）
function TMXMap:ctor()
	self._tilemap = L.TMXTiledMap:create(self.tmx)
	self._tilemap:setAnchorPoint(cc.p(0,0))
	self:addChild(self._tilemap)
	self:setAnchorPoint(cc.p(0,0))
	self._layers = self._tilemap:getLayers()
end

-- 显示瓦片区域
function TMXMap:showRegion(rect)
	self._tilemap:showRegion(rect)
end

-- 设置图层是否显示
function TMXMap:setLayerVisible(lname,visible)
	for _,layer in ipairs(self._layers) do
		if layer:getName() == lname then
			layer:setVisible(visible)
		end
	end
end

-- 添加图层
function TMXMap:addLayer(layer,order)
	self._tilemap:addChild(layer,order)
end

-- 获得地图尺寸
function TMXMap:getSize()
	return self._size
end

-- 获得地图步长
function TMXMap:getStepSize()
	return self._tilesize
end

-- 获得边界偏移点
function TMXMap:getBoundsOffest()
	return self._tileoffest
end

-- 转换为坐标区域
function TMXMap:toCoordBounds(bounds)
	return cc.rect(bounds.x/self._tilesize.width, bounds.y/self._tilesize.height,
		bounds.width/self._tilesize.width,bounds.height/self._tilesize.height)
end

-- 转换为位置区域
function TMXMap:toPositionBounds(bounds)
	return cc.rect(bounds.x * self._tilesize.width,bounds.y*self._tilesize.height,
		bounds.width*self._tilesize.width,bounds.height*self._tilesize.height)
end

-- 坐标转换为索引
function TMXMap:coordToIndex(cx,cy)
	return cx + (self._mapsize.height - cy - 1) * self._mapsize.width + 1
end

-- 索引转换为坐标
function TMXMap:indexToCoord(index)
	index = index - 1
	return index % self._mapsize.width,
		self._mapsize.height - math.floor(index / self._mapsize.width) - 1
end

-- 坐标转换为位置
function TMXMap:coordToPosition(cx,cy)
	return (cx + 0.5) * self._tilesize.width,cy * self._tilesize.height
end

-- 位置转换为坐标
function TMXMap:positionToCoord(x,y)
	return math.floor(x / self._tilesize.width),math.floor(y / self._tilesize.height)
end

-- 位置转换为索引
function TMXMap:positionToIndex(x,y)
	return self:coordToIndex(self:positionToCoord(x,y))
end

-- 索引转换为位置
function TMXMap:indexToPosition(index)
	return self:coordToPosition(self:indexToCoord(index))
end

-- 转换TMX位置边界
function TMXMap:convertTMXPosBounds(bounds)
	return cc.rect(bounds.x/self._tilesize.width,self._mapsize.height - (bounds.y + bounds.height)/self._tilesize.height,
		bounds.width/self._tilesize.width,bounds.height/self._tilesize.height)
end

-- 转换TMX坐标边界
function TMXMap:convertTMXCrdBounds(bounds)
	return cc.rect(bounds.x,self._mapsize.height - (bounds.y + bounds.height),bounds.width,bounds.height)
end

-- 根据位置测试阻挡
function TMXMap:testBlock(x,y)
	return self:testBlockByIndex(self:positionToIndex(x,y))
end

-- 根据坐标测试阻挡
function TMXMap:testBlockByCoord(cx,cy)
	return self:testBlockByIndex(self:coordToIndex(cx,cy))
end

-- 根据索引测试阻挡
function TMXMap:testBlockByIndex(index)
	for i = #self._layers,1,-1 do
		if self._layers[i]:isVisible() then
			if self._blockgroup[i][index] then
				return true
			end
		end
	end
end

-- 根据位置测试对话点
function TMXMap:testTalk(x,y)
	return self:testTalkByIndex(self:positionToIndex(x,y))
end

-- 根据坐标测试对话点
function TMXMap:testTalkByCoord(cx,cy)
	return self:testTalkByIndex(self:coordToIndex(cx,cy))
end

-- 根据索引测试对话点
function TMXMap:testTalkByIndex(index)
	for i = #self._layers,1,-1 do
		if self._layers[i]:isVisible() then
			if self._talkgroup[i][index] then
				return true
			end
		end
	end
end

-- 根据位置获得地形值
function TMXMap:getTerrain(x,y)
	return self:getTerrainByIndex(self:positionToIndex(x,y))
end

-- 根据坐标获得地形值
function TMXMap:getTerrainByCoord(cx,cy)
	return self:getTerrainByIndex(self:coordToIndex(cx,cy))
end

-- 根据索引获得地形值
function TMXMap:getTerrainByIndex(index)
	for i = #self._layers,1,-1 do
		if self._layers[i]:isVisible() then
			local terrain = self._terraingroup[i][index]
			if terrain then
				return terrain
			end
		end
	end
end

-- 根据位置获得阶数
function TMXMap:getSteps(x,y)
	return self:getStepsByIndex(self:positionToIndex(x,y))
end

-- 根据行列获得阶数
function TMXMap:getStepsByCoord(cx,cy)
	return self:getStepsByIndex(self:coordToIndex(cx,cy))
end

-- 根据索引获得阶数
function TMXMap:getStepsByIndex(index)
	for i = #self._layers,1,-1 do
		if self._layers[i]:isVisible() then
			local step = self._stepgroup[i][index]
			if step then
				return step
			end
		end
	end
end

-- 获得传入点位置
function TMXMap:getTeleportIn(inp)
	local telein = self._teleins[inp]
	if telein then
		return cc.p(self:coordToPosition(telein.cx,telein.cy))
	end
end

-- 根据位置获得传出点信息
function TMXMap:getTeleportOut(x,y)
	return self:getTeleportOutByCoord(self:positionToCoord(x,y))
end

-- 根据坐标获得传出点信息
function TMXMap:getTeleportOutByCoord(cx,cy)
	for bounds,teleout in pairs(self._teleouts) do
		if tools:testInBounds(cx,cy,bounds) and
			(not teleout.enable or archMgr:checkEventPoint(unpack(teleout.enable))) and 
			(not teleout.disable or not archMgr:checkEventPoint(unpack(teleout.disable))) then
			return teleout
		end
	end
end

-- 获得NPC信息
function TMXMap:getNPCInfo(name)
	return self._npclist[name]
end

-- 获得NPC列表
function TMXMap:getNPCList()
	return self._npclist
end

-- 获得事件信息
function TMXMap:getEventInfo(name)
	return self._eventlist[name]
end

-- 获得事件列表
function TMXMap:getEventList()
	return self._eventlist
end

-- 获得地图参数
function TMXMap:getParams()
	return self.params
end

return TMXMap
