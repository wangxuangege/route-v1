--[[
    路由上下文对象
]]--
local _M = {
    _VERSION = "0.0.1"
}

require("util.StringUtil")

--------------------------------------------------------------------------------------
-- 获取ngx的IP
-- @param ngx ngx对象
-- 注意：使用该方法要能够正常获取到请求方的IP，需要在代理上面配置
-- proxy_set_header X-Real-IP $remote_addr;
-- proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
--------------------------------------------------------------------------------------
local function getNgxIP(ngx)
    if ngx.__TEST__ then
        return ngx.__TEST__.ip
    end

    local headers = ngx.req.get_headers()
    return headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
end

--------------------------------------------------------------------------------------
-- 获取ngx的request_uri
--------------------------------------------------------------------------------------
local function getNgxRequestUri(ngx)
    if ngx.__TEST__ then
        return ngx.__TEST__.requestUri
    end

    return ngx.var.request_uri
end

--------------------------------------------------------------------------------------
-- 获取IP地址整形表示
-- @param ip ip地址
-- @return ip地址对应的整数,若转换失败，那么返回-1
--------------------------------------------------------------------------------------
local function ip2Long(ip)
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

--------------------------------------------------------------------------------------
-- 获取ngx请求中的request参数
-- @param ngx ngx对象
-- @return
--------------------------------------------------------------------------------------
local function getRequestParams(ngx)
    if ngx.__TEST__ then
        return ngx.__TEST__.requestParams
    end

    return {}
end

--------------------------------------------------------------------------------------
-- 构造路由上下文对象
-- @param ngx对象
-- 对象属性包括：
-- ip: IP地址
-- intIp: IP地址转换成的整数
-- requestUri: 请求uri
-- requestParams: 请求参数
--------------------------------------------------------------------------------------
function _M:new(ngx)
    self = {}

    self.ip = getNgxIP(ngx)
    self.longIP = ip2Long(self.ip)
    self.requestUri = getNgxRequestUri(ngx)
    self.requestParams = getRequestParams(ngx)

    return setmetatable(self, { __index = _M })
end

return _M