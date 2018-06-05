local ParamTailRule = require("rule.ParamTailRule")
local RouteContext = require("context.RouteContext")

local paramTailRule = ParamTailRule:new("mid~3~upstream2,000,001,5DD,003,444,007|instMid~5~upstream4,12345,67890", 100)
print("打印规则：", string.toJSONString(paramTailRule))


local context = RouteContext:new({
    __TEST__ = {
        requestParams = {
            mid = "ABCDEF999000444",
            instMid = "DDDFF33344555DD"
        }
    }
})
local ret1, ret2, ret3 = paramTailRule:getUpstream(context)
print("解析规则：", "ret1=", ret1, ",ret2=", string.toJSONString(ret2))
if ret1 then
    print("命中的规则：", string.toJSONString(ret3))
end
