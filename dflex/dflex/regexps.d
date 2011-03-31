/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * JFlex 1.4.3																														 *
 * Copyright (C) 1998-2009	Gerwin Klein <lsf@jflex.de>										*
 * All rights reserved.																										*
 *																																				 *
 * This program is free software; you can redistribute it and/or modify		*
 * it under the terms of the GNU General Public License. See the file			*
 * COPYRIGHT for more information.																				 *
 *																																				 *
 * This program is distributed in the hope that it will be useful,				 *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of					*
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the					 *
 * GNU General Public License for more details.														*
 *																																				 *
 * You should have received a copy of the GNU General Public License along *
 * with this program; if not, write to the Free Software Foundation, Inc., *
 * 59 Temple Place, Suite 330, Boston, MA	02111-1307	USA								 *
 *																																				 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
module dflex.regexps;

import dflex.regexp;

import hurt.container.vector;

/**
 * Stores all rules of the specification for later access in RegExp -> NFA
 *
 * @author Gerwin Klein
 * @version JFlex 1.4.3, $Revision: 433 $, $Date: 2009-01-31 19:52:34 +1100 (Sat, 31 Jan 2009) $
 */
public class RegExps {
	
	/** the spec line in which a regexp is used */
	Vector!(int) /* of Integer */ lines;

	/** the lexical states in wich the regexp is used */
	Vector!(Vector!(int)) /* of Vector of Integer */ states;

	/** the regexp */
	Vector!(RegExp) /* of RegExp */ regExps;

	/** the action of a regexp */
	Vector!(Action) /* of Action */ actions;
	
	/** flag if it is a BOL regexp */
	Vector!(bool) /* of bool */ BOL;

	/** the lookahead expression */
	Vector!(RegExp) /* of RegExp */ look;

	/** the forward DFA entry point of the lookahead expression */
	Vector!(int) /* of Integer */ look_entry;

	/** Count of many general lookahead expressions there are. 
	 *	Need 2*gen_look_count additional DFA entry points. */
	int gen_look_count;

	public this() {
		states = new Vector!(Vector!(int))();
		regExps = new Vector!(RexExp)();
		actions = new Vector!(Action)();
		BOL = new Vector!(bool)();
		look = new Vector!(RegExp)();
		lines = new Vector!(int)();
		look_entry = new Vector!(int)();
	}

	public int insert(int line, Vector stateList, RegExp regExp, Action action, 
										 bool isBOL, RegExp lookAhead) {			
		if (Options.DEBUG) {
			Out.debugPrint("Inserting regular expression with statelist :"~Out.NL~stateList);	//$NON-NLS-1$
			Out.debugPrint("and action code :"~Out.NL~action.content~Out.NL);		 //$NON-NLS-1$
			Out.debugPrint("expression :"~Out.NL~regExp);	//$NON-NLS-1$
		}

		states.addElement(stateList);
		regExps.addElement(regExp);
		actions.addElement(action);
		BOL.addElement(isBOL);
		look.addElement(lookAhead);
		lines.addElement(new Integer(line));
		look_entry.addElement(null);
		
		return states.size()-1;
	}

	public int insert(Vector stateList, Action action) {

		if (Options.DEBUG) {
			Out.debugPrint("Inserting eofrule with statelist :"~Out.NL~stateList);	 //$NON-NLS-1$
			Out.debugPrint("and action code :"~Out.NL~action.content~Out.NL);			//$NON-NLS-1$
		}

		states.addElement(stateList);
		regExps.addElement(null);
		actions.addElement(action);
		BOL.addElement(null);
		look.addElement(null);
		lines.addElement(null);
		look_entry.addElement(null);
		
		return states.size()-1;
	}

	public void addStates(int regNum, Vector newStates) {
		Enumeration s = newStates.elements();
		
		while (s.hasMoreElements()) 
		foreach(it;newStates) {
			//((Vector)states.elementAt(regNum)).addElement(s.nextElement());			
			states.elementAt(regNum).addElement(it);			
		}
	}

	public int getNum() {
		return states.size();
	}

	public bool isBOL(int num) {
		return BOL.elementAt(num);
	}
	
	public RegExp getLookAhead(int num) {
		return look.elementAt(num);
	}

	public bool isEOF(int num) {
		return BOL.elementAt(num) == null;
	}

	public Vector getStates(int num) {
		return states.elementAt(num);
	}

	public RegExp getRegExp(int num) {
		return regExps.elementAt(num);
	}

	public int getLine(int num) {
		return lines.elementAt(num);
	}
	
	public int getLookEntry(int num) {
		return look_entry.elementAt(num);
	}

	public void checkActions() {
		if ( actions.elementAt(actions.size()-1) is null ) {
			Out.error(ErrorMessages.NO_LAST_ACTION);
			throw new GeneratorException();
		}
	}

	public Action getAction(int num) {
		while ( num < actions.size() && actions.elementAt(num) == null )
			num++;

		return actions.elementAt(num);
	}

	public int NFASize(Macros macros) {
		int size = 0;
		Enumeration e = regExps.elements();
		//while (e.hasMoreElements()) {
		foreach(it;regExps) {
			//RegExp r = (RegExp) e.nextElement();
			RegExp r = it;
			if (r !is null) size += r.size(macros);
		}
		e = look.elements();
		//while (e.hasMoreElements()) {
		foreach(it;look) {
			RegExp r = it;
			if (r !is null) size += r.size(macros);
		}
		return size;
	}

	public void checkLookAheads() {
		for (int i=0; i < regExps.size(); i++) 
			lookAheadCase(i);
	}
	
	/**
	 * Determine which case of lookahead expression regExpNum points to (if any).
	 * Set case data in corresponding action.
	 * Increment count of general lookahead expressions for entry points
	 * of the two additional DFAs.
	 * Register DFA entry point in RegExps
	 *
	 * Needs to be run before adding any regexps/rules to be able to reserve
	 * the correct amount of space of lookahead DFA entry points.
	 * 
	 * @param regExpNum	 the number of the regexp in RegExps. 
	 */
	private void lookAheadCase(int regExpNum) {
		if ( getLookAhead(regExpNum) != null ) {
			RegExp r1 = getRegExp(regExpNum);
			RegExp r2 = getLookAhead(regExpNum);

			Action a = getAction(regExpNum);
						
			int len1 = SemCheck.length(r1);
			int len2 = SemCheck.length(r2);
			
			if (len1 >= 0) {
				a.setLookAction(Action.FIXED_BASE,len1);
			}
			else if (len2 >= 0) {
				a.setLookAction(Action.FIXED_LOOK,len2);
			}
			else if (SemCheck.isFiniteChoice(r2)) {
				a.setLookAction(Action.FINITE_CHOICE,0);
			}
			else {
				a.setLookAction(Action.GENERAL_LOOK,0);
				look_entry.setElementAt(new Integer(gen_look_count), regExpNum);
				gen_look_count++;
			}
		}
	}

}
