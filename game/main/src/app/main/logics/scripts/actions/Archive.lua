--[[
	存档
]]

-- 显示延时
local C_SHOW_DELAY = 0.5

-- 存档地图
local C_ARCHIVEMAP = {
	mapname = "build_palace",
	inpos = "p_revive",
	inmethod = "LINE",
	inface = "UP",
}

local Archive = class("Archive", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Archive:ctor(config)
	if config then
		if type(config) == "table" then
			table.merge(self,config)
		else	-- string
			self:parse(config)
		end
	end
end

-- 执行
function Archive:execute()
	local exps = majorTeam:getNextLevelExps()
	
	local function showEnd()
		uiMgr:openUI("message",{
			autoclose = true,
			texts = gameMgr:getStrings("HARDWORK")
		})
	end

	local function showBye()
		uiMgr:openUI("shadelight",{
			shadetime = 1,
			switch = function (onComplete_)
				local ui = uiMgr:openUI("message",{
					texts = gameMgr:getStrings("BYE")
				})
				performWithDelay(ui, function ()
					ui:closeFrame()
					gameMgr:onExitGame()
				end,C_SHOW_DELAY)
			end
		})
	end

	local function showContinue()
		uiMgr:openUI("select",{
			autoclose = true,
			messages = gameMgr:getStrings("RECORD_MSG4"),
			selects = {
				{
					label = gameMgr:getStrings("YES")[1],
					type = "Y",
				},{
					label = gameMgr:getStrings("NO")[1],
					type = "N",
				}
			},
			onComplete = function (result,item)
				if result and item.type == "Y" then
					showEnd()
				else
					showBye()
				end
			end
		})
	end

	local function doArchive()
		uiMgr:openUI("shadelight",{
			shadetime = 0.5,
			lighttime = 0.5,
			switch = function (onComplete_)
				uiMgr:closeAll("shadelight")
				
				gameMgr:setMapEnv("archivemap", self.archivemap or {
					mapname = gameMgr:getMapEnv("palacemap") or "build_palace",
					inpos = "p_revive",
					inmethod = "LINE",
					inface = "UP",
				})
				archMgr:saveArchive()
				
				local lastbgm = audioMgr:getCurrentBGM()
				audioMgr:listenFinish(audioMgr:playBGM(gameMgr:getArchiveBGM(),false),function ()
					if lastbgm then audioMgr:playBGM(lastbgm) end
					if onComplete_ then onComplete_() end
				end)
			end,
			onComplete = showContinue
		})
	end

	local function showArchive()
		uiMgr:openUI("select",{
			autoclose = true,
			messages = gameMgr:getStrings("RECORD_MSG3"),
			selects = {
				{
					label = gameMgr:getStrings("YES")[1],
					type = "Y",
				},{
					label = gameMgr:getStrings("NO")[1],
					type = "N",
				}
			},
			onComplete = function (result,item)
				if result and item.type == "Y" then
					doArchive()
				else
					showEnd()
				end
			end
		})
	end

	local function showExps()
		if exps then
			uiMgr:openUI("message",{
				autoclose = true,
				texts = gameMgr:getStrings("RECORD_MSG2", { exps = exps }),
				showconfig = {
					usecursor = true
				},
				onComplete = showArchive
			})
		else
			showArchive()
		end
	end

	uiMgr:openUI("message",{
		autoclose = true,
		texts = gameMgr:getStrings("RECORD_MSG1"),
		showconfig = {
			usecursor = true
		},
		onComplete = showExps
	})
end

-- 解析配置 ACTIONS/ARCHIVE>[map],[pos],[method],[face]
function Archive:parse(config)
	local params = config and string.split(config,",") or {}
	self.archivemap = {
		mapname = params[1],
		inpos = params[2],
		inmethod = params[3],
		inface = params[4],
	}
end

return Archive
