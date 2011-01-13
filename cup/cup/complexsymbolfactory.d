module cup.compleysymbolfactory;

import cup.symbol;
import cup.symbolfactory;

/** Default Implementation for SymbolFactory, creates
 * plain old Symbols
 *
 * class DefaultSymbolFactory
 * interface for creating new symbols */
public class Location {
	private string unit = "unknown";
	private int line, column;

	public this(string unit, int line, int column) {
		this.unit = unit;
		this.line = line;
		this.column = column;
	}
	public this(int line, int column) {
		this.line = line;
		this.column = column;
	}
	public string tostring() {
		return this.unit ~ ":" ~ this.line ~ "/" ~ this.column;
	}
	public int getColumn() {
		return this.column;
	}
	public int getLine() {
		return this.line;
	}
	public string getUnit() {
		return this.unit;
	}
}

// ComplexSymbol with detailed Location Informations and a Name
public class ComplexSymbol : Symbol {
	protected string name;
	protected Location xleft , xright;

	public this(string name, int id) {
		super(id);
		this.name = name;
	}

	public this(string name, int id, Object value) {
		super(id,value);
		this.name = name;
	}

	public this(string name, int id, int state) {
		super(id,state);
		this.name = name;
	}

	public this(string name, int id, Symbol left, Symbol right) {
		super(id,left,right);
		this.name = name;
		if(!(left is null))
			this.xleft = (cast(ComplexSymbol)left).xleft;
		if(!(right is null))
			this.xright = (cast(ComplexSymbol)right).xright;
	}

	public this(string name, int id, Location left, Location right) {
		super(id);
		this.name = name;
		this.xleft = left;
		this.xright = right;
	}

	public this(string name, int id, Symbol left, Symbol right, Object value) {
		super(id,value);
		this.name = name;
		if(!(left is null))
			this.xleft = (cast(ComplexSymbol)left).xleft;
		if(!(right is null))
			this.xright = (cast(ComplexSymbol)right).xright;
	}

	public this(string name, int id, Location left, Location right, Object value) {
		super(id,value);
		this.name = name;
		this.xleft = left;
		this.xright = right;
	}

	public Location getLeft() {
		return this.xleft;
	}

	public Location getRight() {
		return this.xright;
	}

	public override string toString() {
		if(this.xleft is null || this.xright is null)
			 return "Symbol: " ~ name;
		return "Symbol: " ~ this.name ~ " (" ~ this.xleft.toString() ~ 
			" - " ~ this.xright.toString() ~ ")";
	}
}

public class ComplexSymbolFactory : SymbolFactory {
	// Factory methods
	public Symbol newSymbol(string name, int id, Location left, Location right, Object value) {
		return new ComplexSymbol(name,id,left,right,value);
	}
	public Symbol newSymbol(string name, int id, Location left, Location right) {
		return new ComplexSymbol(name,id,left,right);
	}
	public Symbol newSymbol(string name, int id, Symbol left, Symbol right, Object value) {
		return new ComplexSymbol(name,id,left,right,value);
	}
	public Symbol newSymbol(string name, int id, Symbol left, Symbol right) {
		return new ComplexSymbol(name,id,left,right);
	}
	public Symbol newSymbol(string name, int id) {
		return new ComplexSymbol(name,id);
	}
	public Symbol newSymbol(string name, int id, Object value) {
		return new ComplexSymbol(name,id,value);
	}
	public Symbol startSymbol(string name, int id, int state) {
		return new ComplexSymbol(name,id,state);
	}
}
