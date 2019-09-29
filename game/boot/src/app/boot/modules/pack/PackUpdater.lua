--[[
	包 更新器
]]
local THIS_MODULE = ...
local C_LOGTAG = "PackUpdater"

local C_DOWNINFO = "down.info"	-- 下载信息
local C_DOWNING_MAX = 3			-- 最大下载数
local C_REDOWN_COUNT = 3		-- 重新下载次数

local cjson = cc.safe_require("cjson")
local utils = cc.safe_require("utils")
local PackUpdater = class("PackUpdater")

-- 获得单例对象
local instance = nil
function PackUpdater:getInstance()
	if instance == nil then
		instance = PackUpdater:create()
	end
	return instance
end

-- 构造函数
function PackUpdater:ctor()
	self._downpath = fileMgr:getWritablePath() .. "/" .. DIRECTORY.DOWNLOAD .. "/"
	self._downinfo = self._downpath .. "/" .. C_DOWNINFO
	self._temppath = fileMgr:getWritablePath() .. "/" .. DIRECTORY.TEMP .. "/"
	fileMgr:removeDirectory(self._temppath)
	fileMgr:createDirectory(self._temppath)
end

--[[
	下载配置
	verscode		版本
	config			配置
	onComplete		完成回调
		R	{true/false}	结果
		P	{float}			进度
]]
function PackUpdater:download(verscode,config,onComplete)
	if fileMgr:isFileExist(self._downinfo) then
		local downconf = cjson.decode(fileMgr:getDataFromFile(self._downinfo))
		if downconf.verscode ~= verscode or downconf.path ~= config.path then
			fileMgr:removeDirectory(self._downpath)
		end
	end
	fileMgr:createDirectory(self._downpath)
	if not fileMgr:isFileExist(self._downinfo) then
		fileMgr:writeStringToFile(cjson.encode({
			verscode = verscode,
			path = config.path,
		}),self._downinfo)
	end
	
	local function _onComplete(...)
		if onComplete then onComplete(...) end
	end

	-- 下载任务配置
	local downtasks = {}
	for i = 1, config.count do
		local downfile = string.format(config.format, i-1) 
		downtasks[i] = {
			remotef = gameConfig.remoteurl .. config.path .. "/" .. downfile,	-- 远程文件
			localf = self._downpath .. downfile,								-- 保存的本地文件
			progress = 0,														-- 进度
			redowncount = 0,													-- 重新下载次数
		}
	end
	local downindex = 1												-- 下载任务索引
	local taskprog = 1 / config.count								-- 每个任务进度
	local downingmax = gameConfig.downingmax or C_DOWNING_MAX		-- 最大正在下载数量
	local downingnum = 0											-- 当前正在下载数量
	local redowncount = gameConfig.redowncount or C_REDOWN_COUNT	-- 重新下载次数
	local downloader = cc.Downloader.new()							-- 下载器
	local updateProgress = nil										-- 进度更新
	local downloadNexts = nil										-- 下载剩下的文件

	updateProgress = function(testend)
		local prog = 0
		local complete = true
		local success = true
		for _,downtask in pairs(downtasks) do
			prog = prog + downtask.progress * taskprog
			if testend and downindex > #downtasks then
				if downtask.state == nil then
					complete = false
				elseif downtask.state == false then
					success = false
				end
			end
		end

		_onComplete("P", prog)

		if testend and downindex > #downtasks then
			if complete then
				if success then
					_onComplete("R", true)
				else -- failure
					_onComplete("R", false)
				end
			end
		end
	end

	downloadNexts = function (downfail)
		while downindex <= #downtasks do
			local downtask = downtasks[downindex]
			if downfail then
				downindex = downindex + 1
				downtask.progress = 0
				downtask.state = false
				updateProgress(true)
			else
				if fileMgr:isFileExist(downtask.localf) then
					downindex = downindex + 1
					downtask.progress = 1
					downtask.state = true
					updateProgress(true)
				else
					if downingnum >= downingmax then
						break		-- 到达最大下载数量
					end
					downloader:createDownloadFileTask(downtask.remotef, downtask.localf, tostring(downindex));
					downindex = downindex + 1
					downingnum = downingnum + 1
				end
			end
		end
	end

	-- 下载文件
	downloader:setOnFileTaskSuccess(function (task)
		local downtask = downtasks[tonumber(task.identifier)]
		downtask.progress = 1
		downtask.state = true
		updateProgress(true)
		downingnum = downingnum - 1
		downloadNexts()
	end)
    downloader:setOnTaskProgress(function (task, received, totalReceived, totalExpected)
		downtasks[tonumber(task.identifier)].progress = totalReceived / totalExpected
		updateProgress(false)
	end)
	downloader:setOnTaskError(function (task, errorCode, errorCodeInternal, errorStr)
		local downtask = downtasks[tonumber(task.identifier)]
		if downtask.redowncount < redowncount then
			downtask.redowncount = downtask.redowncount + 1
			logMgr:info(C_LOGTAG, "retry download %s : %d", downtask.remotef, downtask.redowncount)
			downtask.progress = 0
			updateProgress(false)
			downloader:createDownloadFileTask(downtask.remotef, downtask.localf, task.identifier);
		else
			logMgr:info(C_LOGTAG, "download %s failure : %s", downtask.remotef, errorStr)
			downtask.state = false
			downingnum = downingnum - 1
			updateProgress(true)
			downloadNexts(true)
		end
	end)
	downloadNexts()
end

-- 检查并返回指定包的更新
function PackUpdater:checkUpdate(packname,packpath)
	local rmpack = gameConfig.packs[packname]
	if rmpack then
		packpath = packpath or (PACKSPATH .. packname .. PACK.FORMAT)
		local lcvers = fileMgr:lookPackVersion(packpath) 
		if rmpack.verscode > lcvers then	-- 远程版本号 > 本地版本号
			local compsize = rmpack.complete.size
			local patchsize = 0
			local patchs = {}
			local rmvern = rmpack.versname
			local curvern = utils.get_version_name(lcvers)
			if rmpack.patchs then
				local function findPatch(vernbegin)
					for pname,pconf in pairs(rmpack.patchs) do
						local bgvern,edvern = unpack(string.split(pname,"_"))
						if vernbegin == bgvern then
							return edvern,pconf
						end
					end
				end
				while curvern ~= rmvern do
					local edvern,patch = findPatch(curvern)
					if not edvern then
						break
					end
					patchs[#patchs + 1] = patch
					patchsize = patchsize + patch.size
					curvern = edvern
				end
			end
			if rmvern == curvern and #patchs > 0 and patchsize < compsize then
				return {
					type = "P",					-- 补丁包更新配置
					lcvers = lcvers,
					rmvers = rmpack.verscode,
					size = patchsize,
					patchs = patchs,
					path = packpath,
					pack = packname,
				}
			else
				return {
					type = "C",					-- 整包更新配置
					lcvers = lcvers,
					rmvers = rmpack.verscode,
					size = compsize,
					complete = rmpack.complete,
					path = packpath,
					pack = packname,
				}
			end
		elseif lcvers > rmpack.verscode then	-- 本地版本比服务器更高
			logMgr:warn(C_LOGTAG, "[%s] pack local version(%s) > remote version(%s)", 
				packname, utils.get_version_name(lcvers), utils.get_version_name(rmpack.verscode))
		end
	end
end

--[[
	更新包
	configs					包配置数组，checkUpdate返回组成的数组
	onComplete
		R	{true/false}	结果
		P	{float}			进度
		C	{config}		当前配置
]]
function PackUpdater:updatePacks(configs,onComplete)
	
	local function _onComplete(...)
		if onComplete then onComplete(...) end
	end

	table.asyn_walk_sequence(function ()
		_onComplete("P",1)
		_onComplete("R",true)
	end,configs,function (updateNext,config,index)
		local update = handler(self,config.type == "C" and PackUpdater.completeUpdate or PackUpdater.patchUpdate)
		_onComplete("C",config)
		update(config,function (ctype,result)
			if ctype == "P" then
				_onComplete("P",(1/#configs) * (index - 1 + result))
			elseif ctype == "R" then
				if result then
					updateNext()
				else
					_onComplete("R", false, config)
				end
			end
		end)
	end)
end

--[[
	整包更新
	config	整包配置
	onComplete	完成回调
		R	{true/false}	结果
		P	{float}			进度
]]
function PackUpdater:completeUpdate(config,onComplete)
	logMgr:info(C_LOGTAG, "update pack [%s] by complete from %s to %s, size : %s" ,
		config.pack, utils.get_version_name(config.lcvers), utils.get_version_name(config.rmvers), 
		utils.format_store_size(config.size))

	local function _onComplete(...)
		if onComplete then onComplete(...) end
	end

	local function downEnd()
		local destpack = io.pathinfo(config.path).dirname .. "temp.pack"
		utils.mergeFile(self._downpath,destpack,config.complete.format,true)
		_onComplete("P", 0.9)

		if fileMgr:isFileExist(config.path) then
			fileMgr:removeFile(config.path)
		end
		fileMgr:renameFile(destpack,config.path)

		logMgr:info(C_LOGTAG, "[%s] update success", config.pack)

		_onComplete("P", 1)
		_onComplete("R",true)
	end

	self:download(config.rmvers,config.complete,function (ctype,result)
		if ctype == "P" then
			_onComplete("P", 0.8 * result)
		elseif ctype == "R" then
			if result then
				downEnd()
			else
				_onComplete("R",false)
			end
		end
	end)
end

--[[
	补丁更新
	config		补丁配置
	onComplete	完成回调
		R	{true/false}	结果
		P	{float}			进度
]]
function PackUpdater:patchUpdate(config,onComplete)
	logMgr:info(C_LOGTAG, "update pack [%s] by patchs from %s to %s, size : %s" ,
		config.pack, utils.get_version_name(config.lcvers), utils.get_version_name(config.rmvers), 
		utils.format_store_size(config.size))
	
	local function _onComplete(...)
		if onComplete then onComplete(...) end
	end

	local function downEnd()
		local destpack = io.pathinfo(config.path).dirname .. "pack.temp"
		local temppack = self._temppath .. "pack.temp"
		local function swappath()
			local tmp = destpack
			destpack = temppack
			temppack = tmp
		end
		if #config.patchs % 2 == 0 then
			swappath()
		end

		-- 打第一个补丁
		if not utils.patchH(destpack,config.path,self._temppath .. "1.patch") then
			_onComplete("R",false)
			error(string.format("%s patch 1 failure", config.pack))
		end
		_onComplete("P", 0.8 + 0.1 * (1/#config.patchs))
		
		-- 打剩余补丁
		for i = 2, #config.patchs do
			swappath()
			if not utils.patchH(destpack,temppack,self._temppath .. tostring(i) .. ".patch") then
				_onComplete("R",false)
				error(string.format("%s patch %d failure", config.pack, i))
			end
			_onComplete("P", 0.8 + 0.1 * (i/#config.patchs))
		end
		
		if fileMgr:isFileExist(config.path) then
			fileMgr:removeFile(config.path)
		end
		fileMgr:renameFile(destpack,config.path)

		logMgr:info(C_LOGTAG, "[%s] update success", config.pack)

		_onComplete("P", 1)
		_onComplete("R",true)
	end

	-- 下载所有补丁
	table.asyn_walk_sequence(downEnd,config.patchs,function (downNext, patch, index)
		self:download(config.rmvers,patch,function (ctype,result)
			if ctype == "P" then
				_onComplete("P", (0.8 / #config.patchs) * (index - 1 + result))
			elseif ctype == "R" then
				if result then
					utils.mergeFile(self._downpath,self._temppath .. tostring(index) .. ".patch", patch.format,true)
					downNext()
				else
					_onComplete("R",false)
				end
			end
		end)
	end)
end

return PackUpdater
