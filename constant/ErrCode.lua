--[[
    全局错误码
]]--
local _M = {
    _VERSION = '0.0.1'
}

local errCode = {
    SUCCESS = { 0, '成功 ' },

    RULE_FORMAT_ERROR = { 1, '规则格式错误 ' },

    RULE_UN_EFFECTIVE = { 2, '规则无效 ' },
    RULE_UN_HIT = { 3, '规则没有命中' },

    CONTEXT_UNDEFINE_PARAM = { 4, '路由上下文参数不明确，无法计算路由' },

    UNKNOWN_ERROR = { -1, '未知异常 ' },
}

setmetatable(_M, { __index = errCode })

return _M
