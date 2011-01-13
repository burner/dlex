module symbolfactory;

import symbol;

/** Creates the Symbols interface, which CUP uses as default
 *
 * Interface SymbolFactory
 * 
 * interface for creating new symbols  
 * You can also use this interface for your own callback hooks
 * Declare Your own factory methods for creation of Objects in Your scanner! */
public interface SymbolFactory {
    /** Construction with left/right propagation switched on */
    public Symbol newSymbol(string name, int id, Symbol left, Symbol right, Object value);
    public Symbol newSymbol(string name, int id, Symbol left, Symbol right);
    /** Construction with left/right propagation switched off */
    public Symbol newSymbol(string name, int id, Object value);
    public Symbol newSymbol(string name, int id);
    /** Construction of start symbol */
    public Symbol startSymbol(string name, int id, int state);
}
