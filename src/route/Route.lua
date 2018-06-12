--[[
    ngx路由判断入口
]]--
local LogUtil = require("util.LogUtil")
local CONFIG = require("constant.Config")
local CONSTANT = require("constant.Constant")
local ERR_CODE = require("constant.ErrCode")
local RouteContext = require("route.RouteContext")
local StringUtil = require("util.StringUtil")
local RouteRuleService = require("respository.service.RouteRuleService")

local log = LogUtil:new("ROUTE")

--------------------------------------------------------------------------------------
-- 处理结果处理
--------------------------------------------------------------------------------------
local function handleRet(ngx, upstream)
    if not ngx or ngx.__TEST__ then
        log:info("路由计算结果为：", upstream)
        return
    end

    ngx.var.upstream = upstream
end

--------------------------------------------------------------------------------------
-- 查询所有规则
-- @return code detail
--------------------------------------------------------------------------------------
local function queryAllRules()
    -- 允许的规则类型
    local ruleTypes = CONSTANT.RULE_CLASS_MAP
    if not next(ruleTypes) then
        return {}
    end

    local code, detail = RouteRuleService.selectRouteRulesByStatus('OPEN', false)
    if code ~= ERR_CODE.SUCCESS then
        return code, detail
    end

    local result = {}

    -- 转换为规则对象
    for i = 1, #detail do
        local row = detail[i]
        local type = row.rule_type
        local ruleType = ruleTypes[type]
        if ruleType then
            local rules_str = row.rules_str
            local priority = tonumber(row.priority)
            local rule = ruleType:new(rules_str, priority)
            if rule.effective then
                table.insert(result, rule)
            else
                log:warn("忽略无效规则,rowId=", row.id)
            end
        else
            log:warn("忽略无效规则,rowId=", row.id)
        end
    end

    -- 按照优先级排序
    table.sort(result, function(left, right)
        return left.priority > right.priority
    end)

    return ERR_CODE.SUCCESS, result
end

--------------------------------------------------------------------------------------
-- 判断路由入口
-- @param ngx
-- @return code detail
--------------------------------------------------------------------------------------
local function route(ngx)
    local result = CONFIG.DEFAULT_UPSTREAM
    local hitRule = nil

    -- 目前先不考虑性能，直接从DB获取所有规则，后期优化
    local code, detail = queryAllRules()
    if code == ERR_CODE.SUCCESS then
        local context = RouteContext:build(ngx)
        for i = 1, #detail do
            local rule = detail[i]
            local code, detail = rule:getUpstream(context)
            if code == ERR_CODE.SUCCESS then
                result = detail.upstream
                hitRule = detail.rule
                break
            end
        end
    end

    if hitRule ~= nil then
        log:info("命中规则：", StringUtil.toJSONString(hitRule))
    else
        log:info("没有命中任何规则，走默认规则")
    end

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
