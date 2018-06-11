--[[
    RouteRule服务类
]]--
module(..., package.seeall)

local LogUtil = require("util.LogUtil")
local Mysql = require("respository.mysql.Mysql")
local ERR_CODE = require("constant.ErrCode")

local log = LogUtil:new("ROUTE_RULE_SERVICE")

--------------------------------------------------------------------------------------
-- 查询所有RouteRule
--------------------------------------------------------------------------------------
function selectAllRouteRules()
    local code, detail = Mysql.sQuery("select * from route_rule where 1=1", true)

    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, "查询路由规则失败"
    else
        return ERR_CODE.SUCCESS, detail
    end
end

--------------------------------------------------------------------------------------
-- 查询规则数
--------------------------------------------------------------------------------------
function selectAllRouteRuleSize()
    local code, detail = Mysql.sQuery("select count(*) as num from route_rule where 1=1", true)

    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, detail
    end
    return ERR_CODE.SUCCESS, tonumber(detail[1]['NUM'])
end

--------------------------------------------------------------------------------------
-- 根据主键id查询RouteRule
--------------------------------------------------------------------------------------
function selectRouteRuleById(id)
    local code, detail = Mysql.sQuery(
            string.format("select * from route_rule where id=id", id), true)

    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, "查询路由规则失败"
    else
        if next(detail) then
            return ERR_CODE.SUCCESS, detail[1]
        end
        return ERR_CODE.SUCCESS, {}
    end
end

--------------------------------------------------------------------------------------
-- 根据状态查询RouteRule
--------------------------------------------------------------------------------------
function selectRouteRulesByStatus(status)
    local code, detail = Mysql.sQuery(
            string.format("select * from route_rule where status='%s'", status), true)

    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, "查询路由规则失败"
    else
        return ERR_CODE.SUCCESS, detail
    end
end

--------------------------------------------------------------------------------------
-- 根据类型查询RouteRule
--------------------------------------------------------------------------------------
function selectRouteRulesByRuleType(ruleType)
    local code, detail = Mysql.sQuery(
            string.format("select * from route_rule where rule_type='%s'", ruleType), true)

    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, "查询路由规则失败"
    else
        return ERR_CODE.SUCCESS, detail
    end
end

--------------------------------------------------------------------------------------
-- 根据ID删除RouteRule
--------------------------------------------------------------------------------------
function deleteRouteRuleById(id)
    local code, detail = Mysql.sExecute(
            string.format("delete from route_rule where id=id", id))

    if code ~= ERR_CODE.SUCCESS then
        log:warn("删除失败，错误码:", code[1], "，错误原因：", detail)
        return code, "删除规则失败"
    end
    return ERR_CODE.SUCCESS
end

--------------------------------------------------------------------------------------
-- 更新RouteRule
--------------------------------------------------------------------------------------
function updateRouteRule(rule)
    local code, detail = Mysql.sExecute(string.format([[
                update route_rule
                set rules_str = '%s', status = '%s', priority = %s, update_time = NOW()
                where id=%s
            ]], rule['rulesStr'], rule['status'], rule['priority'], rule['id']))
    if code ~= ERR_CODE.SUCCESS then
        log:warn("更新路由规则失败，错误码:", code[1], "，错误原因：", detail)
        return code, "更新路由规则失败"
    end

    return ERR_CODE.SUCCESS
end

--------------------------------------------------------------------------------------
-- 插入规则
--------------------------------------------------------------------------------------
function insertRouteRule(rule)
    local code, detail = mysql:execute(string.format([[
                insert into route_rule(rule_type, rules_str, priority, status, create_time, update_time)
                values('%s', '%s', %s, '%s', NOW(), NOW())
            ]], rule['ruleType'], rule['rulesStr'], rule['priority'], rule['status']))

    if code ~= ERR_CODE.SUCCESS then
        log:warn("规则添加失败，错误码:", code[1], "，错误原因：", detail)
        return code, "路由规则添加失败"
    end
    return ERR_CODE.SUCCESS
end
