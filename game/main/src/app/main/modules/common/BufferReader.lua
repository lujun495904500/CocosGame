--[[
    缓冲读取
]]
local THIS_MODULE = ...

local struct = cc.safe_require("struct")
local BufferReader = class("BufferReader")

--[[
	构造函数
	buffer		缓冲字符串
	start		开始读取位置
]]
function BufferReader:ctor(buffer, start)
    self._buffer = buffer or ""
    self._index = start or 1
end

--[[ 
	跳过长度字节
	count	长度
]]
function BufferReader:skip(count)
     self._index =  self._index + count
end

--[[
	缓冲区对齐
	size	对齐字节数
]]
function BufferReader:alignment(size)
    local rem = math.mod(self._index - 1, size)
    if rem ~= 0 then
        self:skip(size - rem)
    end
end

--[[
	读取指定格式的数据
	fmt		格式字符串，struct格式化字符串
]]
function BufferReader:read(fmt)
    local values = { struct.unpack(fmt, self._buffer, self._index) }
    self._index = values[#values]
    return unpack(values)
end

--[[
	窥视指定格式的数据
	fmt		格式字符串，struct格式化字符串
]]
function BufferReader:peek(fmt)
    return struct.unpack(fmt, self._buffer, self._index)
end

-- 读取 Byte
function BufferReader:readByte()
    return self:read("<b")
end

-- 读取 unsigned Byte
function BufferReader:readUByte()
    return self:read("<B")
end

-- 窥视 Byte
function BufferReader:peekByte()
    return self:peek("<b")
end

-- 读取 Short
function BufferReader:readShort()
    return self:read("<h")
end

-- 读取 unsigned Short
function BufferReader:readUShort()
    return self:read("<H")
end

-- 窥视 Short
function BufferReader:peekShort()
    return self:peek("<h")
end

-- 读取 Long
function BufferReader:readLong()
    return self:read("<l")
end

-- 读取 unsigned Long
function BufferReader:readULong()
    return self:read("<L")
end

-- 窥视 Long
function BufferReader:peekLong()
    return self:peek("<l")
end

-- 读取 Integer
function BufferReader:readInteger(n)
    return self:read("<i" .. tostring(n or 4))
end

-- 读取 unsigned Integer
function BufferReader:readUInteger(n)
    return self:read("<I" .. tostring(n or 4))
end

-- 窥视 Integer
function BufferReader:peekInteger(n)
    return self:peek("<i" .. tostring(n or 4))
end

-- 读取 以0结束的字符串
function BufferReader:readString()
    return self:read("<s")
end

-- 窥视 以0结束的字符串
function BufferReader:peekString()
    return self:peek("<s")
end

-- 读取指定长度的字符串, 双字节的长度
function BufferReader:readSString()
    local len = self:readUShort()
    return self:readStringByCount(len)
end

-- 读取指定长度的字符串，单字节的长度
function BufferReader:readBString()
    local len = self:readUByte()
    return self:readStringByCount(len)
end

-- 读取 指定数量的字符串
function BufferReader:readStringByCount(count)
    return count > 0 and self:read("<c" .. tostring(count)) or ""
end

-- 窥视 指定数量的字符串
function BufferReader:peekStringByCount(count)
    return count > 0 and self:peek("<c" .. tostring(count)) or ""
end

-- 读取 Float
function BufferReader:readFloat()
    return self:read("<f")
end

-- 窥视 Float
function BufferReader:peekFloat()
    return self:peek("<f")
end

-- 读取 Double
function BufferReader:readDouble()
    return self:read("<d")
end

-- 窥视 Double
function BufferReader:peekDouble()
    return self:peek("<d")
end

-- 获得缓冲区索引
function BufferReader:getIndex()
	return self._index
end

-- 获得缓冲区大小
function BufferReader:getSize()
    return #self._buffer - self._index + 1
end

-- 读取 数据
function BufferReader:readData(count)
	if count > 0 then
		local data = self._buffer:sub(self._index, self._index + count - 1)
    	self._index =  self._index + count
		return data
	else
		return ""
	end
end

-- 窥视 数据
function BufferReader:peekData(count)
	if count > 0 then
		return self._buffer:sub( self._index, self._index + count)
	else
		return ""
	end
end

return BufferReader

