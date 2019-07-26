
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
	width = 426,
	height = 240,
	autoscale = "SHOW_ALL",
	callback = function(framesize)
		local ratio = framesize.width / framesize.height
		if ratio <= 1.34 then
			-- iPad 768*1024(1536*2048) is 4:3 screen
			return {autoscale = "SHOW_ALL"}
		end
	end
}

-- 标志
FLAG = {
	ENABLEREMOTE = true,		-- 远程配置
	ENABLEUPDATE = true,		-- 使能更新
}

-- 目录
DIRECTORY = {
	TEMP		= "temp",		-- 临时
	DOWNLOAD	= "downloads",	-- 下载
	LOG 		= "logs",		-- 日志
}

-- 包
PACK = {
	FORMAT = ".pack",			-- 包格式
	BASES = { "main" },			-- 基础包
	BOOT = {},					-- 启动包
	LOADED = {},				-- 加载包
}
