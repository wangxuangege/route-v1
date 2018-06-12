module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local RouteRuleService = require("respository.service.RouteRuleService")

-- 请求参数type允许的类型
local TYPES = {
    ALL = RouteRuleService.selectAllRouteRules,
    ID = RouteRuleService.selectRouteRuleById,
    RULE_TYPE = RouteRuleService.selectRouteRulesByRuleType,
    STATUS = RouteRuleService.selectRouteRulesByStatus
}

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    return TYPES[requestParams['type']](requestParams['value'], false);
end

--------------------------------------------------------------------------------------
-- 判断参数是否合法
-- 返回errInfo, errMsg
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local type = requestParams['type']
    if StringUtil.isEmpty(type) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '查询条件中type不能为空'
    end

    if not TYPES[type] then
        return ERR_CODE.ADMIN_PARAM_ERROR, '查询条件中type非法'
    end

    if type ~= 'ALL' and StringUtil.isEmpty(requestParams['value']) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '查询条件type非All时，value不能为空'
    end

    return ERR_CODE.SUCCESS
end