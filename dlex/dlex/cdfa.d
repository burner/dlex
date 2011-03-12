module dlex.cdfa;

import dlex.caccept;
import dlex.cnfa;
import dlex.cspec;
import dlex.sparsebitset;

import hurt.container.vector;

class CDfa {
	/***************************************************************
		Member Variables
	***********************************************************/
	int m_group;
	bool m_mark;
	CAccept m_accept;
	int m_anchor;
	Vector!(CNfa) m_nfa_set;
	SparseBitSet m_nfa_bit;
	int m_label;

	/***************************************************************
		Function: CDfa
	**************************************************************/
	this(int label) {
		m_group = 0;
		m_mark = false;

		m_accept = null;
		m_anchor = CSpec.NONE;

		m_nfa_set = null;
		m_nfa_bit = null;

		m_label = label;
	}
}
