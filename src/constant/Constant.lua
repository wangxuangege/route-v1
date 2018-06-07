module (..., package.seeall)

return {
    -- 路由规则类型
    RULE_TYPE = {

        -- IP规则
        IP_RANGE = "IP_RANGE",

        -- 参数尾规则
        PARAM_TAIL = "PARAM_TAIL",
    },

    -- 路由规则类
    RULE_CLASS_MAP = {
        IP_RANGE = require("rule.IpRangeRule"),
        PARAM_TAIL = require("rule.ParamTailRule")
    }

}