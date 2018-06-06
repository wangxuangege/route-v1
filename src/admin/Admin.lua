--[[
    ngx路由规则配置入口
    操作返回json格式为：
    1）成功，返回 { success: true, code: 'SUCCESS', msg: '成功', model: $model }
    2）失败，返回 { success: false, code: $errCode, msg: $errMsg }
]]--

local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local ERR_CODE = require("constant.ErrCode")

local log = LogUtil:new("ADMIN")

-- 支持的操作命令
local COMMANDS = {
    ADD = require("admin.QueryCommand"),
    DELETE = require("admin.DeleteCommand"),
    QUERY = require("admin.QueryCommand")
}

--------------------------------------------------------------------------------------
-- 获取请求参数中的值
--------------------------------------------------------------------------------------
local function getRequestParams(ngx)
    if not ngx then
        return {}
    end

    if ngx and ngx.__TEST__ then
        return ngx.__TEST__.requestParams or {}
    end

    local requestMethod = ngx.var.request_method
    if "GET" == requestMethod then
        return ngx.req.get_uri_args()
    elseif "POST" == requestMethod then
        ngx.req.read_body()
        return ngx.req.get_post_args()
    end

    return {}
end

--------------------------------------------------------------------------------------
-- 操作完成，响应结果
-- 若运行在ngx上面，那么填充response，若运行在本地，直接输出日志即可
--------------------------------------------------------------------------------------
local function callback(ngx, errInfo, ret)
    local result = {}
    if errInfo == ERR_CODE.SUCCESS then
        result.success = true
        result.code = errInfo[1]
        result.msg = errInfo[2]
        result.data = ret
    else
        result.success = false
        result.code = errInfo[1]
        result.msg = ret
    end

    if ngx and ngx.__TEST__ then
        log:info(StringUtil.toJSONString(result))
        return
    end

    if ngx then
        ngx.say(StringUtil.toJSONString(result))
        ngx.exit(200)
    end
end

--------------------------------------------------------------------------------------
-- 入口方法
-- 1. 解析请求命令
-- 2. 判断参数是否合法
-- 3. 执行业务动作
-- 4. 反馈结果
--------------------------------------------------------------------------------------
local function admin(ngx)
    local requestParams = getRequestParams(ngx)
    local command = requestParams['command']

    if StringUtil.isEmpty(command) then
        callback(ngx, ERR_CODE.ADMIN_PARAM_ERROR, '操作命令不能为空')
        return
    end

    local commandInvoker = COMMANDS[command]
    if not commandInvoker then
        callback(ngx, ERR_CODE.ADMIN_PARAM_ERROR, '操作命令不存在')
        return
    end

    if type(commandInvoker.invoke) ~= 'function' then
        callback(ngx, ERR_CODE.ADMIN_INNER_ERROR, '命令执行器没有找到执行模块')
        return
    end

    -- 详细校验参数
    if type(commandInvoker.checkParams) == 'function' then
        local info, errMsg = commandInvoker.checkParams(requestParams)
        if info ~= ERR_CODE.SUCCESS then
            callback(ngx, info, errMsg)
            return
        end
    end

    -- 执行命令
    local errInfo, ret = commandInvoker.invoke(requestParams)
    callback(ngx, errInfo, ret)
end

-- 执行入口方法
admin(ngx)
