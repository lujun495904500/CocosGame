--[[
	The BehaviorTree class, as the name implies, represents the Behavior Tree
 	structure.
]]
local C_LOGTAG = "BehaviorTree"

local b3 = require("app.main.modules.behavior3.b3")
local Tick = require("app.main.modules.behavior3.core.Tick")
local BehaviorTree = class("BehaviorTree")

--[[
	构造函数
	config		行为树配置
		debug
]]
function BehaviorTree:ctor(config)
	if config then
		table.merge(self, config)
	end
	self.id = self.id or utils.create_uuid()
	self.title = self.title or 'The behavior tree'
	self.description = self.description or ''
	self.properties = self.properties or {}
	self:initTree()
end

--[[
	初始化行为树
]]
function BehaviorTree:initTree() 
	if self.nodes then
		local nodes = {}
		for id,nconf in pairs(self.nodes) do
			local cls = b3Mgr:getNodeClass(nconf.name)
			assert(cls, string.format("BehaviorTree.load: Invalid node name '%s'.", nconf.name))
			nodes[id] = cls:create(nconf)
		end
		
		for id,node in pairs(nodes) do
			if node.children then
				local children = {}
				for i,nid in ipairs(node.children) do
					children[i] = nodes[nid]
				end
				node.children = children
			elseif node.child then
				node.child = nodes[node.child]
			end
		end

		self.root = nodes[self.root]
		self.nodes = nodes
	end
end

--[[
	This method dump the current BT into a data structure.
]]
function BehaviorTree:dump()
	local data = {}

    data.title = self.title
    data.description = self.description
    data.root = self.root and self.root.id or nil
    data.properties = self.properties
    data.nodes = {}
    data.custom_nodes = {}

	local stack = { self.root }
	while #stack > 0 do
		local node = stack[#stack]
		stack[#stack] = nil

		local config = {}
		config.id = node.id
		config.name = node.name
		config.title = node.title
		config.description = node.description
		config.properties = node.properties
		config.parameters = node.parameters

		if b3Mgr:isCustomeNode(node.name) then
			local subdata = {}
			subdata.name = node.name
			subdata.title = node.title
			subdata.category = node.category
			data.custom_nodes[#data.custom_nodes + 1] = subdata
		end

		if node.children then
			local children = {}
			for i,child in ipairs(node.children) do
				children[i] = child.id
				stack[#stack + 1] = child
			end
			config.children = children
		elseif node.child then
			stack[#stack + 1] = node.child
			config.child = node.child.id
		end

		data.nodes[#data.nodes + 1] = config
	end

	return data
end

--[[
	Propagates the tick signal through the tree, starting from the root.
]]
function BehaviorTree:tick(target, blackboard)
	if self.root then
		 -- CREATE A TICK OBJECT
		 local tick = Tick:create({
			debug = self.debug,
			target = target,
			blackboard = blackboard,
			tree = self,
		})

		-- TICK NODE 
		local state = self.root:_execute(tick)

		-- CLOSE NODES FROM LAST TICK, IF NEEDED 
		local lastOpenNodes = blackboard:get('openNodes', self.id) or {}
		local currOpenNodes = tick._openNodes
		local start = 1
		for i = 1, math.min(#lastOpenNodes, #currOpenNodes) do
			start = i + 1
			if lastOpenNodes[i] ~= currOpenNodes[i] then
				break
			end
		end

		for i = #lastOpenNodes, start, -1 do
			--logMgr:debug(C_LOGTAG,"close : %s", lastOpenNodes[i].id)
			lastOpenNodes[i]:_close(tick)
		end
		
		-- POPULATE BLACKBOARD 
		blackboard:set('openNodes', currOpenNodes, self.id)
		blackboard:set('nodeCount', tick._nodeCount, self.id)

		return state
	end
end

return BehaviorTree
