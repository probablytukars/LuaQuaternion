--binaries/windows/lua.exe tests/build.lua

local targetTags = {
    {"test", "testend"}, --remove
    {"build", "buildend"}, --uncomment
    {"dev", "devend"}, --remove
    {"prod", "prodend"} -- uncomment
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
    local tagCount = {{0, 0}, {0, 0}, {0, 0}, {0, 0}}
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

local buildMode = {"prod", "dev"}
local className = "Quaternion"

function removeFirstTwoNonWhitespaceChars(inputString)
    local firstTwoNonWhitespaceChars = inputString:match("^%s*()%S()%S*")
    if firstTwoNonWhitespaceChars then
        local startIndex, endIndex = firstTwoNonWhitespaceChars, firstTwoNonWhitespaceChars + 1
        local modifiedString = inputString:sub(1, startIndex - 1) .. inputString:sub(endIndex + 1)
        return modifiedString
    else
        return inputString
    end
end

local function buildFile(readFile, mode)
    local fileToWrite = "luau/" .. mode .. "/" .. className .. ".luau"
    local writeFile = io.open(fileToWrite, "w")
    if not writeFile then
        error("Cannot open file!")
    end
    print(fileToWrite, writeFile)
    local read_mode = "read"
    local ignored_on = nil
    local uncomment_on = nil
    for line in readFile:lines() do
        local lineSearch = string.gsub(line, "%s+", "")
        local tagOnLine = false
        for i, tagpair in pairs(targetTags) do
            local tagStart, tagEnd = tagpair[1], tagpair[2]
            if lineSearch == "--@" .. tagStart then
                if read_mode == "read" then
                    if tagStart == "build"
                    or mode == "prod" and tagStart == "prod" then
                        read_mode = "uncomment"
                        ignored_on = tagStart
                    elseif not(mode == "dev" and tagStart == "dev") then
                        read_mode = "ignore"
                        ignored_on = tagStart
                    end
                end
                tagOnLine = true
                break
            elseif lineSearch == "--@" .. tagEnd then
                if read_mode ~= "read" and ignored_on == tagStart then
                    read_mode = "read"
                    ignored_on = nil
                end
                tagOnLine = true
                break
            elseif lineSearch:sub(1, 5) == "--[=[" then
                tagOnLine = true
                read_mode = "ignore"
            elseif lineSearch:sub(-3) == "]=]" then
                tagOnLine = true
                read_mode = "read"
            end
        end
        if (not tagOnLine) and read_mode ~= "ignore" then
            if read_mode ~= "uncomment" then
                writeFile:write(line .. "\n")
            else
                writeFile:write(removeFirstTwoNonWhitespaceChars(line) .. "\n")
            end
            
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

