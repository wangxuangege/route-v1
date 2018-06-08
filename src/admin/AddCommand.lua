module(..., package.seeall);

local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local Mysql = require("respository.mysql.Mysql")
local LogUtil = require("util.LogUtil")
local CONSTANT = require("constant.Constant")
local Config = require("constant.Config")
local ArrayUtil = require("util.ArrayUtil")

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

    -- 查询目前规则总数
    local code, detail = mysql:query(
            string.format("select count(*) as num from route_rule"), true)
    if code ~= ERR_CODE.SUCCESS then
        log:warn("查询失败，错误原因：", detail)
        return code, "查询规则总数失败，规则总数会被限制，无法确认是否允许添加规则"
    end
    local num = 0
    if next(detail) then
        num = tonumber(detail[1]['NUM'])
        if num and num >= Config.ALLOW_RULE_SIZE then
            return ERR_CODE.ADMIN_BUSINESS_LIMIT, '路由限制规则最多只允许' .. Config.ALLOW_RULE_SIZE .. '条规则'
        end
    end

    -- 添加规则
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

    return ERR_CODE.SUCCESS
end