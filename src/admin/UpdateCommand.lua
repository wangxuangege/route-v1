module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local CONSTANT = require("constant.Constant")
local ArrayUtil = require("util.ArrayUtil")
local RouteRuleService = require("respository.service.RouteRuleService")

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    local code, detail = RouteRuleService.selectRouteRuleById(requestParams['id'], false)
    if code ~= ERR_CODE.SUCCESS then
        return code, "查询路由规则失败，无法确认规则是否存在，更新失败"
    else
        if not next(detail) then
            return ERR_CODE.ADMIN_UN_FIND_RULE, '路由规则不存在，无法更新'
        end
    end
    -- 更新规则
    return RouteRuleService.updateRouteRule(requestParams);
end

--------------------------------------------------------------------------------------
-- 判断参数是否合法
-- 添加规则需要判断如下参数
-- id： 主键
-- ruleType：规则类型
-- rulesStr：规则字符串
-- status：状态
-- priority: 优先级（若不为空，那么必须为正正数）
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local id = requestParams['id']
    local ruleType = requestParams['ruleType']
    local rulesStr = requestParams['rulesStr']
    local priority = requestParams['priority']
    local status = requestParams['status']

    if StringUtil.isEmpty(id) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '规则主键不能为空'
    end

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

    -- 判断规则字符串是否有效
    local code, detail = CONSTANT.RULE_CLASS_MAP[ruleType].parse(rulesStr)
    if code ~= ERR_CODE.SUCCESS then
        return code, detail
    end

    return ERR_CODE.SUCCESS
end