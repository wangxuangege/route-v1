module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local RouteRuleService = require("respository.service.RouteRuleService")

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    return RouteRuleService.deleteRouteRuleById(requestParams['id'])
end

--------------------------------------------------------------------------------------
-- 判断参数是否合法
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local id = requestParams['id']

    if StringUtil.isEmpty(id) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '必须指定要删除的规则主键'
    end

    if not tonumber(id) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '找不到要删除的主键'
    end

    return ERR_CODE.SUCCESS
end