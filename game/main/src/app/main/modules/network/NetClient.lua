--[[
	网络客户端
]]
local THIS_MODULE = ...
local C_LOGTAG = "NetClient"

local NetLine = require("app.main.modules.network.NetLine")
local NetClient = class("NetClient", require("app.main.modules.network.ProtocolHandler"))

-- 获得单例对象
local instance = nil
function NetClient:getInstance()
	if instance == nil then
		instance = NetClient:create()
	end
	return instance
end

-- 构造函数
function NetClient:ctor()
	self:initHandler()
	self._clients = {}			-- 客户端表
end

--[[
	添加网络客户端
	name				名称
	address				地址
	port				端口
	config				配置
		buffthd			缓冲阀值，数据解析时重置缓冲区
		client			客户端配置
			encrypt		加密选择 { "xor","aes" } 
	listen				监听表
		onOpen			打开
		onRecvData		接收数据
		onRecvProt		接收协议
		onClose			关闭
		onError			错误
	immopen				立即打开网络线
]]
function NetClient:addClient(name, address, port, config, listen, immopen)
	if self._clients[name] then
		error(string.format("network client [%s] conflict!", name))
	else
		local netline = NetLine:create("C", name, address, port, config, listen)
		self._clients[name] = netline
		if immopen then netline:open() end
		return netline
	end
end

--[[
	获得网络客户端
	name		名称
]]
function NetClient:getClient(name)
	return self._clients[name]
end

--[[
	移除网络客户端
	name		名称
]]
function NetClient:removeClient(name)
	local netline = self._clients[name]
	if netline then
		netline:close()
		self._clients[name] = nil
	end
end

return NetClient
