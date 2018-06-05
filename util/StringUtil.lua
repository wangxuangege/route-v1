module(..., package.seeall);

--------------------------------------------------------------------------------------
-- 字符串分割
-- @param str 待分割的字符串
-- @param delimiter 分隔符，默认为，
-- @return 分割后获取一个字符串数组
--------------------------------------------------------------------------------------
string.split = function(str, delimiter)
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
string.isEmpty = function(str)
    return str == nil or type(str) ~= "string" or str == ""
end

--------------------------------------------------------------------------------------
-- 去除字符串首尾空格
-- @param str 待处理的字符串
--------------------------------------------------------------------------------------
string.trim = function(str)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end