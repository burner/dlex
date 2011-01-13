module cup.defaultsymbolfactory;

import cup.symbol;
import cup.symbolfactory;

/** Default Implementation for SymbolFactory, creates
 * plain old Symbols
 *
 * interface for creating new symbols */
public class DefaultSymbolFactory : SymbolFactory {
    /** DefaultSymbolFactory for CUP.
     * Users are strongly encoraged to use ComplexSymbolFactory instead, since
     * it offers more detailed information about Symbols in source code.
     * Yet since migrating has always been a critical process, You have the
     * chance of still using the oldstyle Symbols.
     *
     * @deprecated as of CUP v11a
     * replaced by the new java_cup.runtime.ComplexSymbolFactory */
    public this() {
    }

    public Symbol newSymbol(string name ,int id, Symbol left, Symbol right, Object value){
        return new Symbol(id,left,right,value);
    }

    public Symbol newSymbol(string name, int id, Symbol left, Symbol right){
        return new Symbol(id,left,right);
    }

    public Symbol newSymbol(string name, int id, int left, int right, Object value){
        return new Symbol(id,left,right,value);
    }

    public Symbol newSymbol(string name, int id, int left, int right){
        return new Symbol(id,left,right);
    }

    public Symbol startSymbol(string name, int id, int state){
        return new Symbol(id,state);
    }

    public Symbol newSymbol(string name, int id){
        return new Symbol(id);
    }

    public Symbol newSymbol(string name, int id, Object value){
        return new Symbol(id,value);
    }
}
