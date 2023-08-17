local Vector3 = require("../mocks/Vector3")

local CFrame = {_type="CFrame"}
CFrame.__index = CFrame


local function toRotationMatrix(qX, qY, qZ, qW)
    local sqX = qX * qX
    local sqY = qY * qY
    local sqZ = qZ * qZ
    local sqW = qW * qW
    
    local m00 = sqX - sqY - sqZ + sqW
    local m11 = -sqX + sqY - sqZ + sqW
    local m22 = -sqX - sqY + sqZ + sqW 
    
    local qXqY = qX * qY
    local qZqW = qZ * qW
    local m10 = 2 * (qXqY + qZqW)
    local m01 = 2 * (qXqY - qZqW)
    
    local qXqZ = qX * qZ
    local qYqW = qY * qW
    local m20 = 2 * (qXqZ - qYqW)
    local m02 = 2 * (qXqZ + qYqW)
    
    local qYqZ = qY * qZ
    local qXqW = qX * qW
    local m21 = 2 * (qYqZ + qXqW)
    local m12 = 2 * (qYqZ - qXqW)
    
    
    return {m00, m01, m02, m10, m11, m12, m20, m21, m22}
end

local function new(x, y, z, qX, qY, qZ, qW)
    local self = {}
    
    self.X = x or 0
    self.Y = y or 0
    self.Z = z or 0
    
    local matrix = toRotationMatrix(qX, qY, qZ, qW)
    self.matrix = matrix
    
    setmetatable(self, CFrame)
    return self
end

CFrame.new = new

local function fromMatrixArray(matrix)
    local self = {}
    
    self.X = 0
    self.Y = 0
    self.Z = 0
    
    self.matrix = matrix
    
    setmetatable(self, CFrame)
    return self
end

CFrame.fromMatrixArray = fromMatrixArray

local function fromMatrix(pos, right, up, back)
    local self = {}
    
    self.X = 0
    self.Y = 0
    self.Z = 0
    
    self.matrix = {
        right.X, up.X, back.X,
        right.Y, up.Y, back.Y,
        right.Z, up.Z, back.Z,
    }
    
    setmetatable(self, CFrame)
    return self
end

CFrame.fromMatrix = fromMatrix

local function GetComponents(self)
    return {self.X, self.Y, self.Z, table.unpack(self.matrix)}
end

CFrame.GetComponents = GetComponents
CFrame.components = GetComponents

function CFrame.__index(self, key)
    local functionIndex = CFrame[key]
    if functionIndex then
        return functionIndex
    end
    local lower = string.lower(key)
    if lower == "rightvector" then
        local matrix = self.matrix
        local m00, m10, m20 = matrix[1], matrix[4], matrix[7]
        return Vector3.new(m00, m10, m20)
    elseif lower == "upvector" then
        local matrix = self.matrix
        local m01, m11, m21 = matrix[2], matrix[5], matrix[8]
        return Vector3.new(m01, m11, m21)
    elseif lower == "lookvector" then
        local matrix = self.matrix
        local m02, m12, m22 = matrix[3], matrix[6], matrix[9]
        return Vector3.new(-m02, -m12, -m22)
    end
    return nil
end

function CFrame.__newindex(_, key)
    error(tostring(key) .. " cannot be assigned to")
end

return CFrame