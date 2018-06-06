local LogUtil = require("util.LogUtil")
local Mysql = require("respository.mysql.Mysql")

local log = LogUtil:new("测试DB查询")

local mysql = Mysql:create()

local flag, info, msg = mysql:query("select * from route_rule")
if not flag then
    log:warn("查询失败，错误原因：", msg, "，错误info:", string.toJSONString(info))
else
    log:info(string.toJSONString(info))
end

mysql:release()



