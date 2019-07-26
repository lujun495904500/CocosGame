--[[
	A new Tick object is instantiated every tick by BehaviorTree. It is passed
 	as parameter to the nodes through the tree during the traversal.
]]

local Tick = class("Tick")

--[[
	构造函数
	config
		tree
		debug
		target
		blackboard
]]
function Tick:ctor(config)
	if config then
		table.merge(self, config)
	end
	self._openNodes = {}
	self._nodeCount = 0
end

-- Called when entering a node (called by BaseNode).
function Tick:_enterNode(node)
	self._nodeCount = self._nodeCount + 1
	-- TODO: call debug here
end

-- Callback when opening a node (called by BaseNode).
function Tick:_openNode(node)
	table.insert(self._openNodes, node)
	-- TODO: call debug here
end

-- Callback when ticking a node (called by BaseNode).
function Tick:_tickNode(node)
	-- TODO: call debug here
end

-- Callback when closing a node (called by BaseNode).
function Tick:_closeNode(node)
	table.remove(self._openNodes, #self._openNodes)
	-- TODO: call debug here
end

-- Callback when exiting a node (called by BaseNode).
function Tick:_exitNode(node)
	-- TODO: call debug here
end

return Tick
