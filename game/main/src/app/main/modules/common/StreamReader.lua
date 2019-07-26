--[[
    流缓冲读取
]]
local THIS_MODULE = ...

local StreamReader = class("StreamReader", import(".BufferReader"))

-- 清空缓冲区
function StreamReader:clear()
    self._buffer = ""
    self._index = 1
end

-- 追加缓冲
function StreamReader:append(buffer)
    self._buffer = self._buffer .. buffer
end

-- 重新调整缓冲区
function StreamReader:resize()
	if self._index > 1 then
		self._buffer = self._buffer:sub(self._index)
		self._index = 1
	end
end

return StreamReader
