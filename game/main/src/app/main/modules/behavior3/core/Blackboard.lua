--[[
	The Blackboard is the memory structure required by `BehaviorTree` and its
 	nodes. It only have 2 public methods: `set` and `get`. These methods works
 	in 3 different contexts: global, per tree, and per node per tree.
]]

local Blackboard = class("Blackboard")

--[[
	构造函数
]]
function Blackboard:ctor()
	self._baseScope = {}	-- 基础域
end

--[[
	获得指定域空间
	... 	域, 比如 tree, node
]]
function Blackboard:getScope(...)
	local scope = self._baseScope
	for _,sname in ipairs({ ... }) do
		local _scope = scope[sname]
		if not _scope then
			_scope = {}
			scope[sname] = _scope
		end
		scope = _scope
	end
	return scope
end

--[[
	设置参数值
	key		键
	value	值
	...		域, 比如 tree, node
]]
function Blackboard:set(key, value, ...)
	self:getScope(...)[key] = value
end

--[[
	获得参数值
	key		键
	...		域, 比如 tree, node
]]
function Blackboard:get(key, ...)
	return self:getScope(...)[key]
end

--[[
	清空指定域
	...		域, 比如 tree, node
]]
function Blackboard:clear(...)
	local names = { ... }
	if #names > 0 then
		local scopes = {}
		for i = 1, #names - 1 do
			scopes[#scopes + 1] = names[i]
		end
		self:getScope(unpack(scopes))[names[#names]] = nil
	end
end

return Blackboard
