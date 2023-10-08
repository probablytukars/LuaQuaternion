import os

source_folder = "src"
target_folder = 'test_build'
constant_string = '''
local Vector3 = require("mocks/Vector3")
local CFrame = require("mocks/CFrame")
local Enum = {}
Enum.RotationOrder = {
    XYZ = {Value = 0, Name = "XYZ"},
    XZY = {Value = 1, Name = "XZY"},
    YZX = {Value = 2, Name = "YZX"},
    YXZ = {Value = 3, Name = "YXZ"},
    ZXY = {Value = 4, Name = "ZXY"},
    ZYX = {Value = 5, Name = "ZYX"}
}
'''

if not os.path.exists(target_folder):
    os.makedirs(target_folder)


for filename in os.listdir(source_folder):
    if filename.endswith('.lua'):
        source_file_path = os.path.join(source_folder, filename)
        target_file_path = os.path.join(target_folder, filename)
        
        with open(source_file_path, 'r') as source_file:
            file_contents = source_file.read()
        
        modified_contents = constant_string + file_contents
        
        with open(target_file_path, 'w') as target_file:
          target_file.write(modified_contents)
        
        print(f'Processed: {filename}')

print('All files processed.')