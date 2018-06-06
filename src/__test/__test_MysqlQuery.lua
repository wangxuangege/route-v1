local LogUtil = require("util.LogUtil")
local Mysql = require("respository.mysql.Mysql")
local StringUtil = require("util.StringUtil")

local log = LogUtil:new("测试DB查询")

local mysql = Mysql:create()

local flag, info, msg = mysql:query("select * from route_rule")
if not flag then
    log:warn("查询失败，错误原因：", msg, "，错误info:", StringUtil.toJSONString(info))
else
    log:info(StringUtil.toJSONString(info))
end

mysql:release()



