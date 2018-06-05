local LogUtil = require("util.LogUtil")

local log = LogUtil:new("测试日志")
log:debug("我是一条debug日志")
log:info("我是一条info日志")
log:warn("我是一条warn日志")
log:error("我是一条error日志")
