import json
import re

luau_input_file = "Quaternion.luau"

doc_store = []

tag_regex  = r'@(\S+)\s*(.*)'
prop_regex = r'(\S+)\s*(\S*)'

def read_class(doc, text):
    doc["tag"] = "className"
    doc["name"] = text

def read_grouporder(doc, text):
    doc["grouporder"] = json.loads(text)

def read_prop(doc, text):
    name_type = re.findall(prop_regex, text)
    if name_type:
        name, type_ = name_type[0]
    doc["name"] = name
    doc["lua_type"] = type_
    doc["tag"] = "property"
    doc["group"] = "Properties"
    
def read_function(doc, text):
    doc["tag"] = "function"
    
def read_method(doc, text):
    doc["tag"] = "method"
    
def read_alias(doc, text):
    doc["tag"] = "alias"
    doc["alias"] = text

def read_group(doc, text):
    doc["group"] = text

def read_operator(doc, text):
    doc["tag"] = "operation"
    doc["operator"] = text
    

def read_operand1(doc, text):
    doc["operand1"] = text

def read_operand2(doc, text):
    doc["operand2"] = text

def read_return(doc, text):
    doc["return"] = text

tag_map = {
    "class": read_class,
    "grouporder": read_grouporder,
    "prop": read_prop,
    "function": read_function,
    "method": read_method,
    "alias": read_alias,
    "group": read_group,
    "operator": read_operator,
    "operand1": read_operand1,
    "operand2": read_operand2,
    "return": read_return
    
}

def parse_doc_line(file, doc):
    read_desc = False
    reading_desc = False
    function_definition = ""
    read_function_definition = False
    name_found = False
    prev_line = file.tell()
    while True:
        line = file.readline()
        if not line:
            break
        line = line.strip()
        if line.startswith("@"):
            tag, text = re.findall(tag_regex, line)[0]
            if tag in tag_map:
                tag_map[tag](doc, text)
            if reading_desc:
                read_desc = True
        elif line.endswith("]=]"):
            reading_desc = False
            read_desc = True
            if len(doc.keys()) > 0:
                doc_store.append(doc)
            if doc["tag"] == "method" or doc["tag"] == "function":
                read_function_definition = True
            else:
                return
        elif read_function_definition:
            if line == "":
                continue
            if not name_found:
                if line.startswith("local function"):
                    doc["name"] = re.findall("local function (\S+)\(", line)[0]
                elif line.startswith("function"):
                    doc["name"] = re.findall("function (\S+)\(", line)[0].split(".")[-1]
                else:
                    dot_find = re.findall("(\S+)\s*=\s*(\S+)", line)
                    if dot_find:
                        setter, equals = dot_find[0]
                        doc["name"] = setter.split(".")[-1]
                        if not equals.startswith("function("):
                            return
                    else:
                        return
                
                name_found = True
                doc["definition"] = re.findall("(\(.*)", line)[0]
            
            return
        else:
            if not read_desc:
                reading_desc = True
                doc["desc"].append(line)
    
        prev_line = file.tell()
                

def fix_doc_desc(doc):
    new_array = []
    current_string = ""
    
    start_index = next((i for i, item in enumerate(doc["desc"]) if item != ""), None)
    if start_index is None:
        return []
    doc["desc"] = doc["desc"][start_index:]
    
    for item in doc["desc"]:
        if item != "":
            current_string += " " + item if current_string else item
        elif current_string:
            new_array.append(current_string.strip())
            current_string = ""
        else:
            new_array.append("")
    
    if current_string:
        new_array.append(current_string.strip())

    doc["desc"] = new_array

with open(luau_input_file) as file:
    while True:
        line = file.readline()
        if not line:
            break
        line = line.strip()
        if line[0:5] == "--[=[":
            doc = {"desc": []}
            parse_doc_line(file, doc)
            fix_doc_desc(doc)
            

doc_out_tab = []

head_doc = doc_store[0]
grouporder = head_doc["grouporder"]
grouporder.insert(0, "Properties")

doc_out_tab.append({
    "purpose": "top",
    "name": head_doc["name"],
    "desc": head_doc["desc"]
})

for group in grouporder:
    doc_out_tab.append({
        "purpose": "list",
        "name": group,
        "list": []
    })

def get_list_to_append(name):
    for doc_group in doc_out_tab:
        if doc_group["name"] == name:
            if "list" in doc_group:
                return doc_group
    return None

for doc in doc_store:
    if "group" in doc:
        name = doc["group"]
        target_list = get_list_to_append(name)
        if target_list:
            target_list["list"].append(doc)


with open("docs.json", "w") as outfile:
    json.dump(doc_out_tab, outfile, indent=4)

#print(json.dumps(doc_out_tab, indent=4))

