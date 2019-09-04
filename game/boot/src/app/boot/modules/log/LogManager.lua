--[[
	日志管理器
--]]
local THIS_MODULE = ...

-- 最大日志缓冲 默认1M
local C_BUFFERSIZE = 1024 * 1024

-- 日志等级
local C_LEVEL = {
	VERBOSE = 1,	-- 啰嗦
	DEBUG 	= 2,	-- 调试
	INFO 	= 3,	-- 信息
	WARN 	= 4,	-- 警告
	ERROR 	= 5,	-- 错误
	SILENT 	= 6,	-- 寂静,用于关闭日志
}

-- 日志等级标识
local C_LFLAG = {
	[C_LEVEL.VERBOSE] 	= "V",
	[C_LEVEL.DEBUG] 	= "D",
	[C_LEVEL.INFO] 		= "I",
	[C_LEVEL.WARN] 		= "W",
	[C_LEVEL.ERROR] 	= "E",
	[C_LEVEL.SILENT] 	= "S",
}

local utils = cc.safe_require("utils")
local LogManager = class("LogManager")

LogManager.LEVEL = C_LEVEL	-- 日志等级

-- 获得单例对象
local instance = nil
function LogManager:getInstance()
	if instance == nil then
		instance = LogManager:create()
		
		-- 定义错误处理
		__G__TRACKBACK__ = function(msg)
			local msg = debug.traceback(msg, 3)
			instance:error("*", 
				"\n---------------------------------ERROR--------------------------------\n" .. 
				msg .. 
				"\n----------------------------------------------------------------------")
			return msg
		end
	end
	return instance
end

-- 构造函数
function LogManager:ctor()
	self._loglevel = C_LEVEL.VERBOSE								-- 日志输出等级
	self._flushlevel = C_LEVEL.ERROR								-- 日志刷新缓冲等级
	self._buffsize = C_BUFFERSIZE									-- 日志缓冲大小
	self._logformat = handler(self,LogManager._defaultLogFormat)	-- 日志格式函数
	self._logpath = fileMgr:getWritablePath() .. "/" .. DIRECTORY.LOG .. "/"
	self._logfile = self._logpath .. "/" .. os.date("%Y%m%d%H%M%S") .. ".log"
	self._logbuffer = { logs = {}, size = 0, }						-- 日志缓冲
	
	fileMgr:createDirectory(self._logpath)
end

--[[
	默认日志格式化函数
	config	
		level	等级
		tag		标签
		thread	线程
	content		日志内容
]]
function LogManager:_defaultLogFormat(config, content)
	return string.format("%s %s %s%s - ", 
		os.date("%m-%d %H:%M:%S"), 
		config.thread or "[MAIN]", 
		C_LFLAG[config.level], 
		config.tag and ("/" .. config.tag) or "") .. content
end

-- 设置日志输出等级
function LogManager:setLogLevel(level)
	self._loglevel = level
end

-- 设置刷新缓冲区等级
function LogManager:setFlushLevel(level)
	self._flushlevel = level
end

-- 设置日志缓冲区大小
function LogManager:setBufferSize(size)
	self._buffsize = size
end

--[[
	设置日志格式化函数
	format		格式化函数
]]
function LogManager:setLogFormat(format)
	self._logformat = format
	if not format then
		self._logformat = handler(self,LogManager._defaultLogFormat)
	end
end

--[[
	写入日志
	config	
		level	等级
		tag		标签
		thread	线程	
	fmt			格式字符串
	... 		日志参数
]]
function LogManager:writeLog(config, fmt, ...)
	if config.level >= self._loglevel then
		local content = string.format(fmt, ...)
		local log = self._logformat(config, content)
		self:writeContent(config.level, log)
	end
end

--[[
	写入日志内容
	log		日志字符串
]]
function LogManager:writeContent(level, log)
	print(log)
	table.insert(self._logbuffer.logs, log)
	self._logbuffer.size = self._logbuffer.size + #log
	if level >= self._flushlevel or self._logbuffer.size >= self._buffsize then
		self:flushLog()
	end
end

-- 完全写入日志缓冲
function LogManager:flushLog()
	if self._logbuffer.size > 0 then
		fileMgr:appendStringToFile(table.concat(self._logbuffer.logs, "\n") .. "\n", self._logfile)
		self._logbuffer = { logs = {}, size = 0, }
	end
end

-- 输出 VERBOSE 日志
function LogManager:verbose(config, fmt, ...)
	if type(config) ~= "table" then
		config = { tag = config }
	end
	config.level = C_LEVEL.VERBOSE
	self:writeLog(config, fmt, ...)
end

-- 输出 DEBUG 日志
function LogManager:debug(config, fmt, ...)
	if utils.isDebug() then
		if type(config) ~= "table" then
			config = { tag = config }
		end
		config.level = C_LEVEL.DEBUG
		self:writeLog(config, fmt, ...)
	end
end

-- 输出 INFO 日志
function LogManager:info(config, fmt, ...)
	if type(config) ~= "table" then
		config = { tag = config }
	end
	config.level = C_LEVEL.INFO
	self:writeLog(config, fmt, ...)
end

-- 输出 WARN 日志
function LogManager:warn(config, fmt, ...)
	if type(config) ~= "table" then
		config = { tag = config }
	end
	config.level = C_LEVEL.WARN
	self:writeLog(config, fmt, ...)
end

-- 输出 ERROR 日志
function LogManager:error(config, fmt, ...)
	if type(config) ~= "table" then
		config = { tag = config }
	end
	config.level = C_LEVEL.ERROR
	self:writeLog(config, fmt, ...)
end

return LogManager
