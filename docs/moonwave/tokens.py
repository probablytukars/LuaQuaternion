# SOURCE: https://github.com/evaera/moonwave/blob/master/docusaurus-plugin-moonwave/src/components/LuaType.js
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

import re

def is_punc(char):
    return re.match(r'[\{\}<>\-\|&()\[\]]', char) is not None

def is_whitespace(char):
    return re.match(r'\s', char) is not None

def is_atom(char):
    return not is_whitespace(char) and not is_punc(char)

def tokenize(code, is_group=False):
    position = 0
    tokens = []
    
    def next_():
        nonlocal position
        if position < len(code):
            result = code[position]
        else:
            result = ""
        position += 1
        return result
    
    def peek():
        if position < len(code):
            return code[position]
        return ""
    
    def read(condition):
        buffer = ""
        
        while peek() and condition(peek()):
            buffer += next_()
        
        return buffer
    
    def read_balanced(left, right):
        buffer = ""
        depth = 0
        
        while peek():
            if peek() == left:
                depth += 1
            elif peek() == right:
                if depth == 0:
                    break
                else:
                    depth -= 1
            
            buffer += next_()
        
        return buffer
    
    
    while position < len(code):
        read(is_whitespace)
        
        if position >= len(code):
            break
        
        if peek() == "(":
            next_()
            tokens.append({
                "type": "tuple",
                "unseparated_tokens": tokenize(read_balanced("(", ")"), True),
            })
            next_()
            continue
        
        if peek() == "[":
            next_()
            tokens.append({
                "type": "indexer",
                "unseparated_tokens": tokenize(read_balanced("[", "]"), True),
            })
            next_()
            continue
        
        if peek() == "{":
            next_()
            tokens.append({
                "type": "table",
                "unseparated_tokens": tokenize(read_balanced("{", "}"), True),
            })
            next_()
            continue
        
        if (is_group and peek() == ","):
            next_()
            tokens.append({
                "type": "separator"
            })
            continue
        
        if is_punc(peek()):
            punc = next_()
            
            if punc == "-" and peek() == ">":
                tokens.append({
                    "type": "arrow"
                })
                next_()
                continue
            
            if punc == "|":
                tokens.append({"type": "union"})
                continue
            
            if punc == "&":
                tokens.append({"type": "intersection"})
                continue
            
            tokens.append({"type": "punc", "token": punc})
            continue
        
        atom = read(lambda char: char != "," and is_atom(char) if is_group else is_atom(char))
        
        if atom:
            if atom[-1] == ":":
                tokens.append({
                    "type": "identifier", 
                    "identifier": atom[:-1],
                })
            elif ":" in atom:
                identifier, type_ = atom.split(":", 1)
                tokens.append({
                    "type": "identifier",
                    "identifier": identifier
                })
                tokens.append({
                    "type": "lua_type",
                    "lua_type": type_
                })
            else:
                tokens.append({
                    "type": "lua_type", 
                    "lua_type": atom
                })
            continue
        
        raise ValueError(f"Reached bottom of tokenizer with no match: {peek()}")
        
        
    return tokens
    



