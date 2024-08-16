const is_punc = (char: string): boolean => /[\{\}<>\-\|&()\[\]]/.test(char)
const is_whitespace = (char: string): boolean => /\s/.test(char)
const is_atom = (char: string): boolean => !(is_whitespace(char) || is_punc(char))

interface Token {
	type: string;
	identifier?: string;
	lua_type?: string;
	unseparated_tokens?: Token[];
	token?: string; // for punctuation
	separator?: true; // for comma separator
	arrow?: true; // for -> arrow
	union?: true; // for union operator
	intersection?: true; // for intersection operator
}

export function tokenize(code: string, is_group: boolean = false): Token[] {
	let position = 0
	let tokens: Token[] = []
	
	const peek = () => position < code.length ? code[position] : null
	const next = () => {
		let result = peek();
		position += 1
		return result
	}
	const read = (condition: (char: string) => boolean): string => {
		let buffer = ""
		while (peek() && condition(peek())) {buffer += next()}
		return buffer
	}
	const read_balanced = (left: string, right: string): string => {
		let buffer = ""
		let depth = 0
		while (peek()) {
			if (peek() == left) {depth += 1} else 
			if (peek() == right) {if (depth == 0) {break} else {depth -= 1}}
			buffer += next()
		}
		return buffer
	}
	
	const read_brackets = (v_type: string, left: string, right: string) => {
		next()
		tokens.push({
			type: v_type,
			unseparated_tokens: tokenize(read_balanced(left, right), true),
		})
		next()
	}
	
	while (position < code.length) {
		read(is_whitespace)
		
		if (position >= code.length) {break;}
		
		if (peek() == "(") {read_brackets("tuple", "(", ")"); continue;}
		if (peek() == "[") {read_brackets("indexer", "[", "]"); continue;}
		if (peek() == "{") {read_brackets("table", "{", "}"); continue;}
		if (is_group && peek() == ",") {
			next();
			tokens.push({type: "separator"});
			continue;
		}
		if (is_punc(peek())) {
			const punc = next();
			if (punc == "-" && peek() == ">") {
				tokens.push({type: "arrow"});
				next();
				continue
			}
			if (punc == "|") {tokens.push({type: "union"}); continue;}
			if (punc == "&") {tokens.push({type: "intersection"}); continue;}
			
			tokens.push({type: "punc", token: punc});
			continue;
		}
		
		
		const atom = read((char) => is_atom(char) && (char !== "," || !is_group))
		
		if (atom != "") {
			if (atom.endsWith(":")) {
				tokens.push({
					type: "identifier", 
					identifier: atom.slice(0, -1),
				})
			} else if (atom.includes(":")) {
				const [identifier, type_] = atom.split(":", 1)
				tokens.push({
					type: "identifier",
					identifier: identifier
				})
				tokens.push({
					type: "lua_type",
					lua_type: type_
				})
			} else {
				tokens.push({
					type: "lua_type", 
					lua_type: atom
				})
			}
			continue
		}
			
		
		throw new Error(`Reached bottom of tokenizer with no match: ${peek()} \"${atom}\" ${is_group} `)
	}
		
	return tokens
}