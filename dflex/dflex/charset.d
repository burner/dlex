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

module dflex.charset;

import dflex.charsetenumerator;

import hurt.conv.conv;
import hurt.math.mathutil;
import hurt.string.stringbuffer;

/**
 * 
 * @author Gerwin Klein 
 * @version JFlex 1.4.3, $Revision: 433 $, $Date: 2009-01-31 19:52:34 +1100 (Sat, 31 Jan 2009) $ 
 */
public final class CharSet {

	immutable BITS = 6;           // the number of bits to shift (2^6 = 64)
	immutable MOD = (1<<BITS)-1;  // modulus

	long bits[];

	private int numElements;


	public this() {
		this.bits = new long[1];
	}


	public this(int initialSize, int character) {
		this.bits = new long[(initialSize >> BITS)+1];
		this.add(character);
	}


	public void add(int character) {
		this.resize(character);

		if( (bits[character >> BITS] & (1L << (character & MOD))) == 0) numElements++;

		bits[character >> BITS] |= (1L << (character & MOD));    
	}


	private int nbits2size (int nbits) {
		return ((nbits >> BITS) + 1);
	}


	private void resize(int nbits) {
		int needed = nbits2size(nbits);

		if (needed < bits.length) return;

		long newbits[] = new long[max!(int)(bits.length*2,needed)];
		//System.arraycopy(bits, 0, newbits, 0, bits.length);
		bits = newbits.dup;

		bits = newbits;
	}


	public bool isElement(int character) {
		int index = character >> BITS;
		if(index >= bits.length)
			return false;
		return (bits[index] & (1L << (character & MOD))) != 0;
	}


	public CharSetEnumerator characters() {
		return new CharSetEnumerator(this);
	}


	public bool containsElements() {
		return numElements > 0;
	}

	public int size() {
		return numElements;
	}

	public override string toString() {
		CharSetEnumerator set = characters();

		StringBuffer!(char) result = new StringBuffer!(char)("{");

		if ( set.hasMoreElements() ) result.pushBack("" ~ conv!(int,string)(set.nextElement()));

		while ( set.hasMoreElements() ) {
			int i = set.nextElement();
			result.pushBack( ", " ~ conv!(int,string)(i));
		}

		result.pushBack("}");

		return result.toString();
	}
}
