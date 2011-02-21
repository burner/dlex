/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * JFlex 1.4.3                                                             *
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

module dflex.charclasses;

import dflex.charclassinterval;
import dflex.intcharset;
import dflex.interval;
import dflex.outmodule;

import hurt.container.vector;
import hurt.conv.conv;
import hurt.exception.illegalargumentexception;
import hurt.stdio.output;
import hurt.string.stringbuffer;


/** @author Gerwin Klein
 * @version JFlex 1.4.3, $Revision: 433 $, $Date: 2009-01-31 19:52:34 +1100 (Sat, 31 Jan 2009) $
 */
public class CharClasses {

	/** debug flag (for char classes only) */
	private immutable DEBUG = false;

	/** the largest character that can be used in char classes */
	//public dchar maxChar = '\U0000FFFF';
	public dchar maxChar = '\U00010000';

	/** the char classes */
	private Vector!(IntCharSet!(dchar)) classes;

	/** the largest character actually used in a specification */
	private char maxCharUsed;

	/**
	 * Constructs a new CharClass object that provides space for 
	 * classes of characters from 0 to maxCharCode.
	 *
	 * Initially all characters are in class 0.
	 *
	 * @param maxCharCode the last character code to be
	 *                    considered. (127 for 7bit Lexers, 
	 *                    255 for 8bit Lexers and 0xFFFF
	 *                    for Unicode Lexers).
	 */
	public this(int maxCharCode) {
		if(maxCharCode < 0 || maxCharCode > 0xFFFF) 
			throw new IllegalArgumentException();

		// TODO cast
		maxCharUsed = cast(char) maxCharCode;

		classes = new Vector!(IntCharSet!(dchar))();
		classes.append(new IntCharSet!(dchar)(new Interval!(dchar)(cast(dchar) 0, maxChar)));
	}

	/** Returns the greatest Unicode value of the current input character set.
	 */
	public char getMaxCharCode() {
		return maxCharUsed;
	}

	/** Sets the largest Unicode value of the current input character set.
	 *
	 * @param charCode   the largest character code, used for the scanner 
	 *                   (i.e. %7bit, %8bit, %16bit etc.)
	 */
	public void setMaxCharCode(int charCode) {
		if(charCode < 0 || charCode > 0xFFFF) 
			throw new IllegalArgumentException();

		// TODO cast
		maxCharUsed = cast(char)charCode;
	}

	/** Returns the current number of character classes.
	 */
	public int getNumClasses() {
		return classes.getSize();
	}

	/** Updates the current partition, so that the specified set of characters
	 * gets a new character class.
	 *
	 * Characters that are elements of <code>set</code> are not in the same
	 * equivalence class with characters that are not elements of <code>set</code>.
	 *
	 * @param set       the set of characters to distinguish from the rest    
	 * @param caseless  if true upper/lower/title case are considered equivalent  
	 */
	public void makeClass(IntCharSet!(dchar) set, bool caseless) {
		if(caseless) 
			set = set.getCaseless();

		if( DEBUG ) {
			Out.dump("makeClass(" ~ set.toString() ~ ")");
			dump();
		}

		uint oldSize = classes.getSize();
		for(uint i = 0; i < oldSize; i++) {
			IntCharSet!(dchar) x  = classes.get(i);

			if(x.equals(set)) return;

			IntCharSet!(dchar) and = x.and(set);

			if( and.containsElements() ) {
				if( x.equals(and) ) {          
					set.sub(and);
					continue;
				}
				else if( set.equals(and) ) {
					x.sub(and);
					classes.append(and);
					if(DEBUG) {
						Out.dump("makeClass(..) finished");
						dump();
					}
					return;
				}

				set.sub(and);
				x.sub(and);
				classes.append(and);
			}
		}

		if(DEBUG) {
			Out.dump("makeClass(..) finished");
			dump();
		}
	}


	/**
	 * Returns the code of the character class the specified character belongs to.
	 */
	public int getClassCode(dchar letter) {
		int i = -1;
		while(true) {
			IntCharSet!(dchar) x = classes.get(++i);
			if( x.contains(letter) ) return i;      
		}
	}

	/**
	 * Dump charclasses to the dump output stream
	 */
	public void dump() {
		Out.dump(this.toString());
	}  


	/**
	 * Return a string representation of one char class
	 *
	 * @param theClass  the index of the class to
	 */
	public string toString(uint theClass) {
		return classes.get(theClass).toString();
	}


	/**
	 * Return a string representation of the char classes
	 * stored in this class. 
	 *
	 * Enumerates the classes by index.
	 */
	public override string toString() {
		StringBuffer!(char) result = new StringBuffer!(char)("CharClasses:");

		result.pushBack("\n");

		for(uint i = 0; i < classes.getSize(); i++) 
			result.pushBack("class " ~ conv!(uint,string)(i) ~ ":\n" ~
				classes.get(i).toString() ~ "\n");    

		return result.toString();
	}


	/**
	 * Creates a new character class for the single character <code>singleChar</code>.
	 *    
	 * @param caseless  if true upper/lower/title case are considered equivalent  
	 */
	public void makeClass(char singleChar, bool caseless) {
		makeClass(new IntCharSet!(dchar)(singleChar), caseless);
	}


	/**
	 * Creates a new character class for each character of the specified String.
	 *    
	 * @param caseless  if true upper/lower/title case are considered equivalent  
	 */
	public void makeClass(string str, bool caseless) {
		for(uint i = 0; i < str.length; i++) 
			makeClass(str[i], caseless);
	}  


	/**
	 * Updates the current partition, so that the specified set of characters
	 * gets a new character class.
	 *
	 * Characters that are elements of the set <code>v</code> are not in the same
	 * equivalence class with characters that are not elements of the set <code>v</code>.
	 *
	 * @param v   a Vector of Interval objects. 
	 *            This Vector represents a set of characters. The set of characters is
	 *            the union of all intervals in the Vector.
	 *    
	 * @param caseless  if true upper/lower/title case are considered equivalent  
	 */
	public void makeClass(Vector!(Interval!(dchar)) v, bool caseless) {
		makeClass(new IntCharSet!(dchar)(v), caseless);
	}


	/**
	 * Updates the current partition, so that the set of all characters not contained in the specified 
	 * set of characters gets a new character class.
	 *
	 * Characters that are elements of the set <code>v</code> are not in the same
	 * equivalence class with characters that are not elements of the set <code>v</code>.
	 *
	 * This method is equivalent to <code>makeClass(v)</code>
	 * 
	 * @param v   a Vector of Interval objects. 
	 *            This Vector represents a set of characters. The set of characters is
	 *            the union of all intervals in the Vector.
	 * 
	 * @param caseless  if true upper/lower/title case are considered equivalent  
	 */
	public void makeClassNot(Vector!(Interval!(dchar)) v, bool caseless) {
		makeClass(new IntCharSet!(dchar)(v), caseless);
	}


	/**
	 * Returns an array that contains the character class codes of all characters
	 * in the specified set of input characters.
	 */
	private int [] getClassCodes(IntCharSet!(dchar) set, bool negate) {

		if(DEBUG) {
			Out.dump("getting class codes for " ~ set.toString());
			if(negate)
				Out.dump("[negated]");
		}

		uint size = classes.getSize();

		// [fixme: optimize]
		int temp[] = new int[size];
		int tlength = 0;

		for(uint i = 0; i < size; i++) {
			IntCharSet!(dchar) x = classes.get(i);
			if( negate ) {
				if( !set.and(x).containsElements() ) {
					temp[tlength++] = i;
					if(DEBUG) Out.dump("code " ~ conv!(int,string)(i));
				}
			}
			else {
				if( set.and(x).containsElements() ) {
					temp[tlength++] = i;
					if(DEBUG) Out.dump("code " ~ conv!(int,string)(i));
				}
			}
		}

		int result [] = temp.dup;
		//System.arraycopy(temp, 0, result, 0, length);

		return result;
	}


	/**
	 * Returns an array that contains the character class codes of all characters
	 * in the specified set of input characters.
	 * 
	 * @param intervallVec   a Vector of Intervals, the set of characters to get
	 *                       the class codes for
	 *
	 * @return an array with the class codes for intervallVec
	 */
	public int [] getClassCodes(Vector!(Interval!(dchar)) /* Interval */ intervallVec) {
		return getClassCodes(new IntCharSet!(dchar)(intervallVec), false);
	}


	/**
	 * Returns an array that contains the character class codes of all characters
	 * that are <strong>not</strong> in the specified set of input characters.
	 * 
	 * @param intervallVec   a Vector of Intervals, the complement of the
	 *                       set of characters to get the class codes for
	 *
	 * @return an array with the class codes for the complement of intervallVec
	 */
	public int [] getNotClassCodes(Vector!(Interval!(dchar)) /* Interval */ intervallVec) {
		return getClassCodes(new IntCharSet!(dchar)(intervallVec), true);
	}


	/**
	 * Check consistency of the stored classes [debug].
	 *
	 * all classes must be disjoint, checks if all characters
	 * have a class assigned.
	 */
	public void check() {
		for(uint i = 0; i < classes.getSize(); i++)
			for(uint j = i+1; j < classes.getSize(); j++) {
				IntCharSet!(dchar) x = classes.get(i);
				IntCharSet!(dchar) y = classes.get(j);
				if( x.and(y).containsElements() ) {
					writeln("Error: non disjoint char classes " ~ conv!(uint,string)(i) ~ 
						" and " ~ conv!(uint,string)(j));
					writeln("class " ~ conv!(uint,string)(i) ~ ": " ~ x.toString());
					writeln("class " ~ conv!(uint,string)(j) ~ ": " ~ y.toString());
				}
			}

		// check if each character has a classcode 
		// (= if getClassCode terminates)
		for(char c = 0; c < maxChar; c++) {
			getClassCode(c);
			if(c % 100 == 0) writeln(".");
		}

		getClassCode(maxChar);   
	}


	/**
	 * Returns an array of all CharClassIntervalls in this
	 * char class collection. 
	 *
	 * The array is ordered by char code, i.e.
	 * <code>result[i+1].start = result[i].end+1</code>
	 *
	 * Each CharClassInterval contains the number of the
	 * char class it belongs to.
	 */
	public CharClassInterval[] getIntervals() {
		uint i, c;
		uint size = classes.getSize();
		int numIntervalls = 0;   

		for(i = 0; i < size; i++) 
			numIntervalls+= classes.get(i).numIntervalls();    

		CharClassInterval [] result = new CharClassInterval[numIntervalls];

		i = 0; 
		c = 0;
		while(i < numIntervalls) {
			int code = getClassCode(cast(char) c);
			IntCharSet!(dchar) set = classes.get(code);
			Interval!(dchar) iv = set.getNext();

			result[i++] = new CharClassInterval(iv.start, iv.end, code);
			c = iv.end+1;
		}

		return result;
	}
}
