local ParamTailRule = require("rule.ParamTailRule")
local RouteContext = require("route.RouteContext")
local StringUtil = require("util.StringUtil")
local ERR_CODE = require("constant.ErrCode")
local LogUtil = require("util.LogUtil")

local log = LogUtil:new("测试参数尾规则")

local paramTailRule = ParamTailRule:new("mid~3~upstream1,000,001,002,003", 100)
local context = RouteContext:build({
    __TEST__ = {
        requestParams = {
            mid = "342342000"
        }
    }
})

local code, detail = paramTailRule:getUpstream(context)
if code ~= ERR_CODE.SUCCESS then
    log:warn("获取失败，错误码:", code[1], "，错误原因：", detail)
else
    log:info("获取成功", StringUtil.toJSONString(detail))
end

local json = require("json")
local copyNew = ParamTailRule:copy(json.decode(json.encode(paramTailRule)))
local code, detail = copyNew:getUpstream(context)
if code ~= ERR_CODE.SUCCESS then
    log:warn("获取失败，错误码:", code[1], "，错误原因：", detail)
else
    log:info("获取成功", StringUtil.toJSONString(detail))
end
