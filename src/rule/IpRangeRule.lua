--[[
    IP路由规则
]]--
local _M = {
    _VERSION = "0.0.1"
}

require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local RouteUtil = require("util.RouteUtil")

--------------------------------------------------------------------------------------
-- IP路由规则构造方法
-- @param rulesStr 规则字符串
-- @return 返回构造好的IP规则对象
-- 类成员变量:
-- rulesStr: 规则字符串
-- effective: 规则是否有效
-- priority: 优先级（整数）
-- rules: 规则
-- errInfo: 若规则无效，里面存放无效的错误码信息
-- errMsg: 若规则无效，存放无效规则的详细原因
--------------------------------------------------------------------------------------
function _M:new(rulesStr, priority)
    self = {}

    self.rulesStr = rulesStr
    self.priority = tonumber(priority)
    if not self.priority then
        self.priority = 1
    end
    if self.priority <= 0 then
        self.priority = 1
    end

    local effective, info, msg = _M.parse(rulesStr)
    self.effective = effective
    if (self.effective) then
        self.rules = info
    else
        self.errInfo = info
        self.errMsg = msg
        self.priority = 0
    end

    return setmetatable(self, { __index = _M })
end

--------------------------------------------------------------------------------------
-- 获取路由upstream
-- @param context 路由上下文对象
-- @return
-- 1) 首先判断规则是否有效，若规则无效，则返回false, errInfo, errMsg
-- 2) 若路由计算成功，返回true, upstream, rule
--------------------------------------------------------------------------------------
function _M:getUpstream(context)
    if not self.effective then
        return false, ERR_CODE.RULE_UN_EFFECTIVE, '规则无效，计算路由失败'
    end

    if not context.longIP or context.longIP < 0 then
        return false, ERR_CODE.CONTEXT_UNDEFINE_PARAM, '路由上下文中获取IP非法，计算路由失败'
    end

    for _, rule in pairs(self.rules) do
        local range, upstream = rule.range, rule.upstream
        local from, to = range.from, range.to
        if from <= context.longIP and context.longIP <= to then
            return true, upstream, rule
        end
    end

    return false, ERR_CODE.RULE_UN_HIT, '没有命中任何规则'
end

--------------------------------------------------------------------------------------
-- 将规则字符串转换为IP规则
-- @param rulesStr规则数组
-- 1) rulesStr格式为from1~to1,upstream1|from2~to2,upstream2|......
-- 2) 转换为{range = { from = from, to = $to}, upstream = '@upstream'}每条格式后，然后校验IP规则是否有效
-- @return 解析结果
-- 1) 若不符合格式，则返回{false, err_info, err_msg}，其中err_info格式为{err_code, err_msg}
-- 2) 若符合格式，则返回{true}
--------------------------------------------------------------------------------------
function _M.parse(rulesStr)
    if string.isEmpty(rulesStr) then
        return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则不能为空'
    end

    -- 解析规则
    local ruleStrArray = string.split(rulesStr, "|")
    if not next(ruleStrArray) then
        return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则不能为空'
    end

    local result = {}
    for _, ruleStr in pairs(ruleStrArray) do
        if string.isEmpty(ruleStr) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则存在空的子规则'
        end

        local ipSplitPos, _ = string.find(ruleStr, '~')
        if not ipSplitPos then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由子规则格式不正确'
        end

        local upstreamSplitPos, _ = string.find(ruleStr, ',', ipSplitPos)
        if not upstreamSplitPos then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由子规则格式不正确'
        end

        -- 解析IP地址，IP地址可以是整形也可以是标准形
        local fromStr = string.sub(ruleStr, 1, ipSplitPos - 1)
        local toStr = string.sub(ruleStr, ipSplitPos + 1, upstreamSplitPos - 1)
        local from, to = nil, nil
        if string.indexOf(fromStr, '.') > 0 then
            from = RouteUtil.ip2Long(fromStr)
        else
            from = tonumber(fromStr)
        end
        if string.indexOf(toStr, '.') > 0 then
            to = RouteUtil.ip2Long(toStr)
        else
            to = tonumber(toStr)
        end

        local upstream = string.sub(ruleStr, upstreamSplitPos + 1)
        if not from or not to or from == -1 or to == -1 or string.isEmpty(upstream) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由子规则格式不正确'
        end
        table.insert(result, { range = { from = from, to = to }, upstream = upstream })
    end

    -- 校验规则
    local ret, info, msg = _M.check(result)
    if ret then
        return true, result
    end
    return ret, info, msg
end

--------------------------------------------------------------------------------------
-- 检测IP规则是否符合格式
-- @param rules规则数组
-- 1) 每一个数组项为table，{range = { from = from, to = $to}, upstream = '@upstream'}
-- 2) start、end为IP转换的整形表示，且to必须大于from
-- 3) upstream为不空
-- @return 规则是否符合规范
-- 1) 若不符合格式，则返回false, err_info, err_msg，其中err_info格式为{err_code, err_msg}
-- 2) 若符合格式，则返回true
--------------------------------------------------------------------------------------
function _M.check(rules)
    if not next(rules) then
        return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则不能为空'
    end

    table.sort(rules, function(left, right)
        return left['range']['from'] < right['range']['from']
    end)

    local lastToIP = nil
    for _, rule in pairs(rules) do
        local range, upstream = rule['range'], rule['upstream']
        local from, to = range['from'], range['to']

        if string.isEmpty(upstream) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则，upstream不能为空，且必须是字符串'
        end
        if from > to then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则，from必须小于to'
        end

        if lastToIP and from <= lastToIP then
            return false, ERR_CODE.RULE_FORMAT_ERROR, 'IP路由规则，不能存在重叠区间'
        end

        lastToIP = to
    end

    return true
end

return _M