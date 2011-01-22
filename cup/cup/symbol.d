module symbol;

import hurt.conv.conv;

/** Defines the Symbol class, which is used to represent all terminals
 * and nonterminals while parsing.	The lexer should pass CUP Symbols 
 * and CUP returns a Symbol. */

/** Class Symbol
 * what the parser expects to receive from the lexer. 
 * the token is identified as follows:
 * sym:		the symbol type
 * parse_state: the parse state.
 * value:	is the lexical value of type Object
 * left :	is the left position in the original input file
 * right:	is the right position in the original input file
 * xleft:	is the left position Object in the original input file
 * xright:	is the left position Object in the original input file */

public class Symbol {
	/** The symbol number of the terminal or non terminal being represented */
	public int sym;

	/** The parse state to be recorded on the parse stack with this symbol.
	 *	This field is for the convenience of the parser and shouldn't be 
	 *	modified except by the parser. */
	public int parse_state;

	/** This allows us to catch some errors caused by scanners recycling
	 *	symbols.	For the use of the parser only. [CSA, 23-Jul-1999] */
	bool used_by_parser = false;

	/** The data passed to parser */
	public int left, right;
	public Object value;

	public this(int id, Symbol left, Symbol right, Object o){
		this(id,left.left,right.right,o);
	}

	public this(int id, Symbol left, Symbol right){
		this(id,left.left,right.right);
	}

	public this(int id, int l, int r, Object o) {
		this(id);
		this.left = l;
		this.right = r;
		this.value = o;
	}

	public this(int id, Object o) {
		this(id, -1, -1, o);
	}

	public this(int id, int l, int r) {
		this(id, l, r, null);
	}

	public this(int sym_num) {
		this(sym_num, -1);
		this.left = -1;
		this.right = -1;
	}

	public this(int sym_num, int state) {
		this.sym = sym_num;
		this.parse_state = state;
	}

	/** Printing this token out. (Override for pretty-print). */
	public override string toString() {
		return "#" ~ conv!(int,string)(this.sym);
	}
}
