import copy
import json
import os
import re
import markdown

from bs4 import BeautifulSoup
from moonwave.tokens import tokenize

template_input_file = "docs/template.html"
source_folder = "build/docs"
target_folder = "build/api"

if not os.path.exists(target_folder):
    os.makedirs(target_folder)
    

def get_soup_template():
    html_content = ""
    with open(template_input_file, "r") as template_file:
        for line in template_file.readlines():
            html_content = html_content + line.strip()

    return BeautifulSoup(html_content, "html.parser")

SOUP_TEMPLATE = get_soup_template()

def get_template_function():
    templates = {}
    
    for template in SOUP_TEMPLATE.head.find_all("template"):
        template_name = template.get("id")[9:] #"template-"
        template_content = template.contents[0]
        templates[template_name] = template_content
        template.extract()

    def get_template(template_name):
        return copy.copy(templates[template_name])
    
    return get_template

get_template = get_template_function()

def quick_add_template(append_to, template_name, set_string, add_class_=None):
    template = get_template(template_name)
    if set_string:
        template.string = set_string
    if add_class_:
        add_class(template, add_class_)
    append_to.append(template)
    return template

def add_class(element, class_name):
    element['class'] = element.get('class', []) + [class_name]
    
def remove_class(element, class_name):
    if 'class' in element:
        element['class'] = [c for c in element['class'] if c != class_name]




def escape_html(string):
    escape_table = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
    }

    def replace(match):
        return escape_table.get(match.group(0), match.group(0))

    return re.sub(r"[&<>\*\_`']", replace, string)

def escape_formatting(string):
    conversion_dict = {
        '\*': '&#42;',
        '\_': '&#95;',
        '\`': '&#96;'
    }
    
    for pattern, replacement in conversion_dict.items():
        string = string.replace(pattern, replacement)
    
    return string

def formatted_to_html(string):
    string = escape_html(string)
    string = escape_formatting(string)
    
    string = re.sub(r"\*\*\*(.*?)\*\*\*", r"<strong><em>\1</em></strong>", string)
    string = re.sub(r"\*\*(.*?)\*\*", r"<strong>\1</strong>", string)
    string = re.sub(r"\*(.*?)\*", r"<em>\1</em>", string)
    string = re.sub(r"__(.*?)__", r"<u>\1</u>", string)
    string = re.sub(r"`(.*?)`", r"<code class='inline-code'>\1</code>", string)
    string = re.sub(r"```(.*?)```", r"<pre class='code-block'>\1</pre>", string)
    string = string.replace("\n", "<br>")

    return string

def description_array_to_html(desc):
    length = len(desc) - 1
    desc_string = ""
    for i, paragraph in enumerate(desc):
        desc_string = desc_string + formatted_to_html(paragraph)
        if i < length:
            desc_string = desc_string + "<br>"
    return BeautifulSoup(desc_string, "html.parser")

def insert_special_tag(group_item, item, pos=1):
    if "special_tag" in item:
        tag_api = item["special_tag"]
        special_tag = get_template("special-tag-" + tag_api["type"])
        special_tag.span.string = tag_api["text"]
        group_item.insert(pos, special_tag)



lua_types = ["nil", "boolean", "number", "string"]
roblox_types = ["Axes", "BrickColor", "CatalogSearchParams", "CFrame", "Color3", "ColorSequence", "ColorSequenceKeypoint", "Content", "DateTime", "DockWidgetPluginGuiInfo", "Faces", "FloatCurveKey", "Font", "Instance", "NumberRange", "NumberSequence", "NumberSequenceKeypoint", "OverlapParams", "PathWaypoint", "PhysicalProperties", "Random", "Ray", "RaycastParams", "RaycastResult", "RBXScriptConnection", "RBXScriptSignal", "Rect", "Region3", "Region3int16", "SharedTable", "TweenInfo", "UDim2", "Vector2", "Vector2int16", "Vector3", "Vector3int16"]

LUA_TYPE_API = "https://create.roblox.com/docs/luau/"
ROBLOX_DATATYPE_API = "https://create.roblox.com/docs/reference/engine/datatypes/"
ENUM_API = "https://create.roblox.com/docs/reference/engine/enums/"

def anchor_type_href(class_name, append_to, gtype_):
    anchor = get_template("lua-type")
    anchor.string = gtype_
    append_to.append(anchor)
    
    type_ = gtype_
    if gtype_[-1:] == "?":
        type_ = gtype_[:-1]
    
    if type_ == class_name:
        anchor["href"] = ""
        return
    for lua_type in lua_types:
        if type_ == lua_type:
            href = LUA_TYPE_API + type_
            if type_ != "nil":
                anchor["href"] = href + "s"
            else:
                anchor["href"] = href
            return
    for roblox_type in roblox_types:
        if type_ == roblox_type:
            anchor["href"] = ROBLOX_DATATYPE_API + type_
            return
    if type_[:5] == "Enum.":
        anchor["href"] = ENUM_API + type_[5:]
        return
    return

def setup_group_item(item, delete_h3=False):
    group_item = get_template("group-item")
    if delete_h3:
        group_item.h3.extract()
    else:
        group_item.h3.string = item["name"]
        group_item.h3["id"] = item["name"]
    insert_special_tag(group_item, item)
    if len(item["desc"]) > 0:
        group_item.p.append(description_array_to_html(item["desc"]))
    return group_item

# quick_add_template(append_to, "", "", depth_class)

def generate_from_tokens(class_name, append_to, tokens, depth=0, remove_first=False):
    indent = '    ' * (depth + 1)
    depth_class = "depth-" + str(depth % 3)
    found_first_paramater = False
    found_first_type = False
    found_first_seperator = False
    for token in tokens:
        token_type = token["type"]
        if token_type == "tuple":
            quick_add_template(append_to, "tuple", "(", depth_class)
            generate_from_tokens(
                class_name, 
                append_to, 
                token["unseparated_tokens"], 
                depth + 1, 
                depth == 0 and remove_first
            )
            if remove_first:
                found_first_paramater = True
                found_first_type = True
                found_first_seperator = True
            quick_add_template(append_to, "tuple", ")", depth_class)
        elif token_type == "indexer":
            quick_add_template(append_to, "indexer", "[", depth_class)
            generate_from_tokens(
                class_name, 
                append_to, 
                token["unseparated_tokens"], 
                depth + 1
            )
            quick_add_template(append_to, "indexer", "]", depth_class)
        elif token_type == "table":
            quick_add_template(append_to, "table", "{", depth_class)
            generate_from_tokens(
                class_name, 
                append_to, 
                token["unseparated_tokens"], 
                depth + 1
            )
            quick_add_template(append_to, "table", "}", depth_class)
        elif token_type == "separator":
            if remove_first and found_first_paramater and not found_first_seperator:
                found_first_type = True
                found_first_seperator = True
            else:
                quick_add_template(append_to, "separator", ",\u00A0")
        elif token_type == "arrow":
            quick_add_template(append_to, "arrow", None, depth_class)
        elif token_type == "union":
            quick_add_template(append_to, "union", "\u00A0|\u00A0")
        elif token_type == "intersection":
            quick_add_template(append_to, "intersection", "\u00A0&\u00A0")
        elif token_type == "punc":
            tok_text = token["token"]
            if tok_text == "<" or tok_text == ">":
                quick_add_template(append_to, "punc", token["token"], "generic")
            else:
                quick_add_template(append_to, "punc", token["token"])
        elif token_type == "identifier":
            identifier = token["identifier"]
            if depth == 0 and identifier == "":
                quick_add_template(append_to, "arrow", None, depth_class)
            else:
                if remove_first and not found_first_paramater:
                    found_first_paramater = True
                else:
                    quick_add_template(append_to, "identifier", identifier + ":\u00A0")
        elif token_type == "lua_type":
            if remove_first and found_first_paramater and not found_first_type:
                found_first_type = True
            else:
                anchor_type_href(
                    class_name, 
                    append_to, 
                    token["lua_type"]
                )
        
            
def parse_type(class_name, append_to, type_text, remove_first=False):
    type_text = ''.join(type_text.split())
    tokens = tokenize(type_text)
    generate_from_tokens(class_name, append_to, tokens, remove_first=remove_first)
    

class_compatability = {
    "generic": ["lua-type"],
    "prop-dot": ["prop-name"],
    "prop-name": ["prop-colon"],
    "prop-colon": [],
    "method-name": ["dot-call", "colon-call", "tuple"],
    "dot-call": ["method-name"],
    "colon-call": ["method-name"],
    "tuple": ["tuple"],
    "table": ["lua-type", "table"],
    "lua-type": ["separator", "generic", "table"],
    "identifier": ["tuple"],
    "separator": ["lua-type"],
    "operand2": ["op-colon"],
    "op-colon": []
}
    

def get_identifying_class(item):
    class_list = item["class"]
    i_class = class_list[1]
    if i_class != "punc" or len(class_list) < 2:
        return i_class
    else:
        return class_list[2]

def group_similar_items(insert_span):
    i = 0
    groups = 0
    token_list = insert_span.find_all(class_="token")
    length = len(token_list)
    current_group = []
    match_group = None
    prev_group = None
    while i < length:
        token = token_list[i]
        i_class = get_identifying_class(token)
        
        token_starts_space = token.string[0] == "\u00A0"
        token_ends_space = token.string[-1] == "\u00A0"

        if len(current_group) > 0:
            matches_prev = (not token_starts_space) and i_class in prev_group
            if matches_prev:
                current_group.append(token)
                prev_group = class_compatability[i_class]
                
            if not(matches_prev) or token_ends_space or i == length - 1:
                if len(current_group) > 1:
                    group_span = get_template("grouping")
                    for stok in current_group:
                        group_span.append(stok)
                    i_offset = 0
                    if not(matches_prev):
                        i_offset = 1
                    groups += len(current_group) - 1
                    insert_span.insert(i - i_offset - groups, group_span)
                    
                current_group = []
                match_group = None
                prev_group = None
        
        if len(current_group) == 0:
            if not token_ends_space:
                if i_class in class_compatability:
                    match_group = class_compatability[i_class].copy()
                    match_group.append(i_class)
                    current_group = [token]
                    prev_group = class_compatability[i_class]
        
        i += 1
    

def property_to_html(class_name, item):
    group_item = setup_group_item(item)
    insert_span = group_item.find("span", class_="definition")
    quick_add_template(insert_span, "class-name", class_name)
    quick_add_template(insert_span, "punc", ".", "prop-dot")
    quick_add_template(insert_span, "prop-name", item["name"])
    quick_add_template(insert_span, "punc", ":\u00A0", "prop-colon")
    parse_type(class_name, insert_span, item["lua_type"])
    
    group_similar_items(insert_span)
    
    return group_item

def function_to_html(class_name, item, call_syntax):
    group_item = setup_group_item(item)
    insert_span = group_item.find("span", class_="definition")
    quick_add_template(insert_span, "class-name", class_name)
    class_call_syntax = "dot-call" if call_syntax == "." else "colon-call"
    quick_add_template(insert_span, "punc", call_syntax, class_call_syntax)
    quick_add_template(insert_span, "method-name", item["name"])
    
    parse_type(class_name, insert_span, item["definition"], ((call_syntax == ":") and item["remove_first"]))
    
    group_similar_items(insert_span)
    
    return group_item

operation_map = {
    "add": "+",
    "sub": "-",
    "mul": "*",
    "div": "/",
    "pow": "^",
    "eq": "==",
    "lt": "<",
    "le": "<=",
    "gt": ">",
    "ge": ">=",
}

def operation_to_string(class_name, item):
    operator = item["operator"]
    if operator == "unm":
        return "-" + item["operand1"]
    if operator == "len":
        return "#" + item["operand1"]
        
    else:
        return item["operand1"] + "\u00A0" + operation_map[operator] + "\u00A0" + item["operand2"]

def operation_to_html(class_name, item):
    group_item = setup_group_item(item, True)
    add_class(group_item, "operation-item")
    group_item["id"] = operation_to_string(class_name, item)
    insert_span = group_item.find("span", class_="definition")
    
    operator = item["operator"]
    if operator == "unm":
        quick_add_template(insert_span, "operator", "-")
        parse_type(class_name, insert_span, item["operand1"])
    elif operator == "len":
        quick_add_template(insert_span, "operator", "#")
        parse_type(class_name, insert_span, item["operand1"])
    else:
        parse_type(class_name, insert_span, item["operand1"])
        quick_add_template(insert_span, "operator", "\u00A0" + operation_map[operator] + "\u00A0")
        parse_type(class_name, insert_span, item["operand2"])
    
    if "return" in item:
        quick_add_template(insert_span, "punc", ":" + "\u00A0", "op-colon")
        parse_type(class_name, insert_span, item["return"])
    
    group_similar_items(insert_span)
    
    return group_item

def alias_to_html(class_name, item):
    group_item = setup_group_item(item)
    alias_link = "#" + item["alias"]
    alias_anchor = get_template("alias")
    alias_anchor["href"] = alias_link
    alias_anchor.string = item["alias"]
    group_item.p.append("Alias for ")
    group_item.p.append(alias_anchor)
    group_item.p.append(".")
    
    group_item.find("div", class_="box-container").extract()
    
    return group_item

def process_list_json(function_group, soup, class_name):
    group_name = function_group["name"]
    
    group_component = get_template("group-component")
    group_component.h2.string = group_name
    group_component.h2["id"] = group_name
    
    sidebar_list = soup.find("ul", class_="sidebar-list")
    sidebar_super = get_template("sidebar-super")
    sidebar_super.a.string = group_name
    sidebar_super.a["href"] = "#" + group_name
    sidebar_list.append(sidebar_super)
    
    for item in function_group["list"]:
        sidebar_sub = get_template("sidebar-sub")
        tag = item["tag"]
        if "name" in item:
            target_name = item["name"]
        else:
            target_name = operation_to_string(class_name, item)
        
        sidebar_sub.a.string = target_name
        sidebar_sub.a["href"] = "#" + target_name
            
        sidebar_list.append(sidebar_sub)
        
       
        if tag == "property":
            group_component.ul.append(property_to_html(class_name, item))
        elif tag == "function":
            group_component.ul.append(function_to_html(class_name, item, "."))
        elif tag == "method":
            group_component.ul.append(function_to_html(class_name, item, ":"))
        elif tag == "operation":
            group_component.ul.append(operation_to_html(class_name, item))
        elif tag == "alias":
            group_component.ul.append(alias_to_html(class_name, item))
    
    return group_component

def api_page(filename):
    json_source_path = os.path.join(source_folder, filename)
    target_output_path = os.path.join(target_folder, filename[:-4] + "html")
    
    with open(json_source_path, 'r') as json_source:
        json_docs = json.load(json_source)
    
    soup = copy.copy(SOUP_TEMPLATE)
    
    content_list = soup.find("ul", class_="content-list")
    class_name = ""
    for function_group in json_docs:
        purpose = function_group["purpose"]
        if purpose == "top":
            title = get_template("title-description")
            class_name = function_group["name"]
            title.h1.string = function_group["name"]
            title.h1["id"] = function_group["name"]
            desc = function_group["desc"]
            title.p.append(description_array_to_html(desc))
            content_list.append(title)
        elif purpose == "list":
            group_component = process_list_json(function_group, soup, class_name)
            content_list.append(group_component)


    with open(target_output_path, 'w') as target_file:
        target_file.write(str(soup))

    print(f'Processed: {filename} -> html')

def create_api_pages():
    for filename in os.listdir(source_folder):
        if filename.endswith('.json'):
            api_page(filename)
    print('All files processed.')

def create_index_page():
    with open("README.md", "r") as READ_ME_MD:
        READ_ME_HTML = markdown.markdown(READ_ME_MD.read())
    
    read_me_soup = BeautifulSoup(READ_ME_HTML, "html.parser")
    soup = copy.copy(SOUP_TEMPLATE)
    
    soup.find("ul", class_="content-list").extract()
    main = soup.find("main")
    main.append(read_me_soup)
    
    soup.find("nav", class_="class-list").extract()
    
    with open("build/index.html", "w") as READ_ME_HTML:
        READ_ME_HTML.write(str(soup))
    

def main():
    create_api_pages()
    create_index_page()
    

if __name__ == "__main__":
    main()




