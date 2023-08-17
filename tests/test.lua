local Tester = require("Tester")
local Quaternion = require("../src/Quaternion")
local TestLibrary = require("QuaternionTest")
local testData = require("TestData")

local UNSAFE_MODE = true
local tester = Tester.new(Quaternion, TestLibrary, testData, UNSAFE_MODE)

tester:ExecuteTests()