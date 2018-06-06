module(..., package.seeall);

require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local Mysql = require("respository.mysql.Mysql")
local LogUtil = require("util.LogUtil")

local log = LogUtil:new("QUERY")

-- 请求参数type允许的类型
local TYPES = {
    ALL = "where 1=1",
    ID = "where id=%s",
    RULE_TYPE = "where rule_type='%s'",
    STATUS = "where status='%s'"
}

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    local type = requestParams['type']
    local where = TYPES[type]
    if type ~= 'ALL' then
        where = string.format(where, requestParams['value'])
    end

    local mysql = Mysql:create()
    local flag, info, msg = mysql:query(
            string.format("select * from route_rule " .. where))

    if not flag then
        log:warn("查询失败，错误原因：", msg, "，错误info:", string.toJSONString(info))
        return info, "数据库查询失败"
    else
        return ERR_CODE.SUCCESS, info
    end

end

--------------------------------------------------------------------------------------
-- 判断参数是否合法
-- 返回errInfo, errMsg
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local type = requestParams['type']
    if string.isEmpty(type) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '查询条件中type不能为空'
    end

    if not TYPES[type] then
        return ERR_CODE.ADMIN_PARAM_ERROR, '查询条件中type非法'
    end

    if type ~= 'ALL' and string.isEmpty(requestParams['value']) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '查询条件type非All时，value不能为空'
    end

    return ERR_CODE.SUCCESS
end