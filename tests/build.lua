--binaries/windows/lua.exe tests/build.lua

-- http://lua-users.org/wiki/FileInputOutput

local fileName = "src/Quaternion.luau"
local file = io.open(fileName, "r")

if file then
    -- Read the contents of the file
    local content = file:read("*a")  -- "*a" reads the whole file

    -- Close the file
    file:close()

    -- Do something with the content
    
else
    print("Error opening the file.")
end

--[==[
-- see if the file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function lines_from(file)
    if not file_exists(file) then 
        print("file does not exist")
        return {} 
    end
    local lines = {}
    for line in io.lines(file) do 
        lines[#lines + 1] = line
    end
    return lines
end

-- tests the functions above

local lines = lines_from(file)

-- print all line numbers and their contents
for k,v in pairs(lines) do
    print('line[' .. k .. ']', v)
end
--]==]