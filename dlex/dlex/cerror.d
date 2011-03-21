module dlex.cerror;

import hurt.conv.conv;

import std.stdio;

class CError {
	/********************************************************
	 * Function: impos Description:
	 *******************************************************/
	static void impos(string message) {
		writeln("Dlex Error: " ~ message);
	}

	/********************************************************
	 * Constants Description: Error codes for parse_error().
	 *******************************************************/
	static immutable int E_BADEXPR = 0;
	static immutable int E_PAREN = 1;
	static immutable int E_LENGTH = 2;
	static immutable int E_BRACKET = 3;
	static immutable int E_BOL = 4;
	static immutable int E_CLOSE = 5;
	static immutable int E_NEWLINE = 6;
	static immutable int E_BADMAC = 7;
	static immutable int E_NOMAC = 8;
	static immutable int E_MACDEPTH = 9;
	static immutable int E_INIT = 10;
	static immutable int E_EOF = 11;
	static immutable int E_DIRECT = 12;
	static immutable int E_INTERNAL = 13;
	static immutable int E_STATE = 14;
	static immutable int E_MACDEF = 15;
	static immutable int E_SYNTAX = 16;
	static immutable int E_BRACE = 17;
	static immutable int E_DASH = 18;
	static immutable int E_ZERO = 19;
	static immutable int E_BADCTRL = 20;

	/********************************************************
	 * Constants Description: String messages for parse_error();
	 *******************************************************/
	static immutable string[] errmsg = [
			"Malformed regular expression.",
			"Missing close parenthesis.",
			"Too many regular expressions or expression too long.",
			"Missing [ in character class.",
			"^ must be at start of expression or after [.",
			"+ ? or * must follow an expression or subexpression.",
			"Newline in quoted string.",
			"Missing } in macro expansion.",
			"Macro does not exist.",
			"Macro expansions nested too deeply.",
			"JLex has not been successfully initialized.",
			"Unexpected end-of-file found.",
			"Undefined or badly-formed JLex directive.",
			"Internal JLex error.",
			"Unitialized state name.",
			"Badly formed macro definition.",
			"Syntax error.",
			"Missing brace at start of lexical action.",
			"Special character dash - in character class [...] must\n\tbe preceded by start-of-range character.",
			"Zero-length regular expression.",
			"Illegal \\^C-style escape sequence (character following caret must\n\tbe alphabetic)."];

	/********************************************************
	 * Function: parse_error Description:
	 *******************************************************/
	static void parse_error(int error_code, int line_number) {
		writeln("Error: Parse error at line " ~ conv!(int,string)(line_number) ~ ".");
		writeln("Description: " ~ errmsg[error_code]);
		throw new Error("Parse error.");
	}
}
