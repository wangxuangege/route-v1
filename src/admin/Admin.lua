--[[
    ngx路由规则配置入口
    操作返回json格式为：
    1）成功，返回 { success: true, code: 'SUCCESS', msg: '成功', model: $model }
    2）失败，返回 { success: false, code: $errCode, msg: $errMsg }
]]--

local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local ERR_CODE = require("constant.ErrCode")
local NgxUtil = require("util.NgxUtil")
local CONFIG = require("constant.Config")

local log = LogUtil:new("ADMIN")

-- 支持的操作命令
local COMMANDS = {
    ADD = require("admin.AddCommand"),
    DELETE = require("admin.DeleteCommand"),
    QUERY = require("admin.QueryCommand")
}

--------------------------------------------------------------------------------------
-- 操作完成，响应结果
-- 若运行在ngx上面，那么填充response，若运行在本地，直接输出日志即可
--------------------------------------------------------------------------------------
local function writeResponse(ngx, code, detail)
    local result = nil
    if code == ERR_CODE.SUCCESS then
        result = { success = true, code = code[1], msg = code[2], data = detail }
    else
        result = { success = false, code = code[1], msg = detail or code[2] }
    end

    if not ngx or ngx.__TEST__ then
        log:info("执行结果：", StringUtil.toJSONString(result))
        return
    end

    ngx.say(StringUtil.toJSONString(result))
    ngx.exit(200)
    return
end

--------------------------------------------------------------------------------------
-- 处理命令入口方法
-- 1. 解析请求命令
-- 2. 判断参数是否合法
-- 3. 执行业务动作
-- @param ngx
-- @return code detail
--------------------------------------------------------------------------------------
local function handle(requestParams)
    local command = requestParams['command']
    if StringUtil.isEmpty(command) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '操作命令不能为空'
    end

    local commandInvoker = COMMANDS[command]
    if not commandInvoker then
        return ERR_CODE.ADMIN_PARAM_ERROR, '操作命令不存在'
    end

    if type(commandInvoker.invoke) ~= 'function' then
        return ERR_CODE.ADMIN_INNER_ERROR, '命令执行器没有找到执行模块'
    end

    -- 详细校验参数
    if type(commandInvoker.checkParams) == 'function' then
        local code, detail = commandInvoker.checkParams(requestParams)
        if code ~= ERR_CODE.SUCCESS then
            return code, detail
        end
    end

    -- 执行命令
    return commandInvoker.invoke(requestParams)
end

--------------------------------------------------------------------------------------
-- 命令
-- @param ngx
-- @return
--------------------------------------------------------------------------------------
local function admin(ngx)
    -- 获取ngx请求参数
    local requestParams = NgxUtil.getRequestParams(ngx)
    -- 执行业务逻辑
    local code, detail = handle(requestParams)
    -- 输出结果
    writeResponse(ngx, code, detail)
end

if CONFIG.DEBUG then
    -- DEBUG模式下面直接抛出异常
    admin(ngx)
else
    -- 保守执行命令
    if not pcall(admin, ngx) then
        log:error("命令执行异常")
        writeResponse(ngx, ERR_CODE.UNKNOWN_ERROR, "执行命令出现系统未定义异常")
    end
end