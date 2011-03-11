module dlex.caccept;

class CAccept {
	/***************************************************************
		Member Variables
	**************************************************************/
	char m_action[];
	int m_action_read;
	int m_line_number;

	/***************************************************************
		Function: CAccept
	**************************************************************/
	this(char action[], int action_read, int line_number) {
		int elem;

		m_action_read = action_read;

		m_action = new char[m_action_read];
		for(elem = 0; elem < m_action_read; ++elem) {
			m_action[elem] = action[elem];
		}

		m_line_number = line_number;
	}

	/***************************************************************
		Function: CAccept
	**************************************************************/
	this(CAccept accept) {
		int elem;

		m_action_read = accept.m_action_read;
		
		m_action = new char[m_action_read];
		for(elem = 0; elem < m_action_read; ++elem) {
			m_action[elem] = accept.m_action[elem];
		}

		m_line_number = accept.m_line_number;
	}

	/***************************************************************
		Function: mimic
	**************************************************************/
	void mimic(CAccept accept) {
		int elem;

		m_action_read = accept.m_action_read;
		
		m_action = new char[m_action_read];
		for(elem = 0; elem < m_action_read; ++elem) {
			m_action[elem] = accept.m_action[elem];
		}
	}
}
