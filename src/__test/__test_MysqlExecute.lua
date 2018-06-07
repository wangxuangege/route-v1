local LogUtil = require("util.LogUtil")
local Mysql = require("respository.mysql.Mysql")
local ERR_CODE = require("constant.ErrCode")

local log = LogUtil:new("测试DB查询")

local mysql = Mysql:create()

local code, detail = mysql:execute(
        -- "delete from route_rule where id=200" -- 删除
        "insert into route_rule(rule_type, rules_str, priority, status, create_time, update_time)values('IP_RANGE', '3074337169~3074337174,upstream1|3~5,upstream2|172.168.1.1~172.168.1.9,upstream3', 122, 'CLOSE', NOW(), NOW())" -- 插入
        -- "insert into route_rule(rule_type, rules_str, priority, status, create_time, update_time)values('PARAM_TAIL', 'mid~3~upstream2,000,001,5DD,003,444,007|instMid~5~upstream4,12345,67890', 20, 'OPEN', NOW(), NOW())" -- 插入
        -- "insert into route_rule(rule_type, rules_str, priority, status, create_time, update_time)values('IP_RANGE', '3074337169~3074337174,upstream1|3~5,upstream2|172.168.1.1~172.168.1.9,upstream3', 1, 'OPEN', NOW(), NOW())" -- 插入
)
if code ~= ERR_CODE.SUCCESS then
    log:warn("操作失败，错误码:", code[1], "，错误原因：", detail)
else
    log:info("操作成功")
end

mysql:release()




