module dlex.cset;

import dlex.sparsebitset;
import dlex.enumeration;

import hurt.conv.conv;
import hurt.string.stringutil;

class CSet {
	/********************************************************
	 * Member Variables
	 *******************************************************/
	private SparseBitSet m_set;
	private bool m_complement;

	/********************************************************
	 * Function: CSet
	 *******************************************************/
	this() {
		m_set = new SparseBitSet();
		m_complement = false;
	}

	/********************************************************
	 * Function: complement
	 *******************************************************/
	void complement() {
		m_complement = true;
	}

	/********************************************************
	 * Function: add
	 *******************************************************/
	void add(int i) {
		m_set.set(i);
	}

	/********************************************************
	 * Function: addncase
	 *******************************************************/
 	// add, ignoring case.
	void addncase(char c) {
		/* Do this in a Unicode-friendly way. */
		/* (note that duplicate adds have no effect) */
		add(conv!(char,int)(c));
		add(conv!(char,int)(toLowerCase!(char)(c)));
		add(conv!(char,int)(toTitleCase!(char)(c)));
		add(conv!(char,int)(toUpperCase!(char)(c)));
	}

	/********************************************************
	 * Function: contains
	 *******************************************************/
	bool contains(int i) {
		bool result;

		result = m_set.get(i);

		if(m_complement) {
			return (false == result);
		}

		return result;
	}

	/********************************************************
	 * Function: mimic
	 *******************************************************/
	void mimic(CSet set) {
		m_complement = set.m_complement;
		m_set = set.m_set.clone();
	}

	/** Map set using character classes [CSA] */
	void map(CSet set, int[] mapping) {
		m_complement = set.m_complement;
		m_set.clearAll();
		for(Enumeration!(long) e = set.m_set.elements(); e.hasMoreElements();) {
			//int old_value = ((Integer) e.nextElement()).intValue();
			int old_value = conv!(long,int)(e.nextElement());
			if(old_value < mapping.length) // skip unmapped characters
				m_set.set(mapping[old_value]);
		}
	}
}
