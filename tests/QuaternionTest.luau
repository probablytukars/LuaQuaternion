local Assert = require("tests/Assert")
local Vector3 = require("mocks/Vector3")
local CFrame = require("mocks/CFrame")

local Enum = {}
Enum.RotationOrder = {
    XYZ = {Value = 0, Name = "XYZ"},
    XZY = {Value = 1, Name = "XZY"},
    YZX = {Value = 2, Name = "YZX"},
    YXZ = {Value = 3, Name = "YXZ"},
    ZXY = {Value = 4, Name = "ZXY"},
    ZYX = {Value = 5, Name = "ZYX"}
}

local EPSILON = 5e-4

local QuaternionTest = {}
QuaternionTest._order = {
    "ConstructorGroup",
    "DeconstructorGroup",
    "MathGroup",
    "MethodsGroup"
}

local rotationOrders = {"XYZ", "XZY", "YXZ", "YZX", "ZXY", "ZYX"}

local Quaternion
local testData

function QuaternionTest.init(library, data)
    Quaternion = library
    testData = data
end

local function printTable(tbl)
    local tableString = "{\n"
    for key, value in pairs(tbl) do
        tableString = tableString .. '\t["' .. tostring(key) .. '"] = ' 
            .. tostring(value) .. "\n"
    end
    tableString = tableString .. "}"
    print(tableString)
end

local function tableToVector(table)
    return Vector3.new(table.X, table.Y, table.Z)
end


local ConstructorGroup = {}
QuaternionTest.ConstructorGroup = ConstructorGroup
ConstructorGroup._order = {
    "new", "identity", "zero", "fromAxisAngle", "fromCFrame", "fromMatrix", 
    "lookAt", "Angles", "fromOrientation", "fromEulerAngles", "fromVector", 
    "RandomQuaternion"
}
ConstructorGroup._DisplayName = "Constructor Tests"

local new = {}
ConstructorGroup.new = new
new._order = {
    "Full", "Empty", "Frozen", "InvalidIndex", "ReadValues"
}

new.Full = {
    DisplayName = "Full",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        return Assert.KeyValues(q0, {X = 2, Y = 3, Z = 4, W = 5})
    end
}

new.Empty = {
    DisplayName = "Empty",
    test = function()
        local q0 = Quaternion.new()
        return Assert.KeyValues(q0, {X = 0, Y = 0, Z = 0, W = 1})
    end,
}

new.Frozen = {
    DisplayName = "Frozen",
    test = function()
        return Assert.ErrorThrownAll(
            "attempt to modify a readonly table", function()
                local q0 = Quaternion.new()
                q0.X = 1
            end, function()
                local q0 = Quaternion.new()
                q0.Y = 1
            end, function()
                local q0 = Quaternion.new()
                q0.Z = 1
            end, function()
                local q0 = Quaternion.new()
                q0.W = 0
            end)
    end,
}

new.InvalidIndex = {
    DisplayName = "Invalid Index",
    test = function()
        return Assert.ErrorThrown("T cannot be assigned to", function()
            local q0 = Quaternion.new()
            q0.T = 0
        end)
    end,
}

new.ReadValues = {
    DisplayName = "Read Values",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        
        return Assert.Equals(q0.X, 2)
            and Assert.Equals(q0.Y, 3)
            and Assert.Equals(q0.Z, 4)
            and Assert.Equals(q0.W, 5)
    end,
}


local identity = {}
ConstructorGroup.identity = identity
identity._order = {"Identity", "Const"}

identity.Identity = {
    DisplayName = "Identity",
    test = function()
        local qi = Quaternion.identity
        return Assert.KeyValues(qi, {X = 0, Y = 0, Z = 0, W = 1})
    end,
}

identity.Const = {
    DisplayName = "Const",
    test = function()
        local readOnly = "attempt to modify a readonly table"
        return Assert.ErrorThrown(readOnly, function()
            Quaternion.identity = Quaternion.new(5, 6, 7, 8)
        end)
    end,
}

local zero = {}
ConstructorGroup.zero = zero
zero._order = {"zero", "Const"}

zero.zero = {
    DisplayName = "Zero",
    test = function()
        local qi = Quaternion.zero
        return Assert.KeyValues(qi, {X = 0, Y = 0, Z = 0, W = 0})
    end,
}

zero.Const = {
    DisplayName = "Const",
    test = function()
        local readOnly = "attempt to modify a readonly table"
        return Assert.ErrorThrown(readOnly, function()
            Quaternion.zero = Quaternion.new(5, 6, 7, 8)
        end)
    end,
}

local fromAxisAngle = {}
ConstructorGroup.fromAxisAngle = fromAxisAngle
fromAxisAngle._order = {
    "Constructor", "Zero", "NonUnitVector", "BigAngle"
}

fromAxisAngle.Constructor = {
    DisplayName = "Constructor",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local axis, angle = table.unpack(standard.axisAngle)
                    local axisVec = tableToVector(axis)
                    local q0 = Quaternion.fromAxisAngle(axisVec, angle)
                    local qe = standard.quaternion
                    
                    if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}

fromAxisAngle.Zero = {
    DisplayName = "Zero Axis Zero Angle",
    test = function()
        local axis = Vector3.zero
        local angle = 0

        local q = Quaternion.fromAxisAngle(axis, angle)

        return Assert.KeyValues(q, {X = 0, Y = 0, Z = 0, W = 1})
    end,
}

fromAxisAngle.NonUnitVector = {
    DisplayName = "Non Unit Vector",
    test = function()
        local axis = Vector3.yAxis * 2
        local angle = 0

        local q = Quaternion.fromAxisAngle(axis, angle)

        return Assert.KeyValues(q, {X = 0, Y = 0, Z = 0, W = 1})
    end,
}

fromAxisAngle.BigAngle = {
    DisplayName = "Big Angle",
    test = function()
        local axis = Vector3.yAxis * 2
        local angle = math.pi * 12

        local q = Quaternion.fromAxisAngle(axis, angle)

        return Assert.KeyValuesApprox(q, {X = 0, Y = 0, Z = 0, W = 1} ,EPSILON)
    end,
}


local fromCFrame = {}
ConstructorGroup.fromCFrame = fromCFrame
fromCFrame._order = {"Constructor"}

fromCFrame.Constructor = {
    DisplayName = "Constructor",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local cf = CFrame.fromMatrixArray(standard.matrix)
                    local q0 = Quaternion.fromCFrame(cf)
                    local qe = standard.quaternion
                    
                    if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
            return true
        end
    end,
}

local fromMatrix = {}
ConstructorGroup.fromMatrix = fromMatrix
fromMatrix._order = {"Constructor", "SameVectors"}

fromMatrix.Constructor = {
    DisplayName = "Constructor",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local cf = CFrame.fromMatrixArray(standard.matrix)
                    local q0 = Quaternion.fromMatrix(
                        cf.RightVector, 
                        cf.UpVector, 
                        -cf.LookVector
                    )
                    local qe = standard.quaternion
                    
                    if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}

fromMatrix.SameVectors = {
    DisplayName = "Same vectors",
    test = function()
        local cf = CFrame.fromMatrix(
            Vector3.zero, Vector3.xAxis, Vector3.yAxis, Vector3.xAxis
        )
        
        local q0 = Quaternion.fromCFrame(cf)
        local qe = Quaternion.new(0, 0, 0, 1)
        if not Assert.KeyValuesApprox(qe, q0, EPSILON) then
            return false
        end
        
        local cf = CFrame.fromMatrix(
            Vector3.zero, Vector3.zAxis, Vector3.yAxis, Vector3.zAxis
        )
        
        local q0 = Quaternion.fromCFrame(cf)
        local qe = Quaternion.new(-0, -0.707107, 0, 0.707107)
        if not Assert.KeyValuesApprox(qe, q0, EPSILON) then
            return false
        end
        
        local cf = CFrame.fromMatrix(
            Vector3.zero, Vector3.yAxis, Vector3.yAxis, Vector3.yAxis
        )
        
        local q0 = Quaternion.fromCFrame(cf)
        local qe = Quaternion.new(0.5, 0.5, 0.5, 0.5)
        if not Assert.KeyValuesApprox(qe, q0, EPSILON) then
            return false
        end
        
        local cf = CFrame.fromMatrix(
            Vector3.zero, Vector3.yAxis, Vector3.xAxis, Vector3.yAxis
        )
        
        local q0 = Quaternion.fromCFrame(cf)
        local qe = Quaternion.new(0.707107, 0.707107, 0, 0)
        if not Assert.KeyValuesApprox(qe, q0, EPSILON) then
            return false
        end
        
        local cf = CFrame.fromMatrix(
            Vector3.zero, Vector3.yAxis, Vector3.zAxis, Vector3.yAxis
        )
        
        local q0 = Quaternion.fromCFrame(cf)
        local qe = Quaternion.new(0.5, 0.5, 0.5, 0.5)
        if not Assert.KeyValuesApprox(qe, q0, EPSILON) then
            return false
        end
        
        local cf = CFrame.fromMatrix(
            Vector3.zero, Vector3.zero, Vector3.zero, Vector3.zero
        )
        
        local q0 = Quaternion.fromCFrame(cf)
        local qe = Quaternion.new(0, 0, 0, 1)
        if not Assert.KeyValuesApprox(qe, q0, EPSILON) then
            return false
        end
        
        return true
    end,
}


local lookAt = {}
ConstructorGroup.lookAt = lookAt
lookAt._order = {
    "FromLookAt", "FromLookAtWithUp", "LookIsSameAsUp", "RandomLocations"
}

lookAt.FromLookAt = {
    DisplayName = "From look at (1 arg)",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local lookAt = representation.lookAt
                    local cf = CFrame.fromMatrixArray(lookAt.matrix)
                    local q0 = Quaternion.lookAt(Vector3.zero, cf.LookVector)
                    local qe = lookAt.quaternion
                    if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}

lookAt.FromLookAtWithUp = {
    DisplayName = "From look at with up vector (2 args)",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local lookAt = representation.lookWithUp
                    local cf = CFrame.fromMatrixArray(lookAt.matrix)
                    local q0 = Quaternion.lookAt(
                        Vector3.zero, cf.LookVector, cf.UpVector
                    )
                    local qe = lookAt.quaternion
                    if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}

lookAt.LookIsSameAsUp = {
    DisplayName = "Look vector is same as up vector",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local lookAt = representation.lookWithLook
                    local cf = CFrame.fromMatrixArray(lookAt.matrix)
                    local q0 = Quaternion.lookAt(
                        Vector3.zero, cf.LookVector, cf.LookVector
                    )
                    local qe = lookAt.quaternion
                    if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}

lookAt.RandomLocations = {
    DisplayName = "Random Locations",
    test = function()
        for _, look in pairs(testData.LookAt) do
            local from, lookAtPos = look.from, look.at
            local fromVec, lookVec = tableToVector(from)
            local lookVec = tableToVector(lookAtPos)
            local q0 = Quaternion.lookAt(fromVec, lookVec)
            local qe = look.quaternion
            if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                return false, "Failed on " .. collectionName
            end
        end
        return true
    end,
}


local Angles = {}
ConstructorGroup.Angles = Angles
Angles._order = {"Constructor"}

Angles.Constructor = {
    DisplayName = "Constructor",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local XYZ = standard.XYZ
                    local rx, ry, rz = table.unpack(XYZ)
                    local q0 = Quaternion.Angles(rx, ry, rz)
                    local q1 = Quaternion.fromEulerAnglesXYZ(rx, ry, rz)
                    local qe = standard.quaternion
                    
                    if 
                    not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) 
                    or not(Assert.QuaternionsEqualApprox(qe, q1, EPSILON)) 
                    then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}


local fromOrientation = {}
ConstructorGroup.fromOrientation = fromOrientation
fromOrientation._order = {"Constructor"}

fromOrientation.Constructor = {
    DisplayName = "Constructor",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local YXZ = standard.YXZ
                    local rx, ry, rz = table.unpack(YXZ)
                    local q0 = Quaternion.fromOrientation(rx, ry, rz)
                    local q1 = Quaternion.fromEulerAnglesYXZ(rx, ry, rz)
                    local qe = standard.quaternion
                    
                    if 
                    not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) 
                    or not(Assert.QuaternionsEqualApprox(qe, q1, EPSILON)) 
                    then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end,
}

local fromEulerAngles = {}
ConstructorGroup.fromEulerAngles = fromEulerAngles
fromEulerAngles._order = {"Constructor"}

fromEulerAngles.Constructor = {
    DisplayName = "Constructor",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    for _, rotationOrder in pairs(rotationOrders) do
                        local ang = standard[rotationOrder]
                        local rx, ry, rz = table.unpack(ang)
                        local q0 = Quaternion.fromEulerAngles(
                            rx, ry, rz, Enum.RotationOrder[rotationOrder]
                        )
                        local qe = standard.quaternion
                        if not(Assert.QuaternionsEqualApprox(qe, q0, EPSILON)) then
                            return false, "Failed on " .. collectionName
                        end
                    end
                end
            end
        end
        return true
    end,
}

local fromVector = {}
ConstructorGroup.fromVector = fromVector
fromVector._order = {"Constructor"}

fromVector.Constructor = {
    DisplayName = "Constructor",
    test = function()
        local testVector = Vector3.new(0.25, -0.75, 3)
        local q = Quaternion.fromVector(testVector)
        return Assert.KeyValues(q, {
            X = testVector.X, 
            Y = testVector.Y, 
            Z = testVector.Z,
            W = 0
        })
    end,
}



local RandomQuaternion = {}
ConstructorGroup.RandomQuaternion = RandomQuaternion
RandomQuaternion._order = {"IsUnit"}

RandomQuaternion.IsUnit = {
    DisplayName = "Is Unit",
    test = function()
        local randomQuaternion = Quaternion.RandomQuaternion(os.time())
        local q0 = randomQuaternion()
        local length = math.sqrt(q0.X^2 + q0.Y^2 + q0.Z^2 + q0.W^2)
        local dif1 = math.abs(1 - length)
        return dif1 < EPSILON
    end,
}










local DeconstructorGroup = {}
QuaternionTest.DeconstructorGroup = DeconstructorGroup
DeconstructorGroup._order = {
    "ToCFrame", "ToAxisAngle","ToEulerAnglesXYZ", "ToEulerAnglesYXZ", 
    "ToOrientation", "ToEulerAngles", "ToMatrix", "ToMatrixVectors", "Vector", 
    "Real",  "Imaginary", "GetComponents", "components", "ToString"
}
DeconstructorGroup._DisplayName = "Deconstructor Tests"

local ToCFrame = {}
DeconstructorGroup.ToCFrame = ToCFrame
ToCFrame._order = {
    "Unit", "Zero", "NonUnit"
}

ToCFrame.Unit = {
    DisplayName = "Unit",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local quat = standard.quaternion
                    local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
                    local q0 = Quaternion.new(qX, qY, qZ, qW)
                    local qcf = q0:ToCFrame()
                    local ecf = CFrame.fromMatrixArray(standard.ortho)
                    if not Assert.CFramesApproxEqual(ecf, qcf, EPSILON) then
                        return false
                    end
                end
            end
        end
        return true
    end
}

ToCFrame.Zero = {
    DisplayName = "Zero",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local qtcf = q0:ToCFrame()
        
        local expectedCF = CFrame.fromMatrixArray({
            1, 0, 0,
            0, 1, 0,
            0, 0, 1
        })
        
        return Assert.CFramesApproxEqual(qtcf, expectedCF, EPSILON)
    end
}

ToCFrame.NonUnit = {
    DisplayName = "Non Unit",
    test = function()
        local q0 = Quaternion.new(1.9608752, 1.2719190, -4.1337369, 2.3318514)
        local qtcf = q0:ToCFrame()
        
        local expectedCF = CFrame.fromMatrixArray({
            -0.3366784,  0.8670346, -0.3672855,
            -0.5105870, -0.4958354, -0.7024586,
            -0.7911691, -0.0489714,  0.6096337
        })
        
        return Assert.CFramesApproxEqual(qtcf, expectedCF, EPSILON)
    end
}



local ToAxisAngle = {}
DeconstructorGroup.ToAxisAngle = ToAxisAngle
ToAxisAngle._order = {
    "Unit", "Zero", "NonUnit"
}

ToAxisAngle.Unit = {
    DisplayName = "Unit",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local quat = standard.quaternion
                    local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
                    local qe = Quaternion.new(qX, qY, qZ, qW)
                    local axis, angle = qe:ToAxisAngle()
                    local qr = Quaternion.fromAxisAngle(axis, angle)
                    if not(Assert.QuaternionsEqualApprox(qe, qr, EPSILON)) then
                        return false, "Failed on " .. collectionName
                    end
                end
            end
        end
        return true
    end
}

ToAxisAngle.Zero = {
    DisplayName = "Zero",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local axis, angle = q0:ToAxisAngle()

        local expect_axis = Vector3.new(0, 0, 0)
        local expect_angle = 0

        return 
            Assert.ApproxEquals(axis.X, expect_axis.X, EPSILON)
            and Assert.ApproxEquals(axis.Y, expect_axis.Y, EPSILON)
            and Assert.ApproxEquals(axis.Z, expect_axis.Z, EPSILON)
            and Assert.ApproxEquals(angle, expect_angle, EPSILON)
    end
}

ToAxisAngle.NonUnit = {
    DisplayName = "Non Unit",
    test = function()
        local q0 = Quaternion.new(1.9608752, 1.2719190, -4.1337369, 2.3318514)
        local axis, angle = q0:ToAxisAngle()
        
        local expect_axis = Vector3.new(0.4129248, 0.2678431, -0.8704902)
        local expect_angle = 2.2286756
        
        return 
            Assert.ApproxEquals(axis.X, expect_axis.X, EPSILON)
            and Assert.ApproxEquals(axis.Y, expect_axis.Y, EPSILON)
            and Assert.ApproxEquals(axis.Z, expect_axis.Z, EPSILON)
            and Assert.ApproxEquals(angle, expect_angle, EPSILON)
    end
}



local ToEulerAnglesXYZ = {}
DeconstructorGroup.ToEulerAnglesXYZ = ToEulerAnglesXYZ
ToEulerAnglesXYZ._order = {
    "UnitLessHalf", "UnitHalf", "Zero", "NonUnit"
}

ToEulerAnglesXYZ.UnitLessHalf = {
    DisplayName = "Unit test < 0.5",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local quat = standard.quaternion
                    local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
                    local qe = Quaternion.new(qX, qY, qZ, qW)
                    local rx, ry, rz = qe:ToEulerAnglesXYZ()
                    local qr = Quaternion.fromEulerAnglesXYZ(rx, ry, rz)
                    if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                        return false
                    end
                end
            end
        end
        return true
    end
}

ToEulerAnglesXYZ.UnitHalf = {
    DisplayName = "Unit test >= 0.5",
    test = function()
        for k, standard in pairs(testData.HalfUnit) do
            local qX, qY, qZ, qW = table.unpack(standard.quaternion)
            local q0 = Quaternion.new(qX, qY, qZ, qW)
            local qe = Quaternion.new(qX, qY, qZ, qW)
            local rx, ry, rz = qe:ToEulerAnglesXYZ()
            local qr = Quaternion.fromEulerAnglesXYZ(rx, ry, rz)
            if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                return false
            end
        end
        return true
    end
}

ToEulerAnglesXYZ.Zero = {
    DisplayName = "Zero",
    test = function()
        local qX, qY, qZ, qW = 0, 0, 0, 0
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rx, ry, rz = q0:ToEulerAnglesXYZ()

        return Assert.AnglesApproxEquals(rx, 0, EPSILON)
            and Assert.AnglesApproxEquals(ry, 0, EPSILON)
            and Assert.AnglesApproxEquals(rz, 0, EPSILON)
    end
}

ToEulerAnglesXYZ.NonUnit = {
    DisplayName = "Non Unit",
    test = function()
        local qX, qY, qZ, qW = 2, 5, 7, 4
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rx, ry, rz = q0:ToEulerAnglesXYZ()
        local erx, ery, erz = -0.9827937, 0.8087203, 2.55359
        
        return Assert.AnglesApproxEquals(rx, erx, EPSILON)
        and Assert.AnglesApproxEquals(ry, ery, EPSILON)
        and Assert.AnglesApproxEquals(rz, erz, EPSILON)
    end
}



local ToEulerAnglesYXZ = {}
DeconstructorGroup.ToEulerAnglesYXZ = ToEulerAnglesYXZ
ToEulerAnglesYXZ._order = {
    "UnitLessHalf", "UnitHalf", "Zero", "NonUnit"
}

ToEulerAnglesYXZ.UnitLessHalf = {
    DisplayName = "Unit test < 0.5",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local quat = standard.quaternion
                    local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
                    local qe = Quaternion.new(qX, qY, qZ, qW)
                    local rx, ry, rz = qe:ToEulerAnglesYXZ()
                    local qr = Quaternion.fromEulerAnglesYXZ(rx, ry, rz)
                    if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                        return false
                    end
                end
            end
        end
        return true
    end
}

ToEulerAnglesYXZ.UnitHalf = {
    DisplayName = "Unit test >= 0.5",
    test = function()
        for k, standard in pairs(testData.HalfUnit) do
            local qX, qY, qZ, qW = table.unpack(standard.quaternion)
            local q0 = Quaternion.new(qX, qY, qZ, qW)
            local qe = Quaternion.new(qX, qY, qZ, qW)
            local rx, ry, rz = qe:ToEulerAnglesYXZ()
            local qr = Quaternion.fromEulerAnglesYXZ(rx, ry, rz)
            if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                return false
            end
        end
        return true
    end
}

ToEulerAnglesYXZ.Zero = {
    DisplayName = "Zero",
    test = function()
        local qX, qY, qZ, qW = 0, 0, 0, 0
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rx, ry, rz = q0:ToEulerAnglesXYZ()

        return Assert.AnglesApproxEquals(rx, 0, EPSILON)
            and Assert.AnglesApproxEquals(ry, 0, EPSILON)
            and Assert.AnglesApproxEquals(rz, 0, EPSILON)
    end
}

ToEulerAnglesYXZ.NonUnit = {
    DisplayName = "Non Unit",
    test = function()
        local qX, qY, qZ, qW = 2, 5, 7, 4
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rx, ry, rz = q0:ToEulerAnglesYXZ()
        local erx, ery, erz = -0.6119541, 1.0838971, 1.7273982
        
        return Assert.AnglesApproxEquals(rx, erx, EPSILON)
        and Assert.AnglesApproxEquals(ry, ery, EPSILON)
        and Assert.AnglesApproxEquals(rz, erz, EPSILON)
    end
}



local ToOrientation = {}
DeconstructorGroup.ToOrientation = ToOrientation
ToOrientation._order = {
    "UnitLessHalf", "UnitHalf", "Zero", "NonUnit"
}

ToOrientation.UnitLessHalf = {
    DisplayName = "Unit test < 0.5",
    test = function()
        for collectionName, rc in pairs(testData) do
            if rc[1].standard then
                for k, representation in pairs(rc) do
                    local standard = representation.standard
                    local quat = standard.quaternion
                    local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
                    local qe = Quaternion.new(qX, qY, qZ, qW)
                    local rx, ry, rz = qe:ToOrientation()
                    local qr = Quaternion.fromOrientation(rx, ry, rz)
                    if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                        return false
                    end
                end
            end
        end
        return true
    end
}

ToOrientation.UnitHalf = {
    DisplayName = "Unit test >= 0.5",
    test = function()
        for k, standard in pairs(testData.HalfUnit) do
            local qX, qY, qZ, qW = table.unpack(standard.quaternion)
            local q0 = Quaternion.new(qX, qY, qZ, qW)
            local qe = Quaternion.new(qX, qY, qZ, qW)
            local rx, ry, rz = qe:ToOrientation()
            local qr = Quaternion.fromOrientation(rx, ry, rz)
            if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                return false
            end
        end
        return true
    end
}

ToOrientation.Zero = {
    DisplayName = "Zero",
    test = function()
        local qX, qY, qZ, qW = 0, 0, 0, 0
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rx, ry, rz = q0:ToOrientation()

        return Assert.AnglesApproxEquals(rx, 0, EPSILON)
            and Assert.AnglesApproxEquals(ry, 0, EPSILON)
            and Assert.AnglesApproxEquals(rz, 0, EPSILON)
    end
}

ToOrientation.NonUnit = {
    DisplayName = "Non Unit",
    test = function()
        local qX, qY, qZ, qW = 2, 5, 7, 4
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rx, ry, rz = q0:ToOrientation()
        local erx, ery, erz = -0.6119541, 1.0838971, 1.7273982
        
        return Assert.AnglesApproxEquals(rx, erx, EPSILON)
        and Assert.AnglesApproxEquals(ry, ery, EPSILON)
        and Assert.AnglesApproxEquals(rz, erz, EPSILON)
    end
}

local ToEulerAngles = {}
DeconstructorGroup.ToEulerAngles = ToEulerAngles
ToEulerAngles._order = {}

for _, rotationOrder in pairs(rotationOrders) do
    local name = "ToEulerAngles_" .. rotationOrder
    local UnitLessHalf = "UnitLessHalf_" .. name
    local UnitHalf = "UnitHalf_" .. name
    local Zero = "Zero_" .. name
    local NonUnit = "NonUnit" .. name
    
    ToEulerAngles[UnitLessHalf] = {
        DisplayName = rotationOrder .. " Unit Quaternion: test < 0.5",
        test = function()
            for collectionName, rc in pairs(testData) do
                if rc[1].standard then
                    for k, representation in pairs(rc) do
                        local standard = representation.standard
                        local quat = standard.quaternion
                        local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
                        local qe = Quaternion.new(qX, qY, qZ, qW)
                        local rx, ry, rz = qe:ToEulerAngles(Enum.RotationOrder[rotationOrder])
                        local qr = Quaternion.fromEulerAngles(rx, ry, rz, Enum.RotationOrder[rotationOrder])
                        if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                            return false
                        end
                    end
                end
            end
            return true
        end,
    }
    
    ToEulerAngles[UnitHalf] = {
        DisplayName = rotationOrder .. " Unit Quaternion: test >= 0.5",
        test = function()
            for k, standard in pairs(testData.HalfUnit) do
                local qX, qY, qZ, qW = table.unpack(standard.quaternion)
                local q0 = Quaternion.new(qX, qY, qZ, qW)
                local qe = Quaternion.new(qX, qY, qZ, qW)
                local rx, ry, rz = qe:ToEulerAngles(Enum.RotationOrder[rotationOrder])
                local qr = Quaternion.fromEulerAngles(rx, ry, rz, Enum.RotationOrder[rotationOrder])
                if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                    return false
                end
            end
            return true
        end
    }
    
    ToEulerAngles[Zero] = {
        DisplayName = rotationOrder .. " Zero Quaternion",
        test = function()
            local qX, qY, qZ, qW = 0, 0, 0, 0
            local q0 = Quaternion.new(qX, qY, qZ, qW)
            local rx, ry, rz = q0:ToEulerAngles(Enum.RotationOrder[rotationOrder])

            return Assert.AnglesApproxEquals(rx, 0, EPSILON)
                and Assert.AnglesApproxEquals(ry, 0, EPSILON)
                and Assert.AnglesApproxEquals(rz, 0, EPSILON)
        end
    }

    ToEulerAngles[NonUnit] = {
        DisplayName = rotationOrder .. " Non Unit Quaternion",
        test = function()
            local qX, qY, qZ, qW = 2, 5, 7, 4
            local qo = Quaternion.new(qX, qY, qZ, qW)
            local qe = qo.Unit
            local rx, ry, rz = qo:ToEulerAngles(Enum.RotationOrder[rotationOrder])
            local qr = Quaternion.fromEulerAngles(rx, ry, rz, Enum.RotationOrder[rotationOrder])
            if not Assert.QuaternionsEqualApprox(qe, qr, 1e-3) then
                return false
             end
             return true
        end
    }
    
    table.insert(ToEulerAngles._order, UnitLessHalf)
    table.insert(ToEulerAngles._order, UnitHalf)
    table.insert(ToEulerAngles._order, Zero)
    table.insert(ToEulerAngles._order, NonUnit)
end


local ToMatrix = {}
DeconstructorGroup.ToMatrix = ToMatrix
ToMatrix._order = {
    "RandomQuaternions", "PolarQuaternions", "Zero", "NonUnit"
}

ToMatrix.RandomQuaternions = {
    DisplayName = "Random Quaternions",
    test = function()
        local randomQuaternion = Quaternion.RandomQuaternion(os.time())
        for i = 1, 100 do
            local q0 = randomQuaternion()
            local m00, m01, m02, m10, m11, m12, m20, m21, m22 = q0:ToMatrix()
            
            local testCFrame = CFrame.new(0, 0, 0, q0.X, q0.Y, q0.Z, q0.W)
            local qCFrame = CFrame.fromMatrixArray({
                m00, m01, m02, 
                m10, m11, m12, 
                m20, m21, m22
            })
            
            if not Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON)
            then
                return false
            end

        end
        return true
    end
}

ToMatrix.PolarQuaternions = {
    DisplayName = "Polar Quaternions",
    test = function()
        for i, input in pairs(testData.HalfUnit) do
            local quat = input.quaternion
            local qX, qY, qZ, qW = quat.X, quat.Y, quat.Z, quat.W
            local q0 = Quaternion.new(qX, qY, qZ, qW)
            local m00, m01, m02, m10, m11, m12, m20, m21, m22 = q0:ToMatrix()

            local testCFrame = CFrame.new(0, 0, 0, qX, qY, qZ, qW)
            local qCFrame = CFrame.fromMatrixArray({
                m00, m01, m02, 
                m10, m11, m12, 
                m20, m21, m22
            })
            if not Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON) 
            then
                return false
            end
        end
        return true
    end
}

ToMatrix.Zero = {
    DisplayName = "Zero Quaternion",
    test = function()
        local qX, qY, qZ, qW = 0, 0, 0, 0
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local m00, m01, m02, m10, m11, m12, m20, m21, m22 = q0:ToMatrix()

        local testCFrame = CFrame.fromMatrixArray({
            1, 0 ,0, 
            0, 1, 0, 
            0, 0, 1
        })
        
        local qCFrame = CFrame.fromMatrixArray({
            m00, m01, m02, 
            m10, m11, m12, 
            m20, m21, m22
        })

        return Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON) 
    end
}

ToMatrix.NonUnit = {
    DisplayName = "Non Unit Quaternion",
    test = function()
        local qX, qY, qZ, qW = 2, 5, 7, 4
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local m00, m01, m02, m10, m11, m12, m20, m21, m22 = q0:ToMatrix()
        
        local testCFrame = CFrame.fromMatrixArray({
            -0.5744681, -0.3829787,  0.7234042,
            0.8085107, -0.1276596,  0.5744681,
            -0.1276596,  0.9148936,  0.3829787
        })
        
        local qCFrame = CFrame.fromMatrixArray({
            m00, m01, m02, 
            m10, m11, m12, 
            m20, m21, m22
        })
        
        return Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON)
    end
}


local ToMatrixVectors = {}
DeconstructorGroup.ToMatrixVectors = ToMatrixVectors
ToMatrixVectors._order = {
    "RandomQuaternions", "PolarQuaternions", "Zero", "NonUnit"
}

ToMatrixVectors.RandomQuaternions = {
    DisplayName = "Random Quaternions",
    test = function()
        local randomQuaternion = Quaternion.RandomQuaternion(os.time())
        for i = 1, 100 do
            local q0 = randomQuaternion()
            local rightVector, upVector, backVector = q0:ToMatrixVectors()
            
            local testCFrame = CFrame.new(0, 0, 0, q0.X, q0.Y, q0.Z, q0.W)
            local qCFrame = CFrame.fromMatrix(
                Vector3.zero, rightVector, upVector, backVector
            )
            
            if not Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON) 
            then
                return false
            end

        end
        return true
    end
}

ToMatrixVectors.PolarQuaternions = {
    DisplayName = "Polar Quaternions",
    test = function()
        for i, input in pairs(testData.HalfUnit) do
            local qX, qY, qZ, qW = input[1], input[2], input[3], input[4]
            local q0 = Quaternion.new(qX, qY, qZ, qW)
            local rightVector, upVector, backVector = q0:ToMatrixVectors()

            local testCFrame = CFrame.new(0, 0, 0, q0.X, q0.Y, q0.Z, q0.W)
            local qCFrame = CFrame.fromMatrix(
                Vector3.zero, rightVector, upVector, backVector
            )

            if not Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON) 
            then
                return false
            end
        end
        return true
    end
}

ToMatrixVectors.Zero = {
    DisplayName = "Zero Quaternion",
    test = function()
        local qX, qY, qZ, qW = 0, 0, 0, 0
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rightVector, upVector, backVector = q0:ToMatrixVectors()

        local testCFrame = CFrame.fromMatrixArray({
            1, 0 ,0, 
            0, 1, 0, 
            0, 0, 1
        })
        local qCFrame = CFrame.fromMatrix(
            Vector3.zero, rightVector, upVector, backVector
        )

        return Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON) 
    end
}

ToMatrixVectors.NonUnit = {
    DisplayName = "Non Unit Quaternion",
    test = function()
        local qX, qY, qZ, qW = 2, 5, 7, 4
        local q0 = Quaternion.new(qX, qY, qZ, qW)
        local rightVector, upVector, backVector = q0:ToMatrixVectors()

        local testCFrame = CFrame.fromMatrixArray({
            -0.5744681, -0.3829787,  0.7234042,
            0.8085107, -0.1276596,  0.5744681,
            -0.1276596,  0.9148936,  0.3829787
        })
        local qCFrame = CFrame.fromMatrix(
            Vector3.zero, rightVector, upVector, backVector
        )
        
        return Assert.CFramesApproxEqual(testCFrame, qCFrame, EPSILON)
    end
}



local Vector = {}
DeconstructorGroup.Vector = Vector
Vector._order = {
    "Vector"
}

Vector.Vector = {
    DisplayName = "Vector",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local vector = q0:Vector()
        local testVector = Vector3.new(2, 3, 4)
        return Assert.VectorsApproxEqual(testVector, vector, EPSILON)
    end
}



local Real = {}
DeconstructorGroup.Real = Real
Real._order = {
    "Real"
}

Real.Real = {
    DisplayName = "Real",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local qr = q0:Real()
        local qt = Quaternion.new(0, 0, 0, 5)
        
        return Assert.KeyValuesApprox(qt, qr, EPSILON)
    end
}



local Imaginary = {}
DeconstructorGroup.Imaginary = Imaginary
Imaginary._order = {
    "Imaginary"
}

Imaginary.Imaginary = {
    DisplayName = "Imaginary",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local qr = q0:Imaginary()
        local qt = Quaternion.new(2, 3, 4, 0)

        return Assert.KeyValuesApprox(qt, qr, EPSILON)
    end
}



local GetComponents = {}
DeconstructorGroup.GetComponents = GetComponents
GetComponents._order = {
    "GetComponents"
}

GetComponents.GetComponents = {
    DisplayName = "Get Components",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local qX, qY, qZ, qW = q0:GetComponents()
        
        return Assert.ApproxEquals(qX, 2, EPSILON)
            and Assert.ApproxEquals(qY, 3, EPSILON)
            and Assert.ApproxEquals(qZ, 4, EPSILON)
            and Assert.ApproxEquals(qW, 5, EPSILON)
    end
}



local components = {}
DeconstructorGroup.components = components
components._order = {
    "components"
}

components.components = {
    DisplayName = "components",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local qX, qY, qZ, qW = q0:components()

        return Assert.ApproxEquals(qX, 2, EPSILON)
            and Assert.ApproxEquals(qY, 3, EPSILON)
            and Assert.ApproxEquals(qZ, 4, EPSILON)
            and Assert.ApproxEquals(qW, 5, EPSILON)
    end
}



local ToString = {}
DeconstructorGroup.ToString = ToString
ToString._order = {
    "Standard", "DecimalPlaces", "BuiltIn"
}

ToString.Standard = {
    DisplayName = "Standard",
    test = function()
        local q0 = Quaternion.new(
            0.2721655269759087, 
            0.408248290463863, 
            0.5443310539518174, 
            0.6804138174397717
        )
        
        local qts = q0:ToString()
        
        return Assert.Equals(
            "0.2721655269759087, 0.408248290463863, "
            .. "0.5443310539518174, 0.6804138174397717",
            qts
        )
    end
}

ToString.DecimalPlaces = {
    DisplayName = "Decimal Places",
    test = function()
        local q0 = Quaternion.new(
            0.2721655269759087, 
            0.408248290463863, 
            0.5443310539518174, 
            0.6804138174397717
        )

        local qts = q0:ToString(5)
        local qt0 = q0:ToString(0)

        return Assert.Equals(
            "0.27217, 0.40825, 0.54433, 0.68041",
            qts
        ) and Assert.Equals("0, 0, 1, 1", qt0)
    end
}

ToString.BuiltIn = {
    DisplayName = "Built In",
    test = function()
        local q0 = Quaternion.new(
            0.2721655269759087, 
            0.408248290463863, 
            0.5443310539518174, 
            0.6804138174397717
        )

        local qts = tostring(q0)

        return Assert.Equals(
            "0.2721655269759087, 0.408248290463863, "
                .. "0.5443310539518174, 0.6804138174397717",
            qts
        )
    end
}










local MathGroup = {}
QuaternionTest.MathGroup = MathGroup
MathGroup._order = {
    "add", "sub", "mul", "div", "unm", "pow", "eq", "lt", "le", "len", 
    "Exp", "ExpMap", "ExpMapSym", "Log", "LogMap", "LogMapSym"
}
MathGroup._DisplayName = "Math Tests"

local add = {}
MathGroup.add = add
add._order = {
    "QuaternionQuaternion"
}

add.QuaternionQuaternion = {
    DisplayName = "Quaternion + Quaternion",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local q1 = Quaternion.new(6, 7, 8, 9)
        
        local qr = q0 + q1
        local qe = Quaternion.new(8, 10, 12, 14)
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local sub = {}
MathGroup.sub = sub
sub._order = {
    "QuaternionQuaternion"
}

sub.QuaternionQuaternion = {
    DisplayName = "Quaternion - Quaternion",
    test = function()
        local q0 = Quaternion.new(5, 4, 3, 2)
        local q1 = Quaternion.new(6, 7, 8, 9)

        local qr = q0 - q1
        local qe = Quaternion.new(-1, -3, -5, -7)
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local mul = {}
MathGroup.mul = mul
mul._order = {
    "QuaternionQuaternion",
    "NumberQuaternion",
    "QuaternionNumber",
    "QuaternionVector3",
}

mul.QuaternionQuaternion = {
    DisplayName = "Quaternion * Quaternion",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local q1 = Quaternion.new(6, 7, 8, 9)
        
        local qr1 = q0 * q1
        local qe = Quaternion.new(28, 48, 44, -86)
        return Assert.KeyValuesApprox(qe, qe, EPSILON)
    end
}

mul.NumberQuaternion = {
    DisplayName = "number * Quaternion",
    test = function()
        local q0 = Quaternion.new(-0.6132499, 0.3980986, -0.6776496, 0.0789497)
        local scalar = 5.351
        
        local qr = scalar * q0
        local qe = Quaternion.new(
            -3.2815002149, 2.1302256086, -3.6261030096, 0.4224598447
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

mul.QuaternionNumber = {
    DisplayName = "Quaternion * number",
    test = function()
        local q0 = Quaternion.new(-0.6132499, 0.3980986, -0.6776496, 0.0789497)
        local scalar = 5.351

        local qr = q0 * scalar
        local qe = Quaternion.new(
            -3.2815002149, 2.1302256086, -3.6261030096, 0.4224598447
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

mul.QuaternionVector3 = {
    DisplayName = "Quaternion * Vector3",
    test = function()
        local q0 = Quaternion.new(-0.6132499, 0.3980986, -0.6776496, 0.0789497)
        local vector = Vector3.new(5, 7, -2)
        
        local vr = q0 * vector
        local ve = Vector3.new(
            -5.633782386779785, 
            -6.7849040031433105, 
            -0.47500181198120117
        )
        
        return Assert.VectorsApproxEqual(ve, vr, EPSILON)
    end
}



local div = {}
MathGroup.div = div
div._order = {
    "QuaternionNumber",
    "NumberQuaternion",
    "QuaternionQuaternion"
}

div.QuaternionNumber = {
    DisplayName = "Quaternion / number",
    test = function()
        local q0 = Quaternion.new(-3.2815002149, 2.1302256086, -3.6261030096, 0.4224598447)
        local scalar = 5.351

        local qr = q0 / scalar
        local qe = Quaternion.new(
            -0.6132499, 0.3980986, -0.6776496, 0.0789497
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

div.NumberQuaternion = {
    DisplayName = "number / Quaternion",
    test = function()
        local q0 = Quaternion.new(
            -3.2815002149, 2.1302256086, -3.6261030096, 0.4224598447
        )
        local scalar = 5.351

        local qr = scalar / q0
        local qe = Quaternion.new(
            -1.63065660508, 2.51194050921, -1.47568891061, 12.6662925888
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

div.QuaternionQuaternion = {
    DisplayName = "Quaternion / Quaternion",
    test = function()
        local q0 = Quaternion.new(
            -0.24209255263442386, 0.747715351302178, 
            -0.3142680285724605, -0.532492775165249
        )
        local q1 = Quaternion.new(
            0.6161914673752243, -0.35974130246884933, 
            0.6708265260848028, -0.20220297409528667
        )
        
        local qr = q0 / q1
        local qe = Quaternion.new(
            -0.011462763046563101, -0.31150274070277073, 
            0.7944013378649283, -0.5213071666459352
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local unm = {}
MathGroup.unm = unm
unm._order = {
    "unm"
}

unm.unm = {
    DisplayName = "-Quaternion",
    test = function()
        local q0 = Quaternion.new(-0.25, 0.5, 0.75, -0.75)
        
        local qr = -q0
        local qe = Quaternion.new(0.25, -0.5, -0.75, 0.75)
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local pow = {}
MathGroup.pow = pow
pow._order = {
    "QuaternionNumber", "QuaternionNumberNonUnit", "QuaternionNumberZero"
}

pow.QuaternionNumber = {
    DisplayName = "Quaternion ^ number (1e-4 <= scalar <= 1e7)",
    test = function()
        local testQuaternions = {
            Quaternion.new(-0.0712248, 0.6351379, 0.2064367, -0.7408851),
            Quaternion.new(0.0059295, 0.0088943, 0.0148238, 0.999833),
            Quaternion.new(0, 0, 0, 1)
        }
        
        local testPowers = {
            0, 1e-6, 1e-4, 0.1, 0.5, 0.9, 0.999, 
            1.001, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2, 5,
            1e1, 1e3, 1e5, 1e7
        }
        
        for _, quat in pairs(testQuaternions) do
            local axis, angle = quat:ToAxisAngle()
            for powsign = -1, 1, 2 do
                for _, unpow in testPowers do
                    local pow = powsign * unpow
                    local q0 = quat ^ pow
                    local naxis, nangle = q0:ToAxisAngle()
                    
                    local anglepow = angle * pow
                    local sign = (anglepow / (math.pi * 2)) % 2 > 1 and -1 or 1
                    local expect_axis = axis * sign
                    local expect_angle = (anglepow * sign) % (math.pi * 2)
                    if expect_angle < 1e-6 then
                        expect_axis = Vector3.zero
                    end
                    
                    local axisMatches = Assert.VectorsApproxEqual(
                        expect_axis, naxis, EPSILON
                    )
                    local angleMatches = Assert.ApproxEquals(
                        expect_angle, nangle, EPSILON
                    )
                    if not (axisMatches and angleMatches) then
                        return false
                    end
                end
            end
        end
        
        return true
    end
}

pow.QuaternionNumberNonUnit = {
    DisplayName = "non-unit Quaternion ^ number",
    test = function()
        local scalefactor = 2.5
        local q0 = Quaternion.new(
            -0.0712248, 0.6351379, 0.2064367, -0.7408851
        ) * scalefactor
        local pow = 4.3

        local qr = q0 ^ pow
        local qe = Quaternion.new(
            4.330246133831213, -38.614407284045384, 
            -12.55070877076347, -31.253697168093794
        )
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

pow.QuaternionNumberZero = {
    DisplayName = "Zero-Quaternion ^ number",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local pow = 4.3

        local qr = q0 ^ pow
        local qe = Quaternion.new(0, 0, 0, 0)

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

local eq = {}
MathGroup.eq = eq
eq._order = {
    "QuaternionQuaternion", "QuaternionQuaternionNE", "QuaternionAltType",
    "AltTypeQuaternion"
}

eq.QuaternionQuaternion = {
    DisplayName = "Quaternion == Quaternion",
    test = function()
        local q0 = Quaternion.new(2, 5, 3, 7)
        local q1 = Quaternion.new(2, 5, 3, 7)
        
        return q0 == q1
    end
}

eq.QuaternionQuaternionNE = {
    DisplayName = "Quaternion ~= Quaternion",
    test = function()
        local q0 = Quaternion.new(2, 5, 3, 7)
        local q1 = Quaternion.new(5, 3, 7, 2)
        return q0 ~= q1
    end
}

eq.QuaternionAltType = {
    DisplayName = "Quaternion ~= number, Quaternion ~= nil",
    test = function()
        local q0  = Quaternion.new(2, 5, 3, 7)
        local t1 = 5
        local t2 = nil
        
        return (q0 ~= t1) and (q0 ~= t2)
    end
}

eq.AltTypeQuaternion = {
    DisplayName = "number ~= Quaternion, nil ~= Quaternion",
    test = function()
        local t1 = 5
        local t2 = nil
        local q1 = Quaternion.new(2, 5, 3, 7)
        
        return (t1 ~= q1) and (t2 ~= q1)
    end
}



local lt = {}
MathGroup.lt = lt
lt._order = {
    "LessThan", "EqualTo", "GreaterThan"
}

lt.LessThan = {
    DisplayName = "Less than",
    test = function()
        local q0 = Quaternion.new(0, 0.7071068, 0, 0)
        local q1 = Quaternion.new(0, 0, 1, 0)
        
        return (q0 < q1) == true
    end,
}

lt.EqualTo = {
    DisplayName = "Equal to",
    test = function()
        local q0 = Quaternion.new(0, 0.7071068, 0, 0.7071068)
        local q1 = Quaternion.new(0.7071068, 0, 0, 0.7071068)
        
        return (q0 < q1) == false
    end,
}

lt.GreaterThan = {
    DisplayName = "Greater than",
    test = function()
        local q0 = Quaternion.new(0, 1, 0, 0)
        local q1 = Quaternion.new(0, 0.7071068, 0, 0)
        
        return (q0 < q1) == false
    end,
}



local le = {}
MathGroup.le = le
le._order = {
    "LessThan", "EqualTo", "GreaterThan"
}

le.LessThan = {
    DisplayName = "Less than",
    test = function()
        local q0 = Quaternion.new(0, 0.7071068, 0, 0)
        local q1 = Quaternion.new(0, 0, 1, 0)

        return (q0 <= q1) == true
    end,
}

le.EqualTo = {
    DisplayName = "Equal to",
    test = function()
        local q0 = Quaternion.new(0, 0.7071068, 0, 0.7071068)
        local q1 = Quaternion.new(0.7071068, 0, 0, 0.7071068)

        return (q0 <= q1) == true
    end,
}

le.GreaterThan = {
    DisplayName = "Greater than",
    test = function()
        local q0 = Quaternion.new(0, 1, 0, 0)
        local q1 = Quaternion.new(0, 0.7071068, 0, 0)

        return (q0 <= q1) == false
    end,
}





local len = {}
MathGroup.len = len
len._order = {
    "Positive", "Zero", "Negative"
}

len.Positive = {
    DisplayName = "#Quaternion (positive)",
    test = function()
        local q0 = Quaternion.new(2, 5, 7, 3)
        local expect_len = 9.32737905309
        local len = #q0
        
        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

len.Zero = {
    DisplayName = "#Quaternion (zero)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local expect_len = 0
        local len = #q0
        
        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

len.Negative = {
    DisplayName = "#Quaternion (negative)",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_len = 9.32737905309
        local len = #q0
        
        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}



local Exp = {}
MathGroup.Exp = Exp
Exp._order = {
    "NonZero", "ZeroIm", "Zero", "NonUnit"
}

Exp.NonZero = {
    DisplayName = "Non-zero imaginary components",
    test = function()
        local q0 = Quaternion.new(
            -0.0712248, 0.6351379, 0.2064367, -0.7408851
        )
        local qr = q0:Exp()
        local qe = Quaternion.new(
            -0.03145665186103275, 0.2805106059132132, 
            0.09117340312981514, 0.3731578354888756
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Exp.ZeroIm = {
    DisplayName = "Zero imaginary components",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 1)
        local qr = q0:Exp()
        local qe = Quaternion.new(0, 0, 0, 2.718281828459045)
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Exp.Zero = {
    DisplayName = "Zero",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local qr = q0:Exp()
        local qe = Quaternion.new(0, 0, 0, 1)

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Exp.NonUnit = {
    DisplayName = "NonUnit",
    test = function()
        local q0 = Quaternion.new(
            5, -2, -7, 4
        )
        local qr = q0:Exp()
        local qe = Quaternion.new(
            17.27459767624851, -6.909839070499405, 
            -24.184436746747917, -45.27596940351279
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end,
}


local ExpMap = {}
MathGroup.ExpMap = ExpMap
ExpMap._order = {
    "ExpMap"
}

ExpMap.ExpMap = {
    DisplayName = "Exp map",
    test = function()
        local q0 = Quaternion.new(-0.0712248, 0.6351379, 0.2064367, -0.7408851)
        local q1 = Quaternion.new(-0.2900209, 0.3866946, 0.0966736, 0.8700628)
        
        local qr = q0:ExpMap(q1)
        local qe = Quaternion.new(
            0.30038895322946757, 0.5576706582521578, 
            0.6289764510660503, -2.213869328050315
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

local ExpMapSym = {}
MathGroup.ExpMapSym = ExpMapSym
ExpMapSym._order = {
    "ExpMapSym"
}

ExpMapSym.ExpMapSym = {
    DisplayName = "Exp map symmetrical",
    test = function()
        local q0 = Quaternion.new(-0.0712248, 0.6351379, 0.2064367, -0.7408851)
        local q1 = Quaternion.new(-0.2900209, 0.3866946, 0.0966736, 0.8700628)

        local qr = q0:ExpMapSym(q1)
        local qe = Quaternion.new(
            -0.6340878101770875, 0.6140510440725047,
            0.13309931086082374, -2.213869328050315 
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local Log = {}
MathGroup.Log = Log
Log._order = {
    "NonZeroImaginaryReal", "NonZeroImaginaryZeroReal", "NonZeroReal", "Zero",
    "NonUnit"
}

Log.NonZeroImaginaryReal = {
    DisplayName = "Non-zero imaginary, non-zero real",
    test = function()
        local q0 = Quaternion.new(-0.0712248, 0.6351379, 0.2064367, -0.7408851)
        
        local qr = q0:Log()
        local qe = Quaternion.new(
            -0.25506345461237456, 2.2744952169644406, 
            0.7392714035108331, -1.6669825325829514e-08
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Log.NonZeroImaginaryZeroReal = {
    DisplayName = "Non-zero imaginary, zero real",
    test = function()
        local q0 = Quaternion.new(0.2156655, -0.970495, 0.1078328, 0)
        
        local qr = q0:Log()
        local qe = Quaternion.new(
            0.3387665640928002, -1.5244499311166697, 
            0.16938336058621387, 3.2835543966529616e-08
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Log.NonZeroReal = {
    DisplayName = "Zero imaginary, non-zero real",
    test = function()
        local q0 = Quaternion.identity
        
        local qr = q0:Log()
        local qe = Quaternion.zero
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Log.Zero = {
    DisplayName = "Zero imaginary, zero real",
    test = function()
        local q0 = Quaternion.zero
        
        local qr = q0:Log()
        local qe = Quaternion.new(0, 0, 0, -math.huge)
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Log.NonUnit = {
    DisplayName = "Zero imaginary, zero real",
    test = function()
        local q0 = Quaternion.new(5,-2,-7, 4)

        local qr = q0:Log()
        local qe = Quaternion.new(
            0.648525487469683, -0.2594101949878732, 
            -0.9079356824575563, 2.271647391135002
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local LogMap = {}
MathGroup.LogMap = LogMap
LogMap._order = {
    "LogMap"
}

LogMap.LogMap = {
    DisplayName = "Log map",
    test = function()
        local q0 = Quaternion.new(-0.0712248, 0.6351379, 0.2064367, -0.7408851)
        local q1 = Quaternion.new(-0.2900209, 0.3866946, 0.0966736, 0.8700628)
        
        local qr = q0:LogMap(q1)
        local qe = Quaternion.new(
            0.6127445362253545, -1.6313633116780928, 
            -0.8464727054605015, -3.4836792391421445e-08
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local LogMapSym = {}
MathGroup.LogMapSym = LogMapSym
LogMapSym._order = {
    "LogMapSym"
}

LogMapSym.LogMapSym = {
    DisplayName = "Log map symmetrical",
    test = function()
        local q0 = Quaternion.new(-0.0712248, 0.6351379, 0.2064367, -0.7408851)
        local q1 = Quaternion.new(-0.2900209, 0.3866946, 0.0966736, 0.8700628)
        
        local qr = q0:LogMapSym(q1)
        local qe = Quaternion.new(
            -0.3099861338031002, -1.8002172354618482, 
            -0.6453252392777373, -3.483679205835453e-08
        )

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}









local MethodsGroup = {}
QuaternionTest.MethodsGroup = MethodsGroup
MethodsGroup._order = {
    "Length", "LengthSquare", "Hypot", "Normalize", "IsUnit", "Dot",
    "Conjugate", "Inverse", "Negate","Difference", "Distance", 
    "DistanceSym", "DistanceChord", "DistanceAbs", "Slerp", "IdentitySlerp", 
    "SlerpFunction", "Intermediates", "Derivative", "Integrate", "ApproxEq", 
    "IsNaN"
}
MethodsGroup._DisplayName = "Method Tests"

local Length = {}
MethodsGroup.Length = Length
Length._order = {
    "Positive", "Zero", "Negative", "DoubleIndex"
}

Length.Positive = {
    DisplayName = "Quaternion method and property (positive)",
    test = function()
        local q0 = Quaternion.new(2, 5, 7, 3)
        local expect_len = 9.32737905309
        local len = q0:Length()
        local mag = q0.Magnitude

        return Assert.ApproxEquals(expect_len, len, EPSILON)
            and Assert.ApproxEquals(expect_len, mag, EPSILON)
    end
}

Length.Zero = {
    DisplayName = "Quaternion method and property (zero)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local expect_len = 0
        local len = q0:Length()
        local mag = q0.Magnitude

        return Assert.ApproxEquals(expect_len, len, EPSILON)
            and Assert.ApproxEquals(expect_len, mag, EPSILON)
    end
}

Length.Negative = {
    DisplayName = "Quaternion method and property (negative)",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_len = 9.32737905309
        local len = q0:Length()
        local mag = q0.Magnitude

        return Assert.ApproxEquals(expect_len, len, EPSILON)
            and Assert.ApproxEquals(expect_len, mag, EPSILON)
    end
}

Length.DoubleIndex = {
    DisplayName = "Double Index",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_len = 9.32737905309
        local mag = q0.Magnitude
        local mag2 = q0.Magnitude

        return Assert.ApproxEquals(expect_len, mag, EPSILON)
            and Assert.ApproxEquals(expect_len, mag2, EPSILON)
    end
}



local LengthSquare = {}
MethodsGroup.LengthSquare = LengthSquare
LengthSquare._order = {
    "Positive", "Zero", "Negative"
}

LengthSquare.Positive = {
    DisplayName = "Quaternion method and property (positive)",
    test = function()
        local q0 = Quaternion.new(2, 5, 7, 3)
        local expect_len = 87
        local len = q0:LengthSquared()

        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

LengthSquare.Zero = {
    DisplayName = "Quaternion method and property (zero)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local expect_len = 0
        local len = q0:LengthSquared()

        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

LengthSquare.Negative = {
    DisplayName = "Quaternion method and property (negative)",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_len = 87
        local len = q0:LengthSquared()

        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

local Hypot = {}
MethodsGroup.Hypot = Hypot
Hypot._order = {
    "Positive", "Zero", "Negative"
}

Hypot.Positive = {
    DisplayName = "Quaternion method and property (positive)",
    test = function()
        local q0 = Quaternion.new(2, 5, 7, 3)
        local expect_len = 9.32737905309
        local len = q0:Hypot()
        
        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

Hypot.Zero = {
    DisplayName = "Quaternion method and property (zero)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local expect_len = 0
        local len = q0:Hypot()
        
        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}

Hypot.Negative = {
    DisplayName = "Quaternion method and property (negative)",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_len = 9.32737905309
        local len = q0:Hypot()
        
        return Assert.ApproxEquals(expect_len, len, EPSILON)
    end
}



local Normalize = {}
MethodsGroup.Normalize = Normalize
Normalize._order = {
    "Positive", "Zero", "Negative", "DoubleIndex"
}

Normalize.Positive = {
    DisplayName = "Quaternion method and property (positive)",
    test = function()
        local q0 = Quaternion.new(2, 5, 7, 3)
        local expect_quat = Quaternion.new(
            0.2144225, 0.5360563, 0.7504788, 0.3216338
        )
        local norm = q0:Normalize()
        local unit = q0.Unit

        return Assert.KeyValuesApprox(expect_quat, norm, EPSILON)
            and Assert.KeyValuesApprox(expect_quat, unit, EPSILON)
    end
}

Normalize.Zero = {
    DisplayName = "Quaternion method and property (zero)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        local expect_quat = Quaternion.new(0, 0, 0, 1)
        local norm = q0:Normalize()
        local unit = q0.Unit

        return Assert.KeyValuesApprox(expect_quat, norm, EPSILON)
            and Assert.KeyValuesApprox(expect_quat, unit, EPSILON)
    end
}

Normalize.Negative = {
    DisplayName = "Quaternion method and property (negative)",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_quat = Quaternion.new(
           - 0.2144225, 0.5360563, -0.7504788, -0.3216338
        )
        local norm = q0:Normalize()
        local unit = q0.Unit

        return Assert.KeyValuesApprox(expect_quat, norm, EPSILON)
            and Assert.KeyValuesApprox(expect_quat, unit, EPSILON)
    end
}

Normalize.DoubleIndex = {
    DisplayName = "Double Index",
    test = function()
        local q0 = Quaternion.new(-2, 5, -7, -3)
        local expect_quat = Quaternion.new(
            -0.2144225, 0.5360563, -0.7504788, -0.3216338
        )
        local unit = q0.Unit
        local unit2 = q0.Unit

        return Assert.KeyValuesApprox(expect_quat, unit, EPSILON)
            and Assert.KeyValuesApprox(expect_quat, unit2, EPSILON)
            and unit == unit2
    end
}



local IsUnit = {}
MethodsGroup.IsUnit = IsUnit
IsUnit._order = {
    "Zero", "Unit", "CloseUnit", "NonUnit"
}

IsUnit.Zero = {
    DisplayName = "Zero",
    test = function()
        local q0 = Quaternion.zero
        
        local isUnit = q0:IsUnit()
        local expectedUnit = false
        
        return isUnit == expectedUnit
    end
}

IsUnit.Unit = {
    DisplayName = "Unit",
    test = function()
        local hfsq = 0.5 ^ 0.5
        local q0 = Quaternion.new(hfsq, hfsq, 0, 0)

        local isUnit = q0:IsUnit(1e-8)
        local expectedUnit = true

        return isUnit == expectedUnit
    end
}

IsUnit.CloseUnit = {
    DisplayName = "CloseUnit",
    test = function()
        local q0 = Quaternion.new(0.707107, 0.707107, 0, 0)

        local isUnitSmall = q0:IsUnit(1e-8)
        local expectedUnitSmall = false
        
        local isUnitBig = q0:IsUnit(1e-4)
        local expectedUnitBig = true

        return isUnitSmall == expectedUnitSmall and isUnitBig == expectedUnitBig
    end
}

IsUnit.NonUnit = {
    DisplayName = "NonUnit",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)

        local isUnit = q0:IsUnit()
        local expectedUnit = false

        return isUnit == expectedUnit
    end
}



local Dot = {}
MethodsGroup.Dot = Dot
Dot._order = {
    "Dot"
}

Dot.Dot = {
    DisplayName = "Dot",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        local q1 = Quaternion.new(-3, -1, 6, 7)
        
        local dot = q0:Dot(q1)
        local expected_dot = 50
        
        return Assert.ApproxEquals(expected_dot, dot, EPSILON)
    end
}



local Conjugate = {}
MethodsGroup.Conjugate = Conjugate
Conjugate._order = {
    "Conjugate"
}

Conjugate.Conjugate = {
    DisplayName = "Conjugate",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        
        local qr = q0:Conjugate()
        local qe = Quaternion.new(-2, -3, -4, 5)
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local Inverse = {}
MethodsGroup.Inverse = Inverse
Inverse._order = {
    "Inverse", "MultiplicativeInverse"
}

Inverse.Inverse = {
    DisplayName = "Inverse",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)

        local qr = q0:Inverse()
        local qe = Quaternion.new(
            -0.03703703703, -0.05555555555, -0.07407407407, 0.09259259259
        )
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}

Inverse.MultiplicativeInverse = {
    DisplayName = "Multiplicative Inverse",
    test = function()
        local q0 = Quaternion.new(2, 3, 4, 5)
        
        local qr = q0 * q0:Inverse()
        local qe = Quaternion.identity
        
        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local Negate = {}
MethodsGroup.Negate = Negate
Negate._order = {
    "Negate"
}

Negate.Negate = {
    DisplayName = "Negate",
    test = function()
        local q0 = Quaternion.new(-0.25, 0.5, 0.75, -0.75)

        local qr = q0:Negate()
        local qe = Quaternion.new(0.25, -0.5, -0.75, 0.75)

        return Assert.KeyValuesApprox(qe, qr, EPSILON)
    end
}



local Difference = {}
MethodsGroup.Difference = Difference
Difference._order = {
    "SameSphere", "OppositeSphere", "NonUnit"
}

Difference.SameSphere = {
    DisplayName = "Same hemisphere",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        )
        local q2 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(60)
        )
        
        local q1 = q0:Difference(q2)
        local qe = Quaternion.new(0.38302, -0.17861, -0.07899, 0.90286)
        
        local qt = q0:Inverse() * q2
        local qm = q0 * q1
        
        return Assert.KeyValuesApprox(q1, qe, EPSILON)
            and Assert.KeyValuesApprox(q1, qt, EPSILON)
            and Assert.KeyValuesApprox(qm, q2, EPSILON)
    end
}

Difference.OppositeSphere = {
    DisplayName = "Opposite hemisphere",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(60)
        )
        local q2 = Quaternion.fromEulerAngles(
            math.rad(270), math.rad(-30), math.rad(120)
        )
        
        local q1 = q0:Difference(q2)
        local qe = Quaternion.new(-0.46985, 0.57139, 0.29221, 0.60611)
        
        local qt = q0:Inverse() * q2
        local qm = q0 * q1
        
        return Assert.KeyValuesApprox(q1, qe, EPSILON)
            and Assert.KeyValuesApprox(q1, -qt, EPSILON)
            and Assert.KeyValuesApprox(qm, -q2, EPSILON)
    end
}

Difference.NonUnit = {
    DisplayName = "Non Unit",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        ) * 2.503
        local q2 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(60)
        ) * 0.893
        
        local q1 = q0:Difference(q2)
        local qm = q0 * q1
        local qi = q2 / q1
        return Assert.KeyValuesApprox(qm, q2, EPSILON)
            and Assert.KeyValuesApprox(qi, q0, EPSILON)
    end
}



local Distance = {}
MethodsGroup.Distance = Distance
Distance._order = {
    "Degrees1", "Degrees45", "Degrees90", "Degrees180", "Degrees90_2", 
    "Degrees45_2", "Degrees270", "MultipleAxis"
}

Distance.Degrees1 = {
    DisplayName = "1 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(1), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(1)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.Degrees45 = {
    DisplayName = "45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(45), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(45)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.Degrees90 = {
    DisplayName = "90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(90), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(90)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.Degrees180 = {
    DisplayName = "180 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(180), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(180)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.Degrees90_2 = {
    DisplayName = "-90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-90), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(90)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.Degrees45_2 = {
    DisplayName = "-45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-45), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(45)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.Degrees270 = {
    DisplayName = "270 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(math.rad(270), 0, 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(270)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

Distance.MultipleAxis = {
    DisplayName = "Multiple Axis",
    test = function()
        local q0 = Quaternion.fromEulerAngles(math.rad(30), 0, math.rad(120))
        local q1 = Quaternion.fromEulerAngles(math.rad(-150), math.rad(60), 0)
        
        local distance = q0:Distance(q1)
        local expectDistance = math.rad(231.32)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}



local DistanceSym = {}
MethodsGroup.DistanceSym = DistanceSym
DistanceSym._order = {
    "Degrees1", "Degrees45", "Degrees90", "Degrees180", "Degrees90_2", 
    "Degrees45_2", "Degrees270", "MultipleAxis"
}

DistanceSym.Degrees1 = {
    DisplayName = "1 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(1), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(1)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.Degrees45 = {
    DisplayName = "45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(45), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(45)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.Degrees90 = {
    DisplayName = "90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(90), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(90)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.Degrees180 = {
    DisplayName = "180 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(180), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(180)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.Degrees90_2 = {
    DisplayName = "-90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-90), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(90)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.Degrees45_2 = {
    DisplayName = "-45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-45), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(45)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.Degrees270 = {
    DisplayName = "270 degrees -> 90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(math.rad(270), 0, 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(90)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceSym.MultipleAxis = {
    DisplayName = "Multiple Axis",
    test = function()
        local q0 = Quaternion.fromEulerAngles(math.rad(30), 0, math.rad(120))
        local q1 = Quaternion.fromEulerAngles(math.rad(-150), math.rad(60), 0)
        
        local distance = q0:DistanceSym(q1)
        local expectDistance = math.rad(128.68)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}



local DistanceChord = {}
MethodsGroup.DistanceChord = DistanceChord
DistanceChord._order = {
    "Degrees1", "Degrees45", "Degrees90", "Degrees180", "Degrees90_2", 
    "Degrees45_2", "Degrees270", "MultipleAxis"
}

DistanceChord.Degrees1 = {
    DisplayName = "1 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(1), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(1) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.Degrees45 = {
    DisplayName = "45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(45), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(45) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.Degrees90 = {
    DisplayName = "90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(90), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(90) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.Degrees180 = {
    DisplayName = "180 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(180), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(180) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.Degrees90_2 = {
    DisplayName = "-90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-90), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(90) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.Degrees45_2 = {
    DisplayName = "-45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-45), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(45) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.Degrees270 = {
    DisplayName = "270 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(math.rad(270), 0, 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(90) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceChord.MultipleAxis = {
    DisplayName = "Multiple Axis",
    test = function()
        local q0 = Quaternion.fromEulerAngles(math.rad(30), 0, math.rad(120))
        local q1 = Quaternion.fromEulerAngles(math.rad(-150), math.rad(60), 0)
        
        local distance = q0:DistanceChord(q1)
        local expectDistance = 2 * math.sin(math.rad(128.68) / 2)
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}



local DistanceAbs = {}
MethodsGroup.DistanceAbs = DistanceAbs
DistanceAbs._order = {
    "Degrees1", "Degrees45", "Degrees90", "Degrees180", "Degrees90_2", 
    "Degrees45_2", "Degrees270", "MultipleAxis"
}

DistanceAbs.Degrees1 = {
    DisplayName = "1 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(1), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 0.00873

        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.Degrees45 = {
    DisplayName = "45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(45), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 0.39018
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.Degrees90 = {
    DisplayName = "90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(90), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 0.76547
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.Degrees180 = {
    DisplayName = "180 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(180), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 1.41421

        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.Degrees90_2 = {
    DisplayName = "-90 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-90), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 0.76547
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.Degrees45_2 = {
    DisplayName = "-45 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(0, math.rad(-45), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 0.39018
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.Degrees270 = {
    DisplayName = "270 degrees",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, 0)
        local q1 = Quaternion.fromEulerAngles(math.rad(270), 0, 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 0.76535
        
        
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}

DistanceAbs.MultipleAxis = {
    DisplayName = "Multiple Axis",
    test = function()
        local q0 = Quaternion.fromEulerAngles(math.rad(30), 0, math.rad(120))
        local q1 = Quaternion.fromEulerAngles(math.rad(-150), math.rad(60), 0)
        
        local distance = q0:DistanceAbs(q1)
        local expectDistance = 1.06488
        
        return Assert.ApproxEquals(expectDistance, distance, EPSILON)
    end
}



local Slerp = {}
MethodsGroup.Slerp = Slerp
Slerp._order = {
    "SameSphere", "OppositeSphere", "CloseQuaternions"
}
--CLOSE TESTS NLERP

Slerp.SameSphere = {
    DisplayName = "Same hemisphere",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(-60)
        )
        
        local valueMap = {
            {-1.250, Quaternion.new( 0.30455, -0.57750,  0.59160, -0.47303)},
            {-1.000, Quaternion.new( 0.34397, -0.44575,  0.77420, -0.28916)},
            {-0.783, Quaternion.new( 0.35424, -0.29979,  0.87910, -0.10875)},
            {-0.378, Quaternion.new( 0.31246,  0.01644,  0.91963,  0.23743)},
            {-0.175, Quaternion.new( 0.26404,  0.17814,  0.86144,  0.39557)},
            { 0.000, Quaternion.new( 0.21011,  0.30973,  0.77174,  0.51414)},
            { 0.123, Quaternion.new( 0.16673,  0.39468,  0.68886,  0.58472)},
            { 0.345, Quaternion.new( 0.08027,  0.52598,  0.50413,  0.68026)},
            { 0.500, Quaternion.new( 0.01629,  0.59691,  0.35398,  0.71982)},
            { 0.769, Quaternion.new(-0.09477,  0.67189,  0.06861,  0.73135)},
            { 0.918, Quaternion.new(-0.15291,  0.68485, -0.09429,  0.70619)},
            { 1.000, Quaternion.new(-0.18301,  0.68301, -0.18301,  0.68301)},
            { 1.120, Quaternion.new(-0.22392,  0.66887, -0.30956,  0.63770)},
            { 1.500, Quaternion.new(-0.32067,  0.53904, -0.65836,  0.41613)},
            { 2.000, Quaternion.new(-0.35031,  0.21349, -0.91193,  0.00908)},
        }
        
        for _, valuePair in pairs(valueMap) do
            local alpha = valuePair[1]
            local expected = valuePair[2]
            local s0 = q0:Slerp(q1, alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        return true
    end
}

Slerp.OppositeSphere = {
    DisplayName = "Opposite hemisphere",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(60)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(270), math.rad(-30), math.rad(120)
        )
        
        local valueMap = {
            {-1.250, Quaternion.new(-0.60360,  0.16145,  0.32948, -0.70785)},
            {-1.000, Quaternion.new(-0.53285,  0.04750,  0.18446, -0.82449)},
            {-0.783, Quaternion.new(-0.44853, -0.05366,  0.05043, -0.89073)},
            {-0.378, Quaternion.new(-0.24666, -0.23371, -0.20090, -0.91879)},
            {-0.175, Quaternion.new(-0.13079, -0.31331, -0.31858, -0.88501)},
            { 0.000, Quaternion.new(-0.02710, -0.37329, -0.41127, -0.83113)},
            { 0.123, Quaternion.new( 0.04636, -0.40975, -0.47020, -0.78030)},
            { 0.345, Quaternion.new( 0.17682, -0.46203, -0.56087, -0.66384)},
            { 0.500, Quaternion.new( 0.26386, -0.48725, -0.61056, -0.56584)},
            { 0.769, Quaternion.new( 0.40124, -0.50738, -0.66694, -0.36981)},
            { 0.918, Quaternion.new( 0.46731, -0.50523, -0.68082, -0.25071)},
            { 1.000, Quaternion.new( 0.50000, -0.50000, -0.68301, -0.18301)},
            { 1.120, Quaternion.new( 0.54267, -0.48723, -0.67923, -0.08218)},
            { 1.500, Quaternion.new( 0.63228, -0.40888, -0.61358,  0.23784)},
            { 2.000, Quaternion.new( 0.63320, -0.23282, -0.41668,  0.60928)},
        }
        
        for _, valuePair in pairs(valueMap) do
            local alpha = valuePair[1]
            local expected = valuePair[2]
            local s0 = q0:Slerp(q1, alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        return true
    end
}

Slerp.CloseQuaternions = {
    DisplayName = "Close Quaternions (NLERP)",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, math.deg(3))
        local q1 = Quaternion.fromEulerAngles(0, 0, math.deg(3 + 1e-10))
        
        local valueMap = {
            -99.000,-1.500,-0.378, 0.000, 0.345, 0.500, 0.918, 1.000, 2.000, 
            99.000
        }
        
        local expected = Quaternion.new(-0.00000, 0.00000, -0.90039, -0.43508)
        
        for _, alpha in pairs(valueMap) do
            local s0 = q0:Slerp(q1, alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        local bigalpha = 100000
        local s0 = q0:Slerp(q1, bigalpha)
        local expected = Quaternion.new(0.00000, 0.00000, -0.90052, -0.43482)
        if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
            return false
        end
        
        return true
    end
}


local IdentitySlerp = {}
MethodsGroup.IdentitySlerp = IdentitySlerp
IdentitySlerp._order = {
    "SameSphere", "OppositeSphere", "CloseQuaternions"
}

IdentitySlerp.SameSphere = {
    DisplayName = "Same hemisphere",
    test = function()
        local q1 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(-60)
        )
        
        local valueMap = {
            {-1.250, Quaternion.new( 0.21398, -0.79860, 0.21398, 0.52026)},
            {-1.000, Quaternion.new( 0.18301, -0.68301, 0.18301, 0.68301)},
            {-0.783, Quaternion.new( 0.14988, -0.55935, 0.14988, 0.80137)},
            {-0.378, Quaternion.new( 0.07633, -0.28486, 0.07633, 0.95247)},
            {-0.175, Quaternion.new( 0.03579, -0.13355, 0.03579, 0.98975)},
            { 0.000, Quaternion.new(-0.00000, 0.00000, -0.00000, 1.00000)},
            { 0.123, Quaternion.new(-0.02520, 0.09403, -0.02520, 0.99493)},
            { 0.345, Quaternion.new(-0.06985, 0.26069, -0.06985, 0.960356)},
            { 0.500, Quaternion.new(-0.09975, 0.37228, -0.09975, 0.91734)},
            { 0.769, Quaternion.new(-0.14757, 0.55073, -0.14757, 0.80818)},
            { 0.918, Quaternion.new(-0.17112, 0.63862, -0.17112, 0.73048)},
            { 1.000, Quaternion.new(-0.18301, 0.68301, -0.18301, 0.68301)},
            { 1.120, Quaternion.new(-0.19892, 0.74238, -0.19892, 0.60806)},
            { 1.500, Quaternion.new(-0.23602, 0.88082, -0.23602, 0.33577)},
            { 2.000, Quaternion.new(-0.25000, 0.93301, -0.25000, -0.06699)},
        }
        
        for _, valuePair in pairs(valueMap) do
            local alpha = valuePair[1]
            local expected = valuePair[2]
            local s0 = q1:IdentitySlerp(alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        return true
    end
}

IdentitySlerp.OppositeSphere = {
    DisplayName = "Opposite hemisphere",
    test = function()
        local q1 = Quaternion.fromEulerAngles(
            math.rad(270), math.rad(-30), math.rad(120)
        )
        
        local valueMap = {
            {-1.250, Quaternion.new(-0.50188,  0.50188,  0.68558,  0.16192)},
            {-1.000, Quaternion.new(-0.50000,  0.50000,  0.68301, -0.18301)},
            {-0.783, Quaternion.new(-0.44994,  0.44994,  0.61463, -0.46619)},
            {-0.378, Quaternion.new(-0.25456,  0.25456,  0.34773, -0.86573)},
            {-0.175, Quaternion.new(-0.12222,  0.12222,  0.16695, -0.97070)},
            { 0.000, Quaternion.new( 0.00000, -0.00000, -0.00000, -1.00000)},
            { 0.123, Quaternion.new( 0.08633, -0.08633, -0.11793, -0.98549)},
            { 0.345, Quaternion.new( 0.23415, -0.23415, -0.31985, -0.88772)},
            { 0.500, Quaternion.new( 0.32506, -0.32506, -0.44404, -0.76909)},
            { 0.769, Quaternion.new( 0.44526, -0.44526, -0.60823, -0.48327)},
            { 0.918, Quaternion.new( 0.48621, -0.48621, -0.66417, -0.29338)},
            { 1.000, Quaternion.new( 0.50000, -0.50000, -0.68301, -0.18301)},
            { 1.120, Quaternion.new( 0.50851, -0.50851, -0.69464, -0.01764)},
            { 1.500, Quaternion.new( 0.44404, -0.44404, -0.60657,  0.48759)},
            { 2.000, Quaternion.new( 0.18301, -0.18301, -0.25000,  0.93301)}
        }
        
        for _, valuePair in pairs(valueMap) do
            local alpha = valuePair[1]
            local expected = valuePair[2]
            local s0 = q1:IdentitySlerp(alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        return true
    end
}

IdentitySlerp.CloseQuaternions = {
    DisplayName = "Close Quaternions (NLERP)",
    test = function()
        local q1 = Quaternion.fromEulerAngles(0, 0, math.deg(1e-10))
        
        local valueMap = {
            -99.000,-1.500,-0.378, 0.000, 0.345, 0.500, 0.918, 1.000, 2.000, 
            99.000
        }
        
        local expected = Quaternion.new(0.00000, 0.00000, 0.00000, 1.00000)
        
        for _, alpha in pairs(valueMap) do
            local s0 = q1:IdentitySlerp(alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        local bigalpha = 100000
        local s0 = q1:IdentitySlerp(bigalpha)
        local expected = Quaternion.new(0.00000, 0.00000, 0.00029, 1.00000)
        if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
            return false
        end
        
        return true
    end
}



local SlerpFunction = {}
MethodsGroup.SlerpFunction = SlerpFunction
SlerpFunction._order = {
    "SameSphere", "OppositeSphere", "CloseQuaternions"
}

SlerpFunction.SameSphere = {
    DisplayName = "Same hemisphere",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(-60)
        )
        
        local valueMap = {
            {-1.250, Quaternion.new( 0.30455, -0.57750,  0.59160, -0.47303)},
            {-1.000, Quaternion.new( 0.34397, -0.44575,  0.77420, -0.28916)},
            {-0.783, Quaternion.new( 0.35424, -0.29979,  0.87910, -0.10875)},
            {-0.378, Quaternion.new( 0.31246,  0.01644,  0.91963,  0.23743)},
            {-0.175, Quaternion.new( 0.26404,  0.17814,  0.86144,  0.39557)},
            { 0.000, Quaternion.new( 0.21011,  0.30973,  0.77174,  0.51414)},
            { 0.123, Quaternion.new( 0.16673,  0.39468,  0.68886,  0.58472)},
            { 0.345, Quaternion.new( 0.08027,  0.52598,  0.50413,  0.68026)},
            { 0.500, Quaternion.new( 0.01629,  0.59691,  0.35398,  0.71982)},
            { 0.769, Quaternion.new(-0.09477,  0.67189,  0.06861,  0.73135)},
            { 0.918, Quaternion.new(-0.15291,  0.68485, -0.09429,  0.70619)},
            { 1.000, Quaternion.new(-0.18301,  0.68301, -0.18301,  0.68301)},
            { 1.120, Quaternion.new(-0.22392,  0.66887, -0.30956,  0.63770)},
            { 1.500, Quaternion.new(-0.32067,  0.53904, -0.65836,  0.41613)},
            { 2.000, Quaternion.new(-0.35031,  0.21349, -0.91193,  0.00908)},
        }
        
        local sfq = q0:SlerpFunction(q1)
        for _, valuePair in pairs(valueMap) do
            local alpha = valuePair[1]
            local expected = valuePair[2]
            local s0 = sfq(alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        return true
    end
}

SlerpFunction.OppositeSphere = {
    DisplayName = "Opposite hemisphere",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(60)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(270), math.rad(-30), math.rad(120)
        )
        
        local valueMap = {
            {-1.250, Quaternion.new(-0.60360,  0.16145,  0.32948, -0.70785)},
            {-1.000, Quaternion.new(-0.53285,  0.04750,  0.18446, -0.82449)},
            {-0.783, Quaternion.new(-0.44853, -0.05366,  0.05043, -0.89073)},
            {-0.378, Quaternion.new(-0.24666, -0.23371, -0.20090, -0.91879)},
            {-0.175, Quaternion.new(-0.13079, -0.31331, -0.31858, -0.88501)},
            { 0.000, Quaternion.new(-0.02710, -0.37329, -0.41127, -0.83113)},
            { 0.123, Quaternion.new( 0.04636, -0.40975, -0.47020, -0.78030)},
            { 0.345, Quaternion.new( 0.17682, -0.46203, -0.56087, -0.66384)},
            { 0.500, Quaternion.new( 0.26386, -0.48725, -0.61056, -0.56584)},
            { 0.769, Quaternion.new( 0.40124, -0.50738, -0.66694, -0.36981)},
            { 0.918, Quaternion.new( 0.46731, -0.50523, -0.68082, -0.25071)},
            { 1.000, Quaternion.new( 0.50000, -0.50000, -0.68301, -0.18301)},
            { 1.120, Quaternion.new( 0.54267, -0.48723, -0.67923, -0.08218)},
            { 1.500, Quaternion.new( 0.63228, -0.40888, -0.61358,  0.23784)},
            { 2.000, Quaternion.new( 0.63320, -0.23282, -0.41668,  0.60928)},
        }
        
        local sfq = q0:SlerpFunction(q1)
        for _, valuePair in pairs(valueMap) do
            local alpha = valuePair[1]
            local expected = valuePair[2]
            local s0 = sfq(alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        return true
    end
}

SlerpFunction.CloseQuaternions = {
    DisplayName = "Close Quaternions (NLERP)",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, math.deg(3))
        local q1 = Quaternion.fromEulerAngles(0, 0, math.deg(3 + 1e-10))
        
        local valueMap = {
            -99.000,-1.500,-0.378, 0.000, 0.345, 0.500, 0.918, 1.000, 2.000, 
            99.000
        }
        
        local expected = Quaternion.new(-0.00000, 0.00000, -0.90039, -0.43508)
        
        local sfq = q0:SlerpFunction(q1)
        for _, alpha in pairs(valueMap) do
            local s0 = sfq(alpha)
            if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
                return false
            end
        end
        
        local bigalpha = 100000
        local sfq = q0:SlerpFunction(q1)
        local s0 = sfq(bigalpha)
        local expected = Quaternion.new(0.00000, 0.00000, -0.90052, -0.43482)
        if not Assert.KeyValuesApprox(expected, s0, EPSILON) then
            return false
        end
        
        return true
    end
}



local Intermediates = {}
MethodsGroup.Intermediates = Intermediates
Intermediates._order = {
    "SameSphere7End", "OppositeSphere6NoEnd", "CloseQuaternions5",
    "Intermediates0NoEnd", "Intermediates0End"
}

Intermediates.SameSphere7End = {
    DisplayName = "Same hemisphere, 7 steps, ends included",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(-60)
        )
        
        local expectedAlphas = {
            0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1
        }
        
        local intermediates = q0:Intermediates(q1, 7, true)
        local sfq = q0:SlerpFunction(q1)
        for i, alpha in pairs(expectedAlphas) do
            local s0 = sfq(alpha)
            local qi = intermediates[i]
            if not Assert.KeyValuesApprox(s0, qi, EPSILON) then
                return false
            end
        end
        
        return true and #intermediates == 9
    end
}

Intermediates.OppositeSphere6NoEnd = {
    DisplayName = "Opposite hemisphere, 6 steps, ends not included",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(60)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(270), math.rad(-30), math.rad(120)
        )
        
        local expectedAlphas = {
            0.142857, 0.285714, 0.428571, 0.571429, 0.714286, 0.857143
        }
        
        local intermediates = q0:Intermediates(q1, 6)
        local sfq = q0:SlerpFunction(q1)
        for i, alpha in pairs(expectedAlphas) do
            local s0 = sfq(alpha)
            local qi = intermediates[i]
            if not Assert.KeyValuesApprox(s0, qi, EPSILON) then
                return false
            end
        end
        
        return true and #intermediates == 6
    end
}

Intermediates.CloseQuaternions5 = {
    DisplayName = "Close Quaternions (NLERP), 5 steps, no end",
    test = function()
        local q0 = Quaternion.fromEulerAngles(0, 0, math.deg(3))
        local q1 = Quaternion.fromEulerAngles(0, 0, math.deg(3 + 1e-10))
        
        local valueMap = {
            -99.000,-1.500,-0.378, 0.000, 0.345, 0.500, 0.918, 1.000, 2.000, 
            99.000
        }
        
        local expectedAlphas = {0.166667, 0.333333, 0.5, 0.666667, 0.833333}
        
        local intermediates = q0:Intermediates(q1, 5)
        local sfq = q0:SlerpFunction(q1)
        for i, alpha in pairs(expectedAlphas) do
            local s0 = sfq(alpha)
            local qi = intermediates[i]
            if not Assert.KeyValuesApprox(s0, qi, EPSILON) then
                return false
            end
        end
        
        return true and #intermediates == 5
    end
}

Intermediates.Intermediates0NoEnd = {
    DisplayName = "0 steps, ends not included",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(-60)
        )
        
        local intermediates = q0:Intermediates(q1, 0)
        return #intermediates == 0
    end
}

Intermediates.Intermediates0End = {
    DisplayName = "0 steps, ends included",
    test = function()
        local q0 = Quaternion.fromEulerAngles(
            math.rad(-20), math.rad(40), math.rad(120)
        )
        local q1 = Quaternion.fromEulerAngles(
            math.rad(30), math.rad(90), math.rad(-60)
        )
        
        local expectedAlphas = {0, 1}
        
        local intermediates = q0:Intermediates(q1, 0, true)
        local sfq = q0:SlerpFunction(q1)
        for i, alpha in pairs(expectedAlphas) do
            local s0 = sfq(alpha)
            local qi = intermediates[i]
            if not Assert.KeyValuesApprox(s0, qi, EPSILON) then
                return false
            end
        end
        
        return true and #intermediates == 2
    end
}



local Derivative = {}
MethodsGroup.Derivative = Derivative
Derivative._order = {
    "Zero", "NonZero"
}

Derivative.Zero = {
    DisplayName = "Zero vector",
    test = function()
        local q0 = Quaternion.new(0, 0.38268, 0, 0.92388)
        
        local derivq0 = q0:Derivative(Vector3.zero)
        local qe = Quaternion.new(0, 0, 0, 0)
        
        return Assert.KeyValuesApprox(qe, derivq0, EPSILON)
    end
}

Derivative.NonZero = {
    DisplayName = "Non zero vector",
    test = function()
        local q0 = Quaternion.new(0, 0.38268, 0, 0.92388)
        
        local derivq0 = q0:Derivative(Vector3.new(-3.25, 6, -1.32))
        local qe = Quaternion.new(-1.753874, 2.77164, 0.012094, -1.14804)
        
        return Assert.KeyValuesApprox(qe, derivq0, EPSILON)
    end
}



local Integrate = {}
MethodsGroup.Integrate = Integrate
Integrate._order = {
    "ZeroRateNTime", "NRateZeroTime", "NRateNTime"
}

Integrate.ZeroRateNTime = {
    DisplayName = "Zero rate, n timestep",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        
        local rate = Vector3.zero
        local timestep = 0.1753
        
        local qint = q0:Integrate(rate, timestep)
        local qe = q0
        
        return Assert.KeyValuesApprox(qe, qint, EPSILON)
    end
}

Integrate.NRateZeroTime = {
    DisplayName = "n rate, zero timestep",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        
        local rate = Vector3.new(-3.25, 6, -1.32)
        local timestep = 0
        
        local qint = q0:Integrate(rate, timestep)
        local qe = q0
        
        return Assert.KeyValuesApprox(qe, qint, EPSILON)
    end
}

Integrate.NRateNTime = {
    DisplayName = "n rate, n timestep",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        
        local rate = Vector3.new(-3.25, 6, -1.32)
        local timestep = 0.1753
        
        local qint = q0:Integrate(rate, timestep)
        local qe = Quaternion.new(0.75829, 0.05322, -0.23480, -0.60584)
        
        return Assert.KeyValuesApprox(qe, qint, EPSILON)
    end
}



local ApproxEq = {}
MethodsGroup.ApproxEq = ApproxEq
ApproxEq._order = {
    "Equal", "Close", "NearlyEqual", "NotEqual"
}

ApproxEq.Equal = {
    DisplayName = "Equal",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        local q1 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        
        return q0:ApproxEq(q1, EPSILON)
    end
}

ApproxEq.Close = {
    DisplayName = "Close",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        local q1 = Quaternion.new(0.34957, 0.19767, -0.64720, -0.64795)
        
        return q0:ApproxEq(q1, EPSILON)
    end
}

ApproxEq.NearlyEqual = {
    DisplayName = "Nearly equal",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        local q1 = Quaternion.new(0.34523,-0.19826, -0.65565, -0.64158)
        
        return q0:ApproxEq(q1, EPSILON) == false
    end
}

ApproxEq.NotEqual = {
    DisplayName = "Not equal",
    test = function()
        local q0 = Quaternion.new(0.34958, 0.19768, -0.64721, -0.64794)
        local q1 = Quaternion.new(0.10620, 0.65370, 0.21072, 0.71902)
        
        return q0:ApproxEq(q1, EPSILON) == false
    end
}



local IsNaN = {}
MethodsGroup.IsNaN = IsNaN
IsNaN._order = {
    "IsNaN1", "IsNaN2", "IsNaN3", "IsNaN4", "IsNaN4P", "NotNaN"
}

IsNaN.IsNaN1 = {
    DisplayName = "Is NaN (pos 1)",
    test = function()
        local q0 = Quaternion.new(0/0, 0, 0, 0)
        
        return q0:IsNaN() == true
    end
}

IsNaN.IsNaN2 = {
    DisplayName = "Is NaN (pos 2)",
    test = function()
        local q0 = Quaternion.new(0, 0/0, 0, 0)
        
        return q0:IsNaN() == true
    end
}

IsNaN.IsNaN3 = {
    DisplayName = "Is NaN (pos 3)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0/0, 0)
        
        return q0:IsNaN() == true
    end
}

IsNaN.IsNaN4 = {
    DisplayName = "Is NaN (pos 4)",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0/0)
        
        return q0:IsNaN() == true
    end
}

IsNaN.IsNaN4P = {
    DisplayName = "Is NaN (all 4)",
    test = function()
        local q0 = Quaternion.new(0/0, 0/0, 0/0, 0/0)
        
        return q0:IsNaN() == true
    end
}

IsNaN.NotNaN = {
    DisplayName = "Not NaN",
    test = function()
        local q0 = Quaternion.new(0, 0, 0, 0)
        
        return q0:IsNaN() == false
    end
}





return QuaternionTest
