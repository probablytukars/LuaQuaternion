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

    local rightVector = Vector3.new(m00, m10, m20)
    local upVector = Vector3.new(m01, m11, m21)
    local backVector = Vector3.new(m02, m12, m22)
    
    return rightVector, upVector, backVector
end

local function new(x, y, z, qX, qY, qZ, qW)
    local self = {}
    
    self.X = x or 0
    self.Y = y or 0
    self.Z = z or 0
    
    local rightVector, upVector, backVector = toRotationMatrix(qX, qY, qZ, qW)
    
    self.RightVector = rightVector
    self.UpVector = upVector
    self.LookVector = -backVector
    
    setmetatable(self, CFrame)
    return self
end

CFrame.new = new

function CFrame.__index(self, key)
    local functionIndex = CFrame[key]
    if functionIndex then
        return functionIndex
    end
    return nil
end

function CFrame.__newindex(_, key)
    error(tostring(key) .. " cannot be assigned to")
end

return CFrame