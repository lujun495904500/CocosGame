local Queue = class("Queue")

function Queue:ctor(capacity)
	self.capacity = capacity
	self.queue = {}
	self.size_ = 0
	self.head = -1
	self.rear = -1
end

function Queue:pushBack(element)
	if self.size_ == 0 then
		self.head = 0
		self.rear = 1
		self.size_ = 1
		self.queue[self.rear] = element
	else
		local temp = (self.rear + 1) % self.capacity
		if temp == self.head then
			print("Error: capacity is full.")
			return 
		else
			self.rear = temp
		end

		self.queue[self.rear] = element
		self.size_ = self.size_ + 1
	end

end

function Queue:popFront()
	if self.size_ > 0 then
		self.size_ = self.size_ - 1
		self.head = (self.head + 1) % self.capacity
		return self.queue[self.head]
	end
end

function Queue:peekFront()
	if self.size_ > 0 then
		return self.queue[(self.head + 1) % self.capacity] 
	end
end

function Queue:clear()
	self.queue = nil
	self.queue = {}
	self.size_ = 0
	self.head = -1
	self.rear = -1
end

function Queue:isEmpty()
	return self.size_ == 0
end

function Queue:size()
	return self.size_
end

function Queue:printElement()
	local h = self.head
	local r = self.rear
	local str = nil
	local first_flag = true
	while h ~= r do
		if first_flag == true then
			str = "{"..self.queue[h]
			h = (h + 1) % self.capacity
			first_flag = false
		else
			str = str..","..self.queue[h]
			h = (h + 1) % self.capacity
		end
	end
	str = str..","..self.queue[r].."}"
	print(str)
end

return Queue