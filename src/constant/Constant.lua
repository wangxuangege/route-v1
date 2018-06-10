module(..., package.seeall)

return {
    -- 路由规则类
    RULE_CLASS_MAP = {
        IP_RANGE = require("rule.IpRangeRule"),
        PARAM_TAIL = require("rule.ParamTailRule")
    }
}