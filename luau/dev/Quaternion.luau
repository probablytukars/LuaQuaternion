-- Version: 0.0.2


export type Quaternion = {
    
    -- Constructors
    
    new: (qX: number?, qY: number?, qZ: number?, qW: number?) -> Quaternion,
    fromAxisAngle: (axis: Vector3, angle: number) -> Quaternion,
    fromAxisAngleFast: (axis: Vector3, angle: number) -> Quaternion,
    fromCFrame: (cframe: CFrame) -> Quaternion,
    fromMatrix: (vX: Vector3, vY: Vector3, vZ: Vector3?) -> Quaternion,
    lookAt: (from: Vector3, lookAt: Vector3, up: Vector3?) -> Quaternion,
    fromEulerAnglesXYZ: (rx: number, ry: number, rz: number) -> Quaternion,
    Angles: (rx: number, ry: number, rz: number) -> Quaternion,
    fromEulerAnglesYXZ: (rx: number, ry: number, rz: number) -> Quaternion,
    fromOrientation: (rx: number, ry: number, rz: number) -> Quaternion,
    fromEulerAngles: (
        rx: number, ry: number, rz: number, rotationOrder: Enum.RotationOrder?
    ) -> Quaternion,
    fromVector: (vector: Vector3) -> Quaternion,
    RandomQuaternion: (seed: number) -> () -> Quaternion,
    
    -- Constants
    
    identity: Quaternion,
    zero: Quaternion,
    
    -- Properties
    
    X: number,
    Y: number,
    Z: number,
    W: number,
    Unit: Quaternion,
    Magnitude: number,
    
    -- Math operations / metamethods
    
    --[[ 
    add:
        Quaternion + Quaternion -> Quaternion
    
    sub:
        Quaternion - Quaternion -> Quaternion
        
    mul:
        Quaternion * Quaternion -> Quaternion
        Quaternion * number -> Quaternion
        number * Quaternion -> Quaternion
        Quaternion * CFrame -> CFrame
        Quaternion * Vector3 -> Vector3
        Vector3 * Quaternion -> CFrame
    
    
    div:
        Quaternion / Quaternion -> Quaternion
        Quaternion / number -> Quaternion
        number / Quaternion -> Quaternion
        
    unm:
        -Quaternion -> Quaternion
    
    pow:
        Quaternion ^ number -> Quaternion
    
    len:
        #Quaternion -> number
        
    lt (a < b  <internal>->  b > a):
        Quaternion < Quaternion
    
    le (a <= b  <internal>->  b >= a):
        Quaternion <= Quaternion
    
    eq (a == b): (a ~= b  <internal>->  not(a == b))
        Quaternion == Quaternion
    
    --]]
    
    -- Methods
    
    Exp: (q0: Quaternion) -> Quaternion,
    ExpMap: (q0: Quaternion, q1: Quaternion) -> Quaternion,
    ExpMapSym: (q0: Quaternion, q1: Quaternion) -> Quaternion,
    Log: (q0: Quaternion) -> Quaternion,
    LogMap: (q0: Quaternion, q1: Quaternion) -> Quaternion,
    LogMapSym: (q0: Quaternion, q1: Quaternion) -> Quaternion,
    LogInv: (q0: Quaternion, q1: Quaternion) -> Quaternion,
    Length: (q0: Quaternion) -> number,
    LengthSquared: (q0: Quaternion) -> number,
    Hypot: (q0: Quaternion) -> number,
    Normalize: (q0: Quaternion) -> Quaternion,
    IsUnit: (q0: Quaternion, epsilon: number) -> boolean,
    Dot: (q0: Quaternion, q1: Quaternion) -> number,
    Conjugate: (q0: Quaternion) -> Quaternion,
    Inverse: (q0: Quaternion) -> Quaternion,
    Negate: (q0: Quaternion) -> Quaternion,
    Difference: (q0: Quaternion, q1: Quaternion) -> Quaternion,
    Distance: (q0: Quaternion, q1: Quaternion) -> number,
    DistanceSym: (q0: Quaternion, q1: Quaternion) -> number,
    DistanceChord: (q0: Quaternion, q1: Quaternion) -> number,
    DistanceAbs: (q0: Quaternion, q1: Quaternion) -> number,
    Slerp: (q0: Quaternion, q1: Quaternion, alpha: number) -> Quaternion,
    IdentitySlerp: (q1: Quaternion, alpha: number) -> Quaternion,
    SlerpFunction: (q0: Quaternion, q1: Quaternion)
        -> (alpha: number) -> Quaternion,
    Intermediates: (
        q0: Quaternion, q1: Quaternion, n: number, includeEndpoints: boolean?
    ) -> {Quaternion},
    Derivative: (q0: Quaternion, rate: Vector3) -> Quaternion,
    Integrate: (q0: Quaternion, rate: Vector3, timestep: number) -> Quaternion,
    ApproxEq: (q0: Quaternion, q1: Quaternion, epsilon: number) -> boolean,
    IsNaN: (q0: Quaternion) -> boolean,
    
    -- Deconstructors

    ToCFrame: (q0: Quaternion, position: Vector3?) -> CFrame,
    ToAxisAngle: (q0: Quaternion) -> (Vector3, number),
    ToEulerAnglesXYZ: (q0: Quaternion) -> (number, number, number),
    ToEulerAnglesYXZ: (q0: Quaternion) -> (number, number, number),
    ToOrientation: (q0: Quaternion) -> (number, number, number),
    ToEulerAngles: (
        q0: Quaternion, rotationOrder: Enum.RotationOrder?
    ) -> (number, number, number),
    ToMatrix: (q0: Quaternion) ->
    (
        number, number, number, 
        number, number, number,
        number, number, number
    ) ,
    ToMatrixVectors: (q0: Quaternion) -> (Vector3, Vector3, Vector3),
    Vector: (q0: Quaternion) -> Vector3,
    Scalar: (q0: Quaternion) -> number,
    Imaginary: (q0: Quaternion) -> Quaternion,
    GetComponents: (q0: Quaternion) -> (number, number, number, number),
    components: (q0: Quaternion) -> (number, number, number, number),
    ToString: (q0: Quaternion, decimalPlaces: number?) -> string,
}

local EPSILON = 1e-6

local Quaternion = {_type = "Quaternion"}

-- Internal functions for type checking and throwing errors

local function GetType(obj: any): string
    if obj == nil then return "nil" end
    local objMetatable = getmetatable(obj)
    if type(objMetatable) == "table" and objMetatable._type ~= nil then
        return tostring(objMetatable._type)
    else
        return typeof(obj)
    end
end
local function ArgumentError(
    argPlace: number, expectedType: string, gotType: string
)
    
    error(
        "Invalid Argument #" .. tostring(argPlace) ..
            " (expected " .. expectedType .. ", got " .. gotType .. ")", 
        4
    )
end

local function AssertType(
    argPlace: number, argument: unknown, ...: string
): string

    local argumentType = GetType(argument)
    local validTypes = {...}
    for _, Type in pairs(validTypes) do
        if Type:sub(1, 5) == "Enum." then
            if argumentType == "EnumItem" then
                if tostring(argument.EnumType) == Type:sub(6) then
                    return argumentType
                end
            end
        else
            if argumentType == Type then 
                return argumentType 
            end
        end
    end
    if #validTypes > 0 then
        ArgumentError(argPlace, validTypes[1], argumentType)
    else
        ArgumentError(argPlace, "nil", argumentType)
    end
    return ""
end
local function _safeUnit(vector: Vector3, default: Vector3): Vector3
    if vector.Magnitude > EPSILON then
        return vector.Unit
    else
        return default
    end
end

local function new(qX: number?, qY: number?, qZ: number?, qW: number?): Quaternion
    AssertType(1, qX, "number", "nil")
    AssertType(2, qY, "number", "nil")
    AssertType(3, qZ, "number", "nil")
    AssertType(4, qW, "number", "nil")
    local self = setmetatable({
        X = qX or 0,
        Y = qY or 0,
        Z = qZ or 0,
        W = qW or 1,
        _cached = {}
    } :: any, Quaternion)
    
    table.freeze(self)
    
    return self
end

Quaternion.new = new
Quaternion.identity = new(0, 0, 0, 1)
Quaternion.zero = new(0, 0, 0, 0)

-- Private Methods

local function _Orthonormalize(rightVector: Vector3, upVector: Vector3, backVector: Vector3): (Vector3, Vector3, Vector3)
    local xBasis = _safeUnit(rightVector, Vector3.xAxis)
    local _upVector = _safeUnit(upVector, Vector3.yAxis)
    
    local zBasis = xBasis:Cross(_upVector)
    if zBasis.Magnitude > EPSILON then
        zBasis = zBasis.Unit
    else
        zBasis = xBasis:Cross(Vector3.yAxis)
        if zBasis.Magnitude > EPSILON then
            zBasis = zBasis.Unit
        else
            zBasis = Vector3.xAxis
        end
    end
    
    local yBasis = zBasis:Cross(xBasis).Unit
    if zBasis:Dot(backVector) < 0 then
        zBasis = -zBasis
    end
    return xBasis, yBasis, zBasis
end


local function _fromOrthonormalizedMatrix(vX: Vector3, vY: Vector3, vZ: Vector3): Quaternion
    local m00, m10, m20 = vX.X, vX.Y, vX.Z
    local m01, m11, m21 = vY.X, vY.Y, vY.Z
    local m02, m12, m22 = vZ.X, vZ.Y, vZ.Z

    local trace = m00 + m11 + m22

    local qX, qY, qZ, qW

    if trace > 0 then
        local S = math.sqrt(trace + 1) * 2
        qX = (m21 - m12) / S;
        qY = (m02 - m20) / S; 
        qZ = (m10 - m01) / S; 
        qW = 0.25 * S;
    elseif m00 > m11 and m00 > m22 then
        local S = math.sqrt(1 + m00 - m11 - m22) * 2
        qX = 0.25 * S;
        qY = (m01 + m10) / S; 
        qZ = (m02 + m20) / S; 
        qW = (m21 - m12) / S;
    elseif m11 > m22 then
        local S = math.sqrt(1 + m11 - m00 - m22) * 2
        qX = (m01 + m10) / S; 
        qY = 0.25 * S;
        qZ = (m12 + m21) / S; 
        qW = (m02 - m20) / S;
    else
        local S = math.sqrt(1 + m22 - m00 - m11) * 2
        qX = (m02 + m20) / S;
        qY = (m12 + m21) / S;
        qZ = 0.25 * S;
        qW = (m10 - m01) / S;
    end

    return new(qX, qY, qZ, qW)
end

-- Public Methods

local function fromAxisAngle(axis: Vector3, angle: number): Quaternion
    AssertType(1, axis, "Vector3")
    AssertType(2, angle, "number")
    
    axis = _safeUnit(axis, Vector3.xAxis)
    
    local ha = angle / 2
    local sha = math.sin(ha)
    
    local X = sha * axis.X
    local Y = sha * axis.Y
    local Z = sha * axis.Z
    local W = math.cos(ha)
    
    return new(X, Y, Z, W)
end

Quaternion.fromAxisAngle = fromAxisAngle

local function fromAxisAngleFast(axis: Vector3, angle: number): Quaternion
    AssertType(1, axis, "Vector3")
    AssertType(2, angle, "number")
    
    local ha = angle / 2
    local sha = math.sin(ha)
    
    local X = sha * axis.X
    local Y = sha * axis.Y
    local Z = sha * axis.Z
    local W = math.cos(ha)
    
    return new(X, Y, Z, W)
end


Quaternion.fromAxisAngleFast = fromAxisAngleFast

local function fromCFrame(cframe: CFrame): Quaternion
    AssertType(1, cframe, "CFrame")
    
    local Rv, Uv, Lv = cframe.RightVector, cframe.UpVector, -cframe.LookVector
    return _fromOrthonormalizedMatrix(_Orthonormalize(Rv, Uv, Lv))
end

Quaternion.fromCFrame = fromCFrame

local function fromMatrix(vX: Vector3, vY: Vector3, vZ: Vector3?): Quaternion
    AssertType(1, vX, "Vector3")
    AssertType(2, vY, "Vector3")
    AssertType(3, vZ, "Vector3", "nil")
    
    local vXo, vYo = vX.Unit, vY.Unit
    local vZo = 
        if vZ
        then vZ.Unit
        else vX:Cross(vY).Unit
    
    return _fromOrthonormalizedMatrix(_Orthonormalize(vXo, vYo, vZo))
end

Quaternion.fromMatrix = fromMatrix

local function lookAt(from: Vector3, lookAt: Vector3, up: Vector3?): Quaternion
    AssertType(1, from, "Vector3")
    AssertType(2, lookAt, "Vector3")
    AssertType(3, up, "Vector3", "nil")
    
    local lookVector = _safeUnit(lookAt - from, Vector3.zAxis)
    local _up = _safeUnit(up or Vector3.yAxis, Vector3.yAxis)
    
    local rightVector = lookVector:Cross(_up)
    if rightVector.Magnitude > 1e-6 then
        local rightVector = rightVector.Unit
        local upVector = rightVector:Cross(lookVector).Unit
        return _fromOrthonormalizedMatrix(rightVector, upVector, -lookVector)
    end

    local selectVector = lookVector:Cross(Vector3.xAxis)
    if selectVector.Magnitude > 1e-6 then
        local rightVector = selectVector.Unit
        local upVector = rightVector:Cross(lookVector).Unit
        return _fromOrthonormalizedMatrix(rightVector, upVector, -lookVector)
    else
        local upVector = Vector3.zAxis:Cross(lookVector)
        local upSign = upVector:Dot(Vector3.yAxis)
        upVector *= upSign
        local rightVector = lookVector:Cross(upVector)

        return _fromOrthonormalizedMatrix(rightVector, upVector, -lookVector)
    end
end

Quaternion.lookAt = lookAt

local function fromEulerAnglesXYZ(rx: number, ry: number, rz: number): Quaternion
    
    AssertType(1, rx, "number")
    AssertType(2, ry, "number")
    AssertType(3, rz, "number")
    
    local xCos = math.cos(rx / 2)
    local xSin = math.sin(rx / 2)
    local yCos = math.cos(ry / 2)
    local ySin = math.sin(ry / 2)
    local zCos = math.cos(rz / 2)
    local zSin = math.sin(rz / 2)
    
    local xSinyCos = xSin * yCos
    local xCosySin = xCos * ySin
    local xCosyCos = xCos * yCos
    local xSinySin = xSin * ySin
    
    local qX = xSinyCos * zCos + xCosySin * zSin
    local qY = xCosySin * zCos - xSinyCos * zSin
    local qZ = xCosyCos * zSin + xSinySin * zCos
    local qW = xCosyCos * zCos - xSinySin * zSin
    
    return new(qX, qY, qZ, qW)
end

Quaternion.fromEulerAnglesXYZ = fromEulerAnglesXYZ


Quaternion.Angles = fromEulerAnglesXYZ

local function fromEulerAnglesYXZ(rx: number, ry: number, rz: number): Quaternion 
    
    AssertType(1, rx, "number")
    AssertType(2, ry, "number")
    AssertType(3, rz, "number")
    
    local xCos = math.cos(rx / 2)
    local xSin = math.sin(rx / 2)
    local yCos = math.cos(ry / 2)
    local ySin = math.sin(ry / 2)
    local zCos = math.cos(rz / 2)
    local zSin = math.sin(rz / 2)
    
    local xSinyCos = xSin * yCos
    local xCosySin = xCos * ySin
    local xCosyCos = xCos * yCos
    local xSinySin = xSin * ySin

    local qX = xSinyCos * zCos + xCosySin * zSin
    local qY = xCosySin * zCos - xSinyCos * zSin
    local qZ = xCosyCos * zSin - xSinySin * zCos
    local qW = xCosyCos * zCos + xSinySin * zSin

    return new(qX, qY, qZ, qW)
end



Quaternion.fromEulerAnglesYXZ = fromEulerAnglesYXZ


Quaternion.fromOrientation = fromEulerAnglesYXZ

local function fromEulerAngles(rx: number, ry: number, rz: number, rotationOrder: Enum.RotationOrder?): Quaternion 
    AssertType(1, rx, "number")
    AssertType(2, ry, "number")
    AssertType(3, rz, "number")
    AssertType(4, rotationOrder, "Enum.RotationOrder", "nil")
    
    if not rotationOrder then rotationOrder = Enum.RotationOrder.XYZ end

    local xCos = math.cos(rx / 2)
    local yCos = math.cos(ry / 2)
    local zCos = math.cos(rz / 2)
    
    local xSin = math.sin(rx / 2)
    local ySin = math.sin(ry / 2)
    local zSin = math.sin(rz / 2)
    
    local xSinyCos = xSin * yCos
    local xCosySin = xCos * ySin
    local xCosyCos = xCos * yCos
    local xSinySin = xSin * ySin
    
    local qX, qY, qZ, qW
    
    local order = rotationOrder.Name
    if order == "XYZ" then
        qX = xSinyCos * zCos + xCosySin * zSin;
        qY = xCosySin * zCos - xSinyCos * zSin;
        qZ = xCosyCos * zSin + xSinySin * zCos;
        qW = xCosyCos * zCos - xSinySin * zSin;
    elseif order == "YXZ" then
        qX = xSinyCos * zCos + xCosySin * zSin;
        qY = xCosySin * zCos - xSinyCos * zSin;
        qZ = xCosyCos * zSin - xSinySin * zCos;
        qW = xCosyCos * zCos + xSinySin * zSin;
    elseif order == "ZXY" then
        qX = xSinyCos * zCos - xCosySin * zSin;
        qY = xCosySin * zCos + xSinyCos * zSin;
        qZ = xCosyCos * zSin + xSinySin * zCos;
        qW = xCosyCos * zCos - xSinySin * zSin;
    elseif order == "ZYX" then
        qX = xSinyCos * zCos - xCosySin * zSin;
        qY = xCosySin * zCos + xSinyCos * zSin;
        qZ = xCosyCos * zSin - xSinySin * zCos;
        qW = xCosyCos * zCos + xSinySin * zSin;
    elseif order == "YZX" then
        qX = xSinyCos * zCos + xCosySin * zSin;
        qY = xCosySin * zCos + xSinyCos * zSin;
        qZ = xCosyCos * zSin - xSinySin * zCos;
        qW = xCosyCos * zCos - xSinySin * zSin;
    elseif order == "XZY" then
        qX = xSinyCos * zCos - xCosySin * zSin;
        qY = xCosySin * zCos - xSinyCos * zSin;
        qZ = xCosyCos * zSin + xSinySin * zCos;
        qW = xCosyCos * zCos + xSinySin * zSin;
    end
    
    return new(qX, qY, qZ, qW)
end

Quaternion.fromEulerAngles = fromEulerAngles

local function fromVector(vector: Vector3): Quaternion
    AssertType(1, vector, "Vector3")
    
    return new(vector.X, vector.Y, vector.Z, 0)
end

Quaternion.fromVector = fromVector

local function RandomQuaternion(seed: number): () -> Quaternion
    local seed = seed or 1
    
    local random = Random.new(seed)
    local tau = 2 * math.pi
    local sqrt = math.sqrt
    local sin = math.sin
    local cos = math.cos
    return function()
        local u = random:NextNumber(0, 1)
        local v = random:NextNumber(0, 1)
        local w = random:NextNumber(0, 1)
        
        local omu = 1 - u
        local squ = sqrt(u)
        local sqmu = sqrt(omu)
        
        local tpv = tau * v
        local tpw = tau * w
        
        local qX = sqmu * sin(tpv)
        local qY = sqmu * cos(tpv)
        local qZ = squ * sin(tpw)
        local qW = squ * cos(tpw)
        return new(qX, qY, qZ, qW)
        
    end
end

Quaternion.RandomQuaternion = RandomQuaternion















    



local function Add(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return new(q0.X + q1.X, q0.Y + q1.Y, q0.Z + q1.Z, q0.W + q1.W)
end

Quaternion.__add = Add

local function Sub(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return new(q0.X - q1.X, q0.Y - q1.Y, q0.Z - q1.Z, q0.W - q1.W)
end

Quaternion.__sub = Sub

local function Mul(op0: Quaternion | Vector3 | number, op1: Quaternion | CFrame | Vector3 | number): Quaternion | CFrame | Vector3
    local op0type = AssertType(
        1, op0, "Quaternion", "CFrame", "Vector3", "number"
    )
    local op1type = AssertType(
        2, op1, "Quaternion", "CFrame", "Vector3", "number"
    )
    
    if op0type == "Quaternion" and op1type == "Quaternion" then
        local q0X, q0Y, q0Z, q0W = op0.X, op0.Y, op0.Z, op0.W
        local q1X, q1Y, q1Z, q1W = op1.X, op1.Y, op1.Z, op1.W
        return new(
            q0W * q1X + q0X * q1W + q0Y * q1Z - q0Z * q1Y,
            q0W * q1Y - q0X * q1Z + q0Y * q1W + q0Z * q1X,
            q0W * q1Z + q0X * q1Y - q0Y * q1X + q0Z * q1W,
            q0W * q1W - q0X * q1X - q0Y * q1Y - q0Z * q1Z
        )
    elseif op0type == "number" and op1type == "Quaternion" then 
        return new(op0 * op1.X, op0 * op1.Y, op0 * op1.Z, op0 * op1.W)
    elseif op0type == "Quaternion" and op1type == "number" then
        return new(op0.X * op1, op0.Y * op1, op0.Z * op1, op0.W * op1)
    elseif op0type == "Quaternion" and op1type == "CFrame" then 
        return op0:ToCFrame() * op1
    elseif op0type == "Quaternion" and op1type == "Vector3" then
        local op0 = op0:Normalize()
        return (op0 * fromVector(op1) * op0:Conjugate()):Vector()
    elseif op0type == "Vector3" and op1type == "Quaternion" then
        return fromVector(op0) * op1
    else
        if op0type == "Quaternion" then
            error("Cannot multiply Quaternion with " .. op1type .. ".", 2)
        elseif op1type == "Quaternion" then
            error("Cannot multiply " .. op0type .. " with Quaternion.", 2)
        else
            error(
                "Attempt to mulitply"
                .. op0type .. " with " .. op1type
                .. "inside Quaternion mul function. "
                .. "Outside of function domain."
            )
        end

    end
end

Quaternion.__mul = Mul

local function Div(op0: Quaternion | number, op1: number | Quaternion): Quaternion
    
    local op0type = AssertType(1, op0, "Quaternion", "number")
    local op1type = AssertType(2, op1, "Quaternion", "number")
    
    if op0type == "Quaternion" and op1type == "number" then
        return new(op0.X / op1, op0.Y / op1, op0.Z / op1, op0.W / op1)
    elseif op0type == "number" and op1type == "Quaternion" then
        return new(op0 / op1.X, op0 / op1.Y, op0 / op1.Z, op0 / op1.W)
    elseif op0type == "Quaternion" and op1type == "Quaternion" then
        return Mul(op0, op1:Inverse())
    else
        if op0type == "Quaternion" then
            error("Cannot divide Quaternion by " .. op1type .. ".", 2)
        else
            error("Cannot divide " .. op0type .. " by Quaternion.", 2)
        end
    end
end

Quaternion.__div = Div

local function unm(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    return new(-q0.X, -q0.Y, -q0.Z, -q0.W)
end

Quaternion.__unm = unm
Quaternion.Negate = unm

local function Pow(q0: Quaternion, number: number)
    AssertType(1, q0, "Quaternion")
    AssertType(2, number, "number")
    
    local aW, aX, aY, aZ = q0.W, q0.X, q0.Y, q0.Z
    
    local im = aX*aX + aY*aY + aZ*aZ
    local aMag = math.sqrt(aW*aW + im)
    local aIm = math.sqrt(im)
    local cMag = aMag ^ number
    
    if aIm <= EPSILON * aMag then
        return Quaternion.new(0, 0, 0, cMag)
    end
    
    local rx = aX / aIm
    local ry = aY / aIm
    local rz = aZ / aIm
    
    local cAng = number * math.atan2(aIm, aW)
    local cCos = math.cos(cAng)
    local cSin = math.sin(cAng)
    local cMagcSin = cMag * cSin
    
    local cW = cMag*cCos
    local cX = cMagcSin * rx
    local cY = cMagcSin * ry
    local cZ = cMagcSin * rz
    
    return Quaternion.new(cX, cY, cZ, cW)
end

Quaternion.__pow = Pow

local function eq(q0: Quaternion, q1: Quaternion): boolean
    local op0type = GetType(q0)
    local op1type = GetType(q1)
    
    if (op0type == "Quaternion" and op1type == op0type) then
        return q0.X == q1.X and q0.Y == q1.Y and q0.Z == q1.Z and q0.W == q1.W
    else
        return false
    end
end

Quaternion.__eq = eq

local function lt(q0: Quaternion, q1:Quaternion)
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    local q0l = q0:Length()
    local q1l = q1:Length()

    return q0l < q1l
end

Quaternion.__lt = lt

local function le(q0: Quaternion, q1:Quaternion)
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    local q0l = q0:Length()
    local q1l = q1:Length()
    
    return q0l <= q1l
end

Quaternion.__le = le

local function Exp(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    
    local m = math.exp(qW)
    local vv = qX*qX + qY*qY + qZ*qZ
    if vv > 0 then
        local v = vv ^ 0.5
        local s = m * math.sin(v) / v
        return new(qX * s, qY * s, qZ * s, m * math.cos(v))
    else
        return new(0, 0, 0, m)
    end
end

Quaternion.Exp = Exp

local function ExpMap(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return Mul(q0, Exp(q1))
end

Quaternion.ExpMap = ExpMap

local function ExpMapSym(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    local sqrtQ = Pow(q0, 0.5)
    return Mul(Mul(sqrtQ, Exp(q1)), sqrtQ)
end

Quaternion.ExpMapSym = ExpMapSym

local function Log(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    
    local vv = qX*qX + qY*qY + qZ*qZ
    local mm = qW*qW + vv
    if mm > 0 then
        if vv > 0 then
            local m = mm ^ 0.5
            local s = math.acos(qW / m) / (vv ^ 0.5)
            return new(qX * s, qY * s, qZ * s, math.log(m))
        else
            return new(0, 0, 0, math.log(mm)/2)
        end
    else
        return new(0, 0, 0, -math.huge)
    end
end

Quaternion.Log = Log

local function LogMap(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return Log(Mul(q0:Inverse(), q1))
end

Quaternion.LogMap = LogMap

local function LogMapSym(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    local invSqrtq0 = Pow(q0, -0.5)
    return Log(Mul(Mul(invSqrtq0, q1), invSqrtq0))
end

Quaternion.LogMapSym = LogMapSym

local function Length(q0: Quaternion): number 
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    return (qX * qX + qY * qY + qZ * qZ + qW * qW) ^ 0.5
end

Quaternion.Length = Length
Quaternion.__len = Length

local function LengthSquared(q0: Quaternion): number
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    return qX * qX + qY * qY + qZ * qZ + qW * qW
end

Quaternion.LengthSquared = LengthSquared

local function Hypot(q0: Quaternion): number
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local maxComp = math.max(qX, qY, qZ, qW)
    if maxComp > 0 then
        local normalizedQ = q0 / maxComp
        local length = Length(normalizedQ) * maxComp
        
        return length
    end
    return 0
end

Quaternion.Hypot = Hypot

local function Normalize(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    local length = Length(q0)
    if length > 0 then
        return Div(q0, length)
    else
        return Quaternion.identity
    end
end

Quaternion.Normalize = Normalize

local function IsUnit(q0: Quaternion, epsilon: number): boolean
    AssertType(1, q0, "Quaternion")
    
    if not epsilon then epsilon = EPSILON end
    return math.abs(1 - Length(q0)) < epsilon
end

Quaternion.IsUnit = IsUnit

local function ToCFrame(q0: Quaternion, position: Vector3?): CFrame
    AssertType(1, q0, "Quaternion")
    AssertType(2, position, "Vector3", "nil")
    
    q0 = Normalize(q0)

    local vectorPos = position or Vector3.new()
    return CFrame.new(
        vectorPos.X, vectorPos.Y, vectorPos.Z, 
        q0.X, q0.Y, q0.Z, q0.W
    )
end

Quaternion.ToCFrame = ToCFrame

local function Dot(q0: Quaternion, q1: Quaternion): number
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return q0.X * q1.X + q0.Y * q1.Y + q0.Z * q1.Z + q0.W * q1.W
end

Quaternion.Dot = Dot

local function Conjugate(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    return new(-q0.X, -q0.Y, -q0.Z, q0.W)
end

Quaternion.Conjugate = Conjugate

local function Inverse(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local length = qX * qX + qY * qY + qZ * qZ + qW * qW
    
    return new(-q0.X / length, -q0.Y/ length, -q0.Z / length, q0.W / length)
end

Quaternion.Inverse = Inverse

local function LogInv(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return Log(Mul(q0, Inverse(q1)))
end

Quaternion.LogInv = LogInv

local function Negate(q0: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    
    return new(-q0.X, -q0.Y, -q0.Z, -q0.W)
end

Quaternion.Negate = Negate
Quaternion.__unm = Negate

local function Difference(q0: Quaternion, q1: Quaternion): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    if Dot(q0, q1) < 0 then
        q0 = unm(q0)
    end
    return Mul(Inverse(q0), q1)
end

Quaternion.Difference = Difference

local function Distance(q0: Quaternion, q1: Quaternion): number
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return Length(LogMap(q0, q1)) * 2
end

Quaternion.Distance = Distance

local function DistanceSym(q0: Quaternion, q1: Quaternion): number
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return Length(Log(Difference(q0, q1))) * 2
end

Quaternion.DistanceSym = DistanceSym

local function DistanceChord(q0: Quaternion, q1: Quaternion): number
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    return math.sin(DistanceSym(q0, q1) / 2) * 2
end

Quaternion.DistanceChord = DistanceChord

local function DistanceAbs(q0: Quaternion, q1: Quaternion): number
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    local q0minusq1 = Sub(q0, q1)
    local q0plusq1 = Add(q0, q1)
    local dMinus = Length(q0minusq1)
    local dPlus = Length(q0plusq1)
    
    if dMinus < dPlus then
        return dMinus
    end
    return dPlus
end

Quaternion.DistanceAbs = DistanceAbs

local function Slerp(q0: Quaternion, q1: Quaternion, alpha: number): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    AssertType(3, alpha, "number")
    
    q0 = Normalize(q0)
    q1 = Normalize(q1)

    local dot = Dot(q0, q1)

    if dot < 0 then
        q0 = unm(q0)
        dot = -dot
    end

    if dot >= 1 then
        return Normalize(Add(q0, Mul(Sub(q1, q0), alpha)))
    end

    local theta0 = math.acos(dot)
    local sinTheta0 = math.sin(theta0)

    local theta = theta0 * alpha
    local sinTheta = math.sin(theta)

    local s0 = math.cos(theta) - dot * sinTheta / sinTheta0
    local s1 = sinTheta / sinTheta0
    return Normalize(Add(Mul(s0, q0), Mul(s1, q1)))
end

Quaternion.Slerp = Slerp

local function IdentitySlerp(q1: Quaternion, alpha: number): Quaternion 
    AssertType(1, q1, "Quaternion")
    AssertType(2, alpha, "number")
    
    local q0 = 1
    q1 = Normalize(q1)
    local dot = q1.W
    
    if dot < 0 then
        q0 = -1
        dot = -dot
    end
    
    if dot >= 1 then
        return Normalize(new(
                q1.X * alpha, 
                q1.Y * alpha, 
                q1.Z * alpha, 
                (q1.W - q0) * alpha + q0
            ))
    end
    
    local theta0 = math.acos(dot)
    local sinTheta0 = math.sin(theta0)

    local theta = theta0 * alpha
    local sinTheta = math.sin(theta)

    local s0 = math.cos(theta) - dot * sinTheta / sinTheta0
    local s1 = sinTheta / sinTheta0
    return Normalize(new(q1.X * s1, q1.Y * s1, q1.Z * s1, q0 * s0 + q1.W * s1))
end

Quaternion.IdentitySlerp = IdentitySlerp

local function SlerpFunction(q0: Quaternion, q1: Quaternion): (alpha: number) -> Quaternion
    
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    
    q0 = Normalize(q0)
    q1 = Normalize(q1)

    local dot = Dot(q0, q1)

    if dot < 0 then
        q0 = unm(q0)
        dot = -dot
    end

    if dot >= 1 then
        local subQ = Sub(q1, q0)
        
        return function(alpha: number)
            AssertType(1, alpha, "number")
            
            return Normalize(Add(q0, Mul(subQ, alpha)))
        end
    end

    local theta0 = math.acos(dot)
    local sinTheta0 = math.sin(theta0)
    
    return function(alpha: number)
        AssertType(1, alpha, "number")
        
        local theta = theta0 * alpha
        local sinTheta = math.sin(theta)

        local s0 = math.cos(theta) - dot * sinTheta / sinTheta0
        local s1 = sinTheta / sinTheta0
        return Normalize(Add(Mul(s0, q0), Mul(s1, q1)))
    end
end

Quaternion.SlerpFunction = SlerpFunction

local function Intermediates(q0: Quaternion, q1: Quaternion, n: number, includeEndpoints: boolean?): {Quaternion}
    
    AssertType(1, q0, "Quaternion")
    AssertType(1, q1, "Quaternion")
    AssertType(2, n, "number")
    AssertType(2, includeEndpoints, "boolean", "nil")
    
    includeEndpoints = includeEndpoints or false
    
    local stepSize = 1 / (n + 1)
    local steps = 
        if includeEndpoints
        then {q0}
        else {}
    
    local slerpFunc = SlerpFunction(q0, q1)
    
    for i = 1, n do
        local qi = slerpFunc(stepSize * i)
        table.insert(steps, qi)
    end
    
    if includeEndpoints then
        table.insert(steps, q1)
    end
    
    return steps
end

Quaternion.Intermediates = Intermediates

local function Derivative(q0: Quaternion, rate: Vector3): Quaternion
    AssertType(1, q0, "Quaternion")
    AssertType(2, rate, "Vector3")
    
    return Mul(Mul(0.5, q0), fromVector(rate))
end

Quaternion.Derivative = Derivative

local function Integrate(q0: Quaternion, rate: Vector3, timestep: number): Quaternion
    
    AssertType(1, q0, "Quaternion")
    AssertType(2, rate, "Vector3")
    AssertType(3, timestep, "number")
    
    q0 = Normalize(q0)
    
    local rotationVector = (rate * timestep)
    local rotationMag = rotationVector.Magnitude
    if rotationMag > 0 then
        local axis = rotationVector / rotationMag
        local angle = rotationMag
        local q1 = fromAxisAngle(axis, angle)
        return Normalize(Mul(q0, q1))
    else
        return q0
    end
end

Quaternion.Integrate = Integrate

local function ApproxEq(q0: Quaternion, q1: Quaternion, epsilon: number?): boolean 
    
    AssertType(1, q0, "Quaternion")
    AssertType(2, q1, "Quaternion")
    AssertType(3, epsilon, "number", "nil")
    
    epsilon = epsilon or EPSILON
    return DistanceSym(q0, q1) < epsilon
end

Quaternion.ApproxEq = ApproxEq

local function IsNaN(q0: Quaternion): boolean
    AssertType(1, q0, "Quaternion")
    
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    return qX ~= qX or qY ~= qY or qZ ~= qZ or qW ~= qW
end

Quaternion.IsNaN = IsNaN

local function _toRotationMatrix(q0: Quaternion)
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W

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

    return m00, m01, m02, m10, m11, m12, m20, m21, m22
end

local function ToAxisAngle(q0: Quaternion): (Vector3, number)
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    
    local angle = 2 * math.acos(qW);
    local s = math.sqrt(1 - qW * qW);
    
    if s < EPSILON then
        return Vector3.new(qX, qY, qZ), angle
    else
        return Vector3.new(qX / s, qY / s, qZ / s), angle
    end
end

Quaternion.ToAxisAngle = ToAxisAngle

local function ToMatrix(q0: Quaternion): (number, number, number, number, number, number,number, number, number) 
    AssertType(1, q0, "Quaternion")
    
    return _toRotationMatrix(q0)
end

Quaternion.ToMatrix = ToMatrix

local function ToMatrixVectors(q0: Quaternion): (Vector3, Vector3, Vector3) 
    AssertType(1, q0, "Quaternion")
    
    local m00, m01, m02, m10, m11, m12, m20, m21, m22 = _toRotationMatrix(q0)
    
    --Right, Up, Look
    return 
        Vector3.new(m00, m10, m20),
        Vector3.new(m01, m11, m21),
        Vector3.new(m02, m12, m22)
end

Quaternion.ToMatrixVectors = ToMatrixVectors

local function Vector(q0: Quaternion): Vector3 
    AssertType(1, q0, "Quaternion")
    
    return Vector3.new(q0.X, q0.Y, q0.Z)
end

Quaternion.Vector = Vector

local function Real(q0: Quaternion): Quaternion 
    AssertType(1, q0, "Quaternion")
    
    return new(0, 0, 0, q0.W)
end

Quaternion.Real = Real

local function Imaginary(q0: Quaternion): Quaternion 
    AssertType(1, q0, "Quaternion")
    
    return new(q0.X, q0.Y, q0.Z, 0)
end

Quaternion.Imaginary = Imaginary

local function ToEulerAnglesXYZ(q0: Quaternion): (number, number, number) 
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local rX, rY, rZ
    
    local test = qY * qW + qX * qZ
    if math.abs(test) > 0.499999 then
        local sign = test > 0 and 1 or -1
        rX = sign * 2 * math.atan2(qZ, qW)
        rY = sign * math.pi / 2
        rZ = 0
        return rX, rY, rZ
    end
    
    local sqy = qY * qY
    rX = math.atan2(2 * (qX * qW - qY * qZ), 1 - 2 * (qX * qX + sqy))
    rY = math.asin(2 * test)
    rZ = math.atan2(2 * (qZ * qW - qX * qY), 1 - 2 * (qZ * qZ + sqy))
    
    return rX, rY, rZ
end

local function ToEulerAnglesXZY(q0: Quaternion): (number, number, number)
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local rX, rY, rZ

    local test = qZ * qW - qX * qY
    if math.abs(test) > 0.5 - EPSILON then
        local sign = test >= 0 and 1 or -1
        rX = sign * 2 * -math.atan2(qY, qW)
        rY = 0
        rZ = sign * math.pi / 2 
        return rX, rY, rZ
    end
    
    local sqz = qZ * qZ
    rX = math.atan2(2 * (qX * qW + qY * qZ), 1 - 2 * (qX * qX + sqz))
    rY = math.atan2(2 * (qX * qZ + qY * qW), 1 - 2 * (qY * qY + sqz))
    rZ = math.asin(2 * test)

    return rX, rY, rZ
end

local function ToEulerAnglesYXZ(q0: Quaternion): (number, number, number) 
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local rX, rY, rZ

    local test = qX * qW - qY * qZ
    if math.abs(test) > 0.5 - EPSILON then
        local sign = test >= 0 and 1 or -1
        rX = sign * math.pi / 2
        rY = sign * 2 * -math.atan2(qZ, qW)
        rZ = 0
        return rX, rY, rZ
    end
    
    local sqx = qX * qX
    rX = math.asin(2 * test)
    rY = math.atan2(2 * (qX * qZ + qY * qW), 1 - 2 * (qY * qY + sqx))
    rZ = math.atan2(2 * (qX * qY + qZ * qW), 1 - 2 * (qZ * qZ + sqx))

    return rX, rY, rZ
end

local function ToEulerAnglesYZX(q0: Quaternion): (number, number, number) 
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local rX, rY, rZ

    local test = qZ * qW + qX * qY
    if math.abs(test) > 0.5 - EPSILON then
        local sign = test >= 0 and 1 or -1
        rX = 0
        rY = sign * 2 * math.atan2(qX, qW)
        rZ = sign * math.pi / 2
        return rX, rY, rZ
    end
    
    local sqz = qZ * qZ
    rX = math.atan2(2 * (qX * qW - qY * qZ), 1 - 2 * (qX * qX + sqz))
    rY = math.atan2(2 * (qY * qW - qX * qZ), 1 - 2 * (qY * qY + sqz))
    rZ = math.asin(2 * test)

    return rX, rY, rZ
end

local function ToEulerAnglesZXY(q0: Quaternion): (number, number, number) 
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local rX, rY, rZ

    local test = qX * qW + qY * qZ
    if math.abs(test) > 0.5 - EPSILON then
        local sign = test >= 0 and 1 or -1
        rX = sign * math.pi / 2
        rY = 0
        rZ = sign * 2 * math.atan2(qY, qW)
        return rX, rY, rZ
    end
    
    local sqx = qX * qX
    rX = math.asin(2 * test)
    rY = math.atan2(2 * (qY * qW - qX * qZ), 1 - 2 * (qY * qY + sqx))
    rZ = math.atan2(2 * (qZ * qW - qX * qY), 1 - 2 * (qZ * qZ + sqx))

    return rX, rY, rZ
end

local function ToEulerAnglesZYX(q0: Quaternion): (number, number, number) 
    AssertType(1, q0, "Quaternion")
    
    q0 = Normalize(q0)
    local qX, qY, qZ, qW = q0.X, q0.Y, q0.Z, q0.W
    local rX, rY, rZ

    local test = qY * qW - qX * qZ
    if math.abs(test) > 0.5 - EPSILON then
        local sign = test >= 0 and 1 or -1
        rX = 0
        rY = sign * math.pi / 2
        rZ = sign * 2 * -math.atan2(qX, qW)
        return rX, rY, rZ
    end

    local sqy = qY * qY
    rX = math.atan2(2 * (qX * qW + qY * qZ), 1 - 2 * (qX * qX + sqy))
    rY = math.asin(2 * test)
    rZ = math.atan2(2 * (qX * qY + qZ * qW), 1 - 2 * (qZ * qZ + sqy))

    return rX, rY, rZ
end

local TO_EULER_ANGLES_MAP = {
    ["XYZ"] = ToEulerAnglesXYZ,
    ["XZY"] = ToEulerAnglesXZY,
    ["YZX"] = ToEulerAnglesYZX,
    ["YXZ"] = ToEulerAnglesYXZ,
    ["ZXY"] = ToEulerAnglesZXY,
    ["ZYX"] = ToEulerAnglesZYX
}

local function ToEulerAngles(q0: Quaternion, rotationOrder: Enum.RotationOrder?): (number, number, number) 
    
    AssertType(2, rotationOrder, "Enum.RotationOrder", "nil")
    
    if not rotationOrder then rotationOrder = Enum.RotationOrder.XYZ end

    return TO_EULER_ANGLES_MAP[rotationOrder.Name](q0)
end


Quaternion.ToEulerAngles = ToEulerAngles
Quaternion.ToEulerAnglesXYZ = ToEulerAnglesXYZ
Quaternion.ToEulerAnglesYXZ = ToEulerAnglesYXZ

Quaternion.ToOrientation = ToEulerAnglesYXZ

local function GetComponents(q0: Quaternion): (number, number, number, number)
    AssertType(1, q0, "Quaternion")
    return q0.X, q0.Y, q0.Z, q0.W
end

Quaternion.GetComponents = GetComponents

Quaternion.components = GetComponents

local function round(number: number, decimalPlaces: number?): string
    AssertType(1, number, "number")
    AssertType(2, decimalPlaces, "number", "nil")
    
    if decimalPlaces then
        decimalPlaces = math.max(0, decimalPlaces)
        local formatString = string.format("%%.%df", decimalPlaces)
        local roundedNumberString = string.format(formatString, number)
        return roundedNumberString
    end
    return tostring(number)
end

local function ToString(q0: Quaternion, decimalPlaces: number?): string
    AssertType(1, q0, "Quaternion")
    AssertType(2, decimalPlaces, "number", "nil")
    
    return 
        round(q0.X, decimalPlaces) .. ", "
        .. round(q0.Y, decimalPlaces) .. ", "
        .. round(q0.Z, decimalPlaces) .. ", "
        .. round(q0.W, decimalPlaces)
end

Quaternion.__tostring = ToString
Quaternion.ToString = ToString


function Quaternion.__index(q0, key)
    local functionIndex = Quaternion[key]
    if functionIndex then
        return functionIndex
    end
    local lower = string.lower(key)
    local cached = rawget(q0, "_cached")
    if lower == "unit" then
        if not cached.unit then
            local norm = Normalize(q0)
            cached.unit = norm
            return norm
        end
        return cached.unit
    elseif lower == "magnitude" then
        if not cached.magnitude then
            local mag = Length(q0)
            cached.magnitude = mag
            return mag
        end
        return cached.magnitude
    end
    return nil
end

-- Won't throw if we index directly, will instead throw read-only error
-- i.e. this only throws if we try to set anything other than w,x,y,z
function Quaternion.__newindex(_, key)
    error(tostring(key) .. " cannot be assigned to")
end

-- Prevent identity and zero from being changed (const members)
table.freeze(Quaternion)

return Quaternion

--[==[
    Sources:
    [1]: https://github.com/KieranWynn/pyquaternion/blob/master/pyquaternion
        /quaternion.py
    [2]: https://www.euclideanspace.com/maths/geometry/rotations/conversions
    [3]: https://github.com/Quenty/NevermoreEngine/blob/main/src/qframe/src
        /Shared/QFrame.lua
    [4]: https://github.com/Quenty/NevermoreEngine/blob/main/src/quaternion/src
        /Shared/Quaternion.lua
    [5]: https://www.andre-gaschler.com/rotationconverter/
    [6]: https://stackoverflow.com/questions/31600717
--]==]


