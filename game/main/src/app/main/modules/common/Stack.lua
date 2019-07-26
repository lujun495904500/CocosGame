local Stack = class("Stack")

function Stack:ctor()
	self._table = {}
end

function Stack:push(element)
	self._table[#self._table + 1] = element
end

function Stack:pop()
	if #self._table == 0 then
		print("Error: Stack is empty!")
		return
	end
	self._table[#self._table] = nil
end

function Stack:top()
	if #self._table == 0 then
		print("Error: Stack is empty!")
		return
	end
	return self._table[#self._table]
end

function Stack:isEmpty()
	return #self._table == 0
end

function Stack:size()
	return #self._table
end

function Stack:clear()
	self._table = {}
end

function Stack:printElement()
	local size = self:size()

	if self:isEmpty() then
		print("Error: Stack is empty!")
		return
	end

	local str = "{"..self._table[size]
	size = size - 1
	while size > 0 do
		str = str..", "..self._table[size]
		size = size - 1
	end
	str = str.."}"
	print(str)
end

return Stack
