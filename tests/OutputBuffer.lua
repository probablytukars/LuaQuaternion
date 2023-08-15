local OutputBuffer = {}
OutputBuffer.__index = OutputBuffer

function OutputBuffer.new()
    local self = {}
    
    self.buffer = ""
    setmetatable(self, OutputBuffer)
    
    return self
end

function OutputBuffer:Prepend(...)
    local args = {...}
    local n = #args
    local argString = ""
    for i, arg in pairs(args) do
        local str = tostring(arg)
        argString = argString .. str
        if i < n then
            argString = argString .. " "
        end
    end
    self.buffer = argString .. self.buffer
end

function OutputBuffer:PrependNL(...)
    local args = {...}
    table.insert(args, "\n")
    self:Prepend(table.unpack(args))
end

function OutputBuffer:Append(...)
    local args = {...}
    local n = #args
    local argString = ""
    for i, arg in pairs(args) do
        local str = tostring(arg)
        argString = argString .. str
        if i < n then
            argString = argString .. " "
        end
    end
    self.buffer = self.buffer .. argString
end

function OutputBuffer:AppendNL(...)
    self:Append(...)
    self.buffer = self.buffer .. "\n"
end

function OutputBuffer:Reset()
    self.buffer = ""
end

function OutputBuffer:Flush()
    print(self.buffer)
    self:Reset()
end

return OutputBuffer
