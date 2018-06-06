local IPRangeRule = require("rule.IPRangeRule")
local RouteContext = require("context.RouteContext")

local ipRangeRule = IPRangeRule:new("3074337169~3074337174,upstream1|3~5,upstream2|172.168.1.1~172.168.1.9,upstream3")
print("打印规则：", string.toJSONString(ipRangeRule))

local context = RouteContext:new({
    __TEST__ = {
        ip = "183.62.169.146"
    }
})
local ret1, ret2, ret3 = ipRangeRule:getUpstream(context)
print("解析规则：", "ret1=", ret1, ",ret2=", string.toJSONString(ret2))
if ret1 then
    print("命中的规则：", string.toJSONString(ret3))
end
