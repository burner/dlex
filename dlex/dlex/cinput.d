module cinput;

import std.stream;

class CInput {
	/***************************************************************
		Member Variables
	**************************************************************/
	private std.stream.InputStream m_input; /* JLex specification file. */

	bool m_eof_reached; /* Whether EOF has been encountered. */
	bool m_pushback_line; 

	char m_line[]; /* Line buffer. */
	int m_line_read; /* Number of bytes read into line buffer. */
	int m_line_index; /* Current index into line buffer. */

	int m_line_number; /* Current line number. */

	/***************************************************************
		Constants
	**************************************************************/
	static immutable bool EOF = true;
	static immutable bool NOT_EOF = false;
	
	/***************************************************************
		Function: CInput
		Description: 
	**************************************************************/
	this(std.stream.InputStream input) {
		if(CUtility.DEBUG) {
			assert(null !is input);
		}

		/* Initialize input stream. TODO */
		//m_input = new java.io.BufferedReader(input);
		m_input = input;

		/* Initialize buffers and index counters. */
		m_line = null;
		m_line_read = 0;
		m_line_index = 0;

		/* Initialize state variables. */
		m_eof_reached = false;
		m_line_number = 0;
		m_pushback_line = false;
	}

	/***************************************************************
		Function: getLine
		Description: Returns true on EOF, false otherwise.
		Guarantees not to return a blank line, or a line
		of zero length.
	**************************************************************/
	bool getLine() {
		string lineStr;
		int elem;
		
		/* Has EOF already been reached? */
		if (m_eof_reached) {
			return EOF;
		}
		
		/* Pushback current line? */
		if (m_pushback_line) {
			m_pushback_line = false;

			/* Check for empty line. */
			for (elem = 0; elem < m_line_read; ++elem) {
				if (false == CUtility.isspace(m_line[elem])) {
					break;
				}
			}

			/* Nonempty? */
			if (elem < m_line_read) {
				m_line_index = 0;
				return NOT_EOF;
			}
		}

		while(true) {
			if (null == (lineStr = m_input.readLine())) {
				m_eof_reached = true;
				m_line_index = 0;
				return EOF;
			}
			m_line = (lineStr + "\n").toCharArray();
			m_line_read=m_line.length;
			++m_line_number;
			
			/* Check for empty lines and discard them. */
			elem = 0;
			while (CUtility.isspace(m_line[elem])) {
				++elem;
				if (elem == m_line_read) {
					break;
				}
			}
				
			if (elem < m_line_read) {
				break;
			}
		}

		m_line_index = 0;
		return NOT_EOF;
	}
}
