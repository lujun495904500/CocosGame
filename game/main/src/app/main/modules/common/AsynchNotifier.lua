--[[
	异步通知器
]]
local THIS_MODULE = ...

local AsynchNotifier = class("AsynchNotifier")

-- 初始化通知器
function AsynchNotifier:initNotifier()
	self._listeners = {}		-- 监听器
	self._orderkeys = {}		-- 排序键
end

-- 构建排序键
function AsynchNotifier:buildOrderKeys()
	self._orderkeys = table.keys(self._listeners)
	table.sort(self._orderkeys,function (a,b)
		return self._listeners[a].pri > self._listeners[b].pri
	end)
end

-- 添加监听器
function AsynchNotifier:addListener(listener,pri,key)
	self._listeners[key or listener] = {
		entity = listener,
		pri = pri or 0,
	}
	self:buildOrderKeys()
end

-- 移除监听器
function AsynchNotifier:removeListener(key)
	if self._listeners[key] then
		self._listeners[key] = nil
		self:buildOrderKeys()
	end
end

-- 清除所有监听器
function AsynchNotifier:clearListeners()
	self._listeners = {}
	self._orderkeys = {}
end

-- 通知消息
function AsynchNotifier:notify(onComplete, order, ...)
	if #self._orderkeys > 0 then
		local args = { ... }
		local asynwalk = order and table.asyn_walk_sequence or table.asyn_walk_together
		return asynwalk(onComplete, self._orderkeys, function (_onComplete,key,index)
			local listener = self._listeners[key]
			if not listener then
				_onComplete(false)
			else
				listener.entity(function ()
					_onComplete(true)
				end, self, unpack(args))
			end
		end)
	end
	if onComplete then onComplete() end
end

-- notify 同步函数
function AsynchNotifier:syncNotify(...)
	return utils.async_call(handler(self,AsynchNotifier.notify),...)
end

return AsynchNotifier
