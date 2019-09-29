local reboot = ...
local C_LOGTAG = "boot"

cc.FileUtils:getInstance():setPopupNotify(false)
local app = cc.Application:getInstance()

if cc.enable_global then
	cc.enable_global(true)
end

local cjson = require("cjson")
local utils = require("utils")

-- 开启调试
if not reboot and utils.isDebug() then
	require("LuaDebug")("localhost",7003)
end

require "config"
require "cocos.init"

cc.exports.fileMgr = L.FileManager:getInstance()
cc.exports.logMgr = require("app.boot.modules.log.LogManager"):getInstance()
cc.exports.gameConfig = require("app.boot.modules.config.GameConfig"):getInstance()
cc.exports.packUpdater = require("app.boot.modules.pack.PackUpdater"):getInstance()

if device.IS_WINDOWS then
	LOCALCONFIG = "~/localconfig.json"							-- 本地配置
	PACKSPATH = "~/packs"										-- 包目录
	BOOTPACK = "~/boot.pack"									-- boot包路径
elseif device.IS_ANDROID then
	LOCALCONFIG = "~/assets/localconfig.json"
	PACKSPATH = fileMgr:getWritablePath() .. "/packs"
	BOOTPACK = fileMgr:getWritablePath() .. "/boot.pack"
	UNZIPCONF = fileMgr:getWritablePath() .. "/unzipconfig.json"	-- 安卓解压配置
	APKRESVERS = "~/assets/resversion.json"							-- APK资源版本
end

logMgr:info(C_LOGTAG, "local config file : %s", LOCALCONFIG)
logMgr:info(C_LOGTAG, "resource pack path : %s", PACKSPATH)
logMgr:info(C_LOGTAG, "boot pack file : %s", BOOTPACK)
if UNZIPCONF then
	logMgr:info(C_LOGTAG, "unzip config file : %s", UNZIPCONF)
end
if APKRESVERS then
	logMgr:info(C_LOGTAG, "apk resource version : %s", APKRESVERS)
end

------------------------------UpdateScene--------------------------------
local UpdateScene = class("UpdateScene", cc.Layer)

-- 更新场景CSB文件
UpdateScene.CSB = "res/boot/cocosstudio/UpdateScene.csb"

-- 更新场景变量绑定
UpdateScene.BINDS = {
	lb_update = "lb_update",
	gb_update = "gb_update",
}

-- 文本映射
UpdateScene.TEXTS = "res/boot/strings.json"

-- 游戏ICON
UpdateScene.ICON = "res/boot/graphics/images/gameicon.png"

-- 构造函数
function UpdateScene:ctor()
	-- 安装CSB文件并且加载文本映射
	local csbnode = cc.CSLoader:createNode(self.CSB)
	self:addChild(csbnode)
	for wname,wpath in pairs(self.BINDS) do
		self[wname] = csbnode:getChildByPath(wpath)
	end
	self._texts = cjson.decode(fileMgr:getDataFromFile(self.TEXTS))

	self:registerScriptHandler(function (eventName)
		if "enterTransitionFinish" == eventName then
			self:beginUpdate()
		end
	end)

	-- 桌面环境设置标题和图标
	if device.IS_DESKTOP then
		local view = cc.Director:getInstance():getOpenGLView()
		if view then
			view:setViewName(self:getText("GAME_NAME"))
			if self.ICON then view:setIcon(self.ICON) end
		end
	end
end

-- 获得指定文本
function UpdateScene:getText(tid,...)
	return string.format(self._texts[tid], ...)
end

-- 设置更新文本
function UpdateScene:setUpdateText(text,color)
	self.lb_update:setTextColor(color or cc.c4b(255,255,255,255))
	self.lb_update:setString(text)
	logMgr:info(C_LOGTAG, text)
end

-- 开始更新
function UpdateScene:beginUpdate()
	self:setUpdateText(self:getText("UPDATING"))
	self.gb_update:setPercent(0)

	-- 解压安卓资源包,如果未解包过或者安装新APK
	if device.IS_ANDROID then
		local unzipconf = {}
		if fileMgr:isFileExist(UNZIPCONF) then 
			unzipconf = cjson.decode(fileMgr:getDataFromFile(UNZIPCONF))
		end
		local version = app:getVersionCode()
		logMgr:info(C_LOGTAG, "android resources version : %d", unzipconf.packvers or 0)
		logMgr:info(C_LOGTAG, "android application version : %d", version or 0)
		if unzipconf.packvers ~= version then
			self:setUpdateText(self:getText("UNZIP_ASSETS"))
			local apkresconf = {}
			if fileMgr:isFileExist(APKRESVERS) then 
				apkresconf = cjson.decode(fileMgr:getDataFromFile(APKRESVERS))
			end
			for pname, apkpver in pairs(apkresconf) do
				if pname ~= "boot" then
					if fileMgr:lookPackVersion(PACKSPATH .. "/" .. pname .. ".pack") < apkpver then
						local unzipfile = "assets/packs/" .. pname .. ".pack"
						local destfile = PACKSPATH .. "/" .. pname .. ".pack"
						if utils.unzip(utils.getAssetsPath(), unzipfile, destfile) then
							logMgr:info(C_LOGTAG, "unzip %s -> %s", unzipfile, destfile)
						else
							error("android resources unzip failure : " .. unzipfile)
						end
					end
				end
			end
			unzipconf.packvers = version
			fileMgr:writeStringToFile(cjson.encode(unzipconf),UNZIPCONF)
			self:setUpdateText(self:getText("UNZIP_ASSETS_END"))
		end
	end
	
	self:setUpdateText(self:getText("READ_CONFIG"))
	self.gb_update:setPercent(10)
	gameConfig:loadConfig(LOCALCONFIG,function (ctype)
		if "REMOTE" == ctype then	-- 加载远程配置
			self:setUpdateText(self:getText("LOAD_REMOTE_CONFIG"))
			self.gb_update:setPercent(15)
		elseif "END" == ctype then	-- 配置读取完成
			self:setUpdateText(self:getText("READ_CONFIG_END"))
			self.gb_update:setPercent(20)

			-- 更新结束，加载游戏包，并进入游戏
			local function updateEnd()
				self:setUpdateText(self:getText("UPDATE_SUCCESS"))
				self.gb_update:setPercent(80)

				local boot = {
					name = "boot",
					file = "boot" .. PACK.FORMAT,
					path = BOOTPACK,
					version = fileMgr:getPackVersion("boot"),
				}
				PACK.BOOT = boot

				logMgr:info(C_LOGTAG, "BOOT PACK { name=%s, version=%s }", boot.name, utils.get_version_name(boot.version))

				-- 加载基础包
				for i,packname in ipairs(PACK.BASES) do
					local packpath = PACKSPATH .. "/" .. packname .. PACK.FORMAT
					if not fileMgr:loadFilePack(packpath) then
						return self:setUpdateText(self:getText("PACK_LOAD_FAILURE",packname),cc.c4b(255,0,0,255))
					else
						local loaded = {
							name = packname,
							file = packname .. PACK.FORMAT,
							path = packpath,
							version = fileMgr:getPackVersion(packname),
						}
						PACK.LOADED[packname] = loaded
						self.gb_update:setPercent(80 + 20 * (i/#PACK.BASES))

						logMgr:info(C_LOGTAG, "LOADED PACK { name=%s, version=%s }", loaded.name, utils.get_version_name(loaded.version))
					end
				end
				self.gb_update:setPercent(100)
				
				-- 启动游戏
				performWithDelay(self,function ()
					dofile("main.lua") 
				end,1)
			end

			if gameConfig:isPackUpdatable() then
				-- 计算需要更新的包
				self:setUpdateText(self:getText("COMPUTE_UPDATE_PACK"))
				local bootupdate = packUpdater:checkUpdate("boot",BOOTPACK)
				local baseupdates = {}
				for _,packname in ipairs(PACK.BASES) do
					local update = packUpdater:checkUpdate(packname)
					if update then
						baseupdates[#baseupdates + 1] = update
					end
				end
				
				-- 更新包
				if bootupdate then	-- BOOT包
					fileMgr:releaseFilePack("boot")
					packUpdater:updatePacks({ bootupdate } ,function (ctype,result,...)
						if ctype == "C" then
							self:setUpdateText(self:getText("UPDATE_PACK",result.pack))
						elseif ctype == "P" then
							self.gb_update:setPercent(20 + 80 * result)
						elseif ctype == "R" then
							if result then
								fileMgr:loadFilePack(BOOTPACK)

								printInfo("reboot ...")
					
								utils.remove_module("^config$", "^cocos[.].*$", "^app[.].*$")
								dofile("boot.lua", true)
							else
								local config = ...
								self:setUpdateText(self:getText("PACK_UPDATE_FAILURE",config.pack),cc.c4b(255,0,0,255))
							end
						end
					end)
				else	-- 基础包
					packUpdater:updatePacks(baseupdates,function (ctype,result,...)
						if ctype == "C" then
							self:setUpdateText(self:getText("UPDATE_PACK",result.pack))
						elseif ctype == "P" then
							self.gb_update:setPercent(20 + 60 * result)
						elseif ctype == "R" then
							if result then
								updateEnd()
							else
								local config = ...
								self:setUpdateText(self:getText("PACK_UPDATE_FAILURE", config.pack),cc.c4b(255,0,0,255))
							end
						end
					end)
				end
			else
				updateEnd()
			end
		end
	end)
end

-- 切换当前场景
function UpdateScene:showWithScene(transition, time, more)
	self:setVisible(true)
	local scene = display.newScene(self.name_)
	scene:addChild(self)
	display.runScene(scene, transition, time, more)
	return self
end
-------------------------------------------------------------------------

UpdateScene:create():showWithScene()
