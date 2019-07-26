--[[
	音乐音效管理器
--]]
local THIS_MODULE = ...

-- 音频索引路径
local C_AUDIO_IPATH = "res/files/audios"

local AudioManager = class("AudioManager", require("app.main.modules.index.IndexListener"))

-- 获得单例对象
local instance = nil
function AudioManager:getInstance()
	if instance == nil then
		instance = AudioManager:create()
		indexMgr:addListener(instance)
	end
	return instance
end

-- 构造函数
function AudioManager:ctor()
	self._audios = {}

	self._bgmvolume = 0.5	-- bgm音量
	self._sevolume = 0.5	 -- se音量

	ccexp.AudioEngine:lazyInit()
end

-------------------------IndexListener-------------------------
-- 清空索引
function AudioManager:onIndexesRemoved()
	self:releaseAudios(true)
end
-------------------------IndexListener-------------------------

-- 释放音频
function AudioManager:releaseAudios(preload)
	for aname,audio in pairs(self._audios) do 
		if not audio.preload or preload then
			ccexp.AudioEngine:uncache(audio.file)
			self._audios[aname] = nil
		end
	end
end

-- 获得播放音频的长度
function AudioManager:getDuration(audioID)
	return ccexp.AudioEngine:getDuration(audioID)
end

-- 播放BGM
function AudioManager:playBGM(bname,loop)
	local bgm = self:getAudio(bname)
	if bgm then
		self:stopBGM()
		self._curbgm = bname
		self._bgmID = ccexp.AudioEngine:play2d(bgm.file,loop ~= false,self._bgmvolume)
		return self._bgmID
	end
end

-- 停止BGM
function AudioManager:stopBGM()
	if self._bgmID then 
		ccexp.AudioEngine:stop(self._bgmID) 
		self._bgmID = nil
		self._curbgm = nil
	end
end

-- 获得当前BGM
function AudioManager:getCurrentBGM()
	return self._curbgm
end

-- 播放SE
function AudioManager:playSE(bname,volume)
	local se = self:getAudio(bname)
	if se then
		volume = volume or 1.0
		return ccexp.AudioEngine:play2d(se.file,false,volume*self._bgmvolume)
	end
end

-- 监听音乐播放完成
function AudioManager:listenFinish(id,callback)
	if ccexp.AudioEngine:getState(id) == ccexp.AudioState.ERROR then
		callback()
	else
		ccexp.AudioEngine:setFinishCallback(id,callback)
	end
end

-- 获得音频
function AudioManager:getAudio(aname)
	if self._audios[aname] ~= nil then
		return self._audios[aname]
	else
		local afile = indexMgr:getIndex(C_AUDIO_IPATH .. "/" .. aname)
		if afile then
			ccexp.AudioEngine:preload(afile)
			local audio = {file=afile}
			self._audios[aname] = audio
			return audio
		end
	end
end

-- 预加载音频
function AudioManager:preloadAudio(aname)
	self:getAudio(aname).preload = true
end

-- 获取所有音频
function AudioManager:getAllAudios()
	return table.keys(indexMgr:getIndex(C_AUDIO_IPATH))
end

-- 加载所有音频
function AudioManager:loadAllAudios()
	for _,aname in ipairs(self:getAllAudios()) do 
		self:getAudio(aname)
	end
end

-- 输出管理器当前状态
function AudioManager:dump()
	dump(self._audios)
end

return AudioManager
