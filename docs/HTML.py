import copy
import json
import markdown
import os
import re
import sys

import warnings
from bs4 import BeautifulSoup, MarkupResemblesLocatorWarning
from docs.moonwave.tokens import tokenize

warnings.filterwarnings("ignore", category=MarkupResemblesLocatorWarning)

# function to be created at runtime
get_template = None

def quick_add_template(append_to, template_name, set_string=None, add_class_=None):
    template = get_template(template_name)
    if set_string:
        template.string = set_string
    if add_class_:
        add_class(template, add_class_)
    append_to.append(template)
    return template

def create_sidebar_item(append_to, set_string, href):
    sidebar_item = quick_add_template(append_to, "sidebar-item")
    sidebar_item_a = sidebar_item.find("a")
    sidebar_item_a.string = set_string
    sidebar_item_a["href"] = href

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
        r'\*': '&#42;',
        r'\_': '&#95;',
        r'\`': '&#96;'
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

def setup_group_item(item):
    group_item = get_template("group-item")
    if item["tag"] == "operation":
        id = operation_to_string(item)
        add_class(group_item.h3, "no-display")
    else:
        id = item["name"]
    group_item.h3.string = id
    group_item.h3["id"] = id
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

def operation_to_string(item):
    operator = item["operator"]
    if operator == "unm":
        return "-" + item["operand1"]
    if operator == "len":
        return "#" + item["operand1"]
        
    else:
        return item["operand1"] + "\u00A0" + operation_map[operator] + "\u00A0" + item["operand2"]

def operation_to_html(class_name, item):
    group_item = setup_group_item(item)
    add_class(group_item, "operation-item")
    group_item["id"] = operation_to_string(item)
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
            target_name = operation_to_string(item)
        
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

def api_page(json_path, api_path, filename):
    json_file = os.path.join(json_path, filename)
    api_file = os.path.join(api_path, filename[:-4] + "html")
    
    with open(json_file, 'r') as json_fio:
        json_docs = json.load(json_fio)
    
    soup = get_template("SOUP_TEMPLATE")
    
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


    with open(api_file, 'w') as api_fio:
        api_fio.write(str(soup))

    print(f'Processed: {filename} -> html')

def get_api_pages(json_path):
    api_list = []
    for filename in os.listdir(json_path):
        if filename.endswith(".json"):
            api_list.append(filename[:-5])
    return api_list

def create_api_pages(json_path, web_path, api_path):
    for filename in os.listdir(json_path):
        if filename.endswith('.json'):
            api_page(json_path, api_path, filename)
    print('All files processed.')

def create_index_page(read_me_path, index_html_path):
    read_me_html = None
    with open(read_me_path, "r") as read_me_md:
        read_me_html = markdown.markdown(read_me_md.read())
    
    read_me_soup = BeautifulSoup(read_me_html, "html.parser")
    for link in read_me_soup.find_all("a"):
        add_class(link, "color-link")
    
    soup = get_template("SOUP_TEMPLATE")
    
    ul = soup.find("ul", class_="content-list")
    ul.append(read_me_soup)
    
    sidebar_list = soup.find("ul", class_="sidebar-list")
    headings = soup.find_all(re.compile("^h[1-3]"))
    
    for heading in headings:
        tag_name = heading.name
        tag_text = heading.text
        if tag_text in ["ON THIS PAGE", "API"]:
            continue
        if tag_name == "h3":
            sidebar_item = get_template("sidebar-sub")
        else:
            sidebar_item = get_template("sidebar-super")
        
        sidebar_item.a.string = tag_text
        sidebar_item.a["href"] = "#" + tag_text
        sidebar_list.append(sidebar_item)
    
    
    with open(index_html_path, "w") as READ_ME_HTML:
        READ_ME_HTML.write(str(soup))
    


def HTML(u_read_me_path, u_template_html_path, u_build_path, web_path, index_html):
    global get_template
    
    print("Creating HTML API pages from JSON.")
    assert(isinstance(u_template_html_path, str))
    assert(isinstance(u_build_path, str))
    assert(isinstance(u_read_me_path, str))
    assert(isinstance(web_path, str))
    
    template_html_path = os.path.normpath(u_template_html_path)
    build_path = os.path.normpath(u_build_path)
    read_me_path = os.path.normpath(u_read_me_path)
    
    json_path = os.path.join(build_path, "json")
    api_path = os.path.join(build_path, "api")
    index_html_path = os.path.join(build_path, "index.html")
    
    if not os.path.exists(json_path):
        os.makedirs(json_path)
    
    html_content = ""
    with open(template_html_path, "r") as template_file:
        for line in template_file.readlines():
            html_content = html_content + line.strip()

    SOUP_TEMPLATE = BeautifulSoup(html_content, "html.parser")
    
    templates = {"SOUP_TEMPLATE": SOUP_TEMPLATE}
    for template in SOUP_TEMPLATE.head.find_all("template"):
        template_name = template.get("id")[9:] # remove "template-"
        extracted_template = template.extract()
        templates[template_name] = extracted_template.contents[0]
    
    get_template = lambda template_name: copy.copy(templates[template_name])
    
    
    index_css = SOUP_TEMPLATE.find(id="index-css") #/LuaQuaternion/index.css
    index_css["href"] = web_path + "index.css"
    
    index_script = SOUP_TEMPLATE.find(id="index-script") #/LuaQuaternion/index.js
    index_script["src"] = web_path + "index.js"
    
    api_sidebar_desktop = SOUP_TEMPLATE.find(id="api-sidebar-list-desktop")
    create_sidebar_item(api_sidebar_desktop, "Home", web_path + index_html)
    
    api_sidebar_mobile = SOUP_TEMPLATE.find(id="api-sidebar-list-mobile")
    create_sidebar_item(api_sidebar_mobile, "Home", web_path + index_html)
    
    api_pages = get_api_pages(json_path)
    
    for api_page in api_pages:
        api_href = web_path + "api/" + api_page + ".html"
        create_sidebar_item(api_sidebar_desktop, api_page, api_href)
        create_sidebar_item(api_sidebar_mobile, api_page, api_href)
    
    create_api_pages(json_path, web_path, api_path)
    create_index_page(read_me_path, index_html_path)
    


