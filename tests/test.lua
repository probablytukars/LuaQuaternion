package.path = ";.\\?.lua;..\\mocks\\?.lua"
local Tester = require("Tester")
local Quaternion = require("../src/Quaternion")
local TestLibrary = require("QuaternionTest")
local testData = require("TestData")

local tester = Tester.new(Quaternion, TestLibrary, testData, true)

tester:ExecuteTests()