module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local Mysql = require("respository.mysql.Mysql")
local LogUtil = require("util.LogUtil")
local CONSTANT = require("constant.Constant")

local log = LogUtil:new("ADD")

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    local priority = tonumber(requestParams['priority'])
    if priority then
        priority = 1
    end

    local ruleType = requestParams['ruleType']
    local rule = CONSTANT.RULE_CLASS_MAP[ruleType]

    local rulesStr = requestParams['rulesStr']
    local code, detail = rule.parse(rulesStr)
    if code ~= ERR_CODE.SUCCESS then
        return code, detail
    end

    -- 如果规则解析成功，那么保存
    local mysql = Mysql:create()

    local code, detail = mysql:execute(string.format([[
                insert into route_rule(rule_type, rules_str, priority, status, create_time, update_time)
                values('%s', '%s', %s, '%s', NOW(), NOW())
            ]], ruleType, rulesStr, priority, 'OPEN'))

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
-- ruleType：规则类型
-- rulesStr：规则字符串
-- priority: 优先级（若不为空，那么必须为正正数）
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local ruleType = requestParams['ruleType']
    local rulesStr = requestParams['rulesStr']
    local priority = requestParams['priority']

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

    return ERR_CODE.SUCCESS
end