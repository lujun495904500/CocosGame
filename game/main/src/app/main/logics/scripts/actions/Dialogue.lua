--[[
	对话
]]

local Dialogue = class("Dialogue", require("app.main.modules.script.ScriptBase"))

-- 构造函数
function Dialogue:ctor(config)
	if config then
		if type(config) == "table" then
			table.merge(self,config)
		else	-- string
			self:parse(config)
		end
	end
end

-- 执行对话
function Dialogue:execute(onComplete)
	for _,talk in ipairs(self.talks) do 
		local epoints = talk.epoints or {}
		local scripts = talk.scripts or {}
		if (not epoints.ENABLE or archMgr:checkEventPoint(unpack(epoints.ENABLE))) and 
			(not epoints.DISABLE or not archMgr:checkEventPoint(unpack(epoints.DISABLE))) then
			return uiMgr:openUI("dialogue",{
				talks = dbMgr.talks[talk.id],
				epoints = epoints,
				scripts = scripts,
				autoclose = true,
				onComplete = function ()
					if onComplete then onComplete(true) end
				end
			})
		end
	end
	if onComplete then onComplete(false) end
end

-- 解析对话  eg：ACTIONS/TALK>T16|,STD_XZ_TALK_DC,STD_XZ_MEET_DC;T17|,,STD_XZ_MEET_DC
function Dialogue:parse(config)
	self.talks = self.talks or {}

	for _,talkconf in ipairs(string.split(config,";")) do 
		local talk = {}
		local tparams = string.split(talkconf,"|")
		talk.id = tparams[1]
		if #tparams > 1 then	-- 事件点
			if tparams[2] and tparams[2] ~= "" then
				local epoints = {}
				local eps = string.split(tparams[2],",")
				for i,epval in ipairs(eps) do 
					local epconf = tools:parseEPoint(epval)
					if i == 1 then
						epoints["ENABLE"] = epconf
					elseif i == 2 then
						epoints["DISABLE"] = epconf
					else
						epoints[#epoints + 1] = epconf
					end
				end
				talk.epoints = epoints
			end
		end
		if #tparams > 2 then	-- 脚本
			if tparams[3] and tparams[3] ~= "" then
				local scripts = {}
				local spts = string.split(tparams[3],",")
				for _,spt in ipairs(spts) do
					scripts[#scripts + 1] = tools:parseScript(spt, ":")
				end
				talk.scripts = scripts
			end
		end
		self.talks[#self.talks + 1] = talk
	end
end

return Dialogue
