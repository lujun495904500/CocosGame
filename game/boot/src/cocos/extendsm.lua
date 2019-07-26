--[[
	扩展基础功能1
	该扩展可以在多线程中使用
]]

cc = cc or {}
table = table or {}
utils = utils or {}
string = string or {}

-- export global variable
local __g = _G
cc.exports = {}
setmetatable(cc.exports, {
    __newindex = function(_, name, value)
        rawset(__g, name, value)
    end,

    __index = function(_, name)
        return rawget(__g, name)
    end
})

-- disable create unexpected global variable
local g_cenable = true
function cc.enable_global(enable)
	if g_cenable ~= enable then
		g_cenable = enable
		if enable then
			setmetatable(__g, nil)
		else
			setmetatable(__g, {
				__newindex = function(_, name, value)
					error(string.format("USE \" cc.exports.%s = value \" INSTEAD OF SET GLOBAL VARIABLE", name), 0)
				end
			})
		end
	end
end

-- 解决系统require的时候，可能定义全局变量，而又禁止定义
function cc.safe_require(packpath)
	local r = nil
	local oge = g_cenable
	if not oge then
		cc.enable_global(true)
	end
	r = require(packpath)
	if not oge then
		cc.enable_global(false)
	end
	return r
end

-- 匹配通配符
utils.match_wildcard = nil
utils.match_wildcard = function(wcs, str)
	local widx = 1
	local sidx = 1
	while true do
		if widx > #wcs then
			return sidx > #str
		end
		if wcs:byte(widx) == 63 then	-- ?
			widx = widx + 1
			sidx = sidx + 1
		elseif wcs:byte(widx) == 42 then	-- *
			widx = widx + 1
			while sidx <= #str do
				if utils.match_wildcard(wcs:sub(widx), str:sub(sidx)) then
					return true
				end
				sidx = sidx + 1
			end
			return widx > #wcs
		else
			if widx > #wcs or sidx > #str or wcs:byte(widx) ~= str:byte(sidx) then
				return false
			end
			widx = widx + 1
			sidx = sidx + 1
		end
	end
end

-- 匹配通配符列表
function utils.match_wildcards(wcslist, str)
	for _, wcs in ipairs(wcslist) do
		if utils.match_wildcard(wcs, str) then
			return true
		end
	end
end

--[[
	获得版本名称
]]
function utils.get_version_name(vercode)
    local verps = {}
    while true do
        table.insert(verps, 1, math.floor(vercode % 1000))
        if vercode < 1000 then
            break
        else
            vercode = math.floor(vercode / 1000) 
        end
    end

    local vername = ""
    for _,ver in ipairs(verps) do
        if #vername > 0 then
            vername = vername .. "."
        end
        vername = vername .. tostring(ver)
    end
    
	return vername
end

--[[
	获得版本号
]]
function utils.get_version_code(vername)
    local vercode = 0
    local verss = string.split(vername,".")
	for _,ver in ipairs(verss) do
		vercode = vercode * 1000
        vercode = vercode + tonumber(ver)
    end
	return vercode
end

--[[
	格式化存储大小
]]
function utils.format_store_size(size)
	if size <= 1024 then
		return string.format("%dB", size)
	elseif size <= 1048576 then
		return string.format("%.2fKB", size / 1024)
	elseif size <= 1073741824 then
		return string.format("%.2fMB", size / 1048576)
	else
		return string.format("%.2fGB", size / 1073741824)
	end
end

-- 十六进制数字 0-9 a-f
local C_HEXDIGITS = { 48,49,50,51,52,53,54,55,56,57,97,98,99,100,101,102 }
-- 创建UUID
function utils.create_uuid()
	local s = {}
	for i =1,36 do
		s[i] = C_HEXDIGITS[math.random(1,16)]
	end
	-- bits 12-15 of the time_hi_and_version field to 0010
	s[15] = 52;

	-- bits 6-7 of the clock_seq_hi_and_reserved to 01
	s[20] = C_HEXDIGITS[bit.bor(bit.band(s[20],0x3),0x8)]
	
	-- add -
	s[9] = 45
	s[14] = 45
	s[19] = 45
	s[24] = 45
	
	return string.char(unpack(s))
end

function table.nums(t,fn)
    local count = 0
    for k, v in pairs(t) do
        if not fn or fn(v,k) then
            count = count + 1
        end
    end
    return count
end

function table.merge(dest, src)
    if src then
        for k, v in pairs(src) do
            dest[k] = v
        end
    end
    return dest
end

-- 异步循环
function table.asyn_loop(e,...)
    local fns = { ... }
    if #fns <= 0 then
        if e then e() end
    else
        local i = 0
        local lfn = nil 

        lfn = function ()
            i = i + 1
            if i > #fns then
                i = 1
            end
            fns[i](function (r)
                if r then
                    lfn()
                else
                    if e then e() end
                end
            end)
        end

        lfn()
    end
end

-- 异步序列遍历(数组)
function table.asyn_walk_sequence(e,t,fn)
    if #t <= 0 then
        if e then e(0) end
    else
        local i = 0
        local c = 0
        local _wfn = nil

        _wfn = function (r)
            if r then 
                c = c + 1 
            end
            if i + 1 <= #t then
                i = i + 1
                local v = t[i]
                if v then
                    fn(_wfn,v,i)
                else
                    _wfn()
                end
            else
                if e then e(c) end
            end
        end

        _wfn()
    end
end

-- 同步同时遍历(映射表)
function table.asyn_walk_together(e,t,fn)
    if not next(t) then
        if e then e(0) end
    else
        local c = 0
        local ends = {}
        
		local function _efn(ky)
			ends[ky] = true
            for k,_ in pairs(t) do
                if not ends[k] then return false end
            end
            if e then e(c) end
        end

        for k,v in pairs(t) do
            fn(function (r)
                if r then 
                    c = c + 1 
                end
                _efn(k)
            end,v,k)
        end
    end
end

-- 生成指定范围的数组
function table.range(s,len)
    if not s then
        s = 1
    end
    if not len then 
        len = s
        s = 1
    end
    local a = {}
    for i = s, s + len - 1 do
        a[#a + 1] = i
    end
    return a
end

-- 数组 AND 操作
function table._and(t,fn)
    for k, v in pairs(t) do
        if not fn(v, k) then return false end
    end
end

-- 数组 OR 操作
function table._or(t,fn)
    for k, v in pairs(t) do
        if fn(v, k) then return true end
    end
end

-- 过滤数组
function table.filter_array(t,fn)
    local a = {}
    for i, v in ipairs(t) do
        if fn(v, i) then 
            a[#a + 1] = v
        end
    end
    return a
end

-- 合并数组
function table.merge_array(...)
    local a = {}
    for _, a_ in ipairs({...}) do
        for _,v in ipairs(a_) do
            a[#a + 1] = v
        end
    end
    return a
end

-- 把字符串转换为16进制
function string.tohex(str, sp)
	local hexs = {}
	for i = 1, #str do
		hexs[#hexs + 1] = string.format("%02x", str:byte(i)) 
	end
	return table.concat(hexs, sp or "")
end

function string.dump(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

	local function dump_value_(v)
		if type(v) == "string" then
			v = "\"" .. v .. "\""
		end
		return tostring(v)
	end
	
    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(description), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, description, "", 1)

	return table.concat(result, "\n")
end

--[[
	移除指定模块
]]
function utils.remove_module(...)
    local regexnames = { ... }
    for _,pkname in ipairs(table.keys(package.loaded)) do
        for _,regexname in ipairs(regexnames) do
            if string.match(pkname, regexname) then
                package.loaded[pkname] = nil
                break
            end
        end
    end
end

--[[
	异步转同步调用
	asyncfunc 	异步函数,第一个参数为结果回调
	...			其他参数
]]
function utils.async_call(asyncfunc, ...)
	local args = { ... }
	return coroutine.wrap(function ()
		asyncfunc(function (...)
			coroutine.yield(...)
		end, unpack(args))
	end)()
end
