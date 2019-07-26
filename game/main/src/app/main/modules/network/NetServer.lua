--[[
	网络服务端
]]
local THIS_MODULE = ...
local C_LOGTAG = "NetServer"

local NetLine = require("app.main.modules.network.NetLine")
local NetServer = class("NetServer", require("app.main.modules.network.ProtocolHandler"))

-- 获得单例对象
local instance = nil
function NetServer:getInstance()
	if instance == nil then
		instance = NetServer:create()
	end
	return instance
end

-- 构造函数
function NetServer:ctor()
	self:initHandler()
	self._servers = {}			-- 服务端表
	self._netlines = {}			-- 网络线
end

--[[
	添加网络服务器
	name				名称
	address				地址
	port				端口
	config				配置
		buffthd			缓冲阀值，数据解析时重置缓冲区
		server			服务端
			liscount	监听数量
			encrypt		加密表, 如 "xor","aes", 默认 "xor"
		client			客户端
			encrypt		加密表,加密算法优先, 如 "xor","aes", 默认 "xor"
	listen				监听表
		onOpen			打开
		newConnect		新连接
		onClose			关闭
		onError			错误
	immopen				立即监听
]]
function NetServer:addServer(name, address, port, config, listen, immopen)
	if self._servers[name] then
		error(string.format("network server [%s] conflict!", name))
	else
		local netline = NetLine:create("S", name, address, port, config, listen)
		self._servers[name] = netline
		if immopen then netline:open() end
		return netline
	end
end

--[[
	获得网络服务器
	name		名称
]]
function NetServer:getServer(name)
	return self._servers[name]
end

--[[
	移除网络服务器
	name		名称
]]
function NetServer:removeServer(name)
	local netline = self._servers[name]
	if netline then
		netline:close()
		self._servers[name] = nil
	end
end

--[[
	添加网络线
	netline		网络线对象
]]
function NetServer:addNetLine(netline)
	netline:open()
	self._netlines[netline:getName()] = netline
end

--[[
	获得网络线
	name		网络线名称
]]
function NetServer:getNetLine(name)
	return self._netlines[name]
end

--[[
	移除网络线
	name		网络线名称
]]
function NetServer:removeNetLine(name)
	local netline = self._netlines[name]
	if netline then
		netline:close()
		self._netlines[name] = nil
	end
end

--[[
	移除移动服务器线上的所有网络线
	serline		服务端线
]]
function NetServer:removeNetLines(serline)
	for name,_ in pairs(table.keys(self._netlines)) do
		local netline = self._netlines[name]
		if netline:getServerLine() == serline then
			self:removeNetLine(name)
		end
	end
end

return NetServer
