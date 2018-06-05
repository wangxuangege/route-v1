local IPRangeRule = require("rule.IPRangeRule")
local ParamTailRule = require("rule.ParamTailRule")
local RouteContext = require("context.RouteContext")

local function printAll(...)
    local args = { ... }
    for i = 1, #args do
        print(args[i])
    end
end

print('-----------------------------------------------------------------------------------')
local ipRangeRule = IPRangeRule.new("3074337169~3074337174,upstream1|3~5,upstream2|6~7,upstream3")
print(ipRangeRule:toString())

print('-----------------------------------------------------------------------------------')

local paramTailRule = ParamTailRule:new("mid~3~upstream2,000,001,5DD,003,444,007|instMid~5~upstream4,12345,67890", 100)
print(paramTailRule:toString())

print('-----------------------------------------------------------------------------------')
local context = RouteContext:new({
    __TEST__ = {
        ip = "183.62.169.146",
        requestParams = {
            mid = "ABCDEF999000444",
            instMid = "DDDFF33344555DD"
        }
    }
})

local ret1, ret2, ret3 = ipRangeRule:getUpstream(context)
printAll(ret1, ret2, ret3)
print('-----------------------------------------------------------------------------------')
local ret4, ret5, ret6 = paramTailRule:getUpstream(context)
printAll(ret4, ret5, ret6)
print('-----------------------------------------------------------------------------------')