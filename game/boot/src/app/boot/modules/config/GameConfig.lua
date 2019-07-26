--[[
	游戏配置模块
]]
local THIS_MODULE = ...
local C_LOGTAG = "GameConfig"

-- 游戏配置表
local GAMECONFIG = {}

local cjson = cc.safe_require("cjson")
local utils = cc.safe_require("utils")
local GameConfig = class("GameConfig", GAMECONFIG)

-- 获得单例对象
local instance = nil
function GameConfig:getInstance()
	if instance == nil then
		instance = GameConfig:create()
	end
	return instance
end

-- 解密配置数据
function GameConfig:decryptData(data)
	if not self._aesok then
		self._aesok,self._aeskey,self._aesiv = utils.getConfAESKey()
	end
	if data and self._aesok then
		local decok,decdata = utils.AES_decrypt(self._aeskey,self._aesiv,data)
		if not decok then
			error("config decrypt failure")
		else
			return decdata
		end
	end
end

--[[
	加载配置文件
	confile	 配置文件
	onComplete  完成回调
		END		配置读取完成
		REMOTE	加载远程配置
]]
function GameConfig:loadConfig(confile,onComplete)
	self:clear()
	if fileMgr:isFileExist(confile) then
		local lcdata = self:decryptData(fileMgr:getDataFromFile(confile))
		if lcdata then
			table.merge(GAMECONFIG,cjson.decode(lcdata))

			-- 读取远程配置
			if self:isRemoteReadable() then
				if onComplete then onComplete("REMOTE") end
				
				GAMECONFIG.remoteurl = io.pathinfo(GAMECONFIG.remoteconfig).dirname

				logMgr:info(C_LOGTAG, "remote config file : %s", GAMECONFIG.remoteconfig)
				logMgr:info(C_LOGTAG, "remote url : %s", GAMECONFIG.remoteurl)
				
				return utils.http_get(GAMECONFIG.remoteconfig,function (result,data)
					if result then
						local rcdata = self:decryptData(data)
						if rcdata then
							table.merge(GAMECONFIG,cjson.decode(rcdata))
						end
					end
					if onComplete then onComplete("END") end
				end)
			end
		end
	end
	if onComplete then onComplete("END") end
end

-- 清除配置
function GameConfig:clear()
	for _,key in ipairs(table.keys(GAMECONFIG)) do
		GAMECONFIG[key] = nil
	end
end

-- 远程配置是否可以读取
function GameConfig:isRemoteReadable()
	return FLAG.ENABLEREMOTE and GAMECONFIG.enableremote and GAMECONFIG.remoteconfig
end

-- 包是否可以更新
function GameConfig:isPackUpdatable()
	return FLAG.ENABLEUPDATE and GAMECONFIG.enableupdate and GAMECONFIG.remoteurl and GAMECONFIG.packs
end

return GameConfig
