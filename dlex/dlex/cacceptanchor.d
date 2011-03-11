module dlex.cacceptanchor;

import dlex.caccept;
import dlex.cspec;

class CAcceptAnchor {
	/***************************************************************
		Member Variables
	**************************************************************/
	CAccept m_accept;
	int m_anchor;

	/***************************************************************
		Function: CAcceptAnchor
	**************************************************************/
	this() {
		m_accept = null;
		m_anchor = CSpec.NONE;
	}
}
