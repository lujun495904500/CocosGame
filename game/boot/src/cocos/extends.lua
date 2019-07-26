--[[
	扩展基础功能
]]

require "cocos.extendsm"

cc = cc or {}
utils = utils or {}

local fileUtils = cc.FileUtils:getInstance()

local Node = cc.Node

-- 通过路径查找子节点
function Node:getChildByPath(path)
    local child = self
    for _,nname in ipairs(path:split('/')) do
        child = child:getChildByName(nname)
    end
    return child ~= self and child or nil
end

-- 设置可见度使能
function Node:setOpacityEnabled(bool)
    self:setCascadeOpacityEnabled(bool)
    for _,child in ipairs(self:getChildren()) do 
        child:setCascadeOpacityEnabled(bool)
    end
end

--[[
	http GET调用
]]
function utils.http_get(url, onComplete, resptype)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = resptype or cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    local function onReadyStateChanged()
        if onComplete then 
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                onComplete(true,xhr.response)
            else
                onComplete(false)
            end
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChanged)
    xhr:send()
end

-- 获得真实lua文件
function utils.get_real_luafile(filename)
	local finfo = io.pathinfo(filename)
	local luafile = finfo.dirname .. finfo.basename .. ".luac"
	if fileUtils:isFileExist(luafile) then
		return luafile
	end
	luafile = finfo.dirname .. finfo.basename .. ".lua"
	if fileUtils:isFileExist(luafile) then
		return luafile
	end
end

-- 加载lua文件
function loadfile(filename)
	local luafile = utils.get_real_luafile(filename)
	if not luafile then
		error(string.format("not found lua file : %s", filename))
	end
	return load(fileUtils:getDataFromFile(luafile), luafile)
end

-- 执行lua文件
function dofile(filename, ...)
	return loadfile(filename)(...)
end
