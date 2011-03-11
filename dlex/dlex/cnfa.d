module cnfa;

import dlex.caccept;
import dlex.cset;
import dlex.sparsebitset;

class CNfa {
	/********************************************************
	 * Member Variables
	 *******************************************************/
	int m_edge; /*
				 * Label for edge type: character code, CCL (character class),
				 * [STATE, SCL (state class),] EMPTY, EPSILON.
				 */

	CSet m_set; /* Set to store character classes. */
	CNfa m_next; /* Next state (or null if none). */

	CNfa m_next2; /*
				 * Another state with type == EPSILON and null if not used. The
				 * NFA construction should result in two outgoing edges only if
				 * both are EPSILON edges.
				 */

	CAccept m_accept; /* Set to null if nonaccepting state. */
	int m_anchor; /* Says if and where pattern is anchored. */

	int m_label;

	SparseBitSet m_states;

	/********************************************************
	 * Constants
	 *******************************************************/
	static immutable NO_LABEL = -1;

	/********************************************************
	 * Constants: Edge Types Note: Edge transitions on one specific character
	 * are labelled with the character Ascii (Unicode) codes. So none of the
	 * constants below should overlap with the natural character codes.
	 *******************************************************/
	static immutable CCL = -1;
	static immutable EMPTY = -2;
	static immutable EPSILON = -3;

	/********************************************************
	 * Function: CNfa
	 *******************************************************/
	this() {
		m_edge = EMPTY;
		m_set = null;
		m_next = null;
		m_next2 = null;
		m_accept = null;
		m_anchor = CSpec.NONE;
		m_label = NO_LABEL;
		m_states = null;
	}

	/********************************************************
	 * Function: mimic Description: Converts this NFA state into a copy of the
	 * input one.
	 *******************************************************/
	void mimic(CNfa nfa) {
		m_edge = nfa.m_edge;

		if (nfa.m_set !is null) {
			if (m_set is null) {
				m_set = new CSet();
			}
			m_set.mimic(nfa.m_set);
		} else {
			m_set = null;
		}

		m_next = nfa.m_next;
		m_next2 = nfa.m_next2;
		m_accept = nfa.m_accept;
		m_anchor = nfa.m_anchor;

		if(nfa.m_states is null ) {
			m_states = nfa.m_states.clone();
		} else {
			m_states = null;
		}
	}
}
