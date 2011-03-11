module dlex.cdtrans;

import dlex.caccept;
import dlex.cspec;

class CDTrans {
	/*************************************************************
		Member Variables
	***********************************************************/
	int m_dtrans[];
	CAccept m_accept;
	int m_anchor;
	int m_label;

	/*************************************************************
		Constants
	***********************************************************/
	static immutable int F = -1;

	/*************************************************************
		Function: CTrans
	***********************************************************/
	this(int label, CSpec spec) {
		m_dtrans = new int[spec.m_dtrans_ncols];
		m_accept = null;
		m_anchor = CSpec.NONE;
		m_label = label;
	}
}
