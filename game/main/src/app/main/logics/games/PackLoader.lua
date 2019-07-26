--[[
	包加载器
]]
local THIS_MODULE = ...
local C_LOGTAG = "PackLoader"
local C_SHOW_DELAY = 0.2

-- 错误颜色
local C_ERROR_COLOR = cc.c4b(255,0,0,255)

local PackLoader = class("PackLoader")

-- 获得单例对象
local instance = nil
function PackLoader:getInstance()
	if instance == nil then
		instance = PackLoader:create()
	end
	return instance
end

-- 加载指定的包
function PackLoader:loadPacks(packnames,onComplete)
	-- 计算更新
	local packnames = table.unique(packnames,true)
	local updates = {}
	local updateLoaded = false		-- 更新已经加载的包
	if gameConfig:isPackUpdatable() then
		for _,packname in ipairs(packnames) do
			local update = packUpdater:checkUpdate(packname)
			if update then
				if packMgr:getPack(packname) then
					updateLoaded = true
				end
				updates[#updates + 1] = update
			end
		end
	end

	-- 加载包文件
	local function LoadPackFiles()
		local ui = uiMgr:openUI("update")
		ui:setText(gameMgr:getStrings("PACK_LOADING")[1])
		ui:setProgress(0)
		for i,packname in ipairs(packnames) do
			if not packMgr:loadPack(packname) then
				error(string.format("pack [%s] load failure",packname))
				return ui:setText(gameMgr:getStrings("PACK_LOAD_FAILURE", { pack = packname })[1],C_ERROR_COLOR)
			end
			ui:setProgress(i/#packnames)
		end
		ui:setText(gameMgr:getStrings("PACK_LOAD_SUCCESS")[1])
		ui:setProgress(100)
		performWithDelay(ui,function ()
			ui:closeFrame()
			if onComplete then onComplete() end
		end,C_SHOW_DELAY)
	end

	if #updates > 0 then
		local ui = uiMgr:openUI("update")
		-- 释放需要更新的包
		for _,update in ipairs(updates) do
			packMgr:releasePack(update.pack)
		end
		-- 更新所有的包
		packUpdater:updatePacks(updates,function (ctype,result,...)
			if ctype == "C" then
				ui:setText(gameMgr:getStrings("UPDATE_PACK", { pack = result.pack })[1])
			elseif ctype == "P" then
				ui:setProgress(100 * result)
			elseif ctype == "R" then
				if result then
					ui:setText(gameMgr:getStrings("PACK_UPDATE_END")[1])
					performWithDelay(ui,function ()
						ui:closeFrame()
						LoadPackFiles()
					end,C_SHOW_DELAY)
				else
					ui:setText(gameMgr:getStrings("PACK_UPDATE_FAILURE", { pack = ... })[1],C_ERROR_COLOR)
				end
			end
		end)
	else
		LoadPackFiles()
	end
end

return PackLoader
