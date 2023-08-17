local Vector3 = {_type="Vector3"}
Vector3.__index = Vector3

local function new(x, y, z)
    local self = {X = x or 0, Y = y or 0, Z = z or 0}
    setmetatable(self, Vector3)
    return self
end

Vector3.new = new
Vector3.zero = new(0, 0, 0)
Vector3.xAxis = new(1, 0, 0)
Vector3.yAxis = new(0, 1, 0)
Vector3.zAxis = new(0, 0, 1)
Vector3.one = new(1, 1, 1)

local function Add(op1, op2)
    assert(getmetatable(op1) == Vector3)
    assert(getmetatable(op2) == Vector3)
    
    return new(op1.X + op2.X, op1.Y + op2.Y, op1.Z + op2.Z)
end

Vector3.__add = Add

local function Sub(op1, op2)
    assert(getmetatable(op1) == Vector3)
    assert(getmetatable(op2) == Vector3)
    
    return new(op1.X - op2.X, op1.Y - op2.Y, op1.Z - op2.Z)
end

Vector3.__sub = Sub

local function Mul(op1, op2)
    local op1IsVector3 = getmetatable(op1) == Vector3
    local op2IsVector3 = getmetatable(op2) == Vector3
    local op1IsNumber = type(op1) == "number"
    local op2IsNumber = type(op2) == "number"
    
    assert(op1IsVector3 or op1IsNumber)
    assert(op2IsVector3 or op2IsNumber)
    
    if op1IsVector3 and op2IsVector3 then
        return new(op1.X * op2.X, op1.Y * op2.Y, op1.Z * op2.Z)
    elseif op1IsVector3 then
        return new(op1.X * op2, op1.Y * op2, op1.Z * op2)
    else
        return new(op1 * op2.X, op1 * op2.Y, op1 * op2.Z)
    end
end

Vector3.__mul = Mul

local function Div(op1, op2)
    local op1IsVector3 = getmetatable(op1) == Vector3
    local op2IsVector3 = getmetatable(op2) == Vector3
    local op1IsNumber = type(op1) == "number"
    local op2IsNumber = type(op2) == "number"
    
    assert(op1IsVector3 or not(op1IsNumber))
    assert(op2IsVector3 or op2IsNumber)
    
    if op1IsVector3 and op2IsVector3 then
        return new(op1.X * op2.X, op1.Y * op2.Y, op1.Z * op2.Z)
    elseif op1IsVector3 then
        return new(op1.X / op2, op1.Y / op2, op1.Z / op2)
    end
    return
end

Vector3.__div = Div

local function unm(vector)
    return new(-vector.X, -vector.Y, -vector.Z)
end

Vector3.__unm = unm


local function Length(vector)
    local x, y, z = vector.X, vector.Y, vector.Z
    return (x * x + y * y + z * z) ^ 0.5
end

local function Normalize(vector)
    local length = Length(vector)
    return Div(vector, length)
end

function Vector3.__index(self, key)
    local functionIndex = Vector3[key]
    if functionIndex then
        return functionIndex
    end
    local lower = string.lower(key)
    if lower == "unit" then
        local norm = Normalize(self)
        return norm
    elseif lower == "magnitude" then
        local mag = Length(self)
        return mag
    end
    return nil
end

function Vector3.__newindex(_, key)
    error(tostring(key) .. " cannot be assigned to")
end


return Vector3