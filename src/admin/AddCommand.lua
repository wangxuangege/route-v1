module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local CONSTANT = require("constant.Constant")
local Config = require("constant.Config")
local ArrayUtil = require("util.ArrayUtil")
local RouteRuleService = require("respository.service.RouteRuleService")

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    local priority = tonumber(requestParams['priority'])
    if priority then
        priority = 1
    end

    -- 查询目前规则总数
    local code, detail = RouteRuleService.selectAllRouteRuleSize()
    if code ~= ERR_CODE.SUCCESS then
        return code, "查询规则总数失败，规则限制总数" .. Config.ALLOW_RULE_SIZE .. "，无法确认是否超过，添加规则失败"
    elseif detail > Config.ALLOW_RULE_SIZE then
        return ERR_CODE.ALLOW_RULE_SIZE, "添加规则失败，规则限制总数为" .. Config.ALLOW_RULE_SIZE
    end

    return RouteRuleService.insertRouteRule({ ruleType = requestParams['ruleType'], rulesStr = requestParams['rulesStr'], priority = priority, status = 'OPEN' })
end

--------------------------------------------------------------------------------------
-- 判断参数是否合法
-- 添加规则需要判断如下参数
-- ruleType：规则类型
-- rulesStr：规则字符串
-- status：状态
-- priority: 优先级（若不为空，那么必须为正正数）
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local ruleType = requestParams['ruleType']
    local rulesStr = requestParams['rulesStr']
    local priority = requestParams['priority']
    local status = requestParams['status']

    if StringUtil.isEmpty(ruleType)
            or not CONSTANT.RULE_CLASS_MAP[ruleType] then
        return ERR_CODE.ADMIN_PARAM_ERROR, '规则类型不合法'
    end

    if StringUtil.isEmpty(rulesStr) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '规则逻辑串不能为空'
    end

    if not StringUtil.isEmpty(priority) and not tonumber(priority) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '优先级不合法'
    end

    if StringUtil.isEmpty(status) or not ArrayUtil.contain({ "OPEN", "CLOSE" }, status) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '规则状态不能为空，且必须为OPEN或CLOSE'
    end

    local code, detail = CONSTANT.RULE_CLASS_MAP[ruleType].parse(rulesStr)
    if code ~= ERR_CODE.SUCCESS then
        return code, detail
    end

    return ERR_CODE.SUCCESS
end