-- How to test locally
-- Windows: python tests/prepareTest.py && binaries/windows/luau.exe tests/test.lua
-- Linux: python tests/prepareTest.py && binaries/ubuntu/luau tests/test.lua

local Tester = require("tests/Tester")
local Quaternion = require("test_build/Quaternion")
local TestLibrary = require("tests/QuaternionTest")
local testData = require("tests/TestData")

local UNSAFE_MODE = false
local ERROR_ON_FAIL = false
local tester = Tester.new(Quaternion, TestLibrary, testData, UNSAFE_MODE, ERROR_ON_FAIL)

tester:ExecuteTests()