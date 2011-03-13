module dlex.main;

import dlex.clexgen;

import std.stdio;

public class Main {
	/***************************************************************
		Function: main
	**************************************************************/
	public void main(string[] args) {
		CLexGen lg;

		if(args.length < 1) {
			writeln("Usage: JLex.Main <filename>");
			return;
		}

		/* Note: For debuging, it may be helpful to remove the try/catch
		   block and permit the Exception to propagate to the top level. 
		   This gives more information. */
		try {	
			lg = new CLexGen(args[0]);
			lg.generate();
		} catch(Error e) {
			writeln(e.toString());
		}
	}
}    
