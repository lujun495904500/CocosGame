--[[
	网络线
]]
local THIS_MODULE = ...

local NetLine = class("NetLine", require("app.main.modules.network.ProtocolHandler"))

--[[
	构造函数
	ntype 				类型 C/S/N
	name				名称
	address				地址
	port				端口
	config				配置
		buffthd			缓冲阀值，数据解析时重置缓冲区
		client			客户端配置
			encrypt		加密选择 { "xor","aes" } 
	listen				监听表
		onConnect		连接回调
		onClose			关闭回调
	netid				网络ID
]]
function NetLine:ctor(ntype, name, address, port, config, listen, netid)
	self:initHandler()
	self._ntype = ntype
	self._name = name
	self._address = address
	self._port = port
	self._config = config or {}
	self._listen = listen or {}
	self._netid = netid
end

-- 获得名称
function NetLine:getName()
	return self._name
end

-- 获得地址
function NetLine:getAddress()
	return self._address
end

-- 获得端口
function NetLine:getPort()
	return self._port
end

-- 设置监听表
function NetLine:setListen(listen)
	self._listen = listen or {}
end

-- 网络线的服务端线
function NetLine:setServerLine(netline)
	self._serline = netline
end
function NetLine:getServerLine()
	return self._serline
end

-- 是否有效
function NetLine:isValid()
	return self._netid ~= nil
end

-- 客户端回调
function NetLine:onClientCallback(rtype, ...)
	if rtype == "CONNECTED" then
		local netid = ...
		if netid then
			self._netid = netid
			if self._listen.onOpen then 
				self._listen.onOpen(self, true) 
			end
		end
	elseif rtype == "CONNECTFAIL" then
		if self._listen.onOpen then 
			self._listen.onOpen(self, false) 
		end
	elseif rtype == "RECIVE_PROTOCOL" then
		local name, data = ...
		if self._listen.onRecvProt then 
			self._listen.onRecvProt(self, name, data) 
		end
		if not self:handleProtocol(self, name, data) then
			netClient:handleProtocol(self, name, data)
		end
	elseif rtype == "RECIVE_DATA" then
		local data = ...
		if self._listen.onRecvData then 
			self._listen.onRecvData(self, data) 
		end
	elseif rtype == "OPEN_ERROR" then
		local error = ...
		if self._listen.onError then 
			self._listen.onError(self, "open", error) 
		end
	elseif rtype == "CLOSED" then
		if self._netid then
			self._netid = nil
			local error = ...
			if self._listen.onClose then 
				self._listen.onClose(self, error) 
			end
		end
	end
end

-- 服务器回调
function NetLine:onServerCallback(rtype, ...)
	if rtype == "LISTENED" then
		local netid = ...
		if netid then
			self._netid = netid
			if self._listen.onOpen then 
				self._listen.onOpen(self, true) 
			end
		end
	elseif rtype == "NEW_CONNECT" then		-- 新连接
		local netid, address, port = ...
		local netline = NetLine:create("N", netid, address, port, nil, nil, netid)
		netline:setServerLine(self)
		netServer:addNetLine(netline)
		if self._listen.newConnect then 
			self._listen.newConnect(netline) 
		end
	elseif rtype == "OPEN_ERROR" then
		local error = ...
		if self._listen.onError then 
			self._listen.onError(self, "open", error) 
		end
	elseif rtype == "CLOSED" then
		if self._netid then
			self._netid = nil
			netServer:removeNetLines(self)
			local error = ...
			if self._listen.onClose then 
				self._listen.onClose(self, error) 
			end
		end
	end
end

-- 网络连接回调
function NetLine:onNetCallback(rtype, ...)
	if rtype == "RECIVE_PROTOCOL" then
		local name, data = ...
		if self._listen.onRecvProt then 
			self._listen.onRecvProt(self, name, data) 
		end
		if not self:handleProtocol(self, name, data) then
			netServer:handleProtocol(self, name, data)
		end
	elseif rtype == "RECIVE_DATA" then
		local data = ...
		if self._listen.onRecvData then 
			self._listen.onRecvData(self, data) 
		end
	elseif rtype == "CLOSED" then
		if self._netid then
			self._netid = nil
			netServer:removeNetLine(self._name)
			local error = ...
			if self._listen.onClose then 
				self._listen.onClose(self, error) 
			end
		end
	end
end

-- 打开网络线
function NetLine:open()
	if not self._netid then
		if self._ntype == "C" then
			netThread:openClient(handler(self, NetLine.onClientCallback), 
				self._address, self._port, self._config)
		elseif self._ntype == "S" then
			netThread:openServer(handler(self, NetLine.onServerCallback), 
				self._address, self._port, self._config)
		end
	else
		if self._ntype == "N" then
			netThread:openNet(self._netid, handler(self, NetLine.onNetCallback))
		end
	end
end

-- 关闭网络线
function NetLine:close()
	if self._netid then
		local netid = self._netid
		self._netid = nil
		netThread:closeNet(netid)
		if self._ntype == "S" then
			netServer:removeNetLines(self)
		elseif self._ntype == "N" then
			netServer:removeNetLine(self._name)
		end
	end
end

--[[
	写入数据
	data		数据
]]
function NetLine:writeData(data)
	if self._ntype == "C" or self._ntype == "N" and self._netid then
		return netThread:writeData(self._netid, data)
	end
end

--[[
	写入测试数据
	data		数据
]]
function NetLine:writeTest(data)
	if self._ntype == "C" or self._ntype == "N" and self._netid then
		return netThread:writeTest(self._netid, data)
	end
end

--[[
	写入协议
	name		协议名
	data		协议数据
]]
function NetLine:writeProtocol(name, data)
	if self._ntype == "C" or self._ntype == "N" and self._netid then
		return netThread:writeProtocol(self._netid, name, data)
	end
end

return NetLine
