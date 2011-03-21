module dlex.cemit;

import dlex.caccept;
import dlex.cspec;
import dlex.cdtrans;
import dlex.cutility;

import hurt.conv.conv;
import hurt.string.stringbuffer;

import std.stdio;
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
		debug(debugversion) {
			assert(null !is spec);
			assert(null !is outstream);
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

	  debug(debugversion)
	  {
	  assert(null !is m_spec);
	  assert(null !is m_outstream);
	  }*/

	/*m_outstream.writeLine("import java.lang.String;");
	  m_outstream.writeLine("import java.lang.System;");
	  m_outstream.writeLine("import java.io.BufferedReader;");
	  m_outstream.writeLine("import java.io.InputStream;");*/
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

		writeln("---------------------- Transition Table ----------------------");

		for(i = 0; i < m_spec.m_row_map.length; ++i) {
			write("State " ~ conv!(int,string)(i));

			accept = m_spec.m_accept_vector.get(i);
			if(null is accept) {
				writeln(" [nonaccepting]");
			} else {
				writeln(" [accepting, line "
						~ conv!(int,string)(accept.m_line_number)
						~ " <"
						//~ String(accept.m_action,0,accept.m_action_read))
						~ accept.m_action[0..accept.m_action_read]
						~ ">]");
			}
			dtrans = m_spec.m_dtrans_vector.get(m_spec.m_row_map[i]);

			tr = false;
			state = dtrans.m_dtrans[m_spec.m_col_map[0]];
			if(CDTrans.F != state) {
				tr = true;
				write("\tgoto " ~ conv!(int,string)(state) ~ " on [" ~ (conv!(int,string)(0)));
			}
			for(j = 1; j < m_spec.m_dtrans_ncols; ++j) {
				next = dtrans.m_dtrans[m_spec.m_col_map[j]];
				if(state == next) {
					if(CDTrans.F != state) {
						write(conv!(int,string)(j));
					}
				} else {
					state = next;
					if(tr) {
						writeln("]");
						tr = false;
					}
					if(CDTrans.F != state) {
						tr = true;
						write("\tgoto " ~ conv!(int,string)(state) ~ " on [" ~ (conv!(int,string)(j)));
					}
				}
			}
			if(tr) {
				writeln("]");
			}
		}

		writeln("---------------------- Transition Table ----------------------");
	}

	/***************************************************************
		Function: emit
		Description: High-level access function to module.
	 **************************************************************/
	//void emit(CSpec spec, java.io.PrintWriter outstream) {
	void emit(CSpec spec, std.stream.OutputStream outstream) {
		set(spec,outstream);

		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
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
		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
		}

		/* Constants */
		m_outstream.writeLine("\tprivate immutable int YY_BUFFER_SIZE = 512;");

		m_outstream.writeLine("\tprivate immutable int YY_F = -1;");
		m_outstream.writeLine("\tprivate immutable int YY_NO_STATE = -1;");

		m_outstream.writeLine("\tprivate immutable int YY_NOT_ACCEPT = 0;");
		m_outstream.writeLine("\tprivate immutable int YY_START = 1;");
		m_outstream.writeLine("\tprivate immutable int YY_END = 2;");
		m_outstream.writeLine("\tprivate immutable int YY_NO_ANCHOR = 4;");

		// internal
		m_outstream.writeLine("\tprivate immutable int YY_BOL = "~conv!(int,string)(m_spec.BOL)~";");
		m_outstream.writeLine("\tprivate immutable int YY_EOF = "~conv!(int,string)(m_spec.EOF)~";");
		// external
		if(m_spec.m_integer_type || true == m_spec.m_yyeof)
			m_outstream.writeLine("\tpublic immutable int YYEOF = -1;");

		/* User specified class code. */
		if(null !is m_spec.m_class_code) {
			m_outstream.writeString(m_spec.m_class_code[0..m_spec.m_class_read]);
		}

		/* Member Variables */
		//m_outstream.writeLine("\tprivate java.io.BufferedReader yy_reader;");
		m_outstream.writeLine("\tprivate std.stream.InputStream yy_reader;");
		m_outstream.writeLine("\tprivate int yy_buffer_index;");
		m_outstream.writeLine("\tprivate int yy_buffer_read;");
		m_outstream.writeLine("\tprivate int yy_buffer_start;");
		m_outstream.writeLine("\tprivate int yy_buffer_end;");
		m_outstream.writeLine("\tprivate char yy_buffer[];");
		if(m_spec.m_count_chars) {
			m_outstream.writeLine("\tprivate int yychar;");
		}
		if(m_spec.m_count_lines) {
			m_outstream.writeLine("\tprivate int yyline;");
		}
		m_outstream.writeLine("\tprivate bool yy_at_bol;");
		m_outstream.writeLine("\tprivate int yy_lexical_state;");
		/*if(m_spec.m_count_lines || true == m_spec.m_count_chars)
		  {
		  m_outstream.writeLine("\tprivate int yy_buffer_prev_start;");
		  }*/
		m_outstream.writeLine("\n");


		/* Function: first constructor (Reader) */
		m_outstream.writeString("\t");
		//if(true == m_spec.m_public) {
		if(m_spec.m_public) {
			m_outstream.writeString("public ");
		}
		m_outstream.writeString(m_spec.m_class_name);
		//m_outstream.writeString(" (java.io.Reader reader)");
		m_outstream.writeString(" (std.stream.InputStream reader)");

		if(null !is m_spec.m_init_throw_code) {
			m_outstream.writeLine(""); 
			//m_outstream.writeString("\t\tthrows ");  TODO check
			//m_outstream.writeString(m_spec.m_init_throw_code[0..m_spec.m_init_throw_read]); TODO check
			m_outstream.writeLine("");
			m_outstream.writeLine("\t\t{");
		} else {
			m_outstream.writeLine(" {");
		}

		m_outstream.writeLine("\t\tthis ();");		
		m_outstream.writeLine("\t\tif(null is reader) {");
		m_outstream.writeLine("\t\t\tthrow (new Error(\"Error: Bad input stream initializer.\"));");
		m_outstream.writeLine("\t\t}");
		//m_outstream.writeLine("\t\tyy_reader = new java.io.BufferedReader(reader);");
		m_outstream.writeLine("\t\tyy_reader = new std.stream.InputStream(reader);");
		m_outstream.writeLine("\t}");
		m_outstream.writeLine("");


		/* Function: second constructor (InputStream) */
		m_outstream.writeString("\t");
		if(true == m_spec.m_public) {
			m_outstream.writeString("public ");
		}
		m_outstream.writeString(m_spec.m_class_name);
		m_outstream.writeString(" (std.stream.InputStream instream)");

		if(null !is m_spec.m_init_throw_code) {
			m_outstream.writeLine(""); 
			//m_outstream.writeString("\t\tthrows "); TODO check
			//m_outstream.writeLine(m_spec.m_init_throw_code[0..m_spec.m_init_throw_read]); TODO check
			m_outstream.writeLine("\t\t{");
		} else {
			m_outstream.writeLine(" {");
		}

		m_outstream.writeLine("\t\tthis ();");		
		m_outstream.writeLine("\t\tif(null is instream) {");
		m_outstream.writeLine("\t\t\tthrow (new Error(\"Error: Bad input stream initializer.\"));");
		m_outstream.writeLine("\t\t}");
		//m_outstream.writeLine("\t\tyy_reader = new java.io.BufferedReader(new java.io.InputStreamReader(instream));");
		m_outstream.writeLine("\t\tyy_reader = new std.stream.InputStream(new std.stream.InputStream(instream));");
		m_outstream.writeLine("\t}");
		m_outstream.writeLine("");


		/* Function: third, private constructor - only forinternal use */
		m_outstream.writeString("\tprivate ");
		m_outstream.writeString(m_spec.m_class_name);
		m_outstream.writeString(" ()");

		if(null !is m_spec.m_init_throw_code) {
			m_outstream.writeLine(""); 
			//m_outstream.writeString("\t\tthrows "); TODO check
			//m_outstream.writeLine(m_spec.m_init_throw_code[0..m_spec.m_init_throw_read]); TODO check
			m_outstream.writeLine("\t\t{");
		} else {
			m_outstream.writeLine(" {");
		}

		m_outstream.writeLine("\t\tyy_buffer = new char[YY_BUFFER_SIZE];");
		m_outstream.writeLine("\t\tyy_buffer_read = 0;");
		m_outstream.writeLine("\t\tyy_buffer_index = 0;");
		m_outstream.writeLine("\t\tyy_buffer_start = 0;");
		m_outstream.writeLine("\t\tyy_buffer_end = 0;");
		if(m_spec.m_count_chars) {
			m_outstream.writeLine("\t\tyychar = 0;");
		}
		if(m_spec.m_count_lines) {
			m_outstream.writeLine("\t\tyyline = 0;");
		}
		m_outstream.writeLine("\t\tyy_at_bol = true;");
		m_outstream.writeLine("\t\tyy_lexical_state = YYINITIAL;");
		/*if(m_spec.m_count_lines || true == m_spec.m_count_chars)
		  {
		  m_outstream.writeLine("\t\tyy_buffer_prev_start = 0;");
		  }*/

		/* User specified constructor code. */
		if(null !is m_spec.m_init_code) {
			m_outstream.writeString(m_spec.m_init_code[0..m_spec.m_init_read]);
		}

		m_outstream.writeLine("\t}");
		m_outstream.writeLine("");

	}

	/***************************************************************
		Function: emit_states
		Description: Emits constants that serve as lexical states,
		including YYINITIAL.
	 **************************************************************/
	private void emit_states() {
		string[] states;
		string state;
		int index;

		states = m_spec.m_states.keys();
		/*index = 0;*/
		//while(states.hasMoreElements()) {
		foreach(it;states) {
			//state = states.nextElement(); TODO check if it is really a int array
			state = conv!(int,string)(m_spec.m_states[it]);

			debug(debugversion) {
				assert(null !is state);
			}

			m_outstream.writeLine("\tprivate immutable int " 
					~ state 
					~ " = " 
					~ conv!(int,string)(m_spec.m_states[state])
					~ ";");
			/*++index;*/
		}

		m_outstream.writeLine("\tprivate immutable int[] yy_state_dtrans = [");
		for(index = 0; index < m_spec.m_state_dtrans.length; ++index) {
			m_outstream.writeString("\t\t" ~ conv!(int,string)(m_spec.m_state_dtrans[index]));
			if(index < m_spec.m_state_dtrans.length - 1) {
				m_outstream.writeLine(",");
			} else {
				m_outstream.writeLine("");
			}
		}
		m_outstream.writeLine("\t];");
	}

	/***************************************************************
		Function: emit_helpers
		Description: Emits helper functions, particularly 
		error handling and input buffering.
	 **************************************************************/
	private void emit_helpers() {
		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
		}

		/* Function: yy_do_eof */
		m_outstream.writeLine("\tprivate bool yy_eof_done = false;");
		if(null !is m_spec.m_eof_code) {
			m_outstream.writeString("\tprivate void yy_do_eof()");

			if(null !is m_spec.m_eof_throw_code) {
				m_outstream.writeLine(""); 
				//m_outstream.writeString("\t\tthrows "); TODO check
				//m_outstream.writeLine(m_spec.m_eof_throw_code[0..m_spec.m_eof_throw_read]); TODO check
				m_outstream.writeLine("\t\t{");
			} else {
				m_outstream.writeLine(" {");
			}

			m_outstream.writeLine("\t\tif(false == yy_eof_done) {");
			m_outstream.writeString(m_spec.m_eof_code[0..m_spec.m_eof_read]);
			m_outstream.writeLine("\t\t}");
			m_outstream.writeLine("\t\tyy_eof_done = true;");
			m_outstream.writeLine("\t}");
		}

		emit_states();

		/* Function: yybegin */
		m_outstream.writeLine("\tprivate void yybegin(int state) {");
		m_outstream.writeLine("\t\tyy_lexical_state = state;");
		m_outstream.writeLine("\t}");

		/* Function: yy_initial_dtrans */
		/*m_outstream.writeLine("\tprivate int yy_initial_dtrans (int state) {");
		  m_outstream.writeLine("\t\treturn yy_state_dtrans[state];");
		  m_outstream.writeLine("\t}");*/

		/* Function: yy_advance */
		m_outstream.writeLine("\tprivate int yy_advance()");
		//m_outstream.writeLine("\t\tthrows java.io.IOException {"); TODO check
		/*m_outstream.writeLine("\t\t{");*/
		m_outstream.writeLine("\t\tint next_read;");
		m_outstream.writeLine("\t\tint i;");
		m_outstream.writeLine("\t\tint j;");
		m_outstream.writeLine("");

		m_outstream.writeLine("\t\tif(yy_buffer_index < yy_buffer_read) {");
		m_outstream.writeLine("\t\t\treturn yy_buffer[yy_buffer_index++];");
		/*m_outstream.writeLine("\t\t\t++yy_buffer_index;");*/
		m_outstream.writeLine("\t\t}");
		m_outstream.writeLine("");

		m_outstream.writeLine("\t\tif(0 != yy_buffer_start) {");
		m_outstream.writeLine("\t\t\ti = yy_buffer_start;");
		m_outstream.writeLine("\t\t\tj = 0;");
		m_outstream.writeLine("\t\t\twhile(i < yy_buffer_read) {");
		m_outstream.writeLine("\t\t\t\tyy_buffer[j] = yy_buffer[i];");
		m_outstream.writeLine("\t\t\t\t++i;");
		m_outstream.writeLine("\t\t\t\t++j;");
		m_outstream.writeLine("\t\t\t}");
		m_outstream.writeLine("\t\t\tyy_buffer_end = yy_buffer_end - yy_buffer_start;");
		m_outstream.writeLine("\t\t\tyy_buffer_start = 0;");
		m_outstream.writeLine("\t\t\tyy_buffer_read = j;");
		m_outstream.writeLine("\t\t\tyy_buffer_index = j;");
		m_outstream.writeLine("\t\t\tnext_read = yy_reader.read(yy_buffer,");
		m_outstream.writeLine("\t\t\t\t\tyy_buffer_read,");
		m_outstream.writeLine("\t\t\t\t\tyy_buffer.length - yy_buffer_read);");
		m_outstream.writeLine("\t\t\tif(-1 == next_read) {");
		m_outstream.writeLine("\t\t\t\treturn YY_EOF;");
		m_outstream.writeLine("\t\t\t}");
		m_outstream.writeLine("\t\t\tyy_buffer_read = yy_buffer_read + next_read;");
		m_outstream.writeLine("\t\t}");
		m_outstream.writeLine("");

		m_outstream.writeLine("\t\twhile(yy_buffer_index >= yy_buffer_read) {");
		m_outstream.writeLine("\t\t\tif(yy_buffer_index >= yy_buffer.length) {");
		m_outstream.writeLine("\t\t\t\tyy_buffer = yy_double(yy_buffer);");
		m_outstream.writeLine("\t\t\t}");
		m_outstream.writeLine("\t\t\tnext_read = yy_reader.read(yy_buffer,");
		m_outstream.writeLine("\t\t\t\t\tyy_buffer_read,");
		m_outstream.writeLine("\t\t\t\t\tyy_buffer.length - yy_buffer_read);");
		m_outstream.writeLine("\t\t\tif(-1 == next_read) {");
		m_outstream.writeLine("\t\t\t\treturn YY_EOF;");
		m_outstream.writeLine("\t\t\t}");
		m_outstream.writeLine("\t\t\tyy_buffer_read = yy_buffer_read + next_read;");
		m_outstream.writeLine("\t\t}");

		m_outstream.writeLine("\t\treturn yy_buffer[yy_buffer_index++];");
		m_outstream.writeLine("\t}");

		/* Function: yy_move_end */
		m_outstream.writeLine("\tprivate void yy_move_end() {");
		m_outstream.writeLine("\t\tif(yy_buffer_end > yy_buffer_start &&");
		m_outstream.writeLine("\t\t		'\\n' == yy_buffer[yy_buffer_end-1])");
		m_outstream.writeLine("\t\t\tyy_buffer_end--;");
		m_outstream.writeLine("\t\tif(yy_buffer_end > yy_buffer_start &&");
		m_outstream.writeLine("\t\t		'\\r' == yy_buffer[yy_buffer_end-1])");
		m_outstream.writeLine("\t\t\tyy_buffer_end--;");
		m_outstream.writeLine("\t}");

		/* Function: yy_mark_start */
		m_outstream.writeLine("\tprivate bool yy_last_was_cr=false;");
		m_outstream.writeLine("\tprivate void yy_mark_start () {");
		if(m_spec.m_count_lines || true == m_spec.m_count_chars) {
			if(m_spec.m_count_lines) {
				m_outstream.writeLine("\t\tint i;");
				m_outstream.writeLine("\t\tfor(i = yy_buffer_start; i < yy_buffer_index; ++i) {");
				m_outstream.writeLine("\t\t\tif(\'\\n\' == yy_buffer[i] && !yy_last_was_cr) {");
				m_outstream.writeLine("\t\t\t\t++yyline;");
				m_outstream.writeLine("\t\t\t}");
				m_outstream.writeLine("\t\t\tif('\\r' == yy_buffer[i]) {");
				m_outstream.writeLine("\t\t\t\t++yyline;");
				m_outstream.writeLine("\t\t\t\tyy_last_was_cr=true;");
				m_outstream.writeLine("\t\t\t} else yy_last_was_cr=false;");
				m_outstream.writeLine("\t\t}");
			}
			if(m_spec.m_count_chars) {
				m_outstream.writeLine("\t\tyychar = yychar"); 
				m_outstream.writeLine("\t\t\t+ yy_buffer_index - yy_buffer_start;");
			}
		}
		m_outstream.writeLine("\t\tyy_buffer_start = yy_buffer_index;");
		m_outstream.writeLine("\t}");

		/* Function: yy_mark_end */
		m_outstream.writeLine("\tprivate void yy_mark_end() {");
		m_outstream.writeLine("\t\tyy_buffer_end = yy_buffer_index;");
		m_outstream.writeLine("\t}");

		/* Function: yy_to_mark */
		m_outstream.writeLine("\tprivate void yy_to_mark() {");
		m_outstream.writeLine("\t\tyy_buffer_index = yy_buffer_end;");
		m_outstream.writeLine("\t\tyy_at_bol = (yy_buffer_end > yy_buffer_start) &&");
		m_outstream.writeLine("\t\t						('\\r' == yy_buffer[yy_buffer_end-1] ||");
		m_outstream.writeLine("\t\t						 '\\n' == yy_buffer[yy_buffer_end-1] ||");
		m_outstream.writeLine("\t\t						"~ /* unicode LS */
				" 2028/*LS*/ == yy_buffer[yy_buffer_end-1] ||");
		m_outstream.writeLine("\t\t						"~ /* unicode PS */
				" 2029/*PS*/ == yy_buffer[yy_buffer_end-1]);");
		m_outstream.writeLine("\t}");

		/* Function: yytext */
		m_outstream.writeLine("\tprivate string yytext() {");
		//m_outstream.writeLine("\t\treturn (new java.lang.String(yy_buffer,"); TODO check
		m_outstream.writeLine("\t\treturn yy_buffer.idup,");
		m_outstream.writeLine("\t\t\tyy_buffer_start,");
		m_outstream.writeLine("\t\t\tyy_buffer_end - yy_buffer_start);");
		m_outstream.writeLine("\t}");

		/* Function: yylength */
		m_outstream.writeLine("\tprivate int yylength() {");
		m_outstream.writeLine("\t\treturn yy_buffer_end - yy_buffer_start;");
		m_outstream.writeLine("\t}");

		/* Function: yy_double */
		m_outstream.writeLine("\tprivate char[] yy_double(char buf[]) {");
		m_outstream.writeLine("\t\tint i;");
		m_outstream.writeLine("\t\tchar[] newbuf;");
		m_outstream.writeLine("\t\tnewbuf = new char[2*buf.length];");
		m_outstream.writeLine("\t\tfor(i = 0; i < buf.length; ++i) {");
		m_outstream.writeLine("\t\t\tnewbuf[i] = buf[i];");
		m_outstream.writeLine("\t\t}");
		m_outstream.writeLine("\t\treturn newbuf;");
		m_outstream.writeLine("\t}");

		/* Function: yy_error */
		m_outstream.writeLine("\tprivate final int YY_E_INTERNAL = 0;");
		m_outstream.writeLine("\tprivate final int YY_E_MATCH = 1;");
		m_outstream.writeLine("\tprivate string[] yy_error_string = [");
		m_outstream.writeLine("\t\t\"Error: Internal error.\\n\",");
		m_outstream.writeLine("\t\t\"Error: Unmatched input.\\n\"");
		m_outstream.writeLine("\t];");
		m_outstream.writeLine("\tprivate void yy_error(int code, bool fatal) {");
		m_outstream.writeLine("\t\tjava.lang.write(yy_error_string[code]);");
		m_outstream.writeLine("\t\tjava.lang.System.out.flush();");
		m_outstream.writeLine("\t\tif(fatal) {");
		m_outstream.writeLine("\t\t\tthrow new Error(\"Fatal Error.\\n\");");
		m_outstream.writeLine("\t\t}");
		m_outstream.writeLine("\t}");

		/* Function: yy_next */
		/*m_outstream.writeLine("\tprivate int yy_next (int current,char lookahead) {");
		  m_outstream.writeLine("\t\treturn yy_nxt[yy_rmap[current]][yy_cmap[lookahead]];");
		  m_outstream.writeLine("\t}");*/

		/* Function: yy_accept */
		/*m_outstream.writeLine("\tprivate int yy_accept (int current) {");
		  m_outstream.writeLine("\t\treturn yy_acpt[current];");
		  m_outstream.writeLine("\t}");*/


		// Function: private int [][] unpackFromString(int size1, int size2, String st)
		// Added 6/24/98 Raimondas Lencevicius
		// May be made more efficient by replacing String operations
		// Assumes correctly formed input String. Performs no error checking
		m_outstream.writeLine("\tprivate int[][] unpackFromString(int size1, int size2, String st) {");
		m_outstream.writeLine("\t\tint colonIndex = -1;");
		m_outstream.writeLine("\t\tstring lengthString;");
		m_outstream.writeLine("\t\tint sequenceLength = 0;");
		m_outstream.writeLine("\t\tint sequenceInteger = 0;");
		m_outstream.writeLine("");
		m_outstream.writeLine("\t\tint commaIndex;");
		m_outstream.writeLine("\t\tstring workString;");
		m_outstream.writeLine("");
		m_outstream.writeLine("\t\tint res[][] = new int[size1][size2];");
		m_outstream.writeLine("\t\tfor(int i= 0; i < size1; i++) {");
		m_outstream.writeLine("\t\t\tfor(int j= 0; j < size2; j++) {");
		m_outstream.writeLine("\t\t\t\tif(sequenceLength != 0) {");
		m_outstream.writeLine("\t\t\t\t\tres[i][j] = sequenceInteger;");
		m_outstream.writeLine("\t\t\t\t\tsequenceLength--;");
		m_outstream.writeLine("\t\t\t\t\tcontinue;");
		m_outstream.writeLine("\t\t\t\t}");
		m_outstream.writeLine("\t\t\t\tcommaIndex = st.indexOf(',');");
		m_outstream.writeLine("\t\t\t\tworkString = (commaIndex==-1) ? st :");
		m_outstream.writeLine("\t\t\t\t\tst.substring(0, commaIndex);");
		m_outstream.writeLine("\t\t\t\tst = st.substring(commaIndex+1);");	
		m_outstream.writeLine("\t\t\t\tcolonIndex = workString.indexOf(':');");
		m_outstream.writeLine("\t\t\t\tif(colonIndex == -1) {");
		m_outstream.writeLine("\t\t\t\t\tres[i][j] = conv!(string,int)(workString);");
		m_outstream.writeLine("\t\t\t\t\tcontinue;");
		m_outstream.writeLine("\t\t\t\t}");
		m_outstream.writeLine("\t\t\t\tlengthString =");
		m_outstream.writeLine("\t\t\t\t\tworkString.substring(colonIndex+1);");
		m_outstream.writeLine("\t\t\t\tsequenceLength=conv!(string,int)(lengthString);");
		m_outstream.writeLine("\t\t\t\tworkString=workString[0..colonIndex];");
		m_outstream.writeLine("\t\t\t\tsequenceInteger=conv!(string,int)(workString);");
		m_outstream.writeLine("\t\t\t\tres[i][j] = sequenceInteger;");
		m_outstream.writeLine("\t\t\t\tsequenceLength--;");
		m_outstream.writeLine("\t\t\t}");
		m_outstream.writeLine("\t\t}");
		m_outstream.writeLine("\t\treturn res;");
		m_outstream.writeLine("\t}");
	}

	/***************************************************************
		Function: emit_header
		Description: Emits class header.
	 **************************************************************/
	private void emit_header() {
		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
		}

		m_outstream.writeLine("");
		m_outstream.writeLine("");
		if(true == m_spec.m_public) {
			m_outstream.writeString("public ");
		}
		m_outstream.writeString("class ");
		m_outstream.writeString(m_spec.m_class_name[0..m_spec.m_class_name.length]);
		if(m_spec.m_implements_name.length > 0) {
			m_outstream.writeString(" : ");	// former implements
			m_outstream.writeString(m_spec.m_implements_name[0..m_spec.m_implements_name.length]);
		}		
		m_outstream.writeLine(" {");
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

		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
		}

		m_outstream.writeLine("\tprivate int[] yy_acpt = [");
		size = m_spec.m_accept_vector.getSize();
		for(elem = 0; elem < size; ++elem) {
			accept = m_spec.m_accept_vector.get(elem);

			m_outstream.writeString("\t\t/* " ~ conv!(int,string)(elem) ~ " */ ");
			if(null !is accept) {
				is_start = (0 != (m_spec.m_anchor_array[elem] & CSpec.START));
				is_end = (0 != (m_spec.m_anchor_array[elem] & CSpec.END));

				if(is_start && true == is_end) {
					m_outstream.writeString("YY_START | YY_END");
				} else if(is_start) {
					m_outstream.writeString("YY_START");
				} else if(is_end) {
					m_outstream.writeString("YY_END");
				} else {
					m_outstream.writeString("YY_NO_ANCHOR");
				}
			} else {
				m_outstream.writeString("YY_NOT_ACCEPT");
			}

			if(elem < size - 1) {
				m_outstream.writeString(",");
			}

			m_outstream.writeLine("");
		}

		m_outstream.writeLine("\t];");

		// CSA: modified yy_cmap to use string packing 9-Aug-1999
		int[] yy_cmap = new int[m_spec.m_ccls_map.length];
		for(i = 0; i < m_spec.m_ccls_map.length; ++i)
			yy_cmap[i] = m_spec.m_col_map[m_spec.m_ccls_map[i]];
		m_outstream.writeString("\tprivate int[] yy_cmap = unpackFromString(");
		//int[][] tmp = new int[yy_cmap.length][]; TODO check this too
		int[][] tmp = new int[][](yy_cmap.length);
		tmp[0] = yy_cmap;
		//emit_table_as_string(new int[][] { yy_cmap });
		emit_table_as_string(tmp);
		m_outstream.writeLine(")[0];");
		m_outstream.writeLine("");

		// CSA: modified yy_rmap to use string packing 9-Aug-1999
		m_outstream.writeString("\tprivate int[] yy_rmap = unpackFromString(");
		//tmp = new int[m_spec.m_row_map][]; TODO not sure about this
		tmp = new int[][](m_spec.m_row_map.length);
		tmp[0] = m_spec.m_row_map;
		//emit_table_as_string(new int[][] { m_spec.m_row_map });
		emit_table_as_string(tmp);
		m_outstream.writeLine(")[0];");
		m_outstream.writeLine("");

		// 6/24/98 Raimondas Lencevicius
		// modified to use
		//		int[][] unpackFromString(int size1, int size2, String st)
		size = m_spec.m_dtrans_vector.getSize();
		//int[][] yy_nxt = new int[size][]; TODO check if array it is right
		int[][] yy_nxt = new int[][](size);
		for(elem=0; elem<size; elem++) {
			dtrans = m_spec.m_dtrans_vector.get(elem);
			assert(dtrans.m_dtrans.length==m_spec.m_dtrans_ncols);
			yy_nxt[elem] = dtrans.m_dtrans;
		}
		m_outstream.writeString("\tprivate int[][] yy_nxt = unpackFromString(");
		emit_table_as_string(yy_nxt);
		m_outstream.writeLine(");");
		m_outstream.writeLine("");
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
		m_outstream.writeString(conv!(int,string)(ia.length));
		m_outstream.writeString(",");
		m_outstream.writeString( ia.length > 0 ? conv!(int,string)(ia[0].length) : "0");
		m_outstream.writeLine(",");

		StringBuffer!(char) outstr = new StringBuffer!(char)();

		//	RL - Output matrix 
		for(int elem = 0; elem < ia.length; ++elem) {
			for(int i = 0; i < ia[elem].length; ++i) {
				int writeInt = ia[elem][i];
				// RL - sequence?
				if(writeInt == previousInt) {
					if(sequenceStarted) {
						sequenceLength++;
					} else {
						outstr.pushBack(conv!(int,string)(writeInt));
						outstr.pushBack(":");
						sequenceLength = 2;
						sequenceStarted = true;
					}
					// RL - no sequence or end sequence
				} else {
					if(sequenceStarted) {
						outstr.pushBack(conv!(int,string)(sequenceLength));
						outstr.pushBack(",");
						sequenceLength = 0;
						sequenceStarted = false;
					} else {
						if(previousInt != -20) {
							outstr.pushBack(conv!(int,string)(previousInt));
							outstr.pushBack(",");
						}
					}
				}
				previousInt = writeInt;
				// CSA: output in 75 character chunks.
				if(outstr.getSize() > 75) {
					string s = outstr.toString();
					m_outstream.writeLine("\"" ~ s[0..75] ~ "\" ~");
					outstr = new StringBuffer!(char)(s[75..$]);
				}
			}
		}

		if(sequenceStarted) {
			outstr.pushBack(conv!(int,string)(sequenceLength));
		} else {
			outstr.pushBack(conv!(int,string)(previousInt));
		}		
		// CSA: output in 75 character chunks.
		if(outstr.getSize() > 75) {
			string s = outstr.toString();
			m_outstream.writeLine("\"" ~ s[0..75] ~ "\" +");
			outstr = new StringBuffer!(char)(s[75..$]);
		}
		m_outstream.writeString("\"" ~ outstr.toString() ~ "\"");
	}

	/***************************************************************
		Function: emit_driver
		Description: 
	 **************************************************************/
	private void emit_driver() {
		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
		}

		emit_table();

		if(m_spec.m_integer_type) {
			m_outstream.writeString("\tpublic int ");
			m_outstream.writeString(m_spec.m_function_name);
			m_outstream.writeLine("()");
		} else if(m_spec.m_intwrap_type) {
			m_outstream.writeString("\tpublic java.lang.Integer ");
			m_outstream.writeString(m_spec.m_function_name);
			m_outstream.writeLine("()");
		} else {
			m_outstream.writeString("\tpublic ");
			m_outstream.writeString(m_spec.m_type_name);
			m_outstream.writeString(" ");
			m_outstream.writeString(m_spec.m_function_name);
			m_outstream.writeLine("()");
		}

		/*m_outstream.writeLine("\t\tthrows java.io.IOException {");*/
		m_outstream.writeString("\t\tthrows java.io.IOException");
		if(null !is m_spec.m_yylex_throw_code) {
			m_outstream.writeString(", "); 
			m_outstream.writeString(m_spec.m_yylex_throw_code[0..m_spec.m_yylex_throw_read]);
			m_outstream.writeLine("");
			m_outstream.writeLine("\t\t{");
		} else {
			m_outstream.writeLine(" {");
		}

		m_outstream.writeLine("\t\tint yy_lookahead;");
		m_outstream.writeLine("\t\tint yy_anchor = YY_NO_ANCHOR;");
		/*m_outstream.writeLine("\t\tint yy_state "
		  + "= yy_initial_dtrans(yy_lexical_state);");*/
		m_outstream.writeLine("\t\tint yy_state = yy_state_dtrans[yy_lexical_state];");
		m_outstream.writeLine("\t\tint yy_next_state = YY_NO_STATE;");
		/*m_outstream.writeLine("\t\tint yy_prev_stave = YY_NO_STATE;");*/
		m_outstream.writeLine("\t\tint yy_last_accept_state = YY_NO_STATE;");
		m_outstream.writeLine("\t\tbool yy_initial = true;");
		m_outstream.writeLine("\t\tint yy_this_accept;");
		m_outstream.writeLine("");

		m_outstream.writeLine("\t\tyy_mark_start();");
		/*m_outstream.writeLine("\t\tyy_this_accept = yy_accept(yy_state);");*/
		m_outstream.writeLine("\t\tyy_this_accept = yy_acpt[yy_state];");
		m_outstream.writeLine("\t\tif(YY_NOT_ACCEPT != yy_this_accept) {");
		m_outstream.writeLine("\t\t\tyy_last_accept_state = yy_state;");
		m_outstream.writeLine("\t\t\tyy_mark_end();");
		m_outstream.writeLine("\t\t}");

		if(NOT_EDBG) {
			m_outstream.writeLine("\t\tjava.lang.writeln(\"Begin\");");
		}

		m_outstream.writeLine("\t\twhile(true) {");

		m_outstream.writeLine("\t\t\tif(yy_initial && yy_at_bol) yy_lookahead = YY_BOL;");
		m_outstream.writeLine("\t\t\telse yy_lookahead = yy_advance();");
		m_outstream.writeLine("\t\t\tyy_next_state = YY_F;");
		/*m_outstream.writeLine("\t\t\t\tyy_next_state = "
		  + "yy_next(yy_state,yy_lookahead);");*/
		m_outstream.writeLine("\t\t\tyy_next_state = yy_nxt[yy_rmap[yy_state]][yy_cmap[yy_lookahead]];");

		if(NOT_EDBG) {
			m_outstream.writeLine("java.lang.writeln(\"Current state: \" ~ yy_state");
			m_outstream.writeLine("~ \"\tCurrent input: \""); 
			m_outstream.writeLine(" ~ ((char) yy_lookahead));");
		}
		if(NOT_EDBG) {
			m_outstream.writeLine("\t\t\tjava.lang.writeln(\"State = \"~ yy_state);");
			m_outstream.writeLine("\t\t\tjava.lang.writeln(\"Accepting status = \"~ yy_this_accept);");
			m_outstream.writeLine("\t\t\tjava.lang.writeln(\"Last accepting state = \"~ yy_last_accept_state);");
			m_outstream.writeLine("\t\t\tjava.lang.writeln(\"Next state = \"~ yy_next_state);");
			m_outstream.writeLine("\t\t\tjava.lang.writeln(\"Lookahead input = \"~ ((char) yy_lookahead));");
		}

		// handle bare EOF.
		m_outstream.writeLine("\t\t\tif(YY_EOF == yy_lookahead && true == yy_initial) {");
		if(null !is m_spec.m_eof_code) {
			m_outstream.writeLine("\t\t\t\tyy_do_eof();");
		}
		if(true == m_spec.m_integer_type) {
			m_outstream.writeLine("\t\t\t\treturn YYEOF;");
		} else if(null !is m_spec.m_eof_value_code) {
			m_outstream.writeString(m_spec.m_eof_value_code[0..m_spec.m_eof_value_read]);
		} else {
			m_outstream.writeLine("\t\t\t\treturn null;");
		}
		m_outstream.writeLine("\t\t\t}");

		m_outstream.writeLine("\t\t\tif(YY_F != yy_next_state) {");
		m_outstream.writeLine("\t\t\t\tyy_state = yy_next_state;");
		m_outstream.writeLine("\t\t\t\tyy_initial = false;");
		/*m_outstream.writeLine("\t\t\t\tyy_this_accept = yy_accept(yy_state);");*/
		m_outstream.writeLine("\t\t\t\tyy_this_accept = yy_acpt[yy_state];");
		m_outstream.writeLine("\t\t\t\tif(YY_NOT_ACCEPT != yy_this_accept) {");
		m_outstream.writeLine("\t\t\t\t\tyy_last_accept_state = yy_state;");
		m_outstream.writeLine("\t\t\t\t\tyy_mark_end();");
		m_outstream.writeLine("\t\t\t\t}");
		/*m_outstream.writeLine("\t\t\t\tyy_prev_state = yy_state;");*/
		/*m_outstream.writeLine("\t\t\t\tyy_state = yy_next_state;");*/
		m_outstream.writeLine("\t\t\t}");

		m_outstream.writeLine("\t\t\telse {");

		m_outstream.writeLine("\t\t\t\tif(YY_NO_STATE == yy_last_accept_state) {");


		/*m_outstream.writeLine("\t\t\t\t\tyy_error(YY_E_MATCH,false);");
		  m_outstream.writeLine("\t\t\t\t\tyy_initial = true;");
		  m_outstream.writeLine("\t\t\t\t\tyy_state "
		  + "= yy_state_dtrans[yy_lexical_state];");
		  m_outstream.writeLine("\t\t\t\t\tyy_next_state = YY_NO_STATE;");*/
		/*m_outstream.writeLine("\t\t\t\t\tyy_prev_state = YY_NO_STATE;");*/
		/*m_outstream.writeLine("\t\t\t\t\tyy_last_accept_state = YY_NO_STATE;");
		  m_outstream.writeLine("\t\t\t\t\tyy_mark_start();");*/
		/*m_outstream.writeLine("\t\t\t\t\tyy_this_accept = yy_accept(yy_state);");*/
		/*m_outstream.writeLine("\t\t\t\t\tyy_this_accept = yy_acpt[yy_state];");
		  m_outstream.writeLine("\t\t\t\t\tif(YY_NOT_ACCEPT != yy_this_accept) {");
		  m_outstream.writeLine("\t\t\t\t\t\tyy_last_accept_state = yy_state;");
		  m_outstream.writeLine("\t\t\t\t\t}");*/

		m_outstream.writeLine("\t\t\t\t\tthrow (new Error(\"Lexical Error: Unmatched Input.\"));");
		m_outstream.writeLine("\t\t\t\t}");

		m_outstream.writeLine("\t\t\t\telse {");

		m_outstream.writeLine("\t\t\t\t\tyy_anchor = yy_acpt[yy_last_accept_state];");
		/*m_outstream.writeLine("\t\t\t\t\tyy_anchor " 
		  + "= yy_accept(yy_last_accept_state);");*/
		m_outstream.writeLine("\t\t\t\t\tif(0 != (YY_END & yy_anchor)) {");
		m_outstream.writeLine("\t\t\t\t\t\tyy_move_end();");
		m_outstream.writeLine("\t\t\t\t\t}");
		m_outstream.writeLine("\t\t\t\t\tyy_to_mark();");

		m_outstream.writeLine("\t\t\t\t\tswitch (yy_last_accept_state) {");

		emit_actions("\t\t\t\t\t");

		m_outstream.writeLine("\t\t\t\t\tdefault:");
		m_outstream.writeLine("\t\t\t\t\t\tyy_error(YY_E_INTERNAL,false);");
		/*m_outstream.writeLine("\t\t\t\t\t\treturn null;");*/
		m_outstream.writeLine("\t\t\t\t\tcase -1:");
		m_outstream.writeLine("\t\t\t\t\t}");

		m_outstream.writeLine("\t\t\t\t\tyy_initial = true;");
		m_outstream.writeLine("\t\t\t\t\tyy_state = yy_state_dtrans[yy_lexical_state];");
		m_outstream.writeLine("\t\t\t\t\tyy_next_state = YY_NO_STATE;");
		/*m_outstream.writeLine("\t\t\t\t\tyy_prev_state = YY_NO_STATE;");*/
		m_outstream.writeLine("\t\t\t\t\tyy_last_accept_state = YY_NO_STATE;");

		m_outstream.writeLine("\t\t\t\t\tyy_mark_start();");

		/*m_outstream.writeLine("\t\t\t\t\tyy_this_accept = yy_accept(yy_state);");*/
		m_outstream.writeLine("\t\t\t\t\tyy_this_accept = yy_acpt[yy_state];");
		m_outstream.writeLine("\t\t\t\t\tif(YY_NOT_ACCEPT != yy_this_accept) {");
		m_outstream.writeLine("\t\t\t\t\t\tyy_last_accept_state = yy_state;");
		m_outstream.writeLine("\t\t\t\t\t\tyy_mark_end();");
		m_outstream.writeLine("\t\t\t\t\t}");

		m_outstream.writeLine("\t\t\t\t}");		
		m_outstream.writeLine("\t\t\t}");
		m_outstream.writeLine("\t\t}");
		m_outstream.writeLine("\t}");

		/*m_outstream.writeLine("\t\t\t\t");
		  m_outstream.writeLine("\t\t\t");
		  m_outstream.writeLine("\t\t\t");
		  m_outstream.writeLine("\t\t\t");
		  m_outstream.writeLine("\t\t\t");
		  m_outstream.writeLine("\t\t}");*/
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

		debug(debugversion) {
			assert(m_spec.m_accept_vector.getSize() 
					== m_spec.m_anchor_array.length);
		}

		bogus_index = -2;
		size = m_spec.m_accept_vector.getSize();
		for(elem = 0; elem < size; ++elem) {
			accept = m_spec.m_accept_vector.get(elem);
			if(null !is accept) {
				m_outstream.writeLine(tabs ~ "case " ~ conv!(int,string)(elem) ~ ":");
				m_outstream.writeString(tabs ~ "\t");
				m_outstream.writeString(accept.m_action[0..accept.m_action_read].idup);
				m_outstream.writeLine("");
				m_outstream.writeLine(tabs ~ "case " ~ conv!(int,string)(bogus_index) ~ ":");
				m_outstream.writeLine(tabs ~ "\tbreak;");
				--bogus_index;
			}
		}
	}

	/***************************************************************
Function: emit_footer
Description:		 
	 **************************************************************/
	private void emit_footer() {
		debug(debugversion) {
			assert(null !is m_spec);
			assert(null !is m_outstream);
		}

		m_outstream.writeLine("}");
	}
}
