local Tester = require("tests/Tester")
local Quaternion = require("../src/Quaternion")
local TestLibrary = require("QuaternionTest")
local testData = require("TestData")

local UNSAFE_MODE = false
local tester = Tester.new(Quaternion, TestLibrary, testData, UNSAFE_MODE)

tester:ExecuteTests()