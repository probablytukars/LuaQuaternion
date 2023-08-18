local Tester = require("tests/Tester")
local Quaternion = require("src/Quaternion")
local TestLibrary = require("tests/QuaternionTest")
local testData = require("tests/TestData")

local UNSAFE_MODE = false
local tester = Tester.new(Quaternion, TestLibrary, testData, UNSAFE_MODE)

tester:ExecuteTests()