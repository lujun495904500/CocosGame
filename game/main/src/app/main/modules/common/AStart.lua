--[[
	A* 寻路算法
]]
local AStart = class("AStart")

--[[
	构造函数
	spos		开始点
	epos		结束点
	stepsize	步尺寸
	testpass	通过测试
]]
function AStart:ctor(spos,epos,stepsize,testpass)
	self._spos = spos
	self._epos = epos
	self._stepsize = stepsize or cc.size(1,1)
	self._testpass = testpass or (function () return true end)
	self._directs = {
		{offest = cc.p(0,self._stepsize.height), GI = self._stepsize.height},
		{offest = cc.p(-self._stepsize.width,0), GI = self._stepsize.width},
		{offest = cc.p(0,-self._stepsize.height), GI = self._stepsize.height},
		{offest = cc.p(self._stepsize.width,0), GI = self._stepsize.width},
	}
end

-- 计算路径
function AStart:calculatePath()
	local openlist = {}
	local closedlist = {}
	local result = false

	table.insert(openlist,{
		pos = self._spos,
		G = 0,
	})
	while #openlist > 0 do
		local csquare,cindex = self:getSquareLF(openlist)
		table.insert(closedlist, csquare)
		table.remove(openlist, cindex)

		if cc.pEqual(csquare.pos,self._epos) then
			result = true
			break
		end

		local asquares = self:getAdjacentSquares(csquare)
		for _,square in ipairs(asquares) do
			if not self:findSquare(closedlist,square.pos) then
				local _square = self:findSquare(openlist,square.pos)
				if _square then
					if _square.F > square.F then
						_square.F = square.F
						_square.last = square.last
					end
				else -- not
					table.insert(openlist, square)
				end
			end
		end
	end
	if result then
		local paths = {}
		local square = self:findSquare(closedlist,self._epos)
		while square do
			table.insert(paths,1, square.pos)
			square = square.last
		end
		--dump(paths)
		return paths
	end
end

-- 查找指定方格
function AStart:findSquare(list,pos)
	for _,_square in ipairs(list) do
		if cc.pEqual(_square.pos,pos) then
			return _square
		end
	end
end

-- 获得F值最小的方格
function AStart:getSquareLF(list)
	local square = nil
	local sindex = nil
	for i = #list,1,-1 do
		if not square or list[i].F < square.F then
			square = list[i]
			sindex = i
		end
	end
	return square,sindex
end

-- 获得可通过相邻的方格
function AStart:getAdjacentSquares(square)
	local squares = {}
	for _,direct in ipairs(self._directs) do
		local newpos = cc.pAdd(square.pos,direct.offest)
		if self._testpass(newpos) then
			local nsquare = {
				last = square,
				pos = newpos,
				G = square.G + direct.GI,
				H = self:getPointsH(newpos,self._epos)
			}
			nsquare.F = nsquare.G + nsquare.H
			table.insert(squares, nsquare)
		end
	end
	return squares
end

-- 获得点的H值
function AStart:getPointsH(pos1,pos2)
	return math.abs(pos1.x-pos2.x) + math.abs(pos1.y-pos2.y)
end

return AStart
