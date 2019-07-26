--[[
	behavior3 管理器
]]
local THIS_MODULE = ...

-- b3节点索引路径
local C_B3NODE_IPATH = "src/behavior3s"

-- b3树索引路径
local C_B3_IPATH = "res/b3trees"

local BehaviorTree = require("app.main.modules.behavior3.core.BehaviorTree")
local Behavior3Manager = class("Behavior3Manager", require("app.main.modules.behavior3.b3"))

-- 获得单例对象
local instance = nil
function Behavior3Manager:getInstance()
	if instance == nil then
		instance = Behavior3Manager:create()
		indexMgr:addListener(instance, { C_B3NODE_IPATH })
	end
	return instance
end

-- 构造函数
function Behavior3Manager:ctor()
	self._cnodecls = {}		-- 自定义节点类
	self._nodecls = {}		-- 节点类
	self._b3trees = {}		-- b3树

	self:registerNodeClasses(import(".actions.init",THIS_MODULE))
	self:registerNodeClasses(import(".composites.init",THIS_MODULE))
	self:registerNodeClasses(import(".decorators.init",THIS_MODULE))
end

-------------------------IndexListener-------------------------
-- 清空索引
function Behavior3Manager:onIndexesRemoved()
	self:releaseB3Trees()
	self._cnodecls = {}
	self._nodecls = {}
	self:onIndexesLoaded(C_B3NODE_IPATH, indexMgr:getIndex(C_B3NODE_IPATH))
end

-- 加载索引路径
function Behavior3Manager:onIndexesLoaded(ipath, ivalue)
	if ivalue then
		if ipath == C_B3NODE_IPATH then
			for name,clslua in pairs(ivalue) do
				self._cnodecls[name] = require(clslua)
			end
		end
	end
end
-------------------------IndexListener-------------------------

-- 注册节点类
function Behavior3Manager:registerNodeClasses(nodemap)
	for name,cls in pairs(nodemap) do
		self._nodecls[name] = cls
	end
end

--[[
	获得节点类
	name	类名
]]
function Behavior3Manager:getNodeClass(name)
	return self._cnodecls[name] or self._nodecls[name]
end

--[[
	检查是否是自定义节点
]]
function Behavior3Manager:isCustomeNode(name)
	return (self._cnodecls[name] ~= nil)
end

--[[
	获得B3树
	name 	名字
]]
function Behavior3Manager:getB3Tree(name)
	local tree = self._b3trees[name]
	if not tree then
		local config = indexMgr:readJson(indexMgr:getIndex(C_B3_IPATH .. "/" .. name))
		if config then
			tree = BehaviorTree:create(config)
			self._b3trees[name] = tree
		end
	end
	return tree
end

--[[
	释放B3树
]]
function Behavior3Manager:releaseB3Trees()
	self._b3trees = {}
end

-- 输出管理器当前状态
function Behavior3Manager:dump()
	dump(self._nodecls, "Behavior3Manager", 3)
end

return Behavior3Manager
