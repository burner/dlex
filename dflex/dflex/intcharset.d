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

module dflex.intcharset;;

import dflex.interval;
import dflex.outmodule;

import hurt.container.vector;
import hurt.conv.conv;
import hurt.stdio.output;
import hurt.string.stringutil;
import hurt.string.stringbuffer;

/** CharSet implemented with intervalls
 *
 * [fixme: optimizations possible]
 *
 * @author Gerwin Klein
 * @version JFlex 1.4.3, $Revision: 433 $, $Date: 2009-01-31 19:52:34 +1100 (Sat, 31 Jan 2009) $
 */
public final class IntCharSet(T) {

	private immutable DEBUG = false;

	/* invariant: all intervals are disjoint, ordered */
	private Vector!(Interval!(T)) intervalls;  
	private int pos; 

	public this() {
		this.intervalls = new Vector!(Interval!(T))();
	}

	public this(T c) {
		this(new Interval!(T)(c,c));
	}

	public this(Interval!(T) intervall) {
		this();
		intervalls.append(intervall);
	}

	public this(Vector!(Interval!(T)) /* Interval */ chars) {
		int size = chars.getSize();

		this.intervalls = new Vector!(Interval!(T))(size);

		for (int i = 0; i < size; i++) 
			add(chars.get(i));    
	}

	/** returns the index of the intervall that contains
	 * the character c, -1 if there is no such intevall
	 *
	 * @prec: true
	 * @post: -1 <= return < intervalls.size() && 
	 *        (return > -1 --> intervalls[return].contains(c))
	 * 
	 * @param c  the character
	 * @return the index of the enclosing interval, -1 if no such interval  
	 */
	private int indexOf(T c) {
		int start = 0;
		int end = intervalls.getSize()-1;

		while (start <= end) {
			int check = (start+end) / 2;
			Interval!(T) i = intervalls.get(check);

			if (start == end) 
				return i.contains(c) ? start : -1;      

			if (c < i.start) {
				end = check-1;
				continue;
			}

			if (c > i.end) {
				start = check+1;
				continue;
			}

			return check;
		}

		return -1;
	} 

	public IntCharSet!(T) add(IntCharSet!(T) set) {
		for (uint i = 0; i < set.intervalls.getSize(); i++) 
			add(set.intervalls.get(i) );    
		return this;
	}

	public void add(Interval!(T) intervall) {

		int size = intervalls.getSize();

		for (int i = 0; i < size; i++) {
			Interval!(T) elem = intervalls.get(i);

			if ( elem.end+1 < intervall.start ) continue;

			if ( elem.contains(intervall) ) return;      

			if ( elem.start > intervall.end+1 ) {
				intervalls.insert(i, new Interval!(T)(intervall));
				return;
			}

			if (intervall.start < elem.start)
				elem.start = intervall.start;

			if (intervall.end <= elem.end) 
				return;

			elem.end = intervall.end;

			i++;      
			// delete all x with x.contains( intervall.end )
			while (i < size) {
				Interval!(T) x = intervalls.get(i);
				if (x.start > elem.end+1) return;

				elem.end = x.end;
				intervalls.remove(i);
				size--;
			}
			return;      
		}

		intervalls.append(new Interval!(T)(intervall));
	}

	public void add(char c) {
		int size = intervalls.getSize();

		for (int i = 0; i < size; i++) {
			Interval!(T) elem = intervalls.get(i);
			if (elem.end+1 < c) continue;

			if (elem.contains(c)) return; // already there, nothing to do

			// assert(elem.end+1 >= c && (elem.start > c || elem.end < c));

			if (elem.start > c+1) {
				intervalls.insert(i, new Interval!(T)(c,c));
				return;                 
			}

			// assert(elem.end+1 >= c && elem.start <= c+1 && (elem.start > c || elem.end < c));

			if (c+1 == elem.start) {
				elem.start = c;
				return;
			}

			// assert(elem.end+1 == c);
			elem.end = c;

			// merge with next interval if it contains c
			if (i+1 >= size) return;
			Interval!(T) x = intervalls.get(i+1);
			if (x.start <= c+1) {
				elem.end = x.end;
				intervalls.remove(i+1);
			}
			return;
		}

		// end reached but nothing found -> append at end
		intervalls.append(new Interval!(T)(c,c));
	} 


	public bool contains(dchar singleChar) {
		return indexOf(singleChar) >= 0;
	}


	/**
	 * o instanceof Interval
	 */
	public bool equals(Object o) {
		IntCharSet set = cast(IntCharSet) o;
		if( intervalls.getSize() != set.intervalls.getSize() ) return false;

		for(int i = 0; i < intervalls.getSize(); i++) {
			if( !intervalls.get(i).equals( set.intervalls.get(i)) ) 
				return false;
		}

		return true;
	}

	private T min(T)(T a, T b) {
		return a <= b ? a : b;
	}

	private T max(T)(T a, T b) {
		return a >= b ? a : b;
	}

	/* intersection */
	public IntCharSet!(T) and(IntCharSet set) {
		if(DEBUG) {
			write("intersection");
			write("this  : " ~ this.toString());
			write("other : " ~ set.toString());
		}

		IntCharSet!(T) result = new IntCharSet!(T)();

		int i = 0;  // index in this.intervalls
		int j = 0;  // index in set.intervalls

		int size = intervalls.getSize();
		int setSize = set.intervalls.getSize();

		while (i < size && j < setSize) {
			Interval!(T) x = this.intervalls.get(i);
			Interval!(T) y = set.intervalls.get(j);

			if (x.end < y.start) {
				i++;
				continue;
			}

			if (y.end < x.start) {
				j++;
				continue;
			}

			result.intervalls.append(
					new Interval!(T)(
						max(x.start, y.start), 
						min(x.end, y.end)
						)
					);

			if (x.end >= y.end) j++;
			if (y.end >= x.end) i++;
		}

		if (DEBUG) {
			write("result: " ~ result.toString());
		}

		return result;
	}

	/* complement */
	/* prec: this.contains(set), set != null */
	public void sub(IntCharSet set) {
		if (DEBUG) {
			Out.dump("complement");
			Out.dump("this  : " ~ this.toString());
			Out.dump("other : " ~ set.toString());
		}

		int i = 0;  // index in this.intervalls
		int j = 0;  // index in set.intervalls

		int setSize = set.intervalls.getSize();

		while (i < intervalls.getSize() && j < setSize) {
			Interval!(T) x = this.intervalls.get(i);
			Interval!(T) y = set.intervalls.get(j);

			if(DEBUG) {
				Out.dump("this      : "~this.toString());
				Out.dump("this  ["~conv!(int,string)(i)~"] : "~x.toString());
				Out.dump("other ["~conv!(int,string)(j)~"] : "~y.toString());
			}

			if (x.end < y.start) {
				i++;
				continue;
			}

			if (y.end < x.start) {
				j++;
				continue;
			}

			// x.end >= y.start && y.end >= x.start ->
			// x.end <= y.end && x.start >= y.start (prec)

			if ( x.start == y.start && x.end == y.end ) {
				intervalls.remove(i);
				j++;
				continue;
			}

			// x.end <= y.end && x.start >= y.start &&
			// (x.end < y.end || x.start > y.start) ->
			// x.start < x.end 

			if ( x.start == y.start ) {
				x.start = cast(T) (y.end+1);
				j++;
				continue;
			}

			if ( x.end == y.end ) {
				x.end = cast(T) (y.start-1);
				i++;
				j++;
				continue;
			}

			intervalls.insert(i, new Interval!(T)(x.start, cast(T) (y.start-1)));
			x.start = cast(T) (y.end+1);

			i++;
			j++;
		}   

		if (DEBUG) {
			Out.dump("result: "~this.toString());
		}
	}

	public bool containsElements() {
		return intervalls.getSize() > 0;
	}

	public int numIntervalls() {
		return intervalls.getSize();
	}

	// beware: depends on caller protocol, single user only 
	public Interval!(T) getNext() {
		if (pos == intervalls.getSize()) pos = 0;
		return intervalls.get(pos++);
	}

	/** Create a caseless version of this charset.
	 * <p>
	 * The caseless version contains all characters of this char set,
	 * and additionally all lower/upper/title case variants of the 
	 * characters in this set.
	 * 
	 * @return a caseless copy of this set
	 */
	public IntCharSet getCaseless() {
		IntCharSet!(T) n = copy();

		uint size = intervalls.getSize();
		for(uint i=0; i < size; i++) {
			Interval!(T) elem = intervalls.get(i);
			for(T c = elem.start; c <= elem.end; c++) {		//FIXME the IntCharSet stuff following is new
				n.add(new IntCharSet!(T)(toLowerCase!(T)(c))); 
				n.add(new IntCharSet!(T)(toUpperCase!(T)(c))); 
				n.add(new IntCharSet!(T)(toTitleCase!(T)(c))); 
			}
		}

		return n;    
	}


	/**
	 * Make a string representation of this char set.
	 * 
	 * @return a string representing this char set.
	 */
	public override string toString() {
		StringBuffer!(char) result = new StringBuffer!(char)("{ ");

		for (int i = 0; i < intervalls.getSize(); i++)
			result.pushBack( intervalls.get(i).toString() );

		result.pushBack(" }");

		return result.toString();
	}


	/** 
	 * Return a (deep) copy of this char set
	 * 
	 * @return the copy
	 */
	public IntCharSet!(T) copy() {
		IntCharSet!(T) result = new IntCharSet!(T)();
		uint size = intervalls.getSize();
		for(uint i=0; i < size; i++) {
			Interval!(T) iv = intervalls.get(i).copy();
			result.intervalls.append(iv);
		}
		return result;
	}
}
