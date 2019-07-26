--[[
	The BaseNode class is used as super class to all nodes in BehaviorJS. It
  	comprises all common variables and methods that a node must have to
  	execute.	
]]

local b3 = require("app.main.modules.behavior3.b3")
local BaseNode = class("BaseNode")

--[[
	构造函数
	config
		category
		id
		name
		title
		description
		properties
]]
function BaseNode:ctor(config)
	if config then
		table.merge(self, config)
	end
	self.id = self.id or utils.create_uuid()
	self.category = self.category or ""
	self.name = self.name or ""
	self.title = self.title or self.name
	self.description = self.description or ""
	self.properties = self.properties or {}
end

--[[
	This is the main method to propagate the tick signal to this node. This
   	method calls all callbacks: `enter`, `open`, `tick`, `close`, and
   	`exit`. It only opens a node if it is not already open. In the same
   	way, this method only close a node if the node  returned a status
   	different of `RUNNING`.
]]
function BaseNode:_execute(tick)
	-- ENTER
    self:_enter(tick)

	-- OPEN
	self:_open(tick)
	
    -- TICK
    local status = self:_tick(tick)

    -- CLOSE
    if status ~= b3.RUNNING then
		self:_close(tick)
	end

    -- EXIT
    self:_exit(tick)

    return status
end

-- Wrapper for enter method.
function BaseNode:_enter(tick)
	tick:_enterNode(self)
    self:enter(tick)
end

-- Wrapper for open method.
function BaseNode:_open(tick)
	tick:_openNode(self)
    if not tick.blackboard:get('isOpen', tick.tree.id, self.id) then
		tick.blackboard:set('isOpen', true, tick.tree.id, self.id)
    	self:open(tick)
	end
end

-- Wrapper for tick method.
function BaseNode:_tick(tick)
	tick:_tickNode(self)
    return self:tick(tick)
end

-- Wrapper for close method.
function BaseNode:_close(tick)
	self:close(tick)
   	tick.blackboard:set('isOpen', false, tick.tree.id, self.id)
	tick:_closeNode(self)
end

-- Wrapper for exit method.
function BaseNode:_exit(tick)
    self:exit(tick)
	tick:_exitNode(self)
end

--[[
	Enter method, override this to use. It is called every time a node is
   	asked to execute, before the tick itself.
]]
function BaseNode:enter(tick) end
function BaseNode:open(tick) end
function BaseNode:tick(tick) end
function BaseNode:close(tick) end
function BaseNode:exit(tick) end

-- 获得变量真实值
function BaseNode:getRealValue(value, tick)
	if tick and type(value) == "string" then
		if #value > 0 and value:byte(1) == 35 then -- #
			value = value:sub(2)
			if #value > 0 and value:byte(1) ~= 35 then -- 非转义
				value = tick.blackboard:get(value)
			end
		end
	end
	
	return value
end

return BaseNode
