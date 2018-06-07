--[[
    全局配置文件
]]--
module (..., package.seeall)

return {

    -- DEBUG模式
    DEBUG = true,

    -- 默认路由
    DEFAULT_UPSTREAM = "stable",

    -- 日志级别
    -- DEBUG=4,INFO=3,WARN=2,ERR=1,关闭日志=0
    LOG_LEVEL = 4,

    -- 允许规则的最大条目
    ALLOW_RULE_SIZE = 30,

    -- mysql配置
    MYSQL_ADDRESS = "192.168.195.128",
    MYSQL_DB = "route",
    MYSQL_USER = "root",
    MYSQL_PWD = "root",
    MYSQL_PORT = 3306,
    MYSQL_CHARSET = "UTF8",

}