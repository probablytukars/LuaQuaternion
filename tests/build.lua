package.path = ";.\\?.lua;..\\mocks\\?.lua"
print(package.path)
local vector3 = require("Vector3")

local vec = vector3.new(5, 6, 7)
print(vec)