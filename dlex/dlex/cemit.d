module dlex.cemit;

import dlex.cspec;

import std.stream;

class CEmit {
	/***************************************************************
	  Member Variables
	 **************************************************************/
	private CSpec m_spec;
	//private java.io.PrintWriter m_outstream;
	private std.stream.OutputStream m_outstream;

	/***************************************************************
		Constants: Anchor Types
	 **************************************************************/
	private immutable int START = 1;
	private immutable int END = 2;
	private immutable int NONE = 4;

	/***************************************************************
	  Constants
	 **************************************************************/
	private immutable bool EDBG = true;
	private immutable bool NOT_EDBG = false;

	/***************************************************************
		Function: CEmit
		Description: Constructor.
	 **************************************************************/
	this() {
		reset();
	}

	/***************************************************************
		Function: reset
		Description: Clears member variables.
	 **************************************************************/
	private void reset() {
		m_spec = null;
		m_outstream = null;
	}

	/***************************************************************
		Function: set
		Description: Initializes member variables.
	 **************************************************************/
	//private void set(CSpec spec, java.io.PrintWriter outstream) {
	private void set(CSpec spec, std.stream.OutputStream outstream) {
		if (CUtility.DEBUG) {
			assert(null != spec);
			assert(null != outstream);
		}

		m_spec = spec;
		m_outstream = outstream;
	}

	/***************************************************************
		Function: emit_imports
		Description: Emits import packages at top of 
		generated source file.
	 **************************************************************/
	/*void emit_imports
	  (
	  CSpec spec,
	  OutputStream outstream
	  )
	  throws java.io.IOException			
	  {
	  set(spec,outstream);

	  if (CUtility.DEBUG)
	  {
	  assert(null != m_spec);
	  assert(null != m_outstream);
	  }*/

	/*m_outstream.println("import java.lang.String;");
	  m_outstream.println("import java.lang.System;");
	  m_outstream.println("import java.io.BufferedReader;");
	  m_outstream.println("import java.io.InputStream;");*/
	/*	
		reset();
		}*/

	/***************************************************************
		Function: print_details
		Description: Debugging output.
	 **************************************************************/
	private void print_details() {
		int i;
		int j;
		int next;
		int state;
		CDTrans dtrans;
		CAccept accept;
		bool tr;

		writeln("---------------------- Transition Table " 
				+ "----------------------");

		for (i = 0; i < m_spec.m_row_map.length; ++i)
		{
			write("State " + i);

			accept = m_spec.m_accept_vector.elementAt(i);
			if (null == accept)
			{
				writeln(" [nonaccepting]");
			}
			else
			{
				writeln(" [accepting, line "
						+ accept.m_line_number 
						+ " <"
						+ (new java.lang.String(accept.m_action,0,
								accept.m_action_read))
						+ ">]");
			}
			dtrans = m_spec.m_dtrans_vector.elementAt(m_spec.m_row_map[i]);

			tr = false;
			state = dtrans.m_dtrans[m_spec.m_col_map[0]];
			if (CDTrans.F != state)
			{
				tr = true;
				write("\tgoto " + state + " on [" + (conv!(int,char)(0)));
			}
			for (j = 1; j < m_spec.m_dtrans_ncols; ++j)
			{
				next = dtrans.m_dtrans[m_spec.m_col_map[j]];
				if (state == next)
				{
					if (CDTrans.F != state)
					{
						write(conv!(int,char)(j));
					}
				}
				else
				{
					state = next;
					if (tr)
					{
						writeln("]");
						tr = false;
					}
					if (CDTrans.F != state)
					{
						tr = true;
						write("\tgoto " + state + " on [" + (conv!(int,char)(j)));
					}
				}
			}
			if (tr)
			{
				writeln("]");
			}
		}

		writeln("---------------------- Transition Table " 
				+ "----------------------");
	}

	/***************************************************************
		Function: emit
		Description: High-level access function to module.
	 **************************************************************/
	//void emit(CSpec spec, java.io.PrintWriter outstream) {
	void emit(CSpec spec, std.stream.OutputStream outstream) {
		set(spec,outstream);

		if(CUtility.DEBUG) {
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		if(CUtility.OLD_DEBUG) {
			print_details();
		}

		emit_header();
		emit_construct();
		emit_helpers();
		emit_driver();
		emit_footer();

		reset();
	}

	/***************************************************************
		Function: emit_construct
		Description: Emits constructor, member variables,
		and constants.
	 **************************************************************/
	private void emit_construct() {
		if (CUtility.DEBUG) {
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		/* Constants */
		m_outstream.println("\tprivate final int YY_BUFFER_SIZE = 512;");

		m_outstream.println("\tprivate final int YY_F = -1;");
		m_outstream.println("\tprivate final int YY_NO_STATE = -1;");

		m_outstream.println("\tprivate final int YY_NOT_ACCEPT = 0;");
		m_outstream.println("\tprivate final int YY_START = 1;");
		m_outstream.println("\tprivate final int YY_END = 2;");
		m_outstream.println("\tprivate final int YY_NO_ANCHOR = 4;");

		// internal
		m_outstream.println("\tprivate final int YY_BOL = "+m_spec.BOL+";");
		m_outstream.println("\tprivate final int YY_EOF = "+m_spec.EOF+";");
		// external
		if (m_spec.m_integer_type || true == m_spec.m_yyeof)
			m_outstream.println("\tpublic final int YYEOF = -1;");

		/* User specified class code. */
		if (null != m_spec.m_class_code)
		{
			m_outstream.print(new String(m_spec.m_class_code,0,
						m_spec.m_class_read));
		}

		/* Member Variables */
		m_outstream.println("\tprivate java.io.BufferedReader yy_reader;");
		m_outstream.println("\tprivate int yy_buffer_index;");
		m_outstream.println("\tprivate int yy_buffer_read;");
		m_outstream.println("\tprivate int yy_buffer_start;");
		m_outstream.println("\tprivate int yy_buffer_end;");
		m_outstream.println("\tprivate char yy_buffer[];");
		if (m_spec.m_count_chars)
		{
			m_outstream.println("\tprivate int yychar;");
		}
		if (m_spec.m_count_lines)
		{
			m_outstream.println("\tprivate int yyline;");
		}
		m_outstream.println("\tprivate bool yy_at_bol;");
		m_outstream.println("\tprivate int yy_lexical_state;");
		/*if (m_spec.m_count_lines || true == m_spec.m_count_chars)
		  {
		  m_outstream.println("\tprivate int yy_buffer_prev_start;");
		  }*/
		m_outstream.println();


		/* Function: first constructor (Reader) */
		m_outstream.print("\t");
		if (true == m_spec.m_public) {
			m_outstream.print("public ");
		}
		m_outstream.print(new String(m_spec.m_class_name));
		m_outstream.print(" (java.io.Reader reader)");

		if (null != m_spec.m_init_throw_code)
		{
			m_outstream.println(); 
			m_outstream.print("\t\tthrows "); 
			m_outstream.print(new String(m_spec.m_init_throw_code,0,
						m_spec.m_init_throw_read));
			m_outstream.println();
			m_outstream.println("\t\t{");
		}
		else
		{
			m_outstream.println(" {");
		}

		m_outstream.println("\t\tthis ();");		
		m_outstream.println("\t\tif (null == reader) {");
		m_outstream.println("\t\t\tthrow (new Error(\"Error: Bad input "
				+ "stream initializer.\"));");
		m_outstream.println("\t\t}");
		m_outstream.println("\t\tyy_reader = new java.io.BufferedReader(reader);");
		m_outstream.println("\t}");
		m_outstream.println();


		/* Function: second constructor (InputStream) */
		m_outstream.print("\t");
		if (true == m_spec.m_public) {
			m_outstream.print("public ");
		}
		m_outstream.print(new String(m_spec.m_class_name));
		m_outstream.print(" (java.io.InputStream instream)");

		if (null != m_spec.m_init_throw_code)
		{
			m_outstream.println(); 
			m_outstream.print("\t\tthrows "); 
			m_outstream.println(new String(m_spec.m_init_throw_code,0,
						m_spec.m_init_throw_read));
			m_outstream.println("\t\t{");
		}
		else
		{
			m_outstream.println(" {");
		}

		m_outstream.println("\t\tthis ();");		
		m_outstream.println("\t\tif (null == instream) {");
		m_outstream.println("\t\t\tthrow (new Error(\"Error: Bad input "
				+ "stream initializer.\"));");
		m_outstream.println("\t\t}");
		m_outstream.println("\t\tyy_reader = new java.io.BufferedReader(new java.io.InputStreamReader(instream));");
		m_outstream.println("\t}");
		m_outstream.println();


		/* Function: third, private constructor - only for internal use */
		m_outstream.print("\tprivate ");
		m_outstream.print(new String(m_spec.m_class_name));
		m_outstream.print(" ()");

		if (null != m_spec.m_init_throw_code)
		{
			m_outstream.println(); 
			m_outstream.print("\t\tthrows "); 
			m_outstream.println(new String(m_spec.m_init_throw_code,0,
						m_spec.m_init_throw_read));
			m_outstream.println("\t\t{");
		}
		else
		{
			m_outstream.println(" {");
		}

		m_outstream.println("\t\tyy_buffer = new char[YY_BUFFER_SIZE];");
		m_outstream.println("\t\tyy_buffer_read = 0;");
		m_outstream.println("\t\tyy_buffer_index = 0;");
		m_outstream.println("\t\tyy_buffer_start = 0;");
		m_outstream.println("\t\tyy_buffer_end = 0;");
		if (m_spec.m_count_chars)
		{
			m_outstream.println("\t\tyychar = 0;");
		}
		if (m_spec.m_count_lines)
		{
			m_outstream.println("\t\tyyline = 0;");
		}
		m_outstream.println("\t\tyy_at_bol = true;");
		m_outstream.println("\t\tyy_lexical_state = YYINITIAL;");
		/*if (m_spec.m_count_lines || true == m_spec.m_count_chars)
		  {
		  m_outstream.println("\t\tyy_buffer_prev_start = 0;");
		  }*/

		/* User specified constructor code. */
		if (null != m_spec.m_init_code)
		{
			m_outstream.print(new String(m_spec.m_init_code,0,
						m_spec.m_init_read));
		}

		m_outstream.println("\t}");
		m_outstream.println();

	}

	/***************************************************************
Function: emit_states
Description: Emits constants that serve as lexical states,
including YYINITIAL.
	 **************************************************************/
	private void emit_states() {
		Enumeration states;
		String state;
		int index;

		states = m_spec.m_states.keys();
		/*index = 0;*/
		while (states.hasMoreElements()) {
			state = states.nextElement();

			if (CUtility.DEBUG) {
				assert(null != state);
			}

			m_outstream.println("\tprivate final int " 
					+ state 
					+ " = " 
					+ (m_spec.m_states.get(state)).toString() 
					+ ";");
			/*++index;*/
		}

		m_outstream.println("\tprivate final int yy_state_dtrans[] = {");
		for (index = 0; index < m_spec.m_state_dtrans.length; ++index) {
			m_outstream.print("\t\t" + m_spec.m_state_dtrans[index]);
			if (index < m_spec.m_state_dtrans.length - 1) {
				m_outstream.println(",");
			} else {
				m_outstream.println();
			}
		}
		m_outstream.println("\t};");
	}

	/***************************************************************
Function: emit_helpers
Description: Emits helper functions, particularly 
error handling and input buffering.
	 **************************************************************/
	private void emit_helpers() {
		if (CUtility.DEBUG) {
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		/* Function: yy_do_eof */
		m_outstream.println("\tprivate bool yy_eof_done = false;");
		if (null != m_spec.m_eof_code) {
			m_outstream.print("\tprivate void yy_do_eof ()");

			if (null != m_spec.m_eof_throw_code) {
				m_outstream.println(); 
				m_outstream.print("\t\tthrows "); 
				m_outstream.println(new String(m_spec.m_eof_throw_code,0,
							m_spec.m_eof_throw_read));
				m_outstream.println("\t\t{");
			} else {
				m_outstream.println(" {");
			}

			m_outstream.println("\t\tif (false == yy_eof_done) {");
			m_outstream.print(new String(m_spec.m_eof_code,0,
						m_spec.m_eof_read));
			m_outstream.println("\t\t}");
			m_outstream.println("\t\tyy_eof_done = true;");
			m_outstream.println("\t}");
		}

		emit_states();

		/* Function: yybegin */
		m_outstream.println("\tprivate void yybegin (int state) {");
		m_outstream.println("\t\tyy_lexical_state = state;");
		m_outstream.println("\t}");

		/* Function: yy_initial_dtrans */
		/*m_outstream.println("\tprivate int yy_initial_dtrans (int state) {");
		  m_outstream.println("\t\treturn yy_state_dtrans[state];");
		  m_outstream.println("\t}");*/

		/* Function: yy_advance */
		m_outstream.println("\tprivate int yy_advance ()");
		m_outstream.println("\t\tthrows java.io.IOException {");
		/*m_outstream.println("\t\t{");*/
		m_outstream.println("\t\tint next_read;");
		m_outstream.println("\t\tint i;");
		m_outstream.println("\t\tint j;");
		m_outstream.println();

		m_outstream.println("\t\tif (yy_buffer_index < yy_buffer_read) {");
		m_outstream.println("\t\t\treturn yy_buffer[yy_buffer_index++];");
		/*m_outstream.println("\t\t\t++yy_buffer_index;");*/
		m_outstream.println("\t\t}");
		m_outstream.println();

		m_outstream.println("\t\tif (0 != yy_buffer_start) {");
		m_outstream.println("\t\t\ti = yy_buffer_start;");
		m_outstream.println("\t\t\tj = 0;");
		m_outstream.println("\t\t\twhile (i < yy_buffer_read) {");
		m_outstream.println("\t\t\t\tyy_buffer[j] = yy_buffer[i];");
		m_outstream.println("\t\t\t\t++i;");
		m_outstream.println("\t\t\t\t++j;");
		m_outstream.println("\t\t\t}");
		m_outstream.println("\t\t\tyy_buffer_end = yy_buffer_end - yy_buffer_start;");
		m_outstream.println("\t\t\tyy_buffer_start = 0;");
		m_outstream.println("\t\t\tyy_buffer_read = j;");
		m_outstream.println("\t\t\tyy_buffer_index = j;");
		m_outstream.println("\t\t\tnext_read = yy_reader.read(yy_buffer,");
		m_outstream.println("\t\t\t\t\tyy_buffer_read,");
		m_outstream.println("\t\t\t\t\tyy_buffer.length - yy_buffer_read);");
		m_outstream.println("\t\t\tif (-1 == next_read) {");
		m_outstream.println("\t\t\t\treturn YY_EOF;");
		m_outstream.println("\t\t\t}");
		m_outstream.println("\t\t\tyy_buffer_read = yy_buffer_read + next_read;");
		m_outstream.println("\t\t}");
		m_outstream.println();

		m_outstream.println("\t\twhile (yy_buffer_index >= yy_buffer_read) {");
		m_outstream.println("\t\t\tif (yy_buffer_index >= yy_buffer.length) {");
		m_outstream.println("\t\t\t\tyy_buffer = yy_double(yy_buffer);");
		m_outstream.println("\t\t\t}");
		m_outstream.println("\t\t\tnext_read = yy_reader.read(yy_buffer,");
		m_outstream.println("\t\t\t\t\tyy_buffer_read,");
		m_outstream.println("\t\t\t\t\tyy_buffer.length - yy_buffer_read);");
		m_outstream.println("\t\t\tif (-1 == next_read) {");
		m_outstream.println("\t\t\t\treturn YY_EOF;");
		m_outstream.println("\t\t\t}");
		m_outstream.println("\t\t\tyy_buffer_read = yy_buffer_read + next_read;");
		m_outstream.println("\t\t}");

		m_outstream.println("\t\treturn yy_buffer[yy_buffer_index++];");
		m_outstream.println("\t}");

		/* Function: yy_move_end */
		m_outstream.println("\tprivate void yy_move_end () {");
		m_outstream.println("\t\tif (yy_buffer_end > yy_buffer_start &&");
		m_outstream.println("\t\t		'\\n' == yy_buffer[yy_buffer_end-1])");
		m_outstream.println("\t\t\tyy_buffer_end--;");
		m_outstream.println("\t\tif (yy_buffer_end > yy_buffer_start &&");
		m_outstream.println("\t\t		'\\r' == yy_buffer[yy_buffer_end-1])");
		m_outstream.println("\t\t\tyy_buffer_end--;");
		m_outstream.println("\t}");

		/* Function: yy_mark_start */
		m_outstream.println("\tprivate bool yy_last_was_cr=false;");
		m_outstream.println("\tprivate void yy_mark_start () {");
		if (m_spec.m_count_lines || true == m_spec.m_count_chars) {
			if (m_spec.m_count_lines) {
				m_outstream.println("\t\tint i;");
				m_outstream.println("\t\tfor (i = yy_buffer_start; " 
						+ "i < yy_buffer_index; ++i) {");
				m_outstream.println("\t\t\tif ('\\n' == yy_buffer[i] && !yy_last_was_cr) {");
				m_outstream.println("\t\t\t\t++yyline;");
				m_outstream.println("\t\t\t}");
				m_outstream.println("\t\t\tif ('\\r' == yy_buffer[i]) {");
				m_outstream.println("\t\t\t\t++yyline;");
				m_outstream.println("\t\t\t\tyy_last_was_cr=true;");
				m_outstream.println("\t\t\t} else yy_last_was_cr=false;");
				m_outstream.println("\t\t}");
			}
			if (m_spec.m_count_chars) {
				m_outstream.println("\t\tyychar = yychar"); 
				m_outstream.println("\t\t\t+ yy_buffer_index - yy_buffer_start;");
			}
		}
		m_outstream.println("\t\tyy_buffer_start = yy_buffer_index;");
		m_outstream.println("\t}");

		/* Function: yy_mark_end */
		m_outstream.println("\tprivate void yy_mark_end () {");
		m_outstream.println("\t\tyy_buffer_end = yy_buffer_index;");
		m_outstream.println("\t}");

		/* Function: yy_to_mark */
		m_outstream.println("\tprivate void yy_to_mark () {");
		m_outstream.println("\t\tyy_buffer_index = yy_buffer_end;");
		m_outstream.println("\t\tyy_at_bol = "+
				"(yy_buffer_end > yy_buffer_start) &&");
		m_outstream.println("\t\t						"+
				"('\\r' == yy_buffer[yy_buffer_end-1] ||");
		m_outstream.println("\t\t						"+
				" '\\n' == yy_buffer[yy_buffer_end-1] ||");
		m_outstream.println("\t\t						"+ /* unicode LS */
				" 2028/*LS*/ == yy_buffer[yy_buffer_end-1] ||");
		m_outstream.println("\t\t						"+ /* unicode PS */
				" 2029/*PS*/ == yy_buffer[yy_buffer_end-1]);");
		m_outstream.println("\t}");

		/* Function: yytext */
		m_outstream.println("\tprivate java.lang.String yytext () {");
		m_outstream.println("\t\treturn (new java.lang.String(yy_buffer,");
		m_outstream.println("\t\t\tyy_buffer_start,");
		m_outstream.println("\t\t\tyy_buffer_end - yy_buffer_start));");
		m_outstream.println("\t}");

		/* Function: yylength */
		m_outstream.println("\tprivate int yylength () {");
		m_outstream.println("\t\treturn yy_buffer_end - yy_buffer_start;");
		m_outstream.println("\t}");

		/* Function: yy_double */
		m_outstream.println("\tprivate char[] yy_double (char buf[]) {");
		m_outstream.println("\t\tint i;");
		m_outstream.println("\t\tchar newbuf[];");
		m_outstream.println("\t\tnewbuf = new char[2*buf.length];");
		m_outstream.println("\t\tfor (i = 0; i < buf.length; ++i) {");
		m_outstream.println("\t\t\tnewbuf[i] = buf[i];");
		m_outstream.println("\t\t}");
		m_outstream.println("\t\treturn newbuf;");
		m_outstream.println("\t}");

		/* Function: yy_error */
		m_outstream.println("\tprivate final int YY_E_INTERNAL = 0;");
		m_outstream.println("\tprivate final int YY_E_MATCH = 1;");
		m_outstream.println("\tprivate java.lang.String yy_error_string[] = {");
		m_outstream.println("\t\t\"Error: Internal error.\\n\",");
		m_outstream.println("\t\t\"Error: Unmatched input.\\n\"");
		m_outstream.println("\t};");
		m_outstream.println("\tprivate void yy_error (int code,bool fatal) {");
		m_outstream.println("\t\tjava.lang.write(yy_error_string[code]);");
		m_outstream.println("\t\tjava.lang.System.out.flush();");
		m_outstream.println("\t\tif (fatal) {");
		m_outstream.println("\t\t\tthrow new Error(\"Fatal Error.\\n\");");
		m_outstream.println("\t\t}");
		m_outstream.println("\t}");

		/* Function: yy_next */
		/*m_outstream.println("\tprivate int yy_next (int current,char lookahead) {");
		  m_outstream.println("\t\treturn yy_nxt[yy_rmap[current]][yy_cmap[lookahead]];");
		  m_outstream.println("\t}");*/

		/* Function: yy_accept */
		/*m_outstream.println("\tprivate int yy_accept (int current) {");
		  m_outstream.println("\t\treturn yy_acpt[current];");
		  m_outstream.println("\t}");*/


		// Function: private int [][] unpackFromString(int size1, int size2, String st)
		// Added 6/24/98 Raimondas Lencevicius
		// May be made more efficient by replacing String operations
		// Assumes correctly formed input String. Performs no error checking
		m_outstream.println("\tprivate int[][] unpackFromString"+
				"(int size1, int size2, String st) {");
		m_outstream.println("\t\tint colonIndex = -1;");
		m_outstream.println("\t\tString lengthString;");
		m_outstream.println("\t\tint sequenceLength = 0;");
		m_outstream.println("\t\tint sequenceInteger = 0;");
		m_outstream.println();
		m_outstream.println("\t\tint commaIndex;");
		m_outstream.println("\t\tString workString;");
		m_outstream.println();
		m_outstream.println("\t\tint res[][] = new int[size1][size2];");
		m_outstream.println("\t\tfor (int i= 0; i < size1; i++) {");
		m_outstream.println("\t\t\tfor (int j= 0; j < size2; j++) {");
		m_outstream.println("\t\t\t\tif (sequenceLength != 0) {");
		m_outstream.println("\t\t\t\t\tres[i][j] = sequenceInteger;");
		m_outstream.println("\t\t\t\t\tsequenceLength--;");
		m_outstream.println("\t\t\t\t\tcontinue;");
		m_outstream.println("\t\t\t\t}");
		m_outstream.println("\t\t\t\tcommaIndex = st.indexOf(',');");
		m_outstream.println("\t\t\t\tworkString = (commaIndex==-1) ? st :");
		m_outstream.println("\t\t\t\t\tst.substring(0, commaIndex);");
		m_outstream.println("\t\t\t\tst = st.substring(commaIndex+1);");	
		m_outstream.println("\t\t\t\tcolonIndex = workString.indexOf(':');");
		m_outstream.println("\t\t\t\tif (colonIndex == -1) {");
		m_outstream.println("\t\t\t\t\tres[i][j]=Integer.parseInt(workString);");
		m_outstream.println("\t\t\t\t\tcontinue;");
		m_outstream.println("\t\t\t\t}");
		m_outstream.println("\t\t\t\tlengthString =");
		m_outstream.println("\t\t\t\t\tworkString.substring(colonIndex+1);");
		m_outstream.println("\t\t\t\tsequenceLength="+
				"Integer.parseInt(lengthString);");
		m_outstream.println("\t\t\t\tworkString="+
				"workString.substring(0,colonIndex);");
		m_outstream.println("\t\t\t\tsequenceInteger="+
				"Integer.parseInt(workString);");
		m_outstream.println("\t\t\t\tres[i][j] = sequenceInteger;");
		m_outstream.println("\t\t\t\tsequenceLength--;");
		m_outstream.println("\t\t\t}");
		m_outstream.println("\t\t}");
		m_outstream.println("\t\treturn res;");
		m_outstream.println("\t}");
	}

	/***************************************************************
Function: emit_header
Description: Emits class header.
	 **************************************************************/
	private void emit_header() {
		if (CUtility.DEBUG) {
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		m_outstream.println();
		m_outstream.println();
		if (true == m_spec.m_public) {
			m_outstream.print("public ");
		}
		m_outstream.print("class ");
		m_outstream.print(new String(m_spec.m_class_name,0,
					m_spec.m_class_name.length));
		if (m_spec.m_implements_name.length > 0) {
			m_outstream.print(" implements ");	
			m_outstream.print(new String(m_spec.m_implements_name,0,
						m_spec.m_implements_name.length));
		}		
		m_outstream.println(" {");
	}

	/***************************************************************
Function: emit_table
Description: Emits transition table.
	 **************************************************************/
	private void emit_table() {
		int i;
		int elem;
		int size;
		CDTrans dtrans;
		bool is_start;
		bool is_end;
		CAccept accept;

		if (CUtility.DEBUG)
		{
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		m_outstream.println("\tprivate int yy_acpt[] = {");
		size = m_spec.m_accept_vector.size();
		for (elem = 0; elem < size; ++elem) {
			accept = m_spec.m_accept_vector.elementAt(elem);

			m_outstream.print("\t\t/* "+elem+" */ ");
			if (null != accept) {
				is_start = (0 != (m_spec.m_anchor_array[elem] & CSpec.START));
				is_end = (0 != (m_spec.m_anchor_array[elem] & CSpec.END));

				if (is_start && true == is_end) {
					m_outstream.print("YY_START | YY_END");
				} else if (is_start) {
					m_outstream.print("YY_START");
				} else if (is_end) {
					m_outstream.print("YY_END");
				} else {
					m_outstream.print("YY_NO_ANCHOR");
				}
			} else {
				m_outstream.print("YY_NOT_ACCEPT");
			}

			if (elem < size - 1) {
				m_outstream.print(",");
			}

			m_outstream.println();
		}

		m_outstream.println("\t};");

		// CSA: modified yy_cmap to use string packing 9-Aug-1999
		int[] yy_cmap = new int[m_spec.m_ccls_map.length];
		for (i = 0; i < m_spec.m_ccls_map.length; ++i)
			yy_cmap[i] = m_spec.m_col_map[m_spec.m_ccls_map[i]];
		m_outstream.print("\tprivate int yy_cmap[] = unpackFromString(");
		int[][] tmp = new int[yy_cmap.length][];
		tmp[0] = yy_cmap;
		//emit_table_as_string(new int[][] { yy_cmap });
		emit_table_as_string(tmp);
		m_outstream.println(")[0];");
		m_outstream.println();

		// CSA: modified yy_rmap to use string packing 9-Aug-1999
		m_outstream.print("\tprivate int yy_rmap[] = unpackFromString(");
		tmp = new int[m_spec.m_row_map][];
		tmp[0] = m_spec.m_row_map;
		//emit_table_as_string(new int[][] { m_spec.m_row_map });
		emit_table_as_string(tmp);
		m_outstream.println(")[0];");
		m_outstream.println();

		// 6/24/98 Raimondas Lencevicius
		// modified to use
		//		int[][] unpackFromString(int size1, int size2, String st)
		size = m_spec.m_dtrans_vector.size();
		int[][] yy_nxt = new int[size][];
		for (elem=0; elem<size; elem++) {
			dtrans = m_spec.m_dtrans_vector.elementAt(elem);
			assert(dtrans.m_dtrans.length==m_spec.m_dtrans_ncols);
			yy_nxt[elem] = dtrans.m_dtrans;
		}
		m_outstream.print ("\tprivate int yy_nxt[][] = unpackFromString(");
		emit_table_as_string(yy_nxt);
		m_outstream.println(");");
		m_outstream.println();
	}

	/***************************************************************
Function: emit_driver
Description: Output an integer table as a string.	Written by
Raimondas Lencevicius 6/24/98; reorganized by CSA 9-Aug-1999.
From his original comments:
yy_nxt[][] values are coded into a string
by printing integers and representing
integer sequences as "value:length" pairs.
	 **************************************************************/
	private void emit_table_as_string(int[][] ia) {
		int sequenceLength = 0; // RL - length of the number sequence
		bool sequenceStarted = false; // RL - has number sequence started?
		int previousInt = -20; // RL - Bogus -20 state.

		// RL - Output matrix size
		m_outstream.print(ia.length);
		m_outstream.print(",");
		m_outstream.print(ia.length>0?ia[0].length:0);
		m_outstream.println(",");

		StringBuffer outstr = new StringBuffer();

		//	RL - Output matrix 
		for (int elem = 0; elem < ia.length; ++elem) {
			for (int i = 0; i < ia[elem].length; ++i) {
				int writeInt = ia[elem][i];
				// RL - sequence?
				if (writeInt == previousInt) {
					if (sequenceStarted) {
						sequenceLength++;
					} else {
						outstr.append(writeInt);
						outstr.append(":");
						sequenceLength = 2;
						sequenceStarted = true;
					}
					// RL - no sequence or end sequence
				} else {
					if (sequenceStarted) {
						outstr.append(sequenceLength);
						outstr.append(",");
						sequenceLength = 0;
						sequenceStarted = false;
					} else {
						if (previousInt != -20) {
							outstr.append(previousInt);
							outstr.append(",");
						}
					}
				}
				previousInt = writeInt;
				// CSA: output in 75 character chunks.
				if (outstr.length() > 75) {
					String s = outstr.toString();
					m_outstream.println("\""+s.substring(0,75)+"\" +");
					outstr = new StringBuffer(s.substring(75));
				}
			}
		}

		if (sequenceStarted) {
			outstr.append(sequenceLength);
		} else {
			outstr.append(previousInt);
		}		
		// CSA: output in 75 character chunks.
		if (outstr.length() > 75) {
			String s = outstr.toString();
			m_outstream.println("\""+s.substring(0,75)+"\" +");
			outstr = new StringBuffer(s.substring(75));
		}
		m_outstream.print("\""+outstr+"\"");
	}

	/***************************************************************
Function: emit_driver
Description: 
	 **************************************************************/
	private void emit_driver() {
		if (CUtility.DEBUG) {
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		emit_table();

		if (m_spec.m_integer_type) {
			m_outstream.print("\tpublic int ");
			m_outstream.print(new String(m_spec.m_function_name));
			m_outstream.println(" ()");
		} else if (m_spec.m_intwrap_type) {
			m_outstream.print("\tpublic java.lang.Integer ");
			m_outstream.print(new String(m_spec.m_function_name));
			m_outstream.println(" ()");
		} else {
			m_outstream.print("\tpublic ");
			m_outstream.print(new String(m_spec.m_type_name));
			m_outstream.print(" ");
			m_outstream.print(new String(m_spec.m_function_name));
			m_outstream.println(" ()");
		}

		/*m_outstream.println("\t\tthrows java.io.IOException {");*/
		m_outstream.print("\t\tthrows java.io.IOException");
		if (null != m_spec.m_yylex_throw_code) {
			m_outstream.print(", "); 
			m_outstream.print(new String(m_spec.m_yylex_throw_code,0,
						m_spec.m_yylex_throw_read));
			m_outstream.println();
			m_outstream.println("\t\t{");
		} else {
			m_outstream.println(" {");
		}

		m_outstream.println("\t\tint yy_lookahead;");
		m_outstream.println("\t\tint yy_anchor = YY_NO_ANCHOR;");
		/*m_outstream.println("\t\tint yy_state "
		  + "= yy_initial_dtrans(yy_lexical_state);");*/
		m_outstream.println("\t\tint yy_state " 
				+ "= yy_state_dtrans[yy_lexical_state];");
		m_outstream.println("\t\tint yy_next_state = YY_NO_STATE;");
		/*m_outstream.println("\t\tint yy_prev_stave = YY_NO_STATE;");*/
		m_outstream.println("\t\tint yy_last_accept_state = YY_NO_STATE;");
		m_outstream.println("\t\tbool yy_initial = true;");
		m_outstream.println("\t\tint yy_this_accept;");
		m_outstream.println();

		m_outstream.println("\t\tyy_mark_start();");
		/*m_outstream.println("\t\tyy_this_accept = yy_accept(yy_state);");*/
		m_outstream.println("\t\tyy_this_accept = yy_acpt[yy_state];");
		m_outstream.println("\t\tif (YY_NOT_ACCEPT != yy_this_accept) {");
		m_outstream.println("\t\t\tyy_last_accept_state = yy_state;");
		m_outstream.println("\t\t\tyy_mark_end();");
		m_outstream.println("\t\t}");

		if (NOT_EDBG) {
			m_outstream.println("\t\tjava.lang.writeln(\"Begin\");");
		}

		m_outstream.println("\t\twhile (true) {");

		m_outstream.println("\t\t\tif (yy_initial && yy_at_bol) "+
				"yy_lookahead = YY_BOL;");
		m_outstream.println("\t\t\telse yy_lookahead = yy_advance();");
		m_outstream.println("\t\t\tyy_next_state = YY_F;");
		/*m_outstream.println("\t\t\t\tyy_next_state = "
		  + "yy_next(yy_state,yy_lookahead);");*/
		m_outstream.println("\t\t\tyy_next_state = "
				+ "yy_nxt[yy_rmap[yy_state]][yy_cmap[yy_lookahead]];");

		if (NOT_EDBG) {
			m_outstream.println("java.lang.writeln(\"Current state: \"" 
					+ " + yy_state");
			m_outstream.println("+ \"\tCurrent input: \""); 
			m_outstream.println(" + ((char) yy_lookahead));");
		}
		if (NOT_EDBG) {
			m_outstream.println("\t\t\tjava.lang.writeln(\"State = \"" 
					+ "+ yy_state);");
			m_outstream.println("\t\t\tjava.lang.writeln(\"Accepting status = \"" 
					+ "+ yy_this_accept);");
			m_outstream.println("\t\t\tjava.lang.writeln(\"Last accepting state = \"" 
					+ "+ yy_last_accept_state);");
			m_outstream.println("\t\t\tjava.lang.writeln(\"Next state = \"" 
					+ "+ yy_next_state);");
			m_outstream.println("\t\t\tjava.lang.writeln(\"Lookahead input = \"" 
					+ "+ ((char) yy_lookahead));");
		}

		// handle bare EOF.
		m_outstream.println("\t\t\tif (YY_EOF == yy_lookahead " 
				+ "&& true == yy_initial) {");
		if (null != m_spec.m_eof_code) {
			m_outstream.println("\t\t\t\tyy_do_eof();");
		}
		if (true == m_spec.m_integer_type) {
			m_outstream.println("\t\t\t\treturn YYEOF;");
		} else if (null != m_spec.m_eof_value_code) {
			m_outstream.print(new String(m_spec.m_eof_value_code,0,
						m_spec.m_eof_value_read));
		} else {
			m_outstream.println("\t\t\t\treturn null;");
		}
		m_outstream.println("\t\t\t}");

		m_outstream.println("\t\t\tif (YY_F != yy_next_state) {");
		m_outstream.println("\t\t\t\tyy_state = yy_next_state;");
		m_outstream.println("\t\t\t\tyy_initial = false;");
		/*m_outstream.println("\t\t\t\tyy_this_accept = yy_accept(yy_state);");*/
		m_outstream.println("\t\t\t\tyy_this_accept = yy_acpt[yy_state];");
		m_outstream.println("\t\t\t\tif (YY_NOT_ACCEPT != yy_this_accept) {");
		m_outstream.println("\t\t\t\t\tyy_last_accept_state = yy_state;");
		m_outstream.println("\t\t\t\t\tyy_mark_end();");
		m_outstream.println("\t\t\t\t}");
		/*m_outstream.println("\t\t\t\tyy_prev_state = yy_state;");*/
		/*m_outstream.println("\t\t\t\tyy_state = yy_next_state;");*/
		m_outstream.println("\t\t\t}");

		m_outstream.println("\t\t\telse {");

		m_outstream.println("\t\t\t\tif (YY_NO_STATE == yy_last_accept_state) {");


		/*m_outstream.println("\t\t\t\t\tyy_error(YY_E_MATCH,false);");
		  m_outstream.println("\t\t\t\t\tyy_initial = true;");
		  m_outstream.println("\t\t\t\t\tyy_state "
		  + "= yy_state_dtrans[yy_lexical_state];");
		  m_outstream.println("\t\t\t\t\tyy_next_state = YY_NO_STATE;");*/
		/*m_outstream.println("\t\t\t\t\tyy_prev_state = YY_NO_STATE;");*/
		/*m_outstream.println("\t\t\t\t\tyy_last_accept_state = YY_NO_STATE;");
		  m_outstream.println("\t\t\t\t\tyy_mark_start();");*/
		/*m_outstream.println("\t\t\t\t\tyy_this_accept = yy_accept(yy_state);");*/
		/*m_outstream.println("\t\t\t\t\tyy_this_accept = yy_acpt[yy_state];");
		  m_outstream.println("\t\t\t\t\tif (YY_NOT_ACCEPT != yy_this_accept) {");
		  m_outstream.println("\t\t\t\t\t\tyy_last_accept_state = yy_state;");
		  m_outstream.println("\t\t\t\t\t}");*/

		m_outstream.println("\t\t\t\t\tthrow (new Error(\"Lexical Error: Unmatched Input.\"));");
		m_outstream.println("\t\t\t\t}");

		m_outstream.println("\t\t\t\telse {");

		m_outstream.println("\t\t\t\t\tyy_anchor = yy_acpt[yy_last_accept_state];");
		/*m_outstream.println("\t\t\t\t\tyy_anchor " 
		  + "= yy_accept(yy_last_accept_state);");*/
		m_outstream.println("\t\t\t\t\tif (0 != (YY_END & yy_anchor)) {");
		m_outstream.println("\t\t\t\t\t\tyy_move_end();");
		m_outstream.println("\t\t\t\t\t}");
		m_outstream.println("\t\t\t\t\tyy_to_mark();");

		m_outstream.println("\t\t\t\t\tswitch (yy_last_accept_state) {");

		emit_actions("\t\t\t\t\t");

		m_outstream.println("\t\t\t\t\tdefault:");
		m_outstream.println("\t\t\t\t\t\tyy_error(YY_E_INTERNAL,false);");
		/*m_outstream.println("\t\t\t\t\t\treturn null;");*/
		m_outstream.println("\t\t\t\t\tcase -1:");
		m_outstream.println("\t\t\t\t\t}");

		m_outstream.println("\t\t\t\t\tyy_initial = true;");
		m_outstream.println("\t\t\t\t\tyy_state "
				+ "= yy_state_dtrans[yy_lexical_state];");
		m_outstream.println("\t\t\t\t\tyy_next_state = YY_NO_STATE;");
		/*m_outstream.println("\t\t\t\t\tyy_prev_state = YY_NO_STATE;");*/
		m_outstream.println("\t\t\t\t\tyy_last_accept_state = YY_NO_STATE;");

		m_outstream.println("\t\t\t\t\tyy_mark_start();");

		/*m_outstream.println("\t\t\t\t\tyy_this_accept = yy_accept(yy_state);");*/
		m_outstream.println("\t\t\t\t\tyy_this_accept = yy_acpt[yy_state];");
		m_outstream.println("\t\t\t\t\tif (YY_NOT_ACCEPT != yy_this_accept) {");
		m_outstream.println("\t\t\t\t\t\tyy_last_accept_state = yy_state;");
		m_outstream.println("\t\t\t\t\t\tyy_mark_end();");
		m_outstream.println("\t\t\t\t\t}");

		m_outstream.println("\t\t\t\t}");		
		m_outstream.println("\t\t\t}");
		m_outstream.println("\t\t}");
		m_outstream.println("\t}");

		/*m_outstream.println("\t\t\t\t");
		  m_outstream.println("\t\t\t");
		  m_outstream.println("\t\t\t");
		  m_outstream.println("\t\t\t");
		  m_outstream.println("\t\t\t");
		  m_outstream.println("\t\t}");*/
	}

	/***************************************************************
Function: emit_actions
Description:		 
	 **************************************************************/
	private void emit_actions(string tabs) {
		int elem;
		int size;
		int bogus_index;
		CAccept accept;

		if (CUtility.DEBUG) {
			assert(m_spec.m_accept_vector.size() 
					== m_spec.m_anchor_array.length);
		}

		bogus_index = -2;
		size = m_spec.m_accept_vector.size();
		for (elem = 0; elem < size; ++elem) {
			accept = m_spec.m_accept_vector.elementAt(elem);
			if (null != accept) {
				m_outstream.println(tabs + "case " + elem 
						+ ":");
				m_outstream.print(tabs + "\t");
				m_outstream.print(new String(accept.m_action,0,
							accept.m_action_read));
				m_outstream.println();
				m_outstream.println(tabs + "case " + bogus_index + ":");
				m_outstream.println(tabs + "\tbreak;");
				--bogus_index;
			}
		}
	}

	/***************************************************************
Function: emit_footer
Description:		 
	 **************************************************************/
	private void emit_footer() {
		if (CUtility.DEBUG) {
			assert(null != m_spec);
			assert(null != m_outstream);
		}

		m_outstream.println("}");
	}
}
