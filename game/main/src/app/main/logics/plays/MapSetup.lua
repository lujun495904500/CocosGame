--[[
	地图安装
]]

local MapSetup = class("MapSetup")

--[[
	安装地图配置
	configs
	{
		[{
			mapname = "...",
			mapenvs = { ... }
		}] = {
			EVENT = { ... },
			NPC = { ... },
			TELEPORT = {
				IN = { ... },
				OUT = { ... }
			}
		}
	}
]]
function MapSetup:setupMapConfigs(onComplete,map,configs)
	table.asyn_walk_together(onComplete,configs,function (_onComplete,config,cond)
		if not self:checkMapCondition(cond,map) then
			_onComplete(false)
		else
			table.asyn_walk_sequence(function ()
				if config.TELEPORT then
					self:addMapTeleport(map,mconfig.TELEPORT)
				end
				_onComplete(true)
			end,{
				function (onComplete_)
					if config.NPC then
						self:setupMapNPC(onComplete_,map,config.NPC)
					else
						onComplete_()
					end
				end
				,function (onComplete_)
					if config.EVENT then
						self:setupMapEvent(onComplete_,map,config.EVENT)
					else
						onComplete_()
					end
				end
			},function (onComplete_,fn)
				fn(onComplete_)
			end)
		end
	end)
end

-- 检查地图条件
function MapSetup:checkMapCondition(mcond,map)
	if mcond.mapname ~= map:getMapName() then
		return false
	end
	if mcond.mapenvs then
		for mkey,mvalue in pairs(mcond.mapenvs) do
			if mvalue ~= gameMgr:getMapEnv(mkey) then
				return false
			end
		end
	end
	return true
end

-- 安装地图NPC
function MapSetup:setupMapNPC(onComplete,map,npcs)
	table.asyn_walk_together(onComplete,npcs,function (_onComplete,npc,name)
		map:addNPC(function (mapteam)
			_onComplete(mapteam ~= nil)
		end,name,npc)
	end)
end

-- 安装地图事件
function MapSetup:setupMapEvent(onComplete,map,events)
	table.asyn_walk_together(onComplete,events,function (_onComplete,event,name)
		map:addEvent(function (result)
			_onComplete(result)
		end,event.trigger,name,event)
	end)
end

-- 添加地图传送点
function MapSetup:addMapTeleport(map,teleports)
	if teleports.IN then
		for iname,inp in pairs(teleports.IN) do
			map:addTeleportIn(iname,inp.x,inp.y)
		end
	end
	if teleports.OUT then
		for bounds,teleout in pairs(teleports.OUT) do
			map:addTMXTeleportOut(bounds,teleout)
		end
	end
end

return MapSetup
