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

module dflex.interval;

import hurt.string.stringbuffer;
import hurt.conv.conv;

/** An intervall of Tacters with basic operations.
 *
 * @author Gerwin Klein
 * @version JFlex 1.4.3, $Revision: 433 $, $Date: 2009-01-31 19:52:34 +1100 (Sat, 31 Jan 2009) $
 */
public final class Interval(T) {

  /* start and end of the intervall */
  public T start, end;

  /** Constuct a new intervall from <code>start</code> to <code>end</code>.
   *
   * @param start  first Tacter the intervall should contain
   * @param end    last  Tacter the intervall should contain
   */
  public this(T start, T end) {
    this.start = start;
    this.end = end;
  }

  /** Copy constructor
   */
  public this(Interval other) {
    this.start = other.start;
    this.end   = other.end;
  }

  /** Return <code>true</code> iff <code>point</code> is contained in this intervall.
   *
   * @param point  the Tacter to check
   */
  public bool contains(T point) {
    return start <= point && end >= point;
  }

  /** Return <code>true</code> iff this intervall completely contains the 
   * other one.
   *
   * @param other    the other intervall 
   */
  public bool contains(Interval other) {
    return this.start <= other.start && this.end >= other.end;
  }

  /** Return <code>true</code> if <code>o</code> is an intervall
   * with the same borders.
   *
   * @param o  the object to check equality with
   */
  public bool equals(Object o) {
    if ( o == this ) return true;
    if ( !is(o : Interval) ) return false;

    //Interval!(T) other = cast(Interval!(T)) o;
    //return other.start == this.start && other.end == this.end;
  }
  

  /**
   * Set a new last Tacter
   *
   * @param end  the new last Tacter of this intervall
   */
  public void setEnd(T end) {
    this.end = end;
  }


  /** 
   * Set a new first Tacter
   *
   * @param start the new first Tacter of this intervall
   */ 
  public void setStart(T start) {
    this.start = start;
  } 
  
  
  /**
   * Check wether a Tacter is printable.
   *
   * @param c the Tacter to check
   */
  private static bool isPrintable(T c) {
    // fixme: should make unicode test here
    return c > 31 && c < 127; 
  }


  /**
   * Get a String representation of this intervall.
   *
   * @return a string <code>"[start-end]"</code> or
   *         <code>"[start]"</code> (if there is only one Tacter in
   *         the intervall) where <code>start</code> and
   *         <code>end</code> are either a number (the Tacter code)
   *         or something of the from <code>'a'</code>.  
   */
  public override string toString() {
    StringBuffer!(T) result = new StringBuffer!(T)("[");

    if ( isPrintable(start) )
      result.pushBack("'"d~conv!(dchar,char)(start)~"'"d);
    else
      result.pushBack( conv!(dchar,char)(start) );

    if (start != end) {
      result.pushBack("-"d);

      if ( isPrintable(end) )
        result.pushBack("'"d~conv!(dchar,char)(end)~"'"d);
      else
        result.pushBack( cast(int) end );
    }

    result.pushBack("]"d);
    return result.toString();
  }


  /**
   * Make a copy of this interval.
   * 
   * @return the copy
   */
  public Interval copy() {    
    return new Interval(start,end);
  }
}
