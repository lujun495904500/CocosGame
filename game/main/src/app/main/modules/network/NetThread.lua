--[[
	网络 线程
]]
local THIS_MODULE = ...
local C_LOGTAG = "NetThread"

---------------------------------------------------------------------------------------------------------------
--[[
	网络线程函数
	shared		共享表
	crecv		接收通道
	csend		发送通道
]]
local function _NetThread(shared, crecv, csend)
	local C_SELECT_TIME = 0.5	-- SELECT 时间
	local C_LISTEN_COUNT = 10	-- listen 数量
	local C_LOGTAG = "NetThread"
	
	-- 写入频道
	writeChannel = csend

	local function main()
		require "config"
		require "cocos.cocos2d.functions"
		require "cocos.extendsm"
		local effil = cc.safe_require("effil")
		local utils = cc.safe_require("utils")
		local socket = cc.safe_require("socket")
		local SocketIO = require("app.main.modules.network.SocketIO")
		logMgr = require("app.main.modules.network.LogManager"):getInstance()
		protMgr = require("app.main.modules.network.ProtocolManager"):getInstance()
		
		math.randomseed(os.time())

		local seltime 	= shared.seltime or C_SELECT_TIME		-- SELECT 时间
		local liscount	= shared.liscount or C_LISTEN_COUNT		-- listen 数量
		local shutdown 	= false

		-- 检查只允许IPv6
		local function isIPv6Only(address)
			local addrifo = socket.dns.getaddrinfo(address)
			if addrifo ~= nil then
				for k,v in pairs(addrifo) do
					if v.family == "inet6" then
						return true
					end
				end
			end
		end

		local rsocks 		= {}	-- 读socket表
		local wsocks 		= {}	-- 写socket表
		local netidsmap		= {}	-- 网络ID 映射表
		local socksmap 		= {}	-- socket 映射表
		local timersmap 	= {}	-- 定时器表
		local netids		= 0		-- 网络ID
		
		local addSocket 	= nil	-- 添加socket
		local removeSocket 	= nil	-- 移除socket
		local doCallback	= nil	-- 执行回调
		local addTimer		= nil	-- 添加定时器
		local removeTimer	= nil	-- 移除定时器
		local newNetID		= nil	-- 分配网络ID

		-- 添加socket
		addSocket = function (sock, netid)
			local sockio = SocketIO:create(
				sock, 
				netid,
				{
					rsocks = rsocks, 
					wsocks = wsocks,
				},
				{
					addSocket = addSocket,
					removeSocket = removeSocket,
					doCallback = doCallback,
					addTimer = addTimer,
					removeTimer = removeTimer,
					newNetID = newNetID,
				})
			netidsmap[netid] = sockio
			socksmap[sock] = sockio
			return sockio
		end

		--[[
			移除socket
			error 		错误原因
		]]
		removeSocket = function (sock, error)
			local sockio = socksmap[sock]
			if sockio then
				local netid = sockio:getNetID()
				doCallback(sock, "CLOSED", error)
				sockio:release()
				netidsmap[netid] = nil
				socksmap[sock] = nil
				dump(error,"socket closed")
			end
		end

		--[[
			执行socket回调
			sock	绑定socket
			...		参数
		]]
		doCallback = function (sock, ...)
			local sockio = socksmap[sock]
			if sockio then
				local netid = sockio:getNetID()
				csend:push("NET", netid, ...)
			end
		end

		--[[
			添加定时器
			sock	绑定socket
			time	定时时间
			handle	处理程序
			key		键值，如果为nil，则使用handle
		]]
		addTimer = function (sock, time, handle, key)
			local timers = timersmap[sock]
			if not timers then
				timers = {}
				timersmap[sock] = timers
			end
			timers[key or handle] = {
				time 	= time,
				handle 	= handle,
			}
		end

		--[[
			移除定时器
			sock	绑定socket
			key		键值，如果为nil,则清空socket上所有定时器
		]]
		removeTimer = function (sock, key)
			local timers = timersmap[sock]
			if timers then
				if key then
					timers[key] = nil
				else
					timersmap[sock] = {}
				end
			end
		end

		--[[
			分配网络ID
		]]
		newNetID = function ()
			netids = netids - 1
			return netids
		end

		-- 命令处理表
		local commands = {
			--[[
				关闭网络线程
			]]
			["SHUT_DOWN"] = function ()
				shutdown = true		-- 关闭
			end,

			--[[
				清除协议
			]]
			["CLEAR_PROTS"] = function ()
				protMgr:clearProtocols()
			end,

			--[[
				加载协议
				prots		协议路径数组
			]]
			["LOAD_PROTS"] = function (prots)
				protMgr:loadProtocols(prots)
			end,

			--[[
				网络服务端
				netid				网络ID
				address				地址
				port				端口
				config				配置
					buffthd			缓冲阀值,默认为1024
					server			服务端
						liscount	监听数量
						encrypt		加密表, 如 "xor","aes", 默认 "xor"
					client			客户端
						encrypt		加密表,加密算法优先, 如 "xor","aes", 默认 "xor"
			]]
			["OPEN_SERVER"] = function (netid, address, port, config)
				config = config or {}
				config.server = config.server or {}
				local state, error = nil

				local server = isIPv6Only(address) and socket.tcp6() or socket.tcp()
				server:settimeout(0)
				state, error = server:bind(address, port)
				if not state then
					server:close()
					return csend:push("NET", netid, "OPEN_ERROR", error)
				end
				state, error = server:listen(config.server.liscount or liscount)
				if not state then
					server:close()
					return csend:push("NET", netid, "OPEN_ERROR", error)
				end
				local sockio = addSocket(server, netid)
				sockio:setConfig(config)
				sockio:listenClient()
			end,
			
			--[[
				网络客户端
				netid				网络ID
				address				地址
				port				端口
				config				配置
					buffthd			缓冲阀值
					client			客户端
						encrypt		加密表,加密算法优先, 如 "xor","aes", 默认 "xor"
			]]
			["OPEN_CLIENT"] = function (netid, address, port, config)
				config = config or {}
				config.client = config.client or {}
				local state, error = nil

				local client = isIPv6Only(address) and socket.tcp6() or socket.tcp()
				client:settimeout(0)
				state, error = client:connect(address, port)
				if not state and error ~= "timeout" then
					client:close()
					return csend:push("NET", netid, "OPEN_ERROR", error)
				end
				local sockio = addSocket(client, netid)
				sockio:setConfig(config)
				sockio:connectServer()
			end,

			--[[
				关闭网络
				netid				网络ID
			]]
			["CLOSE_NET"] = function (netid)
				local sockio = netidsmap[netid]
				if sockio then
					removeSocket(sockio:getSocket())
				end
			end,
			
			--[[
				写入数据
				netid		网络ID
				data		数据
			]]
			["WRITE_DATA"] = function (netid, data)
				local sockio = netidsmap[netid]
				if sockio then
					sockio:writeData(data)
				end
			end,

			--[[
				写入测试数据
				netid		网络ID
				data		数据
			]]
			["WRITE_TEST"] = function (netid, data)
				local sockio = netidsmap[netid]
				if sockio then
					sockio:writeTest(data)
				end
			end,

			--[[
				写入协议
				netid		网络ID
				name		协议名
				data		协议数据
			]]
			["WRITE_PROTOCOL"] = function (netid, name, data)
				local sockio = netidsmap[netid]
				if sockio then
					sockio:writeProtocol(name, data)
				end
			end,
		}

		-- 加载游戏协议
		protMgr:loadProtocols(shared.prots)
		
		local t_begin = socket.gettime()

		while not shutdown do
			-- 处理操作命令
			local recv = { crecv:pop(0, "s") }
			while #recv > 0 do
				local command = commands[recv[1]]
				if command then
					command(select(2, unpack(recv)))
				end
				recv = { crecv:pop(0, "s") }
			end

			-- select 套接字
			local reads, writes, status = socket.select(rsocks, wsocks, seltime)
			for _,sock in ipairs(reads) do
				local sockio = socksmap[sock]
				if sockio then
					sockio:onRead()
				end
			end
			for _,sock in ipairs(writes) do
				local sockio = socksmap[sock]
				if sockio then
					sockio:onWrite()
				end
			end

			-- 处理定时器
			local t_end = socket.gettime()
			local delaytime = t_end - t_begin
			for _,timers in pairs(timersmap) do
				for _,key in pairs(table.keys(timers)) do
					local timer = timers[key]
					if timer then
						timer.time = timer.time - delaytime
						if timer.time <= 0 then
							timers[key] = nil
							timer.handle()		-- 定时回调
						end
					end
				end
			end
			t_begin = t_end
		end

		-- 关闭
		for sock,_ in pairs(table.keys(socksmap)) do
			removeSocket(sock)
		end
		csend:push("THREAD", "SHUT_DOWN")
	end
	
	local status, msg = xpcall(main, function(msg) return debug.traceback(msg, 3) end)
	if not status then
		writeChannel:push("ERROR", msg)
	end
end
---------------------------------------------------------------------------------------------------------------

-- 默认停止超时(s)
local C_STOP_TIMEOUT = 1

-- 通信通道大小
local C_CHANNEL_SIZE = 50

-- 每次最大接收次数
local C_RECVCOUNT_MAX = 10

-- 协议索引路径
local C_PROT_IPATH = "prot"

local socket = cc.safe_require("socket")
local effil = cc.safe_require("effil")
local NetThread = class("NetThread", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function NetThread:getInstance()
	if instance == nil then
		instance = NetThread:create()
		indexMgr:addListener(instance, { C_PROT_IPATH })
	end
	return instance
end

-- 构造函数
function NetThread:ctor()
	self._shared 	= nil	-- 共享表
	self._csend		= nil	-- 发送通道	
	self._crecv		= nil	-- 接收通道
	self._thread 	= nil	-- 线程对象
	self._timer		= nil	-- 定时器

	self._netids	= 0		-- 网络ID
	self._callbacks = {}	-- 回调表
end
-------------------------IndexListener-------------------------
-- 清空索引
function NetThread:onIndexesRemoved()
	if self._csend then
		self._csend:push("CLEAR_PROTS")
		self:onIndexesLoaded(C_PROT_IPATH, indexMgr:getIndex(C_PROT_IPATH))
	end
end

-- 加载索引路径
function NetThread:onIndexesLoaded(ipath, ivalue)
	if self._csend and ivalue then
		if ipath == C_PROT_IPATH then
			self._csend:push("LOAD_PROTS", ivalue)
		end
	end
end
-------------------------IndexListener-------------------------

--[[
	启动
	config		配置
]]
function NetThread:start(config)
	if not self._thread then
		logMgr:info(C_LOGTAG, "start network thread, send channel %d, recv channel %d", C_CHANNEL_SIZE, C_CHANNEL_SIZE)

		self._shared	= effil.table(table.merge(config or {} ,{
			prots = indexMgr:getIndex(C_PROT_IPATH)
		}))
		self._csend		= effil.channel(C_CHANNEL_SIZE)
		self._crecv		= effil.channel(C_CHANNEL_SIZE)
		self._thread = effil.thread(_NetThread)(self._shared, self._csend, self._crecv)
		self._timer = scheduler:scheduleScriptFunc(handler(self, NetThread.update), 0, false)
	end
end

--[[
	停止
	timeout		超时时间
]]
function NetThread:stop(timeout)
	timeout = (timeout or C_STOP_TIMEOUT) * 1000
	self._callbacks = {}
	if self._timer then
		scheduler:unscheduleScriptEntry(self._timer)
		self._timer = nil
	end
	
	if self._csend then
		self._csend:push("SHUT_DOWN")
	end
	if self._crecv then
		while timeout > 0 do
			local ntime = socket.gettime()
			local rtype,result = self._crecv:pop(timeout, "ms")
			if rtype == "THREAD" and result == "SHUT_DOWN" then
				break
			end
			timeout = timeout - ((socket.gettime() - ntime) * 1000)
		end
	end
	self._shared 	= nil
	self._csend		= nil
	self._crecv		= nil
	self._thread 	= nil

	logMgr:info(C_LOGTAG, "stop network thread")
end

--[[
	更新提取网络数据
]]
function NetThread:update()
	if self._crecv then
		local recvcount = 0
		local recv = { self._crecv:pop(0,"s") }
		while recvcount < C_RECVCOUNT_MAX and #recv > 0 do
			if recv[1] == "NET" then
				local callback = self._callbacks[recv[2]]
				if callback then
					callback(select(3, unpack(recv)))
				end
				if recv[3] == "CLOSED" then
					self._callbacks[recv[2]] = nil
				end
			elseif recv[1] == "LOG" then
				logMgr:writeContent(select(2, unpack(recv)))
			elseif recv[1] == "ERROR" then
				logMgr:error(C_LOGTAG, 
					"\n------------------------------NET ERROR------------------------------\n" .. 
					recv[2] .. 
					"\n----------------------------------------------------------------------")
			end
			recvcount = recvcount + 1
			recv = { self._crecv:pop(0, "s") }
		end
	end
end

--[[
	打开服务器
	callback		回调函数
	address			连接地址
	port			连接端口
	config			客户端配置
]]
function NetThread:openServer(callback, address, port, config)
	if self._csend then
		self._netids = self._netids + 1
		self._callbacks[self._netids] = callback
		self._csend:push("OPEN_SERVER", self._netids, address, port, config or {})
	end
end

--[[
	打开客户端
	callback		回调函数
	address			连接地址
	port			连接端口
	config			客户端配置
]]
function NetThread:openClient(callback, address, port, config)
	if self._csend then
		self._netids = self._netids + 1
		self._callbacks[self._netids] = callback
		self._csend:push("OPEN_CLIENT", self._netids, address, port, config or {})
	end
end

--[[
	打开网络
	netid		网络ID
]]
function NetThread:openNet(netid, callback)
	if self._csend and netid then
		self._callbacks[netid] = callback
	end
end

--[[
	关闭网络
	netid		网络ID
]]
function NetThread:closeNet(netid)
	if self._csend and netid then
		self._callbacks[netid] = nil
		self._csend:push("CLOSE_NET", netid)
	end
end

--[[
	写入通信数据
	netid		网络ID
	data		数据
]]
function NetThread:writeData(netid, data)
	if self._csend and netid then
		self._csend:push("WRITE_DATA", netid, data)
		return true
	end
end

--[[
	写入测试数据
	netid		网络ID
	data		数据
]]
function NetThread:writeTest(netid, data)
	if self._csend and netid then
		self._csend:push("WRITE_TEST", netid, data)
		return true
	end
end

--[[
	写入协议
	netid		网络ID
	name		协议名
	data		协议数据
]]
function NetThread:writeProtocol(netid, name, data)
	if self._csend and netid then
		self._csend:push("WRITE_PROTOCOL", netid, name, data)
		return true
	end
end

return NetThread
