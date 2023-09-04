local Tester = require("tests/Tester")
local Quaternion = require("test_build/Quaternion")
local TestLibrary = require("tests/QuaternionTest")
local testData = require("tests/TestData")

local UNSAFE_MODE = true
local ERROR_ON_FAIL = true
local tester = Tester.new(Quaternion, TestLibrary, testData, UNSAFE_MODE, ERROR_ON_FAIL)

tester:ExecuteTests()