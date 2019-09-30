--[[
	存档管理器
--]]
local THIS_MODULE = ...

-- 事件点块位数
local C_EPOINT_BLOCK = 32

-- 存档插槽
local C_ARCHIVE_SLOT = "slot_"

-- 存档信息
local C_ARCHIVE_INFO = "info.json"

-- 存档数据
local C_ARCHIVE_DATA = "data.json"

-- 插槽前缀长度
local C_SLOT_PRELEN = #C_ARCHIVE_SLOT

local ArchiveManager = class("ArchiveManager")

-- 获得单例对象
local instance = nil
function ArchiveManager:getInstance()
	if instance == nil then
		instance = ArchiveManager:create()
	end
	return instance
end

-- 构造函数
function ArchiveManager:ctor()
	self._listeners = {}	 -- 监听器
	self._data = nil		 -- 存档数据
	self._info = nil		 -- 存档信息
	self._slot = nil		 -- 存档插槽

	self._savepath = fileUtils:getWritablePath() .. DIRECTORY.ARCHIVE .. "/"
	fileUtils:createDirectory(self._savepath)
end

-- 获得所有存档
function ArchiveManager:getArchives()
	local archives = {}
	for _,file in ipairs(fileUtils:listFiles(self._savepath)) do
		if fileUtils:isDirectoryExist(file) and file:sub(-2) ~= "./" and file:sub(-3) ~= "../" then
			local slotdir = io.pathinfo(file:gsub("[\\/]+$","")).filename
			if slotdir:sub(1,C_SLOT_PRELEN) == C_ARCHIVE_SLOT then
				local slot = slotdir:sub(C_SLOT_PRELEN + 1)
				local info = indexMgr:readJson(file .. C_ARCHIVE_INFO)
				if info then
					archives[#archives + 1] = {
						slot = slot,
						name = info.name,
						time = info.time,
						version = info.version,
					}
				end
			end
		end
	end
	table.sort(archives, function (a,b)
		return a.time > b.time
	end)
	return archives
end

-- 加载指定插槽存档数据
function ArchiveManager:loadArchive(slot)
	self._slot = slot or self._slot
	if self._slot then
		local slotdir = self._savepath .. C_ARCHIVE_SLOT .. tostring(self._slot) .. "/"
		if fileUtils:isDirectoryExist(slotdir) then
			self._info = indexMgr:readJson(slotdir .. C_ARCHIVE_INFO)
			self._data = indexMgr:readJson(slotdir .. C_ARCHIVE_DATA)
			if self._info and self._data then
				self:notifyListeners("LOAD")
				return true
			end
		end
	end
	return false
end

-- 保存存档数据到指定插槽
function ArchiveManager:saveArchive(slot)
	self._slot = slot or self._slot
	if self._slot and self._info and self._data then
		self:notifyListeners("SAVE")
		self._info.time = os.time()
		local slotdir = self._savepath .. C_ARCHIVE_SLOT .. tostring(self._slot) .. "/"
		fileUtils:createDirectory(slotdir)
		indexMgr:writeJson(self._info,slotdir .. C_ARCHIVE_INFO)
		indexMgr:writeJson(self._data,slotdir .. C_ARCHIVE_DATA)
		return true
	end
	return false
end

-- 删除指定插槽的存档
function ArchiveManager:deleteArchive(slot)
	if slot then
		local slotdir = self._savepath .. C_ARCHIVE_SLOT .. tostring(slot) .. "/"
		if fileUtils:isDirectoryExist(slotdir) then
			return fileUtils:removeDirectory(slotdir)
		end
	end
	return true
end

-- 在指定插槽创建新存档
--[[
	name:	   存档名称
	slot:	   插槽位置
]]
function ArchiveManager:newArchive(name,slot)
	self._slot = slot or self._slot
	self._info = {
		version = "1.0.0",
		name = name or "New Archive",
	}
	self._data = {
		eventps = {		 -- 事件点
			default = {}	-- 默认
		}
	}
	self:notifyListeners("NEW")
end

-- 添加监听器
--[[
	监听器事件:(NEW,LOAD,SAVE)
]]
function ArchiveManager:addListener(listener)
	self._listeners[listener] = listener
end

-- 通知所有监听器
function ArchiveManager:notifyListeners(event)
	for _,lisner in pairs(self._listeners) do 
		lisner(event,self._data,self._info)
	end
end

-- 获得存档数据
function ArchiveManager:getArchiveData()
	return self._data
end

-- 获得存档信息
function ArchiveManager:getArchiveInfo()
	return self._info
end

-- 检查事件点状态
function ArchiveManager:checkEventPoint(point,segment)
	point = point - 1
	segment = segment or "default"
	local valofst = math.floor(point / C_EPOINT_BLOCK) + 1
	local bitofst = point % C_EPOINT_BLOCK

	local segeps = self._data.eventps[segment]
	if not segeps then return false end
	local epsval = segeps[valofst]
	if not epsval then return false end
	return (bit.band(epsval,bit.lshift(1,bitofst)) ~= 0)
end

-- 设置事件点状态
function ArchiveManager:setEventPoint(state,point,segment)
	point = point - 1
	segment = segment or "default"
	local valofst = math.floor(point / C_EPOINT_BLOCK) + 1
	local bitofst = point % C_EPOINT_BLOCK

	local segeps = self._data.eventps[segment]
	if not segeps then
		segeps = {}
		self._data.eventps[segment] = segeps
	end
	local epsval = segeps[valofst] or 0
	if state then
		epsval = bit.bor(epsval,bit.lshift(1,bitofst))
	else
		epsval = bit.band(epsval,bit.bnot(bit.lshift(1,bitofst)))
	end
	segeps[valofst] = epsval
end

return ArchiveManager
