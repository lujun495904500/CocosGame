--[[
	地图基类
--]]

local MapBase = class("MapBase", require("app.main.modules.meta.MetaBase"))

-- 添加移动图层
function MapBase:addMoveLayer(layer)
end

-- 获得地图尺寸
function MapBase:getSize()
	return cc.p(0,0)
end

-- 获得地图步长
function MapBase:getStepSize()
	return cc.p(0,0)
end

-- 根据位置测试阻挡
function MapBase:testBlock(x,y)
end

-- 根据位置获得地形值
function MapBase:getTerrain(x,y)
end

-- 根据位置获得阶数
function MapBase:getSteps(x,y)
end

-- 获得传入点位置
function MapBase:getTeleportIn(inp)
end

-- 根据位置获得传出点信息
function MapBase:getTeleportOut(x,y)
end

-- 获得npc信息
function MapBase:getNpc(name)
end

-- 获得事件信息
function MapBase:getEvent(name)
end

-- 获得初始化脚本
function MapBase:getInitScript()
end

return MapBase
