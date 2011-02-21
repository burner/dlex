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

module dflex.lexicalstates;

import hurt.container.vector;

/** Simple symbol table, mapping lexical state names to integers. 
 *
 * @author Gerwin Klein
 * @version JFlex 1.4.3, $Revision: 433 $, $Date: 2009-01-31 19:52:34 +1100 (Sat, 31 Jan 2009) $
 */
public class LexicalStates {
  
  /** maps state name to state number */
  int[string] states; 

  /** codes of inclusive states (subset of states) */
  Vector!(int) inclusive;

  /** number of declared states */
  int numStates;

  /** constructs a new lexical state symbol table
   */
  public this() {
    states = new int[string];
    inclusive = new Vector!(int)();
  }
  
  /** insert a new state declaration
   */
  public void insert(string name, bool is_inclusive) {
    if ( states.containsKey(name) ) 
		return;

    numStates++;
    states[name] = code;

    if (is_inclusive) 
      inclusive.append(code);
  }


  /**
   * returns the number (code) of a declared state, 
   * <code>null</code> if no such state has been declared.
   */
  public int getNumber(string name) {
    return states[name];
  }

  
  /**
   * returns the number of declared states
   */
  public int number() {
    return numStates;
  }

  
  /**
   * returns the names of all states
   */
  public string[] names() {
    return states.keys;
  }

  /**
   * returns the code of all inclusive states
   */
  public int[] getInclusiveStates() {
    return inclusive.elements();
  }
}
