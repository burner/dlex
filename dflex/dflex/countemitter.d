/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * jflex 1.4                                                               *
 * Copyright (C) 1998-2009  Gerwin Klein <lsf@jflex.de>                    *
 * All rights reserved.                                                    *
 *                                                                         *
 * This program is free software; you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License. See the file      *
 * COPYRIGHT for more information.                                         *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License along *
 * with this program; if not, write to the Free Software Foundation, Inc., *
 * 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA                 *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

module dflex.countemitter;

import dflex.packemitter;

import hurt.conv.conv;

import std.stdio;

/** An emitter for an array encoded as count/value pairs in a string.
 * 
 * @author Gerwin Klein */
public class CountEmitter : PackEmitter {
	/** number of entries in expanded array */
	private int numEntries;

	/** translate all values by this amount */ 
	private int translate = 0;

	/** Create a count/value emitter for a specific field.
	 * 
	 * @param name   name of the generated array */
	protected this(string name) {
		super(name);
	}

	/** Emits count/value unpacking code for the generated array. 
	 * 
	 * @see JFlex.PackEmitter#emitUnPack() */
	public override void emitUnpack() {
		// close last string chunk:
		writefln("\";\n");

		writefln("  private static int [] zzUnpack" ~ name ~ "() {");
		writefln("    int [] result = new int[" ~ conv!(int,string)(numEntries) ~ "];");
		writefln("    int offset = 0;");

		for(int i = 0; i < chunks; i++) {
			writefln("    offset = zzUnpack" ~ name ~ "(" ~ constName() ~ 
					"_PACKED_" ~ conv!(int,string)(i) ~ ", offset, result);");
		}

		writefln("    return result;");
		writefln("  }\n");

		writefln("  private static int zzUnpack" ~ name ~ "(String packed, int offset, int [] result) {");
		writefln("    int i = 0;       /* index in packed string  */");
		writefln("    int j = offset;  /* index in unpacked array */");
		writefln("    int l = packed.length();");
		writefln("    while (i < l) {");
		writefln("      int count = packed.charAt(i++);");
		writefln("      int value = packed.charAt(i++);");

		if(translate == 1) {
			writefln("      value--;");
		} else if(translate != 0) {
			writefln("      value-= " ~ conv!(int,string)(translate));
		}
		writefln("      do result[j++] = value; while (--count > 0);");
		writefln("    }");
		writefln("    return j;");
		writefln("  }");
	}

	/** Translate all values by given amount.
	 * 
	 * Use to move value interval from [0, 0xFFFF] to something different.
	 * 
	 * @param i   amount the value will be translated by. 
	 *            Example: <code>i = 1</code> allows values in [-1, 0xFFFE]. */
	public void setValTranslation(int i) {
		this.translate = i;    
	}

	/** Emit one count/value pair. 
	 * 
	 * Automatically translates value by the <code>translate</code> value. 
	 * 
	 * @param count
	 * @param value
	 * 
	 * @see CountEmitter#setValTranslation(int) */
	public void emit(int count, int value) {
		numEntries+= count;
		breaks();
		emitUC(count);
		emitUC(value+translate);        
	}
}
