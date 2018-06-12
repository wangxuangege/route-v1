local RouteRuleService = require("respository.service.RouteRuleService")
local LogUtil = require("util.LogUtil")
local StringUtil = require("util.StringUtil")

local log = LogUtil:new("测试路由规则数据库服务类")

local code, detail = RouteRuleService.selectAllRouteRules(false)
log:info("code=", StringUtil.toJSONString(code), ", detail=", StringUtil.toJSONString(detail))

code, detail = RouteRuleService.selectAllRouteRuleSize()
log:info("code=", StringUtil.toJSONString(code), ", detail=", StringUtil.toJSONString(detail))

code, detail = RouteRuleService.selectRouteRuleById(52, false)
log:info("code=", StringUtil.toJSONString(code), ", detail=", StringUtil.toJSONString(detail))

code, detail = RouteRuleService.selectRouteRulesByStatus('OPEN', true)
log:info("code=", StringUtil.toJSONString(code), ", detail=", StringUtil.toJSONString(detail))

code, detail = RouteRuleService.selectRouteRulesByRuleType('IP_RANGE', true)
log:info("code=", StringUtil.toJSONString(code), ", detail=", StringUtil.toJSONString(detail))