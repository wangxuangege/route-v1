--[[
    请求参数末尾匹配规则
]]--
local _M = {
    _VERSION = "0.0.1"
}

require("util.StringUtil")
local ArrayUtil = require("util.ArrayUtil")
local ERR_CODE = require("constant.ErrCode")
local CONSTANT = require("constant.Constant")
local RouteUtil = require("util.RouteUtil")
local BaseRule = require("rule.BaseRule")

--------------------------------------------------------------------------------------
-- IP路由规则构造方法
-- @param rulesStr 规则字符串
-- @return 构造好的参数末尾匹配规则
-- 类成员变量:
-- rulesStr: 规则字符串
-- effective: 规则是否有效
-- priority: 优先级（整数）
-- rules: 规则
-- errInfo: 若规则无效，里面存放无效的错误码信息
-- errMsg: 若规则无效，存放无效规则的详细原因
--------------------------------------------------------------------------------------
function _M:new(rulesStr, priority)
    return BaseRule:build(CONSTANT.RULE_TYPE.PARAM_TAIL, rulesStr, priority, _M)
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
-- @return
-- 1) 首先判断规则是否有效，若规则无效，则返回false, errInfo, errMsg
-- 2) 若路由计算成功，返回true, upstream, rule
--------------------------------------------------------------------------------------
function _M:getUpstream(context)
    if not self.effective then
        return false, ERR_CODE.RULE_UN_EFFECTIVE, '规则无效，计算路由失败'
    end

    local requestParams = context.requestParams
    for _, rule in pairs(self.rules) do
        local paramKey, length, upstream, tails = rule['paramKey'], rule['length'], rule['upstream'], rule['tails']
        local paramValue = requestParams[paramKey]

        -- 只有获取请求参数value不空时候，并且value的值大于长度才会去判断
        if not string.isEmpty(paramValue) and #paramValue >= length then
            local tailValue = string.sub(paramValue, #paramValue - length + 1)
            if ArrayUtil.contain(tails, tailValue) then
                return true, upstream, rule
            end
        end

    end

    return false, ERR_CODE.RULE_UN_HIT, '没有命中任何规则'
end

--------------------------------------------------------------------------------------
-- 将规则字符串转换为参数末尾匹配规则
-- @param rulesStr规则数组
-- 1) rulesStr格式为paramKey~length~upstream,tail1,tail2,tail3......|paramKey~length~upstream,tail1,tail2,tail3...
-- 2) 每一个子规则对应的tail1,tail2,tail3...必须长度为length，需要保证length+upstream必须唯一，不允许配置多余的规则
-- 2) 转换为{paramKey = $paramKey, length = $length, upstream = '@upstream', tails = {tail1, tail2, ...}}格式后，转换后需要校验规则是否有效
-- @return 解析结果
-- 1) 若不符合格式，则返回{false, err_info, err_msg}，其中err_info格式为{err_code, err_msg}
-- 2) 若符合格式，则返回{true}
--------------------------------------------------------------------------------------
function _M.parse(rulesStr)
    if string.isEmpty(rulesStr) then
        return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配规则不能为空'
    end

    -- 解析规则
    local ruleStrArray = string.split(rulesStr, "|")
    if not next(ruleStrArray) then
        return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配规则不能为空'
    end

    local result = {}
    for _, ruleStr in pairs(ruleStrArray) do
        if string.isEmpty(ruleStr) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配规则存在空的子规则'
        end

        local strArray = string.split(ruleStr, ',')
        if not next(ruleStrArray) or #strArray < 2 then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配子规则格式不正确'
        end

        -- 第1个分割出来的一定是paramKey~length~upstream
        local splitArray = string.split(strArray[1], '~')
        if not next(ruleStrArray) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配规则不能为空'
        end

        local paramKey = splitArray[1]
        local length = tonumber(splitArray[2])
        local upstream = splitArray[3]
        if string.isEmpty(paramKey) or not length or string.isEmpty(upstream) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配子规则格式不正确'
        end

        -- 第2个开始，后面所有的都是tail尾
        local tails = {}
        for i = 2, #strArray do
            local tail = strArray[i]
            if string.isEmpty(tail) or #tail ~= length then
                return false, ERR_CODE.RULE_FORMAT_ERROR, '参数末尾匹配子规则格式不正确'
            end
            table.insert(tails, tail)
        end

        table.insert(result, { paramKey = paramKey, upstream = upstream, length = length, tails = tails })
    end

    -- 存放的自规则按照length降序排序
    -- 匹配规则时候会选中匹配最细的规则
    table.sort(result, function(left, right)
        return left.length > right.length
    end)

    -- 校验规则
    local ret, info, msg = _M.check(result)
    if ret then
        return true, result
    end
    return ret, info, msg
end

--------------------------------------------------------------------------------------
-- 校验尾部规则是否有效
-- @param rules规则数组
-- 1) 每一个数组项为table，{ upstream = $upstream, length = $length, tails = {tail1, tail2} }
-- 2) tail长度必须为length，且不能重复，upstream+length组成的key，也不允许重复
-- 3) upstream为不空，length为整数
-- @return 规则是否符合规范
-- 1) 若不符合格式，则返回false, err_info, err_msg，其中err_info格式为{err_code, err_msg}
-- 2) 若符合格式，则返回true
--------------------------------------------------------------------------------------
function _M.check(rules)
    if not next(rules) then
        return false, ERR_CODE.RULE_FORMAT_ERROR, '参数尾部规则不能为空'
    end

    -- 用来限制upstream+length限制必须唯一
    local upstreamAndLengthSet = {}
    -- 用来限制tail不能重复
    local tailSet = {}

    for _, rule in pairs(rules) do
        local length, upstream, tails = rule['length'], rule['upstream'], rule['tails']

        if string.isEmpty(upstream) then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数尾部规则，upstream不能为空，且必须是字符串'
        end

        if type(length) ~= 'number' then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数尾部规则，length必须为整数'
        end

        local upstreamAndLength = upstream .. length
        if upstreamAndLengthSet[upstreamAndLength] then
            return false, ERR_CODE.RULE_FORMAT_ERROR, '参数尾部规则，upstream+length必须唯一'
        end

        for i = 1, #tails do
            local tail = tails[i]
            if string.isEmpty(tail) or #tail ~= length then
                return false, ERR_CODE.RULE_FORMAT_ERROR, '参数尾部规则，tail不能为空，且长度必须等于length'
            end
            if tailSet[tail] then
                return false, ERR_CODE.RULE_FORMAT_ERROR, '参数尾部规则，tail必须唯一'
            end
        end

        ArrayUtil.insert(tails, tails)
        table.insert(upstreamAndLengthSet, upstreamAndLength)
    end

    return true
end

return _M