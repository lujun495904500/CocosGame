--[[
	工具
]]
local THIS_MODULE = ...

local Team = require("app.main.logics.games.Team")
local Role = require("app.main.logics.games.Role")
local Item = require("app.main.logics.games.item.Item")

local Tools = class("Tools")

-- 获得单例对象
local instance = nil
function Tools:getInstance()
	if instance == nil then
		instance = Tools:create()
	end
	return instance
end

--[[
	创建队伍
]]
function Tools:createTeam()
	return Team:create()
end

--[[
	创建角色
	dataid		角色数据ID
	guest		宾客角色
]]
function Tools:createRole(dataid,guest)
	return Role:create("NEW",dataid,guest)
end

--[[
	创建物品
	dataid		物品数据ID
	count		物品的数量
]]
function Tools:createItem(dataid,count)
	local item = Item:create("NEW",{
		id = dataid, 
		count = count
	})
	return item:upgradeType()
end

--[[
	获得两点方向
	spos		开始点
	epos		结束点
	[return]	U/D/L/R
]]
function Tools:getDirect(spos,epos)
	if epos.x > spos.x then
		return "RIGHT"
	elseif epos.y > spos.y then
		return "UP"
	elseif epos.x < spos.x then
		return "LEFT"
	elseif epos.y < spos.y then
		return "DOWN"
	end
end

--[[
	获得相反的方向
	direct		方向
]]
function Tools:getOppositeDirect(direct)
	if direct == "UP" then
		return "DOWN"
	elseif direct == "DOWN" then
		return "UP"
	elseif direct == "LEFT" then
		return "RIGHT"
	elseif direct == "RIGHT" then
		return "LEFT"
	end
end

-- 测试点是否在指定范围内
function Tools:testInBounds(x,y,bounds)
	if x >= bounds.x and x < (bounds.x + bounds.width) and
		y >= bounds.y and y < (bounds.y + bounds.height) then
		return true
	end
end

-- 解析事件点
function Tools:parseEPoint(config,sp)
	if not config or config == "" then return end

	local point,segment
	local eps = string.split(config, sp or ":")
	if #eps > 1 then
		segment = eps[1]
		point = tonumber(eps[2])
	else
		local index = tonumber(eps[1])
		if index == nil then
			local econf = dbMgr.events[eps[1]]
			point = econf.point
			segment = econf.segment
		else
			point = index
		end
	end

	return { point, segment }
end

-- 解析脚本配置
function Tools:parseScript(config,sp)
	if not config or config == "" then return end

	local params = string.split(config,sp or ">")
	return { 
		script = params[1], 
		config = params[2]
	}
end

-- 获得波动随机值
function Tools:getSwingRand(value,swing)
	return math.random(math.floor(value * (1 - swing)),
			math.floor(value * (1 + swing)))
end

return Tools
