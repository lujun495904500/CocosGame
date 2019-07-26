--[[
	PLIST 可加载的
]]
local THIS_MODULE = ...

local PlistLoadable = class("PlistLoadable")

-- 加载plist资源
function PlistLoadable:loadPlist(source, frames, export)
	-- 加载plist帧缓冲
	local texture = display.loadImage(source.image)
	spriteFrameCache:addSpriteFrames(source.plist,texture)

	-- 绑定指定帧
	self._frames = {}
	for _,fname in ipairs(frames) do
		local frame = spriteFrameCache:getSpriteFrame(source.fpath .. fname)
		frame:retain()
		self._frames[fname] = frame
		if export then self[fname] = frame end
	end
end

-- 释放plist资源
function PlistLoadable:releasePlist()
	for _,frame in pairs(self._frames) do 
		frame:release()
	end
end

-- 获得指定帧
function PlistLoadable:getFrame(fname)
	return self._frames[fname]
end

return PlistLoadable
