--[[
	套接字IO
]]
local THIS_MODULE = ...
local C_LOGTAG = "NetThread"

-- 协议版本号
local C_PROT_VERS = 1

-- 缓冲阀值
local C_BUFF_THD = 1024

-- 握手超时
local C_SHAKE_TIMEOUT = 2

-- 心跳超时
local C_HEART_TIMEOUT = 10

-- 客户端心跳分割
local C_HEART_CSPLIT = 2

-- 心跳最大数量
local C_HEART_MAX = 2

-- 发送队列大小
local C_SENDQUEUE_SIZE = 256

-- 数据压缩最小
local C_COMPSIZE_MIN = 1000--3 * 1024 * 1024

-- 默认加密密钥
local C_ENCRYPT_RSAKEY = {
	file = "res/main/secrets/rsa/public_key.pem",
	public = true,
}

-- 默认解密密钥
local C_DECRYPT_RSAKEY = {
	file = "res/main/secrets/rsa/private_key_pkcs8.pem",
}

-- 默认xor密钥配置
local C_XOR_KEY = {
	minlen	= 8,
	maxlen 	= 16,
}

----------------------------------TYPE---------------------------------------
-- 包类型
local C_PTYPE_SHAKE = 1		-- 握手
local C_PTYPE_HEART = 2		-- 心跳
local C_PTYPE_DATA 	= 3		-- 数据
local C_PTYPE_PROT	= 4		-- 协议
local C_PTYPE_TEST 	= 15	-- 测试

-----------------------------------------------------------------------------

----------------------------------FLAG---------------------------------------
-- 数据标识
local C_DFLAG_PTYPE = 15	-- 包类型， 如握手，心跳，协议，数据
local C_DFLAG_COMPS = 16	-- 压缩

-- 服务标识
local C_SFLAG_ENCRYPT = 1	-- 加密

-- 加密标识
local C_EFLAG_XOR = 1		-- 异或加密
local C_EFLAG_AES = 2		-- AES加密

-- 握手标识
local C_HFLAG_ENCRYPT = 1	-- 加密
-----------------------------------------------------------------------------

local effil = cc.safe_require("effil")
local utils = cc.safe_require("utils")
local Queue = require("app.main.modules.common.Queue")
local BufferReader = require("app.main.modules.common.BufferReader")
local StreamReader = require("app.main.modules.common.StreamReader")
local BufferWriter = require("app.main.modules.common.BufferWriter")
local NetError = require("app.main.modules.network.NetError")
local SocketIO = class("SocketIO")

--[[
	构造函数
	socket				套接字实体
	netid				网络ID
	selects
		rsocks			读套接字表
		wsocks			写套接字表
	operates			操作表
		addSocket		添加套接字
		removeSocket	移除套接字
		doCallback		执行回调
		addTimer		添加定时器
		removeTimer		移除定时器
		newNetID		分配网络ID
]]
function SocketIO:ctor(socket, netid, selects, operates)
	self._socket = socket
	self._netid = netid
	self._selects = selects
	self._operates = operates
	self._reader = StreamReader:create()
	self._writeque = Queue:create(C_SENDQUEUE_SIZE)
	self._data = {}			-- 数据

	-- 握手超时
	self._shakeTimeout = function ()
		self._operates.removeSocket(self._socket, NetError.SHAKE_TIMEOUT)
	end

	-- 心跳检查
	self._heartCheck = handler(self, SocketIO.onCheckHeart)

	-- 心跳写入
	self._heartWrite = handler(self, SocketIO.openHeartWrite)
end

-- 获得套接字
function SocketIO:getSocket()
	return self._socket
end

-- 获得网络ID
function SocketIO:getNetID()
	return self._netid
end

-- 监听套接字IO
function SocketIO:setListenIO(sock)
	self._lissocket = sock
end
function SocketIO:getListenIO()
	return self._lissocket
end

-- 设置套接字配置，特别是服务器套接字
function SocketIO:setConfig(config)
	self._config = config or {}
end

--[[
	使能套接字读
	enable		是否可读
]]
function SocketIO:enableRead(enable)
	local index = table.indexof(self._selects.rsocks, self._socket)
	if enable then
		if not index then
			table.insert(self._selects.rsocks, self._socket)
		end
	else
		if index then
			table.remove(self._selects.rsocks, index)
		end
	end
end

--[[
	使能套接字写
	enable		是否可写
]]
function SocketIO:enableWrite(enable)
	local index = table.indexof(self._selects.wsocks, self._socket)
	if enable then
		if not index then
			table.insert(self._selects.wsocks, self._socket)
		end
	else
		if index then
			table.remove(self._selects.wsocks, index)
		end
	end
end

-- 释放
function SocketIO:release()
	if self._socket then
		self:enableRead(false)
		self:enableWrite(false)
		self._operates.removeTimer(self._socket)
		self._socket:close()
		self._socket = nil
	end
end

-- 监听客户端
function SocketIO:listenClient()
	self._action = "listen"
	self:enableRead(true)
	self._operates.doCallback(self._socket, "LISTENED", self:getNetID())
end

-- 连接服务器
function SocketIO:connectServer()
	self._action = "connect"
	self:enableWrite(true)
end

-- 和客户端握手
function SocketIO:shakeClient()
	self._action = "shake_client"
	self._data = {}
	self._step = 1					
	self:enableWrite(true)
end

-- 和服务器握手
function SocketIO:shakeServer()
	self._action = "shake_server"
	self._data = {}
	self._step = 1					
	self:enableRead(true)
	self._operates.addTimer(self._socket, C_SHAKE_TIMEOUT, self._shakeTimeout, "shake")
end

-- 开启心跳检查
function SocketIO:openHeartCheck()
	self._hearts = C_HEART_MAX
	self._operates.addTimer(self._socket, self._data.heart.time, self._heartCheck, "heart")
end

-- 开启心跳发送
function SocketIO:openHeartWrite()
	local writer = BufferWriter:create()
	writer:writeUShort(self._data.heart.id)
	--writer:writeData(string.rep("1",1500))
	self._writeque:pushBack({
		flag = C_PTYPE_HEART,
		data = writer:getData()
	})
	self:enableWrite(true)
	self._operates.addTimer(self._socket, self._data.heart.time, self._heartWrite, "heart")
end

-- 写入数据
function SocketIO:writeData(data)
	self._writeque:pushBack({
		flag = C_PTYPE_DATA,
		data = data,
	})
	self:enableWrite(true)
end

-- 写入测试
function SocketIO:writeTest(data)
	self._writeque:pushBack({
		flag = C_PTYPE_TEST,
		data = data,
	})
	self:enableWrite(true)
end

--[[
	写入协议
	name	协议名
	data	协议数据
]]
function SocketIO:writeProtocol(name, data)
	local protocol = protMgr:getProtocolByName(name)
	if protocol then
		local writer = BufferWriter:create()
		writer:writeUShort(protocol.cmd)
		protocol.pack(writer, data)
		self._writeque:pushBack({
			flag = C_PTYPE_PROT,
			data = writer:getData(),
		})
		self:enableWrite(true)
	end
end

-- 可读操作回调
function SocketIO:onRead()
	if self._action == "listen" then
		self:onListen()
	else
		local recvdata, recvstate = self._socket:receive("*n")
		if not recvdata then
			self._operates.removeSocket(self._socket, 
				(recvstate ~= "closed" and recvstate ~= "timeout") and NetError.DATA_RECIVE or nil)
		else
			self._reader:append(recvdata)

			-- 处理数据
			if self._action then
				if self._action == "shake_client" then
					self:onShakeClient(false)
				elseif self._action == "shake_server" then
					self:onShakeServer(false)
				end
			else
				self:onReadData()
			end
			
			-- 重置缓冲区
			if self._reader:getIndex() > (self._config.buffthd or C_BUFF_THD) then
				self._reader:resize()
			end
		end
	end
end

-- 可写操作回调
function SocketIO:onWrite()
	if self._action then
		if self._action == "connect" then
			self:onConnect()
		elseif self._action == "shake_client" then
			self:onShakeClient(true)
		elseif self._action == "shake_server" then
			self:onShakeServer(true)
		end
	else
		self:onWriteData()
	end
end

-- 通知 服务器listen
function SocketIO:onListen()
	local sock = self._socket:accept()
	local netid = self._operates.newNetID()
	local sockio = self._operates.addSocket(sock, netid)
	sockio:setConfig(self._config)
	sockio:setListenIO(self)
	sockio:shakeClient()
end

-- 通知 客户端connect
function SocketIO:onConnect()
	self._action = nil
	self:enableWrite(false)
	self:shakeServer()
end

-- 通知 数据写入
function SocketIO:onWriteData()
	while not self._writeque:isEmpty() do
		local send = self._writeque:peekFront()
		local result,index = self:_writeData(send)
		if not result then
			return self._operates.removeSocket(self._socket, self._data.error)
		end
		if index >= #send.data then
			self._writeque:popFront()
		else	-- 未完全发送，缓冲区已满
			send.index = index
			break
		end
	end
	if self._writeque:isEmpty() then
		self:enableWrite(false)		-- 队列为空，停止
	end
end

-- 通知 数据读取
function SocketIO:onReadData()
	while true do
		local recv = self:_readData()
		if not recv then
			break		-- 未读到数据，跳出
		end
		if recv.result then
			local ptype = bit.band(recv.flag, C_DFLAG_PTYPE)		-- 包类型
			if ptype == C_PTYPE_HEART then
				self:onReadHeart(recv.flag, recv.data)
			elseif ptype == C_PTYPE_DATA then
				self._operates.doCallback(self._socket, "RECIVE_DATA", recv.data)
			elseif ptype == C_PTYPE_PROT then
				self:onReadProtocol(recv.flag, recv.data)
			elseif ptype == C_PTYPE_TEST then
				logMgr:info(C_LOGTAG, "TEST DATA : %s", recv.data)
			else
				self._operates.removeSocket(self._socket, NetError.PACK_TYPE)
			end
		else
			self._operates.removeSocket(self._socket, self._data.error)
		end
	end
end

-- 通知 读取心跳
function SocketIO:onReadHeart(flag, data)
	local reader = BufferReader:create(data)
	if reader:readUShort() == self._data.heart.id then
		self._hearts = C_HEART_MAX
	end
end

-- 通知 读取协议
function SocketIO:onReadProtocol(flag, data)
	local reader = BufferReader:create(data)
	local cmd = reader:readUShort()
	local protocol = protMgr:getProtocolByCMD(cmd)
	if protocol then
		local pdata = protocol.unpack(reader)
		self._operates.doCallback(self._socket, "RECIVE_PROTOCOL", protocol.name, pdata)
	else
		logMgr:warn(C_LOGTAG, "protocol cmd %d not found!", cmd)
	end
end

-- 检查 心跳包
function SocketIO:onCheckHeart()
	self._hearts = self._hearts - 1
	if self._hearts <= 0 then
		self._operates.removeSocket(self._socket, NetError.HEART_TIMEOUT)
	else
		self._operates.addTimer(self._socket, self._data.heart.time, self._heartCheck, "heart")
	end
end

--[[
	写入数据
	send	
		flag		标志, 16位
		data		数据
		index		数据开始位置
]]
function SocketIO:_writeData(send)
	if not send.index then		-- 数据未开始写入
		if bit.band(send.flag, C_DFLAG_PTYPE) ~= C_PTYPE_SHAKE then
			-- 压缩
			if self._config.compable then
				local cmpsize = self._config.compsize or C_COMPSIZE_MIN
				if #send.data >= cmpsize then
					send.flag = bit.bor(send.flag, C_DFLAG_COMPS)  	-- 添加压缩标识
					
					local writer = BufferWriter:create()
					writer:writeULong(#send.data)
		
					local state,cmpdata = utils.Zlib_compress(send.data)
					if not state then
						self._data.error = NetError.DATA_COMPRESS
						return false
					end
					writer:writeData(cmpdata)
					
					send.data = writer:getData()
				end
			end
	
			-- 加密
			if self._data.encrypt then
				if not self._data.enckey then
					self._data.error = NetError.NOT_DATA_ENCKEY
					return false
				end
	
				if self._data.encrypt == C_EFLAG_XOR  then
					local xorkey = self._config.xorkey or C_XOR_KEY
					local enckey = self:genRandStr(math.random(xorkey.minlen, xorkey.maxlen))
				
					local writer = BufferWriter:create()
					writer:writeBString(enckey)
					writer:writeData(send.data)
					
					send.data = utils.XOR_encrypt(writer:getData(), self._data.enckey)
					self._data.enckey = enckey
				elseif self._data.encrypt == C_EFLAG_AES  then
					local key_, iv_ = self:genRandAES()
					local enckey = {
						key = key_,
						iv = iv_,
					}
					
					local writer = BufferWriter:create()
					writer:writeBString(key_)
					writer:writeBString(iv_)
					writer:writeData(send.data)
					
					local state, encdata = utils.AES_encrypt(self._data.enckey.key, self._data.enckey.iv, writer:getData())
					if not state then
						self._data.error = NetError.AES_ENCRYPT
						return false
					end
					
					send.data = encdata
					self._data.enckey = enckey
				else
					self._data.error = NetError.UNK_DATA_ENCRYPT
					return false
				end
			end
		end
	
		local size = 4 + #send.data
		send.data = struct.pack("<hh", size, send.flag) .. send.data	
	end
	
	local sindex, err = self._socket:send(send.data, send.index)
	if sindex == nil then
		self._data.error = NetError.DATA_SEND
		return false
	end
	
	return true, sindex
end

--[[
	读取数据
	[RETURN]  
		{
			result		结果
				nil		未有完整数据
				false	发生错误
				true	数据读取成功
			flag		标识
			data		数据
		}	
]]
function SocketIO:_readData()
	local size, flag, data
	if self._reader:getSize() >= 4 then
		size, flag = self._reader:peek("<hh")
		if self._reader:getSize() >= size then
			self._reader:skip(4)
			data = self._reader:readData(size - 4)

			if bit.band(flag, C_DFLAG_PTYPE) ~= C_PTYPE_SHAKE then
				-- 解密
				if self._data.encrypt then 
					if not self._data.deckey then
						self._data.error = NetError.NOT_DATA_DECKEY
						return { result = false }
					end

					if self._data.encrypt == C_EFLAG_XOR  then
						local decdata = utils.XOR_encrypt(data, self._data.deckey)

						local reader = BufferReader:create(decdata)
						self._data.deckey = reader:readBString()

						data = reader:readData(reader:getSize())
					elseif self._data.encrypt == C_EFLAG_AES  then
						local state, decdata = utils.AES_decrypt(self._data.deckey.key, self._data.deckey.iv, data)
						if not state then
							self._data.error = NetError.AES_DECRYPT
							return { result = false }
						end

						local reader = BufferReader:create(decdata)
						local key_ = reader:readBString()
						local iv_ = reader:readBString()
						self._data.deckey = {
							key = key_,
							iv = iv_,
						}

						data = reader:readData(reader:getSize())
					else
						self._data.error = NetError.UNK_DATA_DECRYPT
						return { result = false }
					end
				end

				-- 解压
				if bit.band(flag, C_DFLAG_COMPS) ~= 0 then
					local reader = BufferReader:create(data)

					local dsize = reader:readULong()
					local state,uncdata = utils.Zlib_uncompress(dsize, reader:readData(reader:getSize()))
					if not state then
						self._data.error = NetError.DATA_UNCOMPRESS
						return { result = false }
					end

					data = uncdata
				end
			end

			return { result = true, flag = flag, data = data }
		end
	end
end

--------------------------------- GENERATE KEY -------------------------------------
-- 生成指定长度的随机字符串
function SocketIO:genRandStr(len)
	local strs = {}
	for i=1, len do
		strs[#strs + 1] = string.char(math.random(0, 255))
	end
	return table.concat(strs)
end

-- 生成16字节长度的AES
function SocketIO:genRandAES()
	local keys = {}
	local ivs = {}
	for i = 1, 16 do
		keys[#keys + 1] = string.char(math.random(0, 255))
		ivs[#ivs + 1] = string.char(math.random(0, 255))
	end
	return table.concat(keys), table.concat(ivs)
end

------------------------------------ SHAKE -----------------------------------------
--[[
	和客户端握手
	iswrite		当前为写状态
]]
function SocketIO:onShakeClient(iswrite)
	if iswrite then
		if self._step == 1 then		-- 第一阶段，发送服务端配置
			if self:writeServerConfig() then
				self:enableWrite(false)
				self._step = 2
				self:enableRead(true)
				self._operates.addTimer(self._socket, C_SHAKE_TIMEOUT, self._shakeTimeout, "shake")
			else
				self._operates.removeSocket(self._socket, self._data.error)
			end
		elseif self._step == 3 then
			if self:writeServerShake() then
				self:enableWrite(false)
				self._action = nil			-- 握手完成
				self:enableRead(true)
				self:openHeartCheck()
				self._operates.doCallback(self:getListenIO():getSocket(), 
					"NEW_CONNECT", self:getNetID(), self._socket:getsockname())
				logMgr:info(C_LOGTAG, "client shake : \n" .. string.dump(self._data,"config"))
			else
				self._operates.removeSocket(self._socket, self._data.error)
			end
		end
	else	-- read
		if self._step == 2 then
			local result = self:readClientShake()
			if result ~= nil then
				self._operates.removeTimer(self._socket, "shake")
				if result then
					self:enableRead(false)
					self._step = 3
					self:enableWrite(true)
				else
					self._operates.removeSocket(self._socket, self._data.error)
				end
			end
		end
	end
end

--[[
	和服务器握手
	iswrite		当前为写状态
]]
function SocketIO:onShakeServer(iswrite)
	if iswrite then
		if self._step == 2 then
			if self:writeClientShake() then
				self:enableWrite(false)
				self._step = 3
				self:enableRead(true)
				self._operates.addTimer(self._socket, C_SHAKE_TIMEOUT, self._shakeTimeout, "shake")
			else
				self._operates.doCallback(self._socket, "CONNECTFAIL")
				self._operates.removeSocket(self._socket, self._data.error)
			end
		end
	else	-- read
		if self._step == 1 then
			local result = self:readServerConfig()
			if result ~= nil then
				self._operates.removeTimer(self._socket, "shake")
				if result then
					self:enableRead(false)
					self._step = 2
					self:enableWrite(true)
				else	-- 握手错误
					self._operates.doCallback(self._socket, "CONNECTFAIL")
					self._operates.removeSocket(self._socket, self._data.error)
				end
			end
		elseif self._step == 3 then
			local result = self:readServerShake()
			if result ~= nil then
				self._operates.removeTimer(self._socket, "shake")
				if result then
					self._action = nil			-- 握手完成
					self:openHeartWrite()
					self._operates.doCallback(self._socket, "CONNECTED", self:getNetID())
					logMgr:info(C_LOGTAG, "server shake : \n" .. string.dump(self._data,"config"))
				else	-- 握手错误
					self._operates.doCallback(self._socket, "CONNECTFAIL")
					self._operates.removeSocket(self._socket, self._data.error)
				end
			end
		end
	end
end

-- 写服务器配置
function SocketIO:writeServerConfig()
	local flag = C_PTYPE_SHAKE

	local serconf = self._config.server or {}

	local serflag = 0
	if serconf.encrypt then
		serflag = serflag + C_SFLAG_ENCRYPT
	end

	local writer = BufferWriter:create()
	writer:writeUShort(C_PROT_VERS)			-- 协议版本
	writer:writeUShort(serflag)				-- 服务端标识

	if bit.band(serflag,C_SFLAG_ENCRYPT) ~= 0 then
		local encflag = 0
		if table.indexof(serconf.encrypt, "xor") then
			encflag = bit.bor(encflag, C_EFLAG_XOR)
		end
		if table.indexof(serconf.encrypt, "aes") then
			encflag = bit.bor(encflag, C_EFLAG_AES)
		end
		if 0 == encflag then
			encflag = C_EFLAG_XOR		-- 默认
		end
		writer:writeUByte(encflag)		-- 加密方式
	end

	return self:_writeData({ flag = flag, data = writer:getData() })
end

-- 读服务器配置
function SocketIO:readServerConfig()
	local recv = self:_readData()
	if recv then
		if not recv.result then return false end

		if bit.band(recv.flag, C_DFLAG_PTYPE) ~= C_PTYPE_SHAKE then
			self._data.error = NetError.SHAKE_PACK_FLAG
			return false
		end

		local reader = BufferReader:create(recv.data)

		if reader:readUShort() ~= C_PROT_VERS then
			self._data.error = NetError.PROTOCOL_VERSION
			return false
		end

		local cliconf = self._config.client or {}	-- 客户端配置

		local serflag = reader:readUShort()			-- 服务器标识
		if bit.band(serflag, C_SFLAG_ENCRYPT) ~= 0 then
			local encflag = reader:readUByte()
			if cliconf.encrypt then
				for i = 1, #cliconf.encrypt do
					local encname = cliconf.encrypt[i]
					if encname == "xor" and bit.band(encflag, C_EFLAG_XOR) ~= 0 then
						self._data.encrypt = C_EFLAG_XOR
						break
					elseif encname == "aes" then
						self._data.encrypt = C_EFLAG_AES
						break
					end
				end
			end
			if not self._data.encrypt and bit.band(encflag, C_EFLAG_XOR) ~= 0 then
				self._data.encrypt = C_EFLAG_XOR
			end
			if not self._data.encrypt then
				self._data.error = NetError.PROTOCOL_VERSION
				return false
			end
		end
		
		return true
	end
end

-- 写入客户端握手
function SocketIO:writeClientShake()
	local flag = C_PTYPE_SHAKE

	local cliconf = self._config.client or {}
	local key,iv = self:genRandAES()			-- 生成AES
	self._data.shakeAES = {
		key = key,
		iv = iv,
	}

	local writer = BufferWriter:create()
	local writer_ = BufferWriter:create()	

	-- 写入加密密钥
	writer_:writeBString(key)
	writer_:writeBString(iv)
	local rsakey = cliconf.rsakey or C_ENCRYPT_RSAKEY	-- RSA密钥
	local state, encdata 
	if rsakey.public then
		state, encdata = utils.RSA_publicEncrypt(writer_:getData(), rsakey.file)
	else
		state, encdata = utils.RSA_privateEncrypt(writer_:getData(), rsakey.file)
	end
	if not state then
		self._data.error = NetError.RSA_ENCRYPT
		return false
	end
	writer:writeSString(encdata)

	-- 写入数据
	writer_:clear()
	local hflag = 0
	if self._data.encrypt then
		hflag = hflag + C_HFLAG_ENCRYPT
	end
	writer_:writeUShort(hflag)
	if bit.band(hflag, C_HFLAG_ENCRYPT) ~= 0 then
		writer_:writeUShort(self._data.encrypt)
		if self._data.encrypt == C_EFLAG_XOR then  
			local xorkey = self._config.xorkey or C_XOR_KEY
			self._data.deckey = self:genRandStr(math.random(xorkey.minlen, xorkey.maxlen))
			writer_:writeBString(self._data.deckey)
		elseif self._data.encrypt == C_EFLAG_AES then
			local key_, iv_ = self:genRandAES()
			self._data.deckey = {
				key = key_,
				iv = iv_,
			}
			writer_:writeBString(key_)
			writer_:writeBString(iv_)
		end
	end
	state, encdata = utils.AES_encrypt(key, iv, writer_:getData())
	if not state then
		self._data.error = NetError.AES_ENCRYPT
		return false
	end
	writer:writeSString(encdata)

	return self:_writeData({ flag = flag, data = writer:getData() })
end

-- 读取客户端握手
function SocketIO:readClientShake()
	local recv = self:_readData()
	if recv then
		if not recv.result then return false end

		if bit.band(recv.flag, C_DFLAG_PTYPE) ~= C_PTYPE_SHAKE then
			self._data.error = NetError.SHAKE_PACK_FLAG
			return false
		end

		local serconf = self._config.server or {}

		local reader = BufferReader:create(recv.data)

		-- 解密密钥数据
		local rsakey = serconf.rsakey or C_DECRYPT_RSAKEY	-- RSA密钥
		local state, decdata 
		if rsakey.public then
			state, decdata = utils.RSA_publicDecrypt(reader:readSString(), rsakey.file)
		else
			state, decdata = utils.RSA_privateDecrypt(reader:readSString(), rsakey.file)
		end
		if not state then
			self._data.error = NetError.RSA_DECRYPT
			return false
		end
		local kreader = BufferReader:create(decdata)
		local key = kreader:readBString()
		local iv = kreader:readBString()
		self._data.shakeAES = {
			key = key,
			iv = iv,
		}

		-- 解密握手数据
		state, decdata = utils.AES_decrypt(key, iv, reader:readSString())
		if not state then
			self._data.error = NetError.AES_DECRYPT
			return false
		end
		local sreader = BufferReader:create(decdata)
		local hflag = sreader:readUShort()	
		if bit.band(hflag, C_HFLAG_ENCRYPT) ~= 0 then
			self._data.encrypt = sreader:readUShort()	
			if self._data.encrypt == C_EFLAG_XOR then
				self._data.enckey = sreader:readBString()
			elseif self._data.encrypt == C_EFLAG_AES then
				local key_ = sreader:readBString()
				local iv_ = sreader:readBString()
				self._data.enckey = {
					key = key_,
					iv = iv_,
				}
			end
		end
		
		return true
	end
end

-- 写入服务端握手
function SocketIO:writeServerShake()
	local flag = C_PTYPE_SHAKE

	local serconf = self._config.server or {}

	local hflag = 0
	if self._data.encrypt then
		hflag = hflag + C_HFLAG_ENCRYPT
	end
	self._data.heart = {
		time = serconf.hearttime or C_HEART_TIMEOUT,
		id = math.random(10000,60000)
	}

	local writer = BufferWriter:create()
	writer:writeUShort(hflag)
	writer:writeUShort(self._data.heart.time)
	writer:writeUShort(self._data.heart.id)
	if bit.band(hflag, C_HFLAG_ENCRYPT) ~= 0 then
		writer:writeUShort(self._data.encrypt)
		if self._data.encrypt == C_EFLAG_XOR then  
			local xorkey = self._config.xorkey or C_XOR_KEY
			self._data.deckey = self:genRandStr(math.random(xorkey.minlen, xorkey.maxlen))
			writer:writeBString(self._data.deckey)
		elseif self._data.encrypt == C_EFLAG_AES then
			local key_, iv_ = self:genRandAES()
			self._data.deckey = {
				key = key_,
				iv = iv_,
			}
			writer:writeBString(key_)
			writer:writeBString(iv_)
		end
	end
	local state, encdata = utils.AES_encrypt(self._data.shakeAES.key, self._data.shakeAES.iv, writer:getData())
	if not state then
		self._data.error = NetError.AES_ENCRYPT
		return false
	end
	self._data.shakeAES = nil

	return self:_writeData({ flag = flag, data = encdata })
end

-- 读取服务端握手
function SocketIO:readServerShake()
	local recv = self:_readData()
	if recv then
		if not recv.result then return false end

		if bit.band(recv.flag, C_DFLAG_PTYPE) ~= C_PTYPE_SHAKE then
			self._data.error = NetError.SHAKE_PACK_FLAG
			return false
		end

		local cliconf = self._config.client or {}

		local state, decdata = utils.AES_decrypt(self._data.shakeAES.key, self._data.shakeAES.iv, recv.data)
		if not state then
			self._data.error = NetError.AES_DECRYPT
			return false
		end

		local reader = BufferReader:create(decdata)
		local hflag = reader:readUShort()
		self._data.heart = {
			time = reader:readUShort() / C_HEART_CSPLIT,
			id = reader:readUShort(),
		}
		if (bit.band(hflag, C_HFLAG_ENCRYPT) ~= 0) ~= (self._data.encrypt ~= nil) then
			self._data.error = NetError.SHAKE_ENCRYPT_FLAG
			return false
		end
		if self._data.encrypt then
			if self._data.encrypt ~= reader:readUShort() then
				self._data.error = NetError.SHAKE_ENCRYPT_METHOD
				return false
			end
			if self._data.encrypt == C_EFLAG_XOR then
				self._data.enckey = reader:readBString()
			elseif self._data.encrypt == C_EFLAG_AES then
				local key_ = reader:readBString()
				local iv_ = reader:readBString()
				self._data.enckey = {
					key = key_,
					iv = iv_,
				}
			end
		end
		self._data.shakeAES = nil

		return true
	end
end

-----------------------------------------------------------------------------------

return SocketIO
