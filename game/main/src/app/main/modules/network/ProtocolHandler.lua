--[[
	协议处理器
]]
local THIS_MODULE = ...

local ProtocolHandler = class("ProtocolHandler")

-- 初始化处理器
function ProtocolHandler:initHandler()
	self._prothandles = {}		-- 协议处理器
end

--[[
	注册协议处理
	name		协议名称
	handle		处理函数
	proi		处理优先级
	key			处理器键
]]
function ProtocolHandler:regProtHandle(name, handle, proi, key)
	local handlers = self._prothandles[name]
	if not handlers then
		handlers = { map = {}, list = {} }
		self._prothandles[name] = handlers
	end
	handlers.map[key or handle] = {
		handle = handle,
		proi = proi or 0,
	}
	handlers.list = table.values(handlers.map)
	table.sort(handlers.list, function (a,b)
		return a.proi > b.proi
	end)
	return self
end

--[[
	注销协议处理
	name		协议名称
	key			处理器键
]]
function ProtocolHandler:unregProtHandle(name, key)
	local handlers = self._prothandles[name]
	if handlers then
		if key then
			handlers.map[key] = nil
			handlers.list = table.values(handlers.map)
			table.sort(handlers.list, function (a,b)
				return a.proi > b.proi
			end)
		else
			self._prothandles[name] = { map = {}, list = {} }
		end
	end
	return self
end

--[[
	处理协议
	netline		网络线
	name		协议名称
	data		协议数据
]]
function ProtocolHandler:handleProtocol(netline, name, data)
	local handlers = self._prothandles[name]
	if handlers then
		for _,handle in ipairs(handlers.list) do
			handle.handle(netline, name, data)
		end
		return true
	end
end

return ProtocolHandler
