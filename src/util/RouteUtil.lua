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

    local ipArray = StringUtil.split(ip, ".")
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

--------------------------------------------------------------------------------------
-- 拷贝构造方法实现
-- 解决问题：当某lua对象序列化反序列化后，对象会失去调用方法的能力，只有数据部分，调用此方法，允许反序列化的对象允许调用方法
-- @param self 需要新生成的类对象
-- @param data 反序列化后的对象，只有数据成员
-- @param func 含有方法对象的类对象
--------------------------------------------------------------------------------------
function copyClass(self, data, func)
    if type(self) ~= 'table'
            or type(func) ~= 'table' then
        return data
    end

    self = {}
    return setmetatable(self, { __index = function(table, key)
        -- 优先从origin取得数据成员，若取不到，那么在class寻找方法
        return data[key] or func[key]
    end })
end