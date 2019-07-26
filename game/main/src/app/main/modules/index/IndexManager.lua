--[[
	索引管理器
--]]

local THIS_MODULE = ...
local C_LOGTAG = "IndexManager"

local cjson = cc.safe_require("cjson")
local IndexManager = class("IndexManager")

-- 获得单例对象
local instance = nil
function IndexManager:getInstance()
	if instance == nil then
		instance = IndexManager:create()
	end
	return instance
end

-- 构造函数
function IndexManager:ctor()
	self._envs 			= {}			-- 环境变量
	self._indexnodes	= {}			-- 索引节点
	self._indexes 		= {}  			-- 索引表
	self._listen		= { 			-- 监听
		remove = { entities = {} },		-- 移除配置
		loads = {},						-- 加载配置
	}
end

----------------------------------------------------------
--	环境变量

-- 设置环境变量
function IndexManager:setEnv(key, value)
	local fkey = "$(" .. key .. ")"
	if self._envs[fkey] then
		local msg = string.format("index env %s conflict", key)
		if ERROR.INDEX_ENV_CONFLICT then
			error(msg)
		else
			logMgr:warn(C_LOGTAG, msg)
		end
	end
	self._envs[fkey] = value
end

-- 设置环境配置
function IndexManager:setEnvConfig(envconf)
	if envconf then
		for key,value in pairs(envconf) do
			self:setEnv(key, value)
		end
	end
end

-- 获得环境变量
function IndexManager:getEnv(key)
	return self._envs["$(" .. key .. ")"]
end

-- 清除环境变量
function IndexManager:clearEnvs()
	self._envs = {}
end

----------------------------------------------------------
--	json配置读写

-- 读取json文件
function IndexManager:readJson(jsonfile)
	local jsonpath = fileUtils:fullPathForFilename(jsonfile)
	if fileUtils:isFileExist(jsonpath) then
		return cjson.decode(fileUtils:getDataFromFile(jsonpath))
	end
end

-- 写入json文件
function IndexManager:writeJson(jdata,jsonfile)
	if jdata and jsonfile then
		fileUtils:writeStringToFile(cjson.encode(jdata), jsonfile)
	end
end

-- 读取json配置文件，环境变量替换
function IndexManager:readJsonConfig(jsonfile)
	logMgr:verbose(C_LOGTAG, "read config json : %s", jsonfile)
	local jsonpath = fileUtils:fullPathForFilename(jsonfile)
	if fileUtils:isFileExist(jsonpath) then
		local newenvs = { 
			["$(curpath)"] = io.pathinfo(jsonpath).dirname 
		}
		table.merge(newenvs, self._envs)

		local jsondata = fileUtils:getDataFromFile(jsonpath)
		jsondata = jsondata:gsub("%$%(%w+%)", newenvs)

		return cjson.decode(jsondata)
	end
end

----------------------------------------------------------
--	索引操作

-- 合并表
function IndexManager:mergeTalbe(jdest, jsrc, jpath, listen, jsonpath)
	jpath = jpath or ""
	for name,value in pairs(jsrc) do
		if type(name) == "number" then
			name = #jdest + 1
		end
		local ijpath = (jpath ~= "") and (jpath .. "/" .. name) or name

		if type(value) == "table" then
			local itable = jdest[name]
			if not itable then
				itable = {}
				jdest[name] = itable
			end
			self:mergeTalbe(itable, value, ijpath, listen, jsonpath)
		else
			if jdest[name] then
				local msg = string.format("index path %s conflict : %s", ijpath, jsonpath or "[unknown]")
				if ERROR.INDEX_PATH_CONFLICT then
					error(msg)
				else
					logMgr:warn(C_LOGTAG, msg)
				end
			end
			jdest[name] = value
		end

		if listen then self:notifyIndexesLoaded(ijpath, value) end
	end
end

-- 重构索引
function IndexManager:rebuildIndexes()
	self._indexes = {}
	for node,index in pairs(self._indexnodes) do
		self:mergeTalbe(self._indexes, index)
	end
end

-- 获得指定索引
function IndexManager:getIndex(path)
	local value = self._indexes
	for _,pnode in ipairs(path:split('/')) do
		if not value then 
			return nil
		end
		value = value[pnode]
	end
	return value
end

-- 加载索引文件
function IndexManager:loadIndexFile(file, node)
	node = node or file
	local newindex = self:readJsonConfig(file)

	local nodeindex = self._indexnodes[node]
	if not nodeindex then
		self._indexnodes[node] = newindex
	else
		self:mergeTalbe(nodeindex, newindex)
	end

	self:mergeTalbe(self._indexes, newindex, "", true, file)
end

-- 移除索引节点
function IndexManager:removeIndexNode(node)
	if self._indexnodes[node] then
		self._indexnodes[node] = nil
		self:rebuildIndexes()
		self:notifyIndexesRemoved()
	end
end

-- 加载索引文件配置
function IndexManager:loadIndexFileConfig(confile, node)
	local indexconf = self:readJsonConfig(confile)
	if indexconf then
		for _,indexfile in pairs(indexconf) do 
			self:loadIndexFile(indexfile, node or confile)
		end
	end
end

-- 清除全部索引
function IndexManager:clearIndexes()
	self._indexnodes	= {}
	self._indexes 		= {}
	self:notifyIndexesRemoved()
end

----------------------------------------------------------
--	索引监听

-- 添加监听器
function IndexManager:addListener(listener, ipaths, priority)
	self:removeListener(listener)

	local lentity = {
		listener = listener,
		priority = priority or 0,
	}

	-- 更新移除监听器
	self._listen.remove.entities[listener] = lentity
	self._listen.remove.queue = table.values(self._listen.remove.entities)
	table.sort(self._listen.remove.queue, function (a, b)
		return a.priority < b.priority
	end)

	-- 更新加载路径监听器
	if ipaths then
		for _,ipath in ipairs(ipaths) do
			if ipath:byte(#ipath) == 47 then	-- /
				ipath = ipath:sub(1,-2)
			end
			local loadconf = self._listen.loads[ipath]
			if not loadconf then
				loadconf = { entities = {} }
				self._listen.loads[ipath] = loadconf
			end
			loadconf.entities[listener] = lentity
			loadconf.queue = table.values(loadconf.entities)
			table.sort(loadconf.queue, function (a, b)
				return a.priority > b.priority
			end)
		end
	end
end

-- 移除监听器
function IndexManager:removeListener(listener)
	if self._listen.remove.entities[listener] then
		-- 移除移除表
		self._listen.remove.entities[listener] = nil
		self._listen.remove.queue = table.values(self._listen.remove.entities)
		table.sort(self._listen.remove.queue, function (a, b)
			return a.priority < b.priority
		end)

		-- 移除路径表
		for _,loadconf in pairs(self._listen.loads) do
			if loadconf.entities[listener] then
				loadconf.entities[listener] = nil
				loadconf.queue = table.values(loadconf.entities)
				table.sort(loadconf.queue, function (a, b)
					return a.priority > b.priority
				end)
			end
		end
	end
end

-- 清空监听器
function IndexManager:clearListeners()
	self._listen = { 
		remove = { entities = {} },
		loads = {},
	}	
end

-- 通知索引加载
function IndexManager:notifyIndexesLoaded(ipath, ivalue)
	local loadconf = self._listen.loads[ipath]
	if loadconf then
		for _,lentity in ipairs(loadconf.queue or {}) do
			lentity.listener:onIndexesLoaded(ipath, ivalue)
		end
	end
end

-- 通知索引移除
function IndexManager:notifyIndexesRemoved()
	for _,lentity in ipairs(self._listen.remove.queue or {}) do
		lentity.listener:onIndexesRemoved()
	end
end

return IndexManager
