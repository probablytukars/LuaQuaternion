local random = Random.new(tick())
local pi = math.pi
local pi2 = math.pi/2
local pi4 = math.pi/4
local fyxz = CFrame.fromEulerAnglesYXZ

function CFrameToQuaternion(cframe:CFrame)
    local cf = cframe:Orthonormalize()
    
    local vX, vY, vZ = cf.RightVector, cf.UpVector, -cf.LookVector
    
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
    
    return {X = qX, Y = qY, Z = qZ, W = qW}
end

function RandomPoint(scale)
    return random:NextUnitVector() * (random:NextNumber(1e-2, scale) ^ (1/3))
end



local function nearPolarCFrames(cframes, polarCFrames, ...)
    local nearPolarAngles = {...}
    local angles = {-3 * pi4, -pi2, -pi4, 0, pi4, pi2, 3 * pi4, pi}
    
    for  _, polarCFrame in pairs(polarCFrames) do
        for _, ang in pairs(angles) do
            for _, pad in pairs(nearPolarAngles) do
                local pa = math.rad(pad)
                local sina = math.sin(ang) * pa
                local cosa = math.cos(ang) * pa

                local rva = polarCFrame * fyxz(0, sina, cosa)
                local uva = polarCFrame * fyxz(sina, 0, cosa)
                local lva = polarCFrame * fyxz(sina, cosa, 0)

                table.insert(cframes, rva)
                table.insert(cframes, uva)
                table.insert(cframes, lva)
            end
        end
    end
    return cframes
end

local function polarCFrames(CFrames)
    local axes = {
        Vector3.xAxis, Vector3.yAxis, Vector3.zAxis,
        -Vector3.xAxis, -Vector3.yAxis, -Vector3.zAxis,
    }
    for _, upVector in pairs(axes) do
        for _, rightVector in pairs(axes) do
            if math.abs(upVector:Dot(rightVector)) > 0.5 then
                continue
            end
            local polarCFrame = CFrame.fromMatrix(
                Vector3.zero, 
                rightVector, 
                upVector
            )
            table.insert(CFrames, polarCFrame)
        end
    end
    return CFrames
end

local function randomCFrames(CFrames, number)
    for i = 1, number do
        local xAxis = random:NextUnitVector()
        local secondUnit = random:NextUnitVector()
        while math.abs(xAxis:Dot(secondUnit)) > 1 - 1e-6 do
            secondUnit = random:NextUnitVector()
        end 
        local zAxis = xAxis:Cross(secondUnit).Unit
        local yAxis = zAxis:Cross(xAxis).Unit
        table.insert(CFrames, CFrame.fromMatrix(Vector3.new(), xAxis, yAxis))
    end
    return CFrames
end

local function randomNonUnitCFrames(CFrames, number)
    for i = 1, number do
        local xAxis = random:NextUnitVector()
        local secondUnit = random:NextUnitVector()
        while math.abs(xAxis:Dot(secondUnit)) > 1 - 1e-6 do
            secondUnit = random:NextUnitVector()
        end 
        local zAxis = xAxis:Cross(secondUnit).Unit
        local yAxis = zAxis:Cross(xAxis).Unit

        local xScale = random:NextNumber(1e-6, 100)
        local yScale = random:NextNumber(1e-6, 100)
        local zScale = random:NextNumber(1e-6, 100)
        table.insert(CFrames, 
            CFrame.fromMatrix(
                Vector3.new(), 
                xAxis * xScale, yAxis * yScale, zAxis * zScale
            )
        )
    end
    return CFrames
end

local function randomNonOrthonormalized(CFrames, number)
    for i = 1, number do
        local xAxis = random:NextUnitVector() * random:NextNumber(1e-6, 100)
        local yAxis = random:NextUnitVector() * random:NextNumber(1e-6, 100)
        local zAxis = random:NextUnitVector() * random:NextNumber(1e-6, 100)
        table.insert(CFrames, CFrame.fromMatrix(xAxis, yAxis, zAxis))
    end
    return CFrames
end



local function getLookAt(lookAts, number)
    for i = 1, number do
        local from = RandomPoint(100)
        local at = RandomPoint(100)
        local lookAt = CFrame.lookAt(from, at)
        table.insert(lookAts, {from = from, at = at, })
    end
    return lookAts
end


local function generateHalfUnitQuaternions()
    local inputResultMap = {}
    local halfsqrt = 0.5 ^ 0.5
    for x = 1, 3 do
        for xSign = -1, 1, 2 do
            for y = x + 1, 4 do
                for ySign = -1, 1, 2 do
                    local input = {0, 0, 0, 0}
                    input[x] = halfsqrt * xSign
                    input[y] = halfsqrt * ySign
                    table.insert(inputResultMap, input)
                end
            end
        end
    end
    
    for i = 1, 16 do
        local xSign = (i % 2) > 0 and -1 or 1
        local ySign = (i % 4) > 1 and -1 or 1
        local zSign = (i % 8) > 3 and -1 or 1
        local wSign = (i % 16) > 7 and -1 or 1
        local input = {
            0.5 * xSign,
            0.5 * ySign,
            0.5 * zSign,
            0.5 * wSign
        }
        table.insert(inputResultMap, input)
    end
    
    return inputResultMap
end


export type TestData = {
    RepresentationCollection: {
        PolarCFrames: {CFrame},
        NearPolarCFrames: {CFrame},
        RandomCFrames: {CFrame},
        NonUnitCFrames: {CFrame},
        NonOrthonormalized: {CFrame}
    },
    lookAt: {{Vector3}},
    HalfUnit: {{number}}
}

return function(number, ...): TestData
    local testData: TestData = {}
    local representationCollection = {}
    local PolarCFrames = {}
    polarCFrames(PolarCFrames)
    representationCollection.PolarCFrames = PolarCFrames
    representationCollection.NearPolarCFrames = 
        nearPolarCFrames({}, PolarCFrames, ...)
    representationCollection.RandomCFrames = 
        randomCFrames({}, number)
    representationCollection.NonUnitCFrames = 
        randomNonUnitCFrames({}, number)
    representationCollection.NonOrthonormalized = 
        randomNonOrthonormalized({}, number)
    testData.RepresentationCollection = representationCollection
    testData.lookAt = getLookAt({}, number)
    testData.HalfUnit = generateHalfUnitQuaternions()
    return testData
end
