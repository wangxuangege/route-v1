module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local Mysql = require("respository.mysql.Mysql")
local LogUtil = require("util.LogUtil")
local CONSTANT = require("constant.Constant")
local ArrayUtil = require("util.ArrayUtil")

local log = LogUtil:new("UPDATE")

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    local ruleType = requestParams['ruleType']
    local rule = CONSTANT.RULE_CLASS_MAP[ruleType]

    local rulesStr = requestParams['rulesStr']
    local code, detail = rule.parse(rulesStr)
    if code ~= ERR_CODE.SUCCESS then
        return code, detail
    end

    -- 如果规则解析成功，那么保存
    local mysql = Mysql:create()

    -- 查询目前规则总数
    local code, detail = mysql:query(
            string.format("select count(*) as num from route_rule where id=%s", id), true)
    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, "判断规则是否存在异常，无法确认规则是否存在，无法更新"
    end

    local num = 0
    if next(detail) then
        num = tonumber(detail[1]['NUM'])
        if num == 0 then
            return ERR_CODE.ADMIN_UN_FIND_RULE, '路由规则不存在，无法更新'
        end
    end

    -- 更新规则
    local code, detail = mysql:execute(string.format([[
                update route_rule
                set rules_str = '%s', status = '%s', priority = %s, update_time = NOW()
                where id=%s
            ]], rulesStr, requestParams['status'], requestParams['priority'], requestParams['id']))

    if code ~= ERR_CODE.SUCCESS then
        log:warn("规则添加失败，错误码:", code[1], "，错误原因：", detail)
        return code, "规则添加成功"
    end

    mysql:release()

    return ERR_CODE.SUCCESS

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

    if StringUtil.isEmpty(status) or ArrayUtil.contain({ "OPEN", "CLOSE" }, status) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '规则状态不能为空，且必须为OPEN或CLOSE'
    end

    return ERR_CODE.SUCCESS
end