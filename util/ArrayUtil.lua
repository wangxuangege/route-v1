module(..., package.seeall);

--------------------------------------------------------------------------------------
-- 数组合并
-- @param left 数组1
-- @param right 数组2
-- @return 返回合并后的数组
--------------------------------------------------------------------------------------
function merge(left, right)
    if type(left) ~= 'table' or type(right) ~= 'table' then
        return
    end

    local result = {}
    for i = 1, #left do
        table.insert(result, left[i])
    end
    for i = 1, #right do
        table.insert(result, right[i])
    end

    return result
end

--------------------------------------------------------------------------------------
-- 将右边数组合并到左边数组里面去
-- @param left 数组1
-- @param right 数组2
-- @return 返回left
--------------------------------------------------------------------------------------
function insert(left, right)
    if type(left) ~= 'table' or type(right) ~= 'table' then
        return left
    end
    for i = 1, #right do
        table.insert(left, right[i])
    end
    return left
end

--------------------------------------------------------------------------------------
-- 判断数组是否包含某元素
-- @param array 数组
-- @param element 元素
--------------------------------------------------------------------------------------
function contain(array, element)
    if type(array) ~= 'table' then
        return false
    end
    for i = 1, #array do
        if element == array[i] then
            return true
        end
    end
    return false
end