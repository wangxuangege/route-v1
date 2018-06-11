module(..., package.seeall);

--------------------------------------------------------------------------------------
-- 字符串查找
-- @param str
-- @param s 要查找的字符串，
-- @return 若查找成功，返回所在的索引，若查找失败，则返回-1
-------------------------------------------------------------------------------------
indexOf = function(str, s)
    if type(str) ~= 'string' or type(s) ~= 'string' then
        return -1
    end
    local pos = string.find(str, s, 1, true)
    if pos then
        return pos
    end
    return -1
end

--------------------------------------------------------------------------------------
-- 字符串分割
-- @param str 待分割的字符串
-- @param delimiter 分隔符，默认为，
-- @return 分割后获取一个字符串数组
--------------------------------------------------------------------------------------
split = function(str, delimiter)
    if type(delimiter) ~= "string" or string.len(delimiter) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find(str, delimiter, start, true)
        if not pos then
            break
        end

        table.insert(t, string.sub(str, start, pos - 1))
        start = pos + string.len(delimiter)
    end
    table.insert(t, string.sub(str, start))

    return t
end

--------------------------------------------------------------------------------------
-- 判断字符串是否为空
-- @param str 待判断的字符串
--------------------------------------------------------------------------------------
isEmpty = function(str)
    return str == nil or type(str) ~= "string" or str == ""
end

--------------------------------------------------------------------------------------
-- 去除字符串首尾空格
-- @param str 待处理的字符串
--------------------------------------------------------------------------------------
trim = function(str)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------------
-- 转换为json字符串
--------------------------------------------------------------------------------------
toJSONString = function(obj)
    if type(obj) ~= 'table' then
        return tostring(obj)
    end
    local json = require("cjson")
    return json.encode(obj)
end