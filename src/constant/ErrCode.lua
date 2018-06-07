--[[
    全局错误码
]]--
module (..., package.seeall)

local _M = {
    _VERSION = '0.0.1'
}

local errCode = {
    SUCCESS = { 0, '成功 ' },

    RULE_FORMAT_ERROR = { 10001, '规则格式错误 ' },

    RULE_UN_EFFECTIVE = { 20001, '规则无效 ' },
    RULE_UN_HIT = { 20002, '规则没有命中' },

    CONTEXT_UNDEFINE_PARAM = { 30001, '路由上下文参数不明确，无法计算路由' },

    DB_PARAM_ERROR = { 40001, '数据库操作参数问题' },
    DB_INIT_ERROR = { 40002, '数据库操作初始化异常' },
    DB_CURSOR_ERROR = { 40003, '数据库操作出现异常' },

    ADMIN_PARAM_ERROR = { 50001, '路由规则管理操作参数问题' },
    ADMIN_INNER_ERROR = { 50002, '命令实现内部错误' },
    ADMIN_BUSINESS_LIMIT = { 50003, '业务限制' },

    UNKNOWN_ERROR = { 99999, '未知异常 ' },
}

setmetatable(_M, { __index = errCode })

return _M
