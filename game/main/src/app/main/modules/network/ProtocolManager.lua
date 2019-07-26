--[[
	协议管理器
]]
local THIS_MODULE = ...
local C_LOGTAG = "ProtocolManager"

local effil = cc.safe_require("effil")
local utils = cc.safe_require("utils")
local ProtocolManager = class("ProtocolManager")

-- 获得单例对象
local instance = nil
function ProtocolManager:getInstance()
	if instance == nil then
		instance = ProtocolManager:create()
	end
	return instance
end

-- 构造函数
function ProtocolManager:ctor()
	self._nameprots		= {}	-- 协议名表	
	self._cmdprots		= {}	-- 协议命令表
	self._typepackers	= {}	-- 类型打包表

	self:setupTypePackers()
end

--[[
	安装类型打包器
]]
function ProtocolManager:setupTypePackers()
	self._typepackers["int8"] = {
		pack = function (writer, data)
			writer:writeByte(data or 0)
		end,
		unpack = function (reader)
			return reader:readByte()
		end,
	}

	self._typepackers["uint8"] = {
		pack = function (writer, data)
			writer:writeUByte(data or 0)
		end,
		unpack = function (reader)
			return reader:readUByte()
		end,
	}

	self._typepackers["int16"] = {
		pack = function (writer, data)
			writer:writeShort(data or 0)
		end,
		unpack = function (reader)
			return reader:readShort()
		end,
	}

	self._typepackers["uint16"] = {
		pack = function (writer, data)
			writer:writeUShort(data or 0)
		end,
		unpack = function (reader)
			return reader:readUShort()
		end,
	}

	self._typepackers["int32"] = {
		pack = function (writer, data)
			writer:writeLong(data or 0)
		end,
		unpack = function (reader)
			return reader:readULong()
		end,
	}

	self._typepackers["uint32"] = {
		pack = function (writer, data)
			writer:writeULong(data or 0)
		end,
		unpack = function (reader)
			return reader:readULong()
		end,
	}

	self._typepackers["float"] = {
		pack = function (writer, data)
			writer:writeFloat(data or 0) 
		end,
		unpack = function (reader)
			return reader:readFloat()
		end,
	}

	self._typepackers["double"] = {
		pack = function (writer, data)
			writer:writeDouble(data or 0) 
		end,
		unpack = function (reader)
			return reader:readDouble()
		end,
	}

	self._typepackers["string"] = {
		pack = function (writer, data)
			writer:writeSString(data or "") 
		end,
		unpack = function (reader)
			return reader:readSString()
		end,
	}

	self._typepackers["[]"] = {
		pack = function (writer, data, dtype)
			local packfun = self:getPacker(dtype)
			data = data or {}
			writer:writeShort(#data)
			for i = 1,#data do
				packfun(writer, data[i])
			end
		end,
		unpack = function (reader, dtype)
			local unpackfun = self:getUnpacker(dtype)
			local data = effil.table()
			local size = reader:readShort()
			for i = 1, size do
				data[i] = unpackfun(reader)
			end
			return data
		end,
	}
end

--[[
	获得打包器
	dtype		类型
]]
function ProtocolManager:getPacker(dtype)
	local typetb = self._typepackers[dtype] or self._nameprots[dtype]
	return typetb and typetb.pack
end

--[[
	获得解包器
	dtype		类型
]]
function ProtocolManager:getUnpacker(dtype)
	local typetb = self._typepackers[dtype] or self._nameprots[dtype]
	return typetb and typetb.unpack
end

--[[
	打包数据
	writer  	缓冲写入器
	fmt			数据格式
	...			数据
]]
function ProtocolManager:packData(writer, fmt, ...)
	writer:write(fmt, ...)
end

--[[
	解包数据
	reader		缓冲读取器
	fmt			数据格式
]]
function ProtocolManager:unpackData(reader, fmt)
	return reader:read(fmt)
end

-- 通过协议名获得协议
function ProtocolManager:getProtocolByName(pname)
	return self._nameprots[pname]
end

-- 通过协议命令获得协议
function ProtocolManager:getProtocolByCMD(cmd)
	return self._cmdprots[cmd]
end

-- 清空包协议
function ProtocolManager:clearProtocols()
	self._nameprots	= {}
	self._cmdprots	= {}
end

-- 加载包协议
function ProtocolManager:loadProtocols(prots)
	if prots then
		for _,protlua in effil.ipairs(prots) do
			for _,protocol in pairs(require(protlua)) do
				assert(not self._nameprots[protocol.name], string.format("protocol name [%s] conflict!!!", protocol.name))
				self._nameprots[protocol.name] = protocol
				if protocol.cmd then
					assert(not self._cmdprots[protocol.cmd], string.format("protocol cmd [%d] conflict!!!", protocol.cmd))
					self._cmdprots[protocol.cmd] = protocol
				end
			end
		end
		--dump(self._nameprots)
		--dump(self._cmdprots)
	end
end

return ProtocolManager
