--[[
    提供rule一些公用方法
]]--

module(..., package.seeall);

--------------------------------------------------------------------------------------
-- 路由规则构造方法
-- @param self 需要构造的对象
-- @param ruleType 规则类型
-- @param rulesStr 规则字符串
-- @param priority 优先级
-- @param func 类对象（主要需要方法）
-- @return 返回构造好的规则对象
-- 类成员变量:
-- ruleType: 规则类型
-- rulesStr: 规则字符串
-- effective: 规则是否有效
-- priority: 优先级（整数）
-- rules: 规则
-- errInfo: 若规则无效，里面存放无效的错误码信息
-- errMsg: 若规则无效，存放无效规则的详细原因
--------------------------------------------------------------------------------------
function build(self, ruleType, rulesStr, priority, func)
    self = {}

    self.ruleType = ruleType
    self.rulesStr = rulesStr
    self.priority = tonumber(priority)
    if not self.priority then
        self.priority = 1
    end
    if self.priority <= 0 then
        self.priority = 1
    end

    local effective, info, msg = func.parse(rulesStr)
    self.effective = effective
    if (self.effective) then
        self.rules = info
    else
        self.errInfo = info
        self.errMsg = msg
        self.priority = 0
    end

    return setmetatable(self, { __index = func })
end
