local OutputBuffer = require("OutputBuffer")

local buffer = OutputBuffer.new()

local Tester = {}
Tester.__index = Tester

function Tester.new(testModule, testWithoutProtection)
    local self = {}
    
    self.testModule = testModule
    self.testWithoutProtection = testWithoutProtection or false
    
    setmetatable(self, Tester)
    
    return self
end

local function getResultString(
    totalTests, testsPassed, testsFailed, unhandledExceptions
)
    return
        "[" .. tostring(testsPassed)
            .. " / " .. tostring(totalTests)
            .. "] tests passed."
        .. "\nFailures: " .. tostring(testsFailed)
        .. "\nUnhandled Exceptions: " .. tostring(unhandledExceptions)
end

function Tester:runTest(test, call)
    local success, result, reason 
    if self.testWithoutProtection then
        result = test.test()
        success = true
    else
        success, result, reason = pcall(test.test)
    end
    if success then
        if result then
            return 0, "       [✔] Pass - " .. test.DisplayName
        else
            return 1, "       [❌] Fail - " .. test.DisplayName
        end
    else
        return 2, "       ❗❗❗ Unhandled Exception - " .. test.DisplayName
    end
end

function Tester:testFunctionGroup(functionGroup)
    local totalTests = 0
    local testsPassed = 0
    local testsFailed = 0
    local unhandledExceptions = 0
    
    local functionGroupOrder = functionGroup._order
    for _, functionIndexName in pairs(functionGroupOrder) do
        local functionTests = functionGroup[functionIndexName]
        local order = functionTests._order
        local nord = #order
        local allPassed = true
        
        for i, testIndex in pairs(order) do
            totalTests = totalTests + 1
            local test = functionTests[testIndex]
            local status, result = self:runTest(test)
            if status == 0 then
                testsPassed = testsPassed + 1
            elseif status == 1 then
                testsFailed = testsFailed + 1
                allPassed = false
            else
                unhandledExceptions = unhandledExceptions + 1
                allPassed = false
            end
            if i < nord then
                buffer:AppendNL(result)
            else
                buffer:Append(result)
            end
        end
        
        local functionTestsOutput
        if allPassed then
            functionTestsOutput = "[✔] All tests passed - "
                .. functionIndexName
        else
            functionTestsOutput = "[❌] Tests failed - "
                .. functionIndexName
        end
        
        buffer:PrependNL(functionTestsOutput)
        buffer:Flush()
    end
    
    local resultString = getResultString(
        totalTests, testsPassed, testsFailed, unhandledExceptions
    )
    
    buffer:AppendNL()
    buffer:AppendNL(functionGroup._DisplayName)
    buffer:AppendNL(resultString)
    buffer:Flush()
    
    return totalTests, testsPassed, testsFailed, unhandledExceptions
end

function Tester:ExecuteTests()
    local totalTests = 0
    local testsPassed = 0
    local testsFailed = 0
    local unhandledExceptions = 0
    
    local testGroupOrder = self.testModule._order
    
    for _, groupName in pairs(testGroupOrder) do
        local testGroupTable = self.testModule[groupName]
        local groupDisplayName = testGroupTable._DisplayName
        local stars = string.rep("*", 15)
        print(stars .. " ".. groupDisplayName .. " " .. stars)
        
        local fnTests, fnPassed, fnFailed, fnUnhandled = 
            self:testFunctionGroup(testGroupTable)
        
        totalTests = totalTests + fnTests
        testsPassed = testsPassed + fnPassed
        testsFailed = testsFailed + fnFailed
        unhandledExceptions = unhandledExceptions + fnUnhandled
    end
    
    local finalResultString = getResultString(
        totalTests, testsPassed, testsFailed, unhandledExceptions
    )
    
    print("Final results:")
    print(finalResultString)
end

return Tester
