--[[
    路由上下文对象
]]--
module(..., package.seeall)

local _M = {
    _VERSION = "0.0.1"
}

require("util.StringUtil")
local RouteUtil = require("util.RouteUtil")
local NgxUtil = require("util.NgxUtil")

--------------------------------------------------------------------------------------
-- 构造路由上下文对象
-- @param ngx对象
-- 对象属性包括：
-- ip: IP地址
-- intIp: IP地址转换成的整数
-- requestUri: 请求uri
-- requestParams: 请求参数
--------------------------------------------------------------------------------------
function _M:build(ngx)
    self = {}

    self.ip = NgxUtil.getNgxIP(ngx)
    self.longIP = RouteUtil.ip2Long(self.ip)
    self.requestUri = NgxUtil.getNgxRequestUri(ngx)
    self.requestParams = NgxUtil.getRequestParams(ngx)

    return setmetatable(self, { __index = _M })
end

return _M