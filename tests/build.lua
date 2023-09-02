--binaries/windows/lua.exe tests/build.lua

local targetTags = {
    {"lua", "luaend"},
    {"luau", "luauend"},
    {"dev", "devend"},
}

local function printTable(tbl)
    local tableString = "{\n"
    for key, value in pairs(tbl) do
        tableString = tableString .. '\t["' .. tostring(key) .. '"] = ' 
            .. tostring(value) .. "\n"
    end
    tableString = tableString .. "}"
    print(tableString)
end

local function countTags(file)
    local tagCount = {{0, 0}, {0, 0}, {0, 0}}
    for line in file:lines() do
        for i, tagpair in pairs(targetTags) do
            local tagStart, tagEnd = tagpair[1], tagpair[2]
            local lineSearch = string.gsub(line, "%s+", "")
            local founds = lineSearch == "--@" .. tagStart and 1 or 0
            local founde  = lineSearch == "--@" .. tagEnd and 1 or 0
            tagCount[i][1] = tagCount[i][1] + founds
            tagCount[i][2] = tagCount[i][2] + founde
        end
    end
    for i, tagCountPair in pairs(tagCount) do
        local tagStart, tagEnd = tagCountPair[1], tagCountPair[2]
        local tagSn, tagEn = targetTags[i][1], targetTags[i][2]
        local match = tagEnd - tagStart
        if match > 0 then
            error(
                "Tag count mismatch: There are " .. tostring(match)
                 .. " more " .. tagEn .. " than " .. tagSn .. "."
            )
        elseif match < 0 then
            error(
                "Tag count mismatch: There are " .. tostring(-match)
                 .. " more " .. tagSn .. " than " .. tagEn .. "."
            )
        end
    end
end

local buildMode = {"production", "development"}
local className = "Quaternion"

local function buildFile(readFile, mode)
    local fileToWrite = "luau/" .. mode .. "/" .. className .. ".luau"
    local writeFile = io.open(fileToWrite, "w")
    print(fileToWrite, writeFile)
    local ignore_mode = false
    local ignored_on = nil
    for line in readFile:lines() do
        local lineSearch = string.gsub(line, "%s+", "")
        local tagOnLine = false
        for i, tagpair in pairs(targetTags) do
            local tagStart, tagEnd = tagpair[1], tagpair[2]
            if lineSearch == "--@" .. tagStart
            or lineSearch == "--@" .. tagEnd then
                tagOnLine = true
            end
            
            local valid_tag = true
            if tagStart == "luau" or tagStart == "lua" then
                valid_tag = language ~= tagStart
            end
            if valid_tag and tagStart == "dev" then
                valid_tag = mode == "production"
            end
            if valid_tag then
                if lineSearch == "--@" .. tagStart then
                    if not ignore_mode then
                        ignore_mode = true
                        ignored_on = tagStart
                    end
                elseif lineSearch == "--@" .. tagEnd then
                    if ignore_mode and ignored_on == tagStart then
                        ignore_mode = false
                        ignored_on = nil
                    end
                end
            end
        end
        if (not tagOnLine) and not(ignore_mode) then
            writeFile:write(line .. "\n")
        end
    end
    writeFile:close()
end


local fileName = "src/" .. className .. ".luau"
local file = io.open(fileName, "r")
if file then
    countTags(file)
    file:seek("set", 0)
    for _, mode in pairs(buildMode) do
        buildFile(file, mode)
        file:seek("set", 0)
    end
    file:close()
    print("Build was successful!")
else
    error("Error opening the file.")
end

