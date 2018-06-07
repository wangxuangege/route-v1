--[[
    封装mysql数据库的操作
]]--
module (..., package.seeall)

local _M = {
    _VERSION = "0.0.1"
}
local CONFIG = require("constant.Config")
local LogUtil = require("util.LogUtil")
local ERR_CODE = require("constant.ErrCode")
local StringUtil = require("util.StringUtil")
local RouteUtil = require("util.RouteUtil")

local log = LogUtil:new("MYSQL")

--------------------------------------------------------------------------------------
-- 创建一个数据库可操作对象
-- 若创建失败，那么类的可用状态设置为false
-- 类的成员变量如下：
-- available：数据库是否可用
-- errInfo: 若数据库不可用，初始化errInfo
-- errMsg: 若数据库不可用，错误信息
--------------------------------------------------------------------------------------
function _M:create()
    local mysql = require("luasql.mysql")

    self = {}

    -- 默认不可用，初始化完全后置为true
    self.available = false

    local env = mysql.mysql()
    if env == nil then
        self.errInfo = ERR_CODE.DB_INIT_ERROR
        self.errMsg = 'mysql环境获取失败，无法进行数据库操作'
        log:error(self.errMsg)
        return
    end
    self.env = env

    local connect = self.env:connect(CONFIG.MYSQL_DB, CONFIG.MYSQL_USER, CONFIG.MYSQL_PWD, CONFIG.MYSQL_ADDRESS, CONFIG.MYSQL_PORT)
    if connect == nil then
        self.errInfo = ERR_CODE.DB_INIT_ERROR
        self.errMsg = 'mysql数据库连接创建失败，无法进行数据库操作'
        log:error(self.errMsg)
        return
    end
    self.connect = connect

    -- 初始化环境和连接成功
    self.available = true

    return setmetatable(self, { __index = _M })
end

--------------------------------------------------------------------------------------
-- 创建和释放应该成对出现
--------------------------------------------------------------------------------------
function _M:release(env, connect)
    if self.connect ~= nil then
        self.connect:close()
    end
    if self.env ~= nil then
        self.env:close()
    end
    self.available = false
end

--------------------------------------------------------------------------------------
-- 数据库查询
-- @param 查询sql
-- @param 查询结果映射
-- @return code detail
-- 1) 若数据库查询成功，detail为查询的结果
-- 2) 若数据库查询失败，detail为失败的原因
--------------------------------------------------------------------------------------
function _M:query(sql, option)
    if not self.available then
        return ERR_CODE.DB_INIT_ERROR, '数据库初始化失败，不能进行数据库操作'
    end

    if StringUtil.isEmpty(sql) then
        return ERR_CODE.DB_PARAM_ERROR, '数据库查询sql不能为空'
    end

    local cursor, errorString = self.connect:execute(sql)
    if nil ~= errorString then
        log:error("数据库查询失败")
        return ERR_CODE.DB_CURSOR_ERROR, '数据库查询失败'
    end

    local row = cursor:fetch({}, "a")
    if -1 == row then
        -- 数据库查询记录为空
        return ERR_CODE.SUCCESS, {}
    else
        local result = {}
        while row do
            table.insert(result, RouteUtil.copyData(row, option))
            row = cursor:fetch(row, "a")
        end
        return ERR_CODE.SUCCESS, result
    end
end

--------------------------------------------------------------------------------------
-- 数据库增删改
-- @param 增删改的sql
-- @return code detail
-- 1) 若数据库查询成功
-- 2) 若数据库查询失败，detail为失败的原因
--------------------------------------------------------------------------------------
function _M:execute(sql)
    if not self.available then
        return  ERR_CODE.DB_INIT_ERROR, '数据库初始化失败，不能进行数据库操作'
    end

    if StringUtil.isEmpty(sql) then
        return false, ERR_CODE.DB_PARAM_ERROR, '数据库查询sql不能为空'
    end

    local cursor, errorString = self.connect:execute(sql)
    if nil ~= errorString then
        log:error("数据库操作失败")
        return ERR_CODE.DB_CURSOR_ERROR, '数据库操作失败'
    end

    return ERR_CODE.SUCCESS
end

return _M