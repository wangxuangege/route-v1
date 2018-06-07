local IPRangeRule = require("rule.IPRangeRule")
local RouteContext = require("context.RouteContext")
local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local ERR_CODE = require("constant.ErrCode")

local log = LogUtil:new("测试IP规则")

local ipRangeRule = IPRangeRule:new("3074337169~3074337174,upstream1|3~5,upstream2|172.168.1.1~172.168.1.9,upstream3")
local context = RouteContext:new({
    __TEST__ = {
        ip = "183.62.169.146"
    }
})
local code, detail = ipRangeRule:getUpstream(context)
if code ~= ERR_CODE.SUCCESS then
    log:warn("获取失败，错误码:", code[1], "，错误原因：", detail)
else
    log:info("获取成功", StringUtil.toJSONString(detail))
end

local json = require("json")
local copyNew = IPRangeRule:copy(json.decode(json.encode(ipRangeRule)))
local code, detail = copyNew:getUpstream(context)
if code ~= ERR_CODE.SUCCESS then
    log:warn("获取失败，错误码:", code[1], "，错误原因：", detail)
else
    log:info("获取成功", StringUtil.toJSONString(detail))
end