--[[
    ngx路由判断入口
]]--
local LogUtil = require("util.LogUtil")
local CONFIG = require("constant.Config")
local ERR_CODE = require("constant.ErrCode")
local RouteContext = require("route.RouteContext")

local log = LogUtil:new("ROUTE")

--------------------------------------------------------------------------------------
-- 处理结果处理
--------------------------------------------------------------------------------------
local function handleRet(ngx, upstream)
    if not ngx then
        log:info("路由计算结果为：", upstream)
        return
    end

    ngx.var.upstream = upstream
end

--------------------------------------------------------------------------------------
-- 判断路由入口
-- @param ngx
-- @return code detail
--------------------------------------------------------------------------------------
local function route(ngx)
    local context = RouteContext:build2(ngx)
    local result = "BETA1"
    handleRet(ngx, result)
end


if CONFIG.DEBUG then
    -- DEBUG模式下面直接抛出异常
    route(ngx)
else
    -- 保守执行路由计算
    if not pcall(route, ngx) then
        log:error("路由计算出现异常，使用默认路由")
        handleRet(ngx, CONFIG.DEFAULT_UPSTREAM)
    end
end
