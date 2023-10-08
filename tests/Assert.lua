local Assert = {}

local function stringExists(searchString, stringToFind)
    local indexStart = string.find(searchString, stringToFind)
    return indexStart and true or false
end

function Assert.IsNaN(a)
    return a ~= a
end

function Assert.Equals(a, b)
    local aeb = a == b
    local aIsNaN = a ~= a
    local bIsNaN = b ~= b
    return aeb or (aIsNaN and bIsNaN)
end

function Assert.NotEquals(a, b)
    local aneb = a ~= b
    local aIsNaN = a ~= a
    local bIsNaN = b ~= b
    return (aneb and (not (aIsNaN and bIsNaN)))
end

function Assert.EqualsAll(...)
    local args = {...}
    local numArgs = #args
    if numArgs < 2 then return true end
    for i = 2, numArgs do
        if Assert.NotEquals(args[1], args[i]) then
            return false
        end
    end
    return true
end

function Assert.ApproxEquals(a, b, epsilon)
    if not epsilon then error("Epsilon not passed!") end
    local aIsNaN = a ~= a
    local bIsNaN = b ~= b
    
    return (aIsNaN and bIsNaN) or math.abs(a - b) < epsilon
end

function Assert.AnglesApproxEquals(a, b, epsilon)
    if not epsilon then error("Epsilon not passed!") end
    local aIsNaN = a ~= a
    local bIsNaN = b ~= b
    
    if aIsNaN and bIsNaN then
        return true
    end
    if aIsNaN or bIsNaN then
        return false
    end
    
    local difference = a - b
    local smallestDif = (difference + math.pi) % (math.pi * 2) - math.pi
    return math.abs(smallestDif) < epsilon
end

function Assert.VectorsApproxEqual(a, b, epsilon)
    local xeq = Assert.ApproxEquals(a.X, b.X, epsilon)
    local yeq = Assert.ApproxEquals(a.Y, b.Y, epsilon)
    local zeq = Assert.ApproxEquals(a.Z, b.Z, epsilon)
    return xeq and yeq and zeq
end



function Assert.CFramesApproxEqual(a, b, epsilon, includePosition)
    if not epsilon then error("Epsilon not passed!") end
    
    local ax, ay, az, 
    am00, am01, am02, 
    am10, am11, am12, 
    am20, am21, am22 = a:GetComponents()
    local bx, by, bz, 
    bm00, bm01, bm02, 
    bm10, bm11, bm12, 
    bm20, bm21, bm22 = b:GetComponents()
    
    local m00e = Assert.ApproxEquals(am00, bm00, epsilon)
    local m01e = Assert.ApproxEquals(am01, bm01, epsilon)
    local m02e = Assert.ApproxEquals(am02, bm02, epsilon)
    local m10e = Assert.ApproxEquals(am10, bm10, epsilon)
    local m11e = Assert.ApproxEquals(am11, bm11, epsilon)
    local m12e = Assert.ApproxEquals(am12, bm12, epsilon)
    local m20e = Assert.ApproxEquals(am20, bm20, epsilon)
    local m21e = Assert.ApproxEquals(am21, bm21, epsilon)
    local m22e = Assert.ApproxEquals(am22, bm22, epsilon)
    
    local arvd = Assert.IsNaN(a.RightVector:Dot(a.RightVector))
    local auvd = Assert.IsNaN(a.UpVector:Dot(a.UpVector))
    local alvd = Assert.IsNaN(a.LookVector:Dot(a.LookVector))
    
    local brvd = Assert.IsNaN(b.RightVector:Dot(b.RightVector))
    local buvd = Assert.IsNaN(b.UpVector:Dot(b.UpVector))
    local blvd = Assert.IsNaN(b.LookVector:Dot(b.LookVector))
    
    local bothRnan = (arvd and brvd)
    local bothUnan = (auvd and buvd)
    local bothLnan = (alvd and blvd)
    
    local xpe, ype, zpe = true, true, true
    
    if includePosition then
        xpe = Assert.ApproxEquals(a.X, b.X, epsilon)
        ype = Assert.ApproxEquals(a.Y, b.Y, epsilon)
        zpe = Assert.ApproxEquals(a.Z, b.Z, epsilon)
    end
    
    local positionsEqual = xpe and ype and zpe
    
    local rightVectorEqual = (m00e and m10e and m20e) or bothRnan
    local upVectorEqual = (m01e and m11e and m21e) or bothUnan
    local lookVectorEqual = (m02e and m12e and m22e) or bothLnan
    
    local componentsEqual = 
        rightVectorEqual and upVectorEqual and lookVectorEqual
    
    return positionsEqual and componentsEqual
end

function Assert.NotNull(a)
    return a ~= nil
end

function Assert.Null(a)
    return a == nil
end

function Assert.HasMetatable(a, meta)
    return getmetatable(a) == meta
end

function Assert.KeyValues(a, tab)
    for key, value in pairs(tab) do
        if key:sub(0, 1) ~= "_" then
            if a[key] ~= value then
                return false
            end
        end
    end
    return true
end

function Assert.KeyValuesApprox(a, tab, epsilon)
    if not epsilon then error("Epsilon not passed!") end
    for key, value in pairs(tab) do
        if key:sub(0, 1) ~= "_" then
            if a[key] then
                if math.abs(a[key] - value) >= epsilon then
                    return false
                end
            else 
                return false
            end
        end
    end
    return true
end

function Assert.QuaternionsEqualApprox(qe, qr, epsilon)
    return 
        Assert.KeyValuesApprox(qe, qr, epsilon) 
        or Assert.KeyValuesApprox(qe, -qr, epsilon)
end


function Assert.ErrorThrown(expectedErrorMessage, func)
    local success, err = pcall(func)
    if success then 
        return false 
    end

    local hasExpectedMessage = stringExists(
        tostring(err), 
        expectedErrorMessage
    )
    return hasExpectedMessage
end

function Assert.ErrorThrownAll(expectedErrorMessage, ...)
    for _, func in pairs({...}) do
        local errorThrown = Assert.ErrorThrown(expectedErrorMessage, func)
        if not errorThrown then
            return false
        end
    end
    return true
end


return Assert
