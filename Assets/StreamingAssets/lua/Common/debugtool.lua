
local print = print

-- 打印普通日志
function Log(...)

    print(...)
end

function formatLog(...)
    local msgs = {...}
    local strs = ''
    for i = 1, #msgs do
        strs = strs..tostring(msgs[i])..' '
    end
    return strs
end

-- 会打印栈信息
function print_log(...)
    Util.Log("打印信息:".. formatLog(...) .."\n\t"..debug.traceback().."\n[end]")
end

-- 错误日志，会打印栈信息
function print_error(...)
    Util.LogError("打印信息:".. formatLog(...) .."\n\t"..debug.traceback().."\n[end]")
end

--警告日志
function print_warn(...)
    Util.LogWarning(...)
end

-- 格式化输出字符串，类似c函数printf风格
function Printf(fmt, ...)
    print(string.format(fmt, ...))
end

-- 打印一个table
function PrintTable(tbl, level)
    level = level or 1

    local indent_str = ""
    for i = 1, level do
        indent_str = indent_str.."  "
    end

    print(indent_str .. "{")
    for k,v in pairs(tbl) do
        local item_str = string.format("%s%s = %s", indent_str .. "  ", tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
            PrintTable(v, level + 1)
        end
    end
    print(indent_str .. "}")
end


function ToPrintTblStr(t, maxlevel)
    maxlevel = maxlevel or 0
    local names = {}

    local function ser(t1, name, level)
        if maxlevel > 0 and level > maxlevel then
            return "{...}"
        end

        names[t1] = name
        local items = {}
        for k, v in pairs(t1) do
            local key
            local tp = type(k)
            if tp == "string" then
                key = string.format("[%q]", k)
            elseif tp == "number" or tp == "boolean" or tp == "table" or tp == "function" then
                key = string.format("[%s]", tostring(k))
            else
                assert(false, "key type unsupported")
            end

            tp = type(v)
            local str
            if tp == "string" then
                str = string.format("%s = %q,", key, v)
            elseif tp == "number" or tp == "boolean" or tp == "function" then
                str = string.format("%s = %s,", key, tostring(v))
            elseif tp == "table" then
                if names[v] then
                    str = string.format("%s = %s,", key, names[v])
                else
                    str = string.format("%s = %s,", key, ser(v, string.format("%s%s", name, key), level+1))
                end
            else
                assert(false, "value type unsupported")
            end
            str = string.format("%s%s", string.rep("\t", level), str)
            table.insert(items, str)
        end

        if #items == 0 then
            return "{}"
        end

        local tabs = string.rep("\t", level - 1)
        local ret
        if level ~= 1 then
            ret = string.format("\n%s{\n%s\n%s}", tabs, table.concat(items, "\n"), tabs)
        else
            ret = string.format("%s{\n%s\n%s}", tabs, table.concat(items, "\n"), tabs)
        end
        return ret
    end

    return ser(t, "$self", 1)
end

-- 在同一个console打印luaTable
function LogTable(t, name)

    if GAME_ASSETBUNDLE and not IS_LOCLA_WINDOWS_DEBUG_EXE then
        return
    end

    local tableDict = {}
    local layer = 0
    local maxlayer = 999

    local function cmp(t1, t2)
        return tostring(t1) < tostring(t2)
    end

    local function table_r (t, name, indent, full, layer)
        local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
        local tag = indent .. id .. ' = '
        local out = {}  -- result
        if type(t) == "table" and layer < maxlayer then
            if tableDict[t] ~= nil then
                table.insert(out, tag .. '{} -- ' .. tableDict[t] .. ' (self reference)')
            else
                tableDict[t]= full and (full .. '.' .. id) or id
                if next(t) then -- Table not empty
                    table.insert(out, tag .. '{')
                    local keys = {}
                    for key,value in pairs(t) do
                        table.insert(keys, key)
                    end
                    table.sort(keys, cmp)
                    for i, key in ipairs(keys) do
                        local value = t[key]
                        table.insert(out,table_r(value,key,indent .. '|  ',tableDict[t], layer + 1))
                    end
                    table.insert(out,indent .. '}')
                else table.insert(out,tag .. '{}') end
            end
        else
            local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
            table.insert(out, tag .. val)
        end
        return table.concat(out, '\n')
    end

    local function tableTostring(t, name)
        return table_r(t, name or 'Table', '', '', layer)
    end

    local function printc(...)
        local args = {}
        local len = select("#", ...)
        for i=1, len do
            local v = select(i, ...)
            table.insert(args, tostring(v))
        end
        local s = table.concat(args, " ")
        print_log(s)
    end
    printc("LogTable ", tableTostring(t, name))
end