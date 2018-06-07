local LogUtil = require("util.LogUtil")
local Mysql = require("respository.mysql.Mysql")
local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")

local log = LogUtil:new("测试DB查询")

local mysql = Mysql:create()

local code, detail = mysql:query("select * from route_rule")
if code ~= ERR_CODE.SUCCESS then
    log:warn("查询失败，错误码:", code[1], "，错误原因：", detail)
else
    log:info("结果为：", StringUtil.toJSONString(detail))
end

mysql:release()



