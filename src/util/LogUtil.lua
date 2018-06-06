--[[
    日志输出
    1）若是运行在ngx上面，那么直接使用ngx.log进行输出
    2）若运行在本地上面，那么在控制台输出日志内容
]]--
local _M = {
    _VERSION = "0.0.1"
}

local CONFIG = require("constant.config")

function _M:new(tag, ngx)
    self = {}

    self.tag = tag
    self.ngx = ngx
    return setmetatable(self, { __index = _M })
end

function _M:debug(...)
    if CONFIG.LOG_LEVEL <= 3 then
        return
    end

    _M:write(" DEBUG ", " TAG[", self.tag or 'ROUTE', "] ", ...)
end

function _M:info(...)
    if CONFIG.LOG_LEVEL <= 2 then
        return
    end

    _M:write("  INFO ", " TAG[", self.tag or 'ROUTE', "] ", ...)
end

function _M:warn(...)
    if CONFIG.LOG_LEVEL <= 1 then
        return
    end

    _M:write("  WARN ", " TAG[", self.tag or 'ROUTE', "] ", ...)
end

function _M:error(...)
    if CONFIG.LOG_LEVEL <= 0 then
        return
    end

    _M:write(" ERROR ", " TAG[", self.tag or 'ROUTE', "] ", ...)
end

-- 日志会考虑适配，若运行在ngx上面，那么直接用ngx.log打印日志，否则打印在控制台
function _M:write(...)
    if self.ngx and self.ngx.log then
        self.ngx.log({ ... })
        return
    end

    print(table.concat({ ... }))
end

return _M