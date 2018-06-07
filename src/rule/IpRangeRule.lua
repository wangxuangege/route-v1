--[[
    IP路由规则
]]--
module (..., package.seeall)

local _M = {
    _VERSION = "0.0.1"
}

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local RouteUtil = require("util.RouteUtil")
local CONSTANT = require("constant.Constant")
local BaseRule = require("rule.BaseRule")

--------------------------------------------------------------------------------------
-- IP路由规则构造方法
-- @param rulesStr 规则字符串
-- @param priority 规则优先级
-- @return 返回构造好的IP规则对象
--------------------------------------------------------------------------------------
function _M:new(rulesStr, priority)
    return BaseRule:build(CONSTANT.RULE_TYPE.IP_RANGE, rulesStr, priority, _M)
end

--------------------------------------------------------------------------------------
-- 拷贝构造方法
-- @param rule 待拷贝的对象
-- @return 拷贝的结果，这样拷贝后的对象就能够方法调用
--------------------------------------------------------------------------------------
function _M:copy(rule)
    return RouteUtil:copyClass(rule, _M)
end

--------------------------------------------------------------------------------------
-- 获取路由upstream
-- @param context 路由上下文对象
-- @return code, detail
-- 1) 首先判断规则是否有效，若规则无效，则detail1为错误原因
-- 2) 若路由计算成功，则detail为计算出来的结果，{ upstream = $upstream, rule = $rule }
--------------------------------------------------------------------------------------
function _M:getUpstream(context)
    if not self.effective then
        return ERR_CODE.RULE_UN_EFFECTIVE, '规则无效，计算路由失败'
    end

    if not context.longIP or context.longIP < 0 then
        return ERR_CODE.CONTEXT_UNDEFINE_PARAM, '路由上下文中获取IP非法，计算路由失败'
    end

    for _, rule in pairs(self.rules) do
        local range, upstream = rule.range, rule.upstream
        local from, to = range.from, range.to
        if from <= context.longIP and context.longIP <= to then
            return ERR_CODE.SUCCESS, { upstream = upstream, rule = rule }
        end
    end

    return ERR_CODE.RULE_UN_HIT, '没有命中任何规则'
end

--------------------------------------------------------------------------------------
-- 将规则字符串转换为IP规则
-- @param rulesStr规则数组
-- 1) rulesStr格式为from1~to1,upstream1|from2~to2,upstream2|......
-- 2) 转换为{range = { from = from, to = $to}, upstream = '@upstream'}每条格式后，然后校验IP规则是否有效
-- @return code detail
-- 1) 若不符合格式，detail为错误详细原因
-- 2) 若符合格式，detail为解析出来的规则
--------------------------------------------------------------------------------------
function _M.parse(rulesStr)
    if StringUtil.isEmpty(rulesStr) then
        return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则不能为空'
    end

    -- 解析规则
    local ruleStrArray = StringUtil.split(rulesStr, "|")
    if not next(ruleStrArray) then
        return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则不能为空'
    end

    local result = {}
    for _, ruleStr in pairs(ruleStrArray) do
        if StringUtil.isEmpty(ruleStr) then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则存在空的子规则'
        end

        local ipSplitPos, _ = string.find(ruleStr, '~')
        if not ipSplitPos then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由子规则格式不正确'
        end

        local upstreamSplitPos, _ = string.find(ruleStr, ',', ipSplitPos)
        if not upstreamSplitPos then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由子规则格式不正确'
        end

        -- 解析IP地址，IP地址可以是整形也可以是标准形
        local fromStr = string.sub(ruleStr, 1, ipSplitPos - 1)
        local toStr = string.sub(ruleStr, ipSplitPos + 1, upstreamSplitPos - 1)
        local from, to = nil, nil
        if StringUtil.indexOf(fromStr, '.') > 0 then
            from = RouteUtil.ip2Long(fromStr)
        else
            from = tonumber(fromStr)
        end
        if StringUtil.indexOf(toStr, '.') > 0 then
            to = RouteUtil.ip2Long(toStr)
        else
            to = tonumber(toStr)
        end

        local upstream = string.sub(ruleStr, upstreamSplitPos + 1)
        if not from or not to or from == -1 or to == -1 or StringUtil.isEmpty(upstream) then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由子规则格式不正确'
        end
        table.insert(result, { range = { from = from, to = to }, upstream = upstream })
    end

    -- 校验规则
    local code, detail = _M.check(result)
    if code == ERR_CODE.SUCCESS then
        return ERR_CODE.SUCCESS, result
    end
    return code, detail
end

--------------------------------------------------------------------------------------
-- 检测IP规则是否符合格式
-- @param rules规则数组
-- 1) 每一个数组项为table，{range = { from = from, to = $to}, upstream = '@upstream'}
-- 2) start、end为IP转换的整形表示，且to必须大于from
-- 3) upstream为不空
-- @return code detail
-- 1) 若不符合格式，detail为错误详细原因
-- 2) 若符合格式
--------------------------------------------------------------------------------------
function _M.check(rules)
    if not next(rules) then
        return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则不能为空'
    end

    table.sort(rules, function(left, right)
        return left['range']['from'] < right['range']['from']
    end)

    local lastToIP = nil
    for _, rule in pairs(rules) do
        local range, upstream = rule['range'], rule['upstream']
        local from, to = range['from'], range['to']

        if StringUtil.isEmpty(upstream) then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则，upstream不能为空，且必须是字符串'
        end
        if from > to then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则，from必须小于to'
        end

        if lastToIP and from <= lastToIP then
            return ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则，不能存在重叠区间'
        end

        lastToIP = to
    end

    return ERR_CODE.SUCCESS
end

return _M