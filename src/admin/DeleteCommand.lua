module(..., package.seeall);

--------------------------------------------------------------------------------------
-- 执行命令
--------------------------------------------------------------------------------------
function invoke(requestParams)
    local mysql = Mysql:create()

    local code, detail = mysql:execute(
            string.format("delete from route_rule where id=%s", requestParams['id']))

    if code ~= ERR_CODE.SUCCESS then
        log:warn("删除失败，错误码:", code[1], "，错误原因：", detail)
        return code, "规则删除失败"
    end

    mysql:release()

    return ERR_CODE.SUCCESS
end

--------------------------------------------------------------------------------------
-- 判断参数是否合法
--------------------------------------------------------------------------------------
function checkParams(requestParams)
    local id = requestParams['id']
    if StringUtil.isEmpty(id) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '必须指定要删除的规则主键'
    end
    if not tonumber(id) then
        return ERR_CODE.ADMIN_PARAM_ERROR, '找不到要删除的主键'
    end
    return ERR_CODE.SUCCESS
end