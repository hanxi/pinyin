local utf8 = utf8 or {}

if not utf8.len or not utf8.sub then
    -- 获取单个字符长度
    local function get_char_size(char)
        if not char then
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end

    -- 获取中文字符长度
    function utf8.len(str)
        local len = 0
        local currentIndex = 1
        while currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            currentIndex = currentIndex + get_char_size(char)
            len = len + 1
        end
        return len
    end

    -- 截取中文字符串
    function utf8.sub(str, startChar, numChars)
        local startIndex = 1
        while startChar > 1 do
            local char = string.byte(str, startIndex)
            startIndex = startIndex + get_char_size(char)
            startChar = startChar - 1
        end

        local currentIndex = startIndex

        while numChars > 0 and currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            currentIndex = currentIndex + get_char_size(char)
            numChars = numChars - 1
        end

        return string.sub(str, startIndex, currentIndex - 1)
    end
end

local function pairs_sorted(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function get_py_table(data)
    local py_array = {}
    local sp_array = {}
    local py_table_index = {}
    for k, v in pairs_sorted(data) do
        local idx = #py_array + 1
        py_array[idx] = k
        sp_array[idx] = string.sub(k, 1, 1)
        for i = 1, utf8.len(v) do
            local char = utf8.sub(v, i, 1)
            if not py_table_index[char] then
                py_table_index[char] = {idx}
            else
                table.insert(py_table_index[char], idx)
            end
        end
    end
    return py_array, sp_array, py_table_index
end

local origin = require "origin"
local py_array, sp_array, py_table_index = get_py_table(origin)

local code = [[
local utf8 = utf8 or {}

if not utf8.len or not utf8.sub then
    local function get_char_size(char)
        if not char then
            return 0
        elseif char > 240 then
            return 4
        elseif char > 225 then
            return 3
        elseif char > 192 then
            return 2
        else
            return 1
        end
    end

    function utf8.len(str)
        local len = 0
        local currentIndex = 1
        while currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            currentIndex = currentIndex + get_char_size(char)
            len = len + 1
        end
        return len
    end

    function utf8.sub(str, startChar, numChars)
        local startIndex = 1
        while startChar > 1 do
            local char = string.byte(str, startIndex)
            startIndex = startIndex + get_char_size(char)
            startChar = startChar - 1
        end

        local currentIndex = startIndex

        while numChars > 0 and currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            currentIndex = currentIndex + get_char_size(char)
            numChars = numChars - 1
        end

        return string.sub(str, startIndex, currentIndex - 1)
    end
end

return function (chars, is_string, separator)
    separator = separator or ' '
    local pinyin, sp = {}, {}
    for i = 1, utf8.len(chars) do
        local char = utf8.sub(chars, i, 1)
        if #char == 1 then
            pinyin[i] = {char}
            sp[i] = {char}
        else
            local index = py_table_index[char]
            pinyin[i] = {}
            sp[i] = {}
            for j = 1, #index do
                local idx = index[j]
                pinyin[i][j] = py_array[idx]
                sp[i][j] = sp_array[idx]
            end
        end
    end
    if is_string then
        for i = 1, #pinyin do
            pinyin[i] = table.concat(pinyin[i], '/')
            sp[i] = table.concat(sp[i], '/')
        end
        return table.concat(pinyin, separator), table.concat(sp, separator)
    else
        return pinyin, sp
    end
end
]]

local serpent = require "serpent"
local py_array_str = serpent.line(py_array, {comment=false})
local sp_array_str = serpent.line(sp_array, {comment=false})
local py_table_index_str = serpent.line(py_table_index, {comment=false})
local file = io.open("pinyin.lua", "w")
file:write("local py_array = ")
file:write(py_array_str, "\n")
file:write("local sp_array = ")
file:write(sp_array_str, "\n")
file:write("local py_table_index = ")
file:write(py_table_index_str, "\n")
file:write(code)
file:close()