module cnfapair;

import dlex.cnfa;

class CNfaPair {
	/***************************************************************
		Member Variables
	**************************************************************/
	CNfa m_start;
	CNfa m_end;
	
	/***************************************************************
		Function: CNfaPair
	**************************************************************/
	this() {
		m_start = null;
		m_end = null;
	}
}
