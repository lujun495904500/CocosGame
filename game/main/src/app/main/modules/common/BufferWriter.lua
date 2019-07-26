--[[
    缓冲写入
]]
local THIS_MODULE = ...

local BufferWriter = class("BufferWriter")

-- 构造函数
function BufferWriter:ctor()
    self._buffer = ""
end

--[[
	填充指定数量的字符
	count		数量
	char		字符，默认为0
]]
function BufferWriter:fill(count, char)
    self._buffer = self._buffer .. string.rep(char or "\0", count)
end

--[[
	缓冲区对齐
	size		对齐字节数
	char		填充字符，默认为0
]]
function BufferWriter:alignment(size, char)
    local rem = math.mod(#self._buffer, size)
    if rem ~= 0 then
        self:fill(size - rem, char or "\0")
    end
end

--[[
	写入指定数据到缓冲区
	fmt		数据格式，struct格式化字符串
	...		数据值
]]
function BufferWriter:write(fmt, ...)
    self._buffer = self._buffer .. struct.pack(fmt, ...)
end

-- 写入 Byte
function BufferWriter:writeByte(byte)
    self:write("<b",byte)
end

-- 写入 unsigned Byte
function BufferWriter:writeUByte(byte)
    self:write("<B",byte)
end

-- 写入 Short
function BufferWriter:writeShort(short)
    self:write("<h",short)
end

-- 写入 unsigned Short
function BufferWriter:writeUShort(short)
    self:write("<H",short)
end

-- 写入 Long
function BufferWriter:writeLong(long)
    self:write("<l",long)
end

-- 写入 unsigned Long
function BufferWriter:writeULong(long)
    self:write("<L",long)
end

-- 写入 Integer
function BufferWriter:writeInteger(integer,n)
    self:write("<i" .. tostring(n or 4),integer)
end

-- 写入 unsigned Integer
function BufferWriter:writeUInteger(integer,n)
    self:write("<I" .. tostring(n or 4),integer)
end

-- 写入 以0结束的字符串
function BufferWriter:writeString(str)
    self:write("<s", str)
end

-- 写入指定长度的字符串
function BufferWriter:writeSString(str)
    self:writeUShort(#str)
    self:writeStringByCount(str)
end

-- 写入unsigned char长度的字符串
function BufferWriter:writeBString(str)
    self:writeUByte(#str)
    self:writeStringByCount(str)
end

-- 写入 指定数量的字符串
function BufferWriter:writeStringByCount(str, count)
    count = count or #str
    if count > 0 then
        self:write("<c" .. tostring(count), str)
    end
end

-- 写入 Float
function BufferWriter:writeFloat(float)
    self:write("<f",float)
end

-- 写入 Double
function BufferWriter:writeDouble(double)
    self:write("<d",double)
end

-- 写入 数据
function BufferWriter:writeData(data)
	self._buffer = self._buffer .. data
end

-- 获得缓冲数据
function BufferWriter:getData()
    return self._buffer
end

-- 清空缓冲区
function BufferWriter:clear()
	self._buffer = ""
end

return BufferWriter
