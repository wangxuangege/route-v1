module(..., package.seeall);

--------------------------------------------------------------------------------------
-- 获取IP地址整形表示
-- @param ip ip地址
-- @return ip地址对应的整数,若转换失败，那么返回-1
--------------------------------------------------------------------------------------
function ip2Long(ip)
    if ip == nil then
        return -1
    end

    local ipArray = string.split(ip, ".")
    if ipArray == nil or #ipArray ~= 4 then
        return -1
    end

    local result = 0
    local power = 3
    for _, segment in pairs(ipArray) do
        local segmentInt = tonumber(segment)
        if not segmentInt then
            return -1
        end
        result = result + segmentInt * math.pow(256, power)
        power = power - 1
    end
    return result
end