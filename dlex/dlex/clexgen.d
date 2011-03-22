module dlex.clexgen;

import dlex.caccept;
import dlex.cdtrans;
import dlex.cemit;
import dlex.cerror;
import dlex.cinput;
import dlex.cmakenfa;
import dlex.cminimize;
import dlex.cnfa2dfa;
import dlex.cset;
import dlex.csimplifynfa;
import dlex.cspec;
import dlex.cnfa;
import dlex.cutility;
import dlex.enumeration;
import dlex.sparsebitset;

import dlex.vector;
import hurt.conv.conv;
import hurt.util.array;
import hurt.util.stacktrace;
import hurt.string.stringutil;

import std.stream;
import std.stdio;

class CLexGen {
	/***************************************************************
	 * Member Variables
	 **************************************************************/
	private std.stream.InputStream m_instream; /* JLex specification file. */
	private std.stream.OutputStream m_outstream; /* Lexical analyzer source file. */

	private CInput m_input; /* Input buffer class. */

	private int[char] m_tokens; /*
								 * Hashtable that maps characters to their
								 * corresponding lexical code forthe internal
								 * lexical analyzer.
								 */
	private CSpec m_spec; /*
						 * Spec class holds information about the generated
						 * lexer.
						 */
	private bool m_init_flag; /*
								 * Flag set to true only upon successful
								 * initialization.
								 */

	private CMakeNfa m_makeNfa; /* NFA machine generator module. */
	private CNfa2Dfa m_nfa2dfa; /*
								 * NFA to DFA machine (transition table)
								 * conversion module.
								 */
	private CMinimize m_minimize; /* Transition table compressor. */
	private CSimplifyNfa m_simplifyNfa; /* NFA simplifier using char classes */
	private CEmit m_emit; /*
						 * Output module that emits source code into the
						 * generated lexer file.
						 */

	/********************************************************
	 * Constants
	 *******************************************************/
	private static immutable bool ERROR = false;
	private static immutable bool NOT_ERROR = true;
	private static immutable int BUFFER_SIZE = 1024;

	/********************************************************
	 * Constants: Token Types
	 *******************************************************/
	static immutable int EOS = 1;
	static immutable int ANY = 2;
	static immutable int AT_BOL = 3;
	static immutable int AT_EOL = 4;
	static immutable int CCL_END = 5;
	static immutable int CCL_START = 6;
	static immutable int CLOSE_CURLY = 7;
	static immutable int CLOSE_PAREN = 8;
	static immutable int CLOSURE = 9;
	static immutable int DASH = 10;
	static immutable int END_OF_INPUT = 11;
	static immutable int L = 12;
	static immutable int OPEN_CURLY = 13;
	static immutable int OPEN_PAREN = 14;
	static immutable int OPTIONAL = 15;
	static immutable int OR = 16;
	static immutable int PLUS_CLOSE = 17;

	/***************************************************************
	 * Function: CLexGen
	 **************************************************************/
	this(string filename) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"clexgen.this");
		debug st.putArgs("string", "filename", filename);
			
		/* Successful initialization flag. */
		m_init_flag = false;

		/* Open input stream. */
		//m_instream = new java.io.FileReader(filename);
		m_instream = new std.stream.File(filename);
		if(m_instream is null) {
			writeln("Error: Unable to open input file " ~ filename ~ ".");
			return;
		}

		/* Open output stream. */
		//m_outstream = new java.io.PrintWriter(new java.io.BufferedWriter(
		m_outstream = new std.stream.File(filename ~ ".d", FileMode.OutNew);
		if(m_outstream is null) {
			writeln("Error: Unable to open output file " ~ filename ~ ".d");
			return;
		}

		/* Create input buffer class. */
		m_input = new CInput(m_instream);

		/* Initialize character hash table. */
		//m_tokens = new Hashtable();
		m_tokens['$'] = AT_EOL;
		m_tokens['('] = OPEN_PAREN;
		m_tokens[')'] = CLOSE_PAREN;
		m_tokens['*'] = CLOSURE;
		m_tokens['+'] = PLUS_CLOSE;
		m_tokens['-'] = DASH;
		m_tokens['.'] = ANY;
		m_tokens['?'] = OPTIONAL;
		m_tokens['['] = CCL_START;
		m_tokens[']'] = CCL_END;
		m_tokens['^'] = AT_BOL;
		m_tokens['{'] = OPEN_CURLY;
		m_tokens['|'] = OR;
		m_tokens['}'] = CLOSE_CURLY;

		/* Initialize spec structure. */
		m_spec = new CSpec(this);

		/* Nfa to dfa converter. */
		m_nfa2dfa = new CNfa2Dfa();
		m_minimize = new CMinimize();
		m_makeNfa = new CMakeNfa();
		m_simplifyNfa = new CSimplifyNfa();

		m_emit = new CEmit();

		/* Successful initialization flag. */
		m_init_flag = true;
	}

	/***************************************************************
	 * Function: generate Description:
	 **************************************************************/
	void generate() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"generate");
		if(false == m_init_flag) {
			CError.parse_error(CError.E_INIT, 0);
		}

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
			assert(m_init_flag);
		}

		/* m_emit.emit_imports(m_spec,m_outstream); */

		if(m_spec.m_verbose) {
			writeln("Processing first section -- user code.");
		}
		userCode();
		if(m_input.m_eof_reached) {
			CError.parse_error(CError.E_EOF, m_input.m_line_number);
		}
		debug writeln("User Code done");

		if(m_spec.m_verbose) {
			writeln("Processing second section -- " ~ "JLex declarations.");
		}
		userDeclare();
		if(m_input.m_eof_reached) {
			CError.parse_error(CError.E_EOF, m_input.m_line_number);
		}
		debug writeln("User Declare done");

		if(m_spec.m_verbose) {
			writeln("Processing third section -- lexical rules.");
		}
		userRules();
		if(CUtility.DO_DEBUG) {
			print_header();
		}
		debug writeln("User Rules done");

		if(m_spec.m_verbose) {
			writeln("Outputting lexical analyzer code.");
		}
		m_emit.emit(m_spec, m_outstream);
		debug writeln("emit done");

		if(m_spec.m_verbose && true == CUtility.OLD_DUMP_DEBUG) {
			details();
		}

		m_outstream.close();
	}

	/***************************************************************
	 * Function: userCode Description: Process first section of specification,
	 * echoing it into output file.
	 **************************************************************/
	private void userCode() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"userCode");
		int count = 0;

		if(false == m_init_flag) {
			CError.parse_error(CError.E_INIT, 0);
		}

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		if(m_input.m_eof_reached) {
			CError.parse_error(CError.E_EOF, m_input.m_line_number);
		}

		while(true) {
			if(m_input.getLine()) {
				/* Eof reached. */
				StackTrace.printTrace();
				CError.parse_error(CError.E_EOF, m_input.m_line_number);
			}

			if(2 <= m_input.m_line_read && '%' == m_input.m_line[0]
					&& '%' == m_input.m_line[1]) {
				/* Discard remainder of line. */
				m_input.m_line_index = m_input.m_line_read;
				return;
			}

			m_outstream.write(m_input.m_line[0..m_input.m_line_read]);
		}
	}

	/***************************************************************
	 * Function: getName
	 **************************************************************/
	private char[] getName() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"getName");
		char buffer[];
		int elem;

		/* Skip white space. */
		while(m_input.m_line_index < m_input.m_line_read
				&& true == CUtility
						.isspace(m_input.m_line[m_input.m_line_index])) {
			++m_input.m_line_index;
		}

		/* No name? */
		if(m_input.m_line_index >= m_input.m_line_read) {
			CError.parse_error(CError.E_DIRECT, 0);
		}

		/* Determine length. */
		elem = m_input.m_line_index;
		while(elem < m_input.m_line_read
				&& false == CUtility.isnewline(m_input.m_line[elem])) {
			++elem;
		}

		/* Allocate non-terminated buffer of exact length. */
		buffer = new char[elem - m_input.m_line_index];

		/* Copy. */
		elem = 0;
		while(m_input.m_line_index < m_input.m_line_read
				&& false == CUtility
						.isnewline(m_input.m_line[m_input.m_line_index])) {
			buffer[elem] = m_input.m_line[m_input.m_line_index];
			++elem;
			++m_input.m_line_index;
		}

		return buffer;
	}

	private immutable int CLASS_CODE = 0;
	private immutable int INIT_CODE = 1;
	private immutable int EOF_CODE = 2;
	private immutable int INIT_THROW_CODE = 3;
	private immutable int YYLEX_THROW_CODE = 4;
	private immutable int EOF_THROW_CODE = 5;
	private immutable int EOF_VALUE_CODE = 6;

	/***************************************************************
	 * Function: packCode Description:
	 **************************************************************/
	private char[] packCode(char start_dir[], char end_dir[], char prev_code[],
			int prev_read, int specified) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"packCode");
			
		debug(debugversion) {
			assert(INIT_CODE == specified || CLASS_CODE == specified
					|| EOF_CODE == specified || EOF_VALUE_CODE == specified
					|| INIT_THROW_CODE == specified
					|| YYLEX_THROW_CODE == specified
					|| EOF_THROW_CODE == specified);
		}

		if(0 != CUtility.charncmp(m_input.m_line, 0, start_dir, 0,
				start_dir.length - 1)) {
			CError.parse_error(CError.E_INTERNAL, 0);
		}

		if(null is prev_code) {
			prev_code = new char[BUFFER_SIZE];
			prev_read = 0;
		}

		if(prev_read >= prev_code.length) {
			prev_code = CUtility.doubleSize(prev_code);
		}

		m_input.m_line_index = start_dir.length - 1;
		while(true) {
			while(m_input.m_line_index >= m_input.m_line_read) {
				if(m_input.getLine()) {
					CError.parse_error(CError.E_EOF, m_input.m_line_number);
				}

				if(0 == CUtility.charncmp(m_input.m_line, 0, end_dir, 0,
						end_dir.length - 1)) {
					m_input.m_line_index = end_dir.length - 1;

					switch (specified) {
					case CLASS_CODE:
						m_spec.m_class_read = prev_read;
						break;

					case INIT_CODE:
						m_spec.m_init_read = prev_read;
						break;

					case EOF_CODE:
						m_spec.m_eof_read = prev_read;
						break;

					case EOF_VALUE_CODE:
						m_spec.m_eof_value_read = prev_read;
						break;

					case INIT_THROW_CODE:
						m_spec.m_init_throw_read = prev_read;
						break;

					case YYLEX_THROW_CODE:
						m_spec.m_yylex_throw_read = prev_read;
						break;

					case EOF_THROW_CODE:
						m_spec.m_eof_throw_read = prev_read;
						break;

					default:
						CError.parse_error(CError.E_INTERNAL,
								m_input.m_line_number);
						break;
					}

					return prev_code;
				}
			}

			while(m_input.m_line_index < m_input.m_line_read) {
				prev_code[prev_read] = m_input.m_line[m_input.m_line_index];
				++prev_read;
				++m_input.m_line_index;

				if(prev_read >= prev_code.length) {
					prev_code = CUtility.doubleSize(prev_code);
				}
			}
		}
	}

	/***************************************************************
	 * Member Variables: JLex directives.
	 **************************************************************/
	private char m_state_dir[] = [ '%', 's', 't', 'a', 't', 'e', '\0' ];

	private char m_char_dir[] = [ '%', 'c', 'h', 'a', 'r', '\0' ];

	private char m_line_dir[] = [ '%', 'l', 'i', 'n', 'e', '\0' ];

	private char m_cup_dir[] = [ '%', 'c', 'u', 'p', '\0' ];

	private char m_class_dir[] = [ '%', 'c', 'l', 'a', 's', 's', '\0' ];

	private char m_implements_dir[] = [ '%', 'i', 'm', 'p', 'l', 'e', 'm', 'e',
			'n', 't', 's', '\0' ];

	private char m_function_dir[] = [ '%', 'f', 'u', 'n', 'c', 't', 'i', 'o',
			'n', '\0' ];

	private char m_type_dir[] = [ '%', 't', 'y', 'p', 'e', '\0' ];

	private char m_integer_dir[] = [ '%', 'i', 'n', 't', 'e', 'g', 'e', 'r',
			'\0' ];

	private char m_intwrap_dir[] = [ '%', 'i', 'n', 't', 'w', 'r', 'a', 'p',
			'\0' ];

	private char m_full_dir[] = [ '%', 'f', 'u', 'l', 'l', '\0' ];

	private char m_unicode_dir[] = [ '%', 'u', 'n', 'i', 'c', 'o', 'd', 'e',
			'\0' ];

	private char m_ignorecase_dir[] = [ '%', 'i', 'g', 'n', 'o', 'r', 'e', 'c',
			'a', 's', 'e', '\0' ];

	private char m_notunix_dir[] = [ '%', 'n', 'o', 't', 'u', 'n', 'i', 'x',
			'\0' ];

	private char m_init_code_dir[] = [ '%', 'i', 'n', 'i', 't', '[', '\0' ];

	private char m_init_code_end_dir[] = [ '%', 'i', 'n', 'i', 't', ']', '\0' ];

	private char m_init_throw_code_dir[] = [ '%', 'i', 'n', 'i', 't', 't', 'h',
			'r', 'o', 'w', '[', '\0' ];

	private char m_init_throw_code_end_dir[] = [ '%', 'i', 'n', 'i', 't', 't',
			'h', 'r', 'o', 'w', ']', '\0' ];

	private char m_yylex_throw_code_dir[] = [ '%', 'y', 'y', 'l', 'e', 'x',
			't', 'h', 'r', 'o', 'w', '[', '\0' ];

	private char m_yylex_throw_code_end_dir[] = [ '%', 'y', 'y', 'l', 'e', 'x',
			't', 'h', 'r', 'o', 'w', ']', '\0' ];

	private char m_eof_code_dir[] = [ '%', 'e', 'o', 'f', '[', '\0' ];

	private char m_eof_code_end_dir[] = [ '%', 'e', 'o', 'f', ']', '\0' ];

	private char m_eof_value_code_dir[] = [ '%', 'e', 'o', 'f', 'v', 'a', 'l',
			'[', '\0' ];

	private char m_eof_value_code_end_dir[] = [ '%', 'e', 'o', 'f', 'v', 'a',
			'l', ']', '\0' ];

	private char m_eof_throw_code_dir[] = [ '%', 'e', 'o', 'f', 't', 'h', 'r',
			'o', 'w', '[', '\0' ];

	private char m_eof_throw_code_end_dir[] = [ '%', 'e', 'o', 'f', 't', 'h',
			'r', 'o', 'w', ']', '\0' ];

	private char m_class_code_dir[] = [ '%', '[', '\0' ];

	private char m_class_code_end_dir[] = [ '%', ']', '\0' ];

	private char m_yyeof_dir[] = [ '%', 'y', 'y', 'e', 'o', 'f', '\0' ];

	private char m_public_dir[] = [ '%', 'p', 'u', 'b', 'l', 'i', 'c', '\0' ];

	/***************************************************************
	 * Function: userDeclare Description:
	 **************************************************************/
	private void userDeclare() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"userDeclare");
		int elem;

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		if(m_input.m_eof_reached) {
			/* End-of-file. */
			CError.parse_error(CError.E_EOF, m_input.m_line_number);
		}

		while(false == m_input.getLine()) {
			/* Look fordouble percent. */
			if(2 <= m_input.m_line_read && '%' == m_input.m_line[0]
					&& '%' == m_input.m_line[1]) {
				/* Mess around with line. */
				m_input.m_line_read -= 2;
				arrayCopy(m_input.m_line, 2, m_input.m_line, 0,
						m_input.m_line_read);

				m_input.m_pushback_line = true;
				/* Check forand discard empty line. */
				if(0 == m_input.m_line_read || '\n' == m_input.m_line[0]) {
					m_input.m_pushback_line = false;
				}

				return;
			}

			if(0 == m_input.m_line_read) {
				continue;
			}

			if('%' == m_input.m_line[0]) {
				/* Special lex declarations. */
				if(1 >= m_input.m_line_read) {
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					continue;
				}

				switch (m_input.m_line[1]) {
				case '{':
					if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_class_code_dir, 0, m_class_code_dir.length - 1)) {
						m_spec.m_class_code = packCode(m_class_code_dir,
								m_class_code_end_dir, m_spec.m_class_code,
								m_spec.m_class_read, CLASS_CODE);
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'c':
					if(0 == CUtility.charncmp(m_input.m_line, 0, m_char_dir,
							0, m_char_dir.length - 1)) {
						/* Set line counting to ON. */
						m_input.m_line_index = m_char_dir.length;
						m_spec.m_count_chars = true;
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_class_dir, 0, m_class_dir.length - 1)) {
						m_input.m_line_index = m_class_dir.length;
						m_spec.m_class_name = getName();
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_cup_dir, 0, m_cup_dir.length - 1)) {
						/* Set Java CUP compatibility to ON. */
						m_input.m_line_index = m_cup_dir.length;
						m_spec.m_cup_compatible = true;
						// this is what %cup does: [CSA, 27-Jul-1999]
						m_spec.m_implements_name = "java_cup.runtime.Scanner".dup;
						m_spec.m_function_name = "next_token".dup;
						m_spec.m_type_name = "java_cup.runtime.Symbol".dup;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'e':
					if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_eof_code_dir, 0, m_eof_code_dir.length - 1)) {
						m_spec.m_eof_code = packCode(m_eof_code_dir,
								m_eof_code_end_dir, m_spec.m_eof_code,
								m_spec.m_eof_read, EOF_CODE);
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_eof_value_code_dir, 0,
							m_eof_value_code_dir.length - 1)) {
						m_spec.m_eof_value_code = packCode(
								m_eof_value_code_dir, m_eof_value_code_end_dir,
								m_spec.m_eof_value_code,
								m_spec.m_eof_value_read, EOF_VALUE_CODE);
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_eof_throw_code_dir, 0,
							m_eof_throw_code_dir.length - 1)) {
						m_spec.m_eof_throw_code = packCode(
								m_eof_throw_code_dir, m_eof_throw_code_end_dir,
								m_spec.m_eof_throw_code,
								m_spec.m_eof_throw_read, EOF_THROW_CODE);
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'f':
					if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_function_dir, 0, m_function_dir.length - 1)) {
						/* Set line counting to ON. */
						m_input.m_line_index = m_function_dir.length;
						m_spec.m_function_name = getName();
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_full_dir, 0, m_full_dir.length - 1)) {
						m_input.m_line_index = m_full_dir.length;
						m_spec.m_dtrans_ncols = CUtility.MAX_EIGHT_BIT + 1;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'i':
					if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_integer_dir, 0, m_integer_dir.length - 1)) {
						/* Set line counting to ON. */
						m_input.m_line_index = m_integer_dir.length;
						m_spec.m_integer_type = true;
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_intwrap_dir, 0, m_intwrap_dir.length - 1)) {
						/* Set line counting to ON. */
						m_input.m_line_index = m_integer_dir.length;
						m_spec.m_intwrap_type = true;
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_init_code_dir, 0, m_init_code_dir.length - 1)) {
						m_spec.m_init_code = packCode(m_init_code_dir,
								m_init_code_end_dir, m_spec.m_init_code,
								m_spec.m_init_read, INIT_CODE);
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_init_throw_code_dir, 0,
							m_init_throw_code_dir.length - 1)) {
						m_spec.m_init_throw_code = packCode(
								m_init_throw_code_dir,
								m_init_throw_code_end_dir,
								m_spec.m_init_throw_code,
								m_spec.m_init_throw_read, INIT_THROW_CODE);
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_implements_dir, 0, m_implements_dir.length - 1)) {
						m_input.m_line_index = m_implements_dir.length;
						m_spec.m_implements_name = getName();
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_ignorecase_dir, 0, m_ignorecase_dir.length - 1)) {
						/* Set m_ignorecase to ON. */
						m_input.m_line_index = m_ignorecase_dir.length;
						m_spec.m_ignorecase = true;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'l':
					if(0 == CUtility.charncmp(m_input.m_line, 0, m_line_dir,
							0, m_line_dir.length - 1)) {
						/* Set line counting to ON. */
						m_input.m_line_index = m_line_dir.length;
						m_spec.m_count_lines = true;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'n':
					if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_notunix_dir, 0, m_notunix_dir.length - 1)) {
						/* Set line counting to ON. */
						m_input.m_line_index = m_notunix_dir.length;
						m_spec.m_unix = false;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'p':
					if(0 == CUtility.charncmp(m_input.m_line, 0, m_public_dir,
							0, m_public_dir.length - 1)) {
						/* Set public flag. */
						m_input.m_line_index = m_public_dir.length;
						m_spec.m_public = true;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 's':
					if(0 == CUtility.charncmp(m_input.m_line, 0, m_state_dir,
							0, m_state_dir.length - 1)) {
						/* Recognize state list. */
						m_input.m_line_index = m_state_dir.length;
						saveStates();
						break;
					}

					/* Undefined directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 't':
					if(0 == CUtility.charncmp(m_input.m_line, 0, m_type_dir,
							0, m_type_dir.length - 1)) {
						/* Set Java CUP compatibility to ON. */
						m_input.m_line_index = m_type_dir.length;
						m_spec.m_type_name = getName();
						break;
					}

					/* Undefined directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'u':
					if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_unicode_dir, 0, m_unicode_dir.length - 1)) {
						m_input.m_line_index = m_unicode_dir.length;
						m_spec.m_dtrans_ncols = CUtility.MAX_SIXTEEN_BIT + 1;
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				case 'y':
					if(0 == CUtility.charncmp(m_input.m_line, 0, m_yyeof_dir,
							0, m_yyeof_dir.length - 1)) {
						m_input.m_line_index = m_yyeof_dir.length;
						m_spec.m_yyeof = true;
						break;
					} else if(0 == CUtility.charncmp(m_input.m_line, 0,
							m_yylex_throw_code_dir, 0,
							m_yylex_throw_code_dir.length - 1)) {
						m_spec.m_yylex_throw_code = packCode(
								m_yylex_throw_code_dir,
								m_yylex_throw_code_end_dir,
								m_spec.m_yylex_throw_code,
								m_spec.m_yylex_throw_read, YYLEX_THROW_CODE);
						break;
					}

					/* Bad directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;

				default:
					/* Undefined directive. */
					CError.parse_error(CError.E_DIRECT, m_input.m_line_number);
					break;
				}
			} else {
				/* Regular expression macro. */
				m_input.m_line_index = 0;
				saveMacro();
			}

			if(CUtility.OLD_DEBUG) {
				writeln("Line number " ~ conv!(int,string)(m_input.m_line_number) ~ ":");
				writeln(m_input.m_line[0..m_input.m_line_read]);
			}
		}
	}

	/***************************************************************
	 * Function: userRules Description: Processes third section of JLex
	 * specification and creates minimized transition table.
	 **************************************************************/
	private void userRules() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"userRules");
		int code;

		if(false == m_init_flag) {
			StackTrace.printTrace();
			CError.parse_error(CError.E_INIT, 0);
		}

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		/* UNDONE: Need to handle states preceding rules. */

		if(m_spec.m_verbose) {
			writeln("Creating NFA machine representation.");
		}
		m_makeNfa.allocate_BOL_EOF(m_spec);
		m_makeNfa.thompson(this, m_spec, m_input);

		m_simplifyNfa.simplify(m_spec);

		/* print_nfa(); */

		debug(debugversion) {
			assert(END_OF_INPUT == m_spec.m_current_token);
		}

		if(m_spec.m_verbose) {
			writeln("Creating DFA transition table.");
		}
		m_nfa2dfa.make_dfa(this, m_spec);

		if(CUtility.FOODEBUG) {
			print_header();
		}

		if(m_spec.m_verbose) {
			writeln("Minimizing DFA transition table.");
		}
		m_minimize.min_dfa(m_spec);
	}

	/***************************************************************
	 * Function: printccl Description: Debugging routine that outputs readable
	 * form of character class.
	 **************************************************************/
	private void printccl(CSet set) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"printccl");
			
		int i;

		write(" [");
		for(i = 0; i < m_spec.m_dtrans_ncols; ++i) {
			if(set.contains(i)) {
				write(interp_int(i));
			}
		}
		write(']');
	}

	/***************************************************************
	 * Function: plab Description:
	 **************************************************************/
	private string plab(CNfa state) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"plab");
			
		if(null is state) {
			return "--";
		}

		int index = m_spec.m_nfa_states.indexOf(state);

		return conv!(int,string)(index);
	}

	/***************************************************************
	 * Function: interp_int Description:
	 **************************************************************/
	private string interp_int(int i) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"interp_int");
		debug st.putArgs("int", "i", i);
			
		switch (i) {
			case cast(int)('\b'):
				return "\\b";

			case cast(int)('\t'):
				return "\\t";

			case cast(int)('\n'):
				return "\\n";

			case cast(int)('\f'):
				return "\\f";

			case cast(int)('\r'):
				return "\\r";

			case cast(int)(' '):
				return "\\ ";

			default:
				return conv!(int,string)(i);
			}
	}

	/***************************************************************
	 * Function: print_nfa Description:
	 **************************************************************/
	void print_nfa() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"print_nfa");

		int elem;
		CNfa nfa;
		int size;
		string[] states;
		int index;
		int i;
		int j;
		int vsize;
		string state;

		writeln("--------------------- NFA -----------------------");

		size = m_spec.m_nfa_states.getSize();
		for(elem = 0; elem < size; ++elem) {
			nfa = m_spec.m_nfa_states.get(elem);

			write("Nfa state " ~ plab(nfa) ~ ": ");

			if(null is nfa.m_next) {
				write("(TERMINAL)");
			} else {
				write("--> " ~ plab(nfa.m_next));
				write("--> " ~ plab(nfa.m_next2));

				switch (nfa.m_edge) {
				case CNfa.CCL:
					printccl(nfa.m_set);
					break;

				case CNfa.EPSILON:
					write(" EPSILON ");
					break;

				default:
					write(" " ~ interp_int(nfa.m_edge));
					break;
				}
			}

			if(0 == elem) {
				write(" (START STATE)");
			}

			if(null !is nfa.m_accept) {
				write(" accepting "
						~ ((0 != (nfa.m_anchor & CSpec.START)) ? "^" : "")
						~ "<"
						~ nfa.m_accept.m_action[0..nfa.m_accept.m_action_read] ~ ">"
						~ ((0 != (nfa.m_anchor & CSpec.END)) ? "$" : ""));
			}

			writeln();
		}

		states = m_spec.m_states.keys();
		foreach(it;states) {
			state = it;
			if(state in m_spec.m_states) {
				index = m_spec.m_states[state];
			} else {
				index = -1;
			}

			debug(debugversion) {
				assert(null !is state);
				assert(index != -1);
			}

			writeln("State \"" ~ state ~ "\" has identifying index " ~ conv!(int,string)(index) ~ ".");
			write("\tStart states of matching rules: ");

			i = index;
			vsize = m_spec.m_state_rules[i].getSize();

			for(j = 0; j < vsize; ++j) {
				nfa = m_spec.m_state_rules[i].get(j);

				write(conv!(int,string)(m_spec.m_nfa_states.indexOf(nfa)) ~ " ");
			}

			writeln();
		}

		writeln("-------------------- NFA ----------------------");
	}

	/***************************************************************
	 * Function: getStates Description: Parses the state area of a rule, from
	 * the beginning of a line. < state1, state2 ... > regular_expression {
	 * action } Returns null on only EOF. Returns all_states, initialied
	 * properly to correspond to all states, ifno states are found. Special
	 * Notes: This function treats commas as optional and permits states to be
	 * spread over multiple lines.
	 **************************************************************/
	private SparseBitSet all_states = null;

	SparseBitSet getStates() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"getStates");
		int start_state;
		int count_state;
		SparseBitSet states;
		string name;
		int index;
		int i;
		int size;

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		states = null;

		/* Skip white space. */
		while(CUtility.isspace(m_input.m_line[m_input.m_line_index])) {
			++m_input.m_line_index;

			while(m_input.m_line_index >= m_input.m_line_read) {
				/* Must just be an empty line. */
				if(m_input.getLine()) {
					/* EOF found. */
					return null;
				}
			}
		}

		/* Look forstates. */
		if('<' == m_input.m_line[m_input.m_line_index]) {
			++m_input.m_line_index;

			states = new SparseBitSet();

			/* Parse states. */
			while(true) {
				/* We may have reached the end of the line. */
				while(m_input.m_line_index >= m_input.m_line_read) {
					if(m_input.getLine()) {
						/* EOF found. */
						CError.parse_error(CError.E_EOF, m_input.m_line_number);
						return states;
					}
				}

				while(true) {
					/* Skip white space. */
					while(CUtility
							.isspace(m_input.m_line[m_input.m_line_index])) {
						++m_input.m_line_index;

						while(m_input.m_line_index >= m_input.m_line_read) {
							if(m_input.getLine()) {
								/* EOF found. */
								CError.parse_error(CError.E_EOF,
										m_input.m_line_number);
								return states;
							}
						}
					}

					if(',' != m_input.m_line[m_input.m_line_index]) {
						break;
					}

					++m_input.m_line_index;
				}

				if('>' == m_input.m_line[m_input.m_line_index]) {
					++m_input.m_line_index;
					if(m_input.m_line_index < m_input.m_line_read) {
						m_advance_stop = true;
					}
					return states;
				}

				/* Read in state name. */
				start_state = m_input.m_line_index;
				while(false == CUtility
						.isspace(m_input.m_line[m_input.m_line_index])
						&& ',' != m_input.m_line[m_input.m_line_index]
						&& '>' != m_input.m_line[m_input.m_line_index]) {
					++m_input.m_line_index;

					if(m_input.m_line_index >= m_input.m_line_read) {
						/* End of line means end of state name. */
						break;
					}
				}
				count_state = m_input.m_line_index - start_state;

				/* Save name after checking definition. */
				// TODO check forindex out of bound on this associated array
				name = m_input.m_line[start_state..count_state].idup;
				if(name in m_spec.m_states) {
					index = m_spec.m_states[name];
				} else {
					index = -1;
				}
				if(index == -1) {
					/* Uninitialized state. */
					writeln("Uninitialized State Name: " ~ name);
					CError.parse_error(CError.E_STATE, m_input.m_line_number);
				}
				states.set(index);
			}
		}

		if(null is all_states) {
			all_states = new SparseBitSet();

			size = m_spec.m_states.length;
			for(i = 0; i < size; ++i) {
				all_states.set(i);
			}
		}

		if(m_input.m_line_index < m_input.m_line_read) {
			m_advance_stop = true;
		}
		return all_states;
	}

	/********************************************************
	 * Function: expandMacro Description: Returns false on error, true
	 * otherwise.
	 *******************************************************/
	private bool expandMacro() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"expandMacro");
		int elem;
		int start_macro;
		int end_macro;
		int start_name;
		int count_name;
		string def;
		int def_elem;
		string name;
		char replace[];
		int rep_elem;

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		/* Check formacro. */
		if('{' != m_input.m_line[m_input.m_line_index]) {
			CError.parse_error(CError.E_INTERNAL, m_input.m_line_number);
			return ERROR;
		}

		start_macro = m_input.m_line_index;
		elem = m_input.m_line_index + 1;
		if(elem >= m_input.m_line_read) {
			CError.impos("Unfinished macro name");
			return ERROR;
		}

		/* Get macro name. */
		start_name = elem;
		while('}' != m_input.m_line[elem]) {
			++elem;
			if(elem >= m_input.m_line_read) {
				CError.impos("Unfinished macro name at line " ~ conv!(int,string)(m_input.m_line_number));
				return ERROR;
			}
		}
		count_name = elem - start_name;
		end_macro = elem;

		/* Check macro name. */
		if(0 == count_name) {
			CError.impos("Nonexistent macro name");
			return ERROR;
		}

		/* Debug checks. */
		debug(debugversion) {
			assert(0 < count_name);
		}

		/* Retrieve macro definition. */
		name = m_input.m_line[start_name..count_name].idup;
		if(name in m_spec.m_macros) {
			def = m_spec.m_macros[name];
		} else {
			//if(null is def) {
			/* CError.impos("Undefined macro \"" + name + "\"."); */
			writeln("Error: Undefined macro \"" ~ name ~ "\".");
			CError.parse_error(CError.E_NOMAC, m_input.m_line_number);
			return ERROR;
		}
		if(CUtility.OLD_DUMP_DEBUG) {
			writeln("expanded escape: " ~ def);
		}

		/*
		 * Replace macro in new buffer, beginning by copying first part of line
		 * buffer.
		 */
		replace = new char[m_input.m_line.length];
		for(rep_elem = 0; rep_elem < start_macro; ++rep_elem) {
			replace[rep_elem] = m_input.m_line[rep_elem];

			debug(debugversion) {
				assert(rep_elem < replace.length);
			}
		}

		/* Copy macro definition. */
		if(rep_elem >= replace.length) {
			replace = CUtility.doubleSize(replace);
		}
		for(def_elem = 0; def_elem < def.length; ++def_elem) {
			replace[rep_elem] = def[def_elem];

			++rep_elem;
			if(rep_elem >= replace.length) {
				replace = CUtility.doubleSize(replace);
			}
		}

		/* Copy last part of line. */
		if(rep_elem >= replace.length) {
			replace = CUtility.doubleSize(replace);
		}
		for(elem = end_macro + 1; elem < m_input.m_line_read; ++elem) {
			replace[rep_elem] = m_input.m_line[elem];

			++rep_elem;
			if(rep_elem >= replace.length) {
				replace = CUtility.doubleSize(replace);
			}
		}

		/* Replace buffer. */
		m_input.m_line = replace;
		m_input.m_line_read = rep_elem;

		if(CUtility.OLD_DEBUG) {
			writeln(m_input.m_line[0..m_input.m_line_read]);
		}
		return NOT_ERROR;
	}

	/***************************************************************
	 * Function: saveMacro Description: Saves macro definition of form:
	 * macro_name = macro_definition
	 **************************************************************/
	private void saveMacro() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"saveMacro");
		int elem;
		int start_name;
		int count_name;
		int start_def;
		int count_def;
		bool saw_escape;
		bool in_quote;
		bool in_ccl;

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		/*
		 * Macro declarations are of the following form: macro_name
		 * macro_definition
		 */

		elem = 0;

		/* Skip white space preceding macro name. */
		while(CUtility.isspace(m_input.m_line[elem])) {
			++elem;
			if(elem >= m_input.m_line_read) {
				/*
				 * End of line has been reached, and line was found to be empty.
				 */
				return;
			}
		}

		/* Read macro name. */
		start_name = elem;
		while(false == CUtility.isspace(m_input.m_line[elem])
				&& '=' != m_input.m_line[elem]) {
			++elem;
			if(elem >= m_input.m_line_read) {
				/* Macro name but no associated definition. */
				CError.parse_error(CError.E_MACDEF, m_input.m_line_number);
			}
		}
		count_name = elem - start_name;

		/* Check macro name. */
		if(0 == count_name) {
			/* Nonexistent macro name. */
			CError.parse_error(CError.E_MACDEF, m_input.m_line_number);
		}

		/* Skip white space between name and definition. */
		while(CUtility.isspace(m_input.m_line[elem])) {
			++elem;
			if(elem >= m_input.m_line_read) {
				/* Macro name but no associated definition. */
				CError.parse_error(CError.E_MACDEF, m_input.m_line_number);
			}
		}

		if('=' == m_input.m_line[elem]) {
			++elem;
			if(elem >= m_input.m_line_read) {
				/* Macro name but no associated definition. */
				CError.parse_error(CError.E_MACDEF, m_input.m_line_number);
			}
		} else
			/* macro definition without = */
			CError.parse_error(CError.E_MACDEF, m_input.m_line_number);

		/* Skip white space between name and definition. */
		while(CUtility.isspace(m_input.m_line[elem])) {
			++elem;
			if(elem >= m_input.m_line_read) {
				/* Macro name but no associated definition. */
				CError.parse_error(CError.E_MACDEF, m_input.m_line_number);
			}
		}

		/* Read macro definition. */
		start_def = elem;
		in_quote = false;
		in_ccl = false;
		saw_escape = false;
		while(false == CUtility.isspace(m_input.m_line[elem])
				|| true == in_quote || true == in_ccl || true == saw_escape) {
			if('\"' == m_input.m_line[elem] && false == saw_escape) {
				in_quote = !in_quote;
			}

			if('\\' == m_input.m_line[elem] && false == saw_escape) {
				saw_escape = true;
			} else {
				saw_escape = false;
			}
			if(false == saw_escape && false == in_quote) { // CSA, 24-jul-99
				if('[' == m_input.m_line[elem] && false == in_ccl)
					in_ccl = true;
				if(']' == m_input.m_line[elem] && true == in_ccl)
					in_ccl = false;
			}

			++elem;
			if(elem >= m_input.m_line_read) {
				/* End of line. */
				break;
			}
		}
		count_def = elem - start_def;

		/* Check macro definition. */
		if(0 == count_def) {
			/* Nonexistent macro name. */
			CError.parse_error(CError.E_MACDEF, m_input.m_line_number);
		}

		/* Debug checks. */
		debug(debugversion) {
			assert(0 < count_def);
			assert(0 < count_name);
			assert(null !is m_spec.m_macros);
		}

		if(CUtility.OLD_DEBUG) {
			writeln("macro name \"" ~ m_input.m_line[start_name..count_name] ~ "\".");
			writeln("macro definition \"" ~ m_input.m_line[start_def..count_def] ~ "\".");
		}

		/* Add macro name and definition to table. */
		m_spec.m_macros[m_input.m_line[start_name..count_name].idup] = m_input.m_line[start_def..count_def].idup;
	}

	/***************************************************************
	 * Function: saveStates Description: Takes state declaration and makes
	 * entries forthem in state hashtable in CSpec structure. State declaration
	 * should be of the form: %state name0[, name1, name2 ...] (But commas are
	 * actually optional as long as there is white space in between them.)
	 **************************************************************/
	private void saveStates() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"saveStates");
		int start_state;
		int count_state;

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		/* EOF found? */
		if(m_input.m_eof_reached) {
			return;
		}

		/* Debug checks. */
		debug(debugversion) {
			assert('%' == m_input.m_line[0]);
			assert('s' == m_input.m_line[1]);
			assert(m_input.m_line_index <= m_input.m_line_read);
			assert(0 <= m_input.m_line_index);
			assert(0 <= m_input.m_line_read);
		}

		/* Blank line? No states? */
		if(m_input.m_line_index >= m_input.m_line_read) {
			return;
		}

		while(m_input.m_line_index < m_input.m_line_read) {
			if(CUtility.OLD_DEBUG) {
				writeln("line read " ~ conv!(int,string)(m_input.m_line_read) 
					~ "\tline index = " ~ conv!(int,string)(m_input.m_line_index));
			}

			/* Skip white space. */
			while(CUtility.isspace(m_input.m_line[m_input.m_line_index])) {
				++m_input.m_line_index;
				if(m_input.m_line_index >= m_input.m_line_read) {
					/* No more states to be found. */
					return;
				}
			}

			/* Look forstate name. */
			start_state = m_input.m_line_index;
			while(false == CUtility
					.isspace(m_input.m_line[m_input.m_line_index])
					&& ',' != m_input.m_line[m_input.m_line_index]) {
				++m_input.m_line_index;
				if(m_input.m_line_index >= m_input.m_line_read) {
					/* End of line and end of state name. */
					break;
				}
			}
			count_state = m_input.m_line_index - start_state;

			if(CUtility.OLD_DEBUG) {
				writeln("State name \""
						~ m_input.m_line[start_state..count_state]
						~ "\".");
				writeln("Integer index \"" ~ conv!(int,string)(m_spec.m_states.length)
						~ "\".");
			}

			/* Enter new state name, along with unique index. */
			m_spec.m_states[m_input.m_line[start_state..count_state].idup] = m_spec.m_states.length;

			/* Skip comma. */
			if(',' == m_input.m_line[m_input.m_line_index]) {
				++m_input.m_line_index;
				if(m_input.m_line_index >= m_input.m_line_read) {
					/* End of line. */
					return;
				}
			}
		}
	}

	/********************************************************
	 * Function: expandEscape Description: Takes escape sequence and returns
	 * corresponding character code.
	 *******************************************************/
	private char expandEscape() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"expandEscape");
		char r;

		/* Debug checks. */
		debug(debugversion) {
			assert(m_input.m_line_index < m_input.m_line_read);
			assert(0 < m_input.m_line_read);
			assert(0 <= m_input.m_line_index);
		}

		if('\\' != m_input.m_line[m_input.m_line_index]) {
			++m_input.m_line_index;
			return m_input.m_line[m_input.m_line_index - 1];
		} else {
			bool unicode_escape = false;
			++m_input.m_line_index;
			switch (m_input.m_line[m_input.m_line_index]) {
			case 'b':
				++m_input.m_line_index;
				return '\b';

			case 't':
				++m_input.m_line_index;
				return '\t';

			case 'n':
				++m_input.m_line_index;
				return '\n';

			case 'f':
				++m_input.m_line_index;
				return '\f';

			case 'r':
				++m_input.m_line_index;
				return '\r';

			case '^':
				++m_input.m_line_index;
				r = toUpperCase(m_input.m_line[m_input.m_line_index]);
				if(r < '@' || r > 'Z') // non-fatal
					CError.parse_error(CError.E_BADCTRL, m_input.m_line_number);
				//r = (char) (r - '@');
				r = cast(char)(r - '@');
				++m_input.m_line_index;
				return r;

			case 'u':
				unicode_escape = true;
			case 'x':
				++m_input.m_line_index;
				r = 0;
				for(int i = 0; i < (unicode_escape ? 4 : 2); i++)
					if(CUtility.ishexdigit(m_input.m_line[m_input.m_line_index])) {
						//r = (char) (r << 4);
						//r = (char) (r | CUtility
						r = cast(char)(r << 4);
						r = r | CUtility.hex2bin(m_input.m_line[m_input.m_line_index]);
						++m_input.m_line_index;
					} else
						break;

				return r;

			default:
				if(false == CUtility
						.isoctdigit(m_input.m_line[m_input.m_line_index])) {
					r = m_input.m_line[m_input.m_line_index];
					++m_input.m_line_index;
				} else {
					r = 0;
					for(int i = 0; i < 3; i++)
						if(CUtility.isoctdigit(m_input.m_line[m_input.m_line_index])) {
							r = cast(char)(r << 3);
							r = r | CUtility.oct2bin(m_input.m_line[m_input.m_line_index]);
							++m_input.m_line_index;
						} else
							break;
				}
				return r;
			}
		}
	}

	/********************************************************
	 * Function: packAccept Description: Packages and returns CAccept foraction
	 * next in input stream.
	 *******************************************************/
	CAccept packAccept() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"packAccept");
		CAccept accept;
		char action[];
		int action_index;
		int brackets;
		bool insinglequotes;
		bool indoublequotes;
		bool instarcomment;
		bool inslashcomment;
		bool escaped;
		bool slashed;

		action = new char[BUFFER_SIZE];
		action_index = 0;

		debug(debugversion) {
			assert(null !is this);
			assert(null !is m_outstream);
			assert(null !is m_input);
			assert(null !is m_tokens);
			assert(null !is m_spec);
		}

		/* Get a new line, ifneeded. */
		while(m_input.m_line_index >= m_input.m_line_read) {
			if(m_input.getLine()) {
				CError.parse_error(CError.E_EOF, m_input.m_line_number);
				return null;
			}
		}

		/* Look forbeginning of action. */
		while(CUtility.isspace(m_input.m_line[m_input.m_line_index])) {
			++m_input.m_line_index;

			/* Get a new line, ifneeded. */
			while(m_input.m_line_index >= m_input.m_line_read) {
				if(m_input.getLine()) {
					CError.parse_error(CError.E_EOF, m_input.m_line_number);
					return null;
				}
			}
		}

		/* Look forbrackets. */
		if('{' != m_input.m_line[m_input.m_line_index]) {
			CError.parse_error(CError.E_BRACE, m_input.m_line_number);
		}

		/* Copy new line into action buffer. */
		brackets = 0;
		insinglequotes = indoublequotes = inslashcomment = instarcomment = escaped = slashed = false;
		while(true) {
			action[action_index] = m_input.m_line[m_input.m_line_index];

			/* Look forquotes. */
			if((insinglequotes || indoublequotes) && escaped)
				escaped = false; // only protects one char, but this is enough.
			else if((insinglequotes || indoublequotes)
					&& '\\' == m_input.m_line[m_input.m_line_index])
				escaped = true;
			else if(!(insinglequotes || inslashcomment || instarcomment)
					&& '\"' == m_input.m_line[m_input.m_line_index])
				indoublequotes = !indoublequotes; // unescaped double quote.
			else if(!(indoublequotes || inslashcomment || instarcomment)
					&& '\'' == m_input.m_line[m_input.m_line_index])
				insinglequotes = !insinglequotes; // unescaped single quote.
			/* Look forcomments. */
			if(instarcomment) { // inside "/*" comment; look for"*/"
				if(slashed && '/' == m_input.m_line[m_input.m_line_index])
					instarcomment = slashed = false;
				else
					// note that inside a star comment, slashed means starred
					slashed = ('*' == m_input.m_line[m_input.m_line_index]);
			} else if(!inslashcomment && !insinglequotes && !indoublequotes) {
				// not in comment, look for/* or //
				inslashcomment = (slashed && '/' == m_input.m_line[m_input.m_line_index]);
				instarcomment = (slashed && '*' == m_input.m_line[m_input.m_line_index]);
				slashed = ('/' == m_input.m_line[m_input.m_line_index]);
			}

			/* Look forbrackets. */
			if(!insinglequotes && !indoublequotes && !instarcomment
					&& !inslashcomment) {
				if('{' == m_input.m_line[m_input.m_line_index]) {
					++brackets;
				} else if('}' == m_input.m_line[m_input.m_line_index]) {
					--brackets;

					if(0 == brackets) {
						++action_index;
						++m_input.m_line_index;

						break;
					}
				}
			}

			++action_index;
			/* Double the buffer size, ifneeded. */
			if(action_index >= action.length) {
				action = CUtility.doubleSize(action);
			}

			++m_input.m_line_index;
			/* Get a new line, ifneeded. */
			while(m_input.m_line_index >= m_input.m_line_read) {
				inslashcomment = slashed = false;
				if(insinglequotes || indoublequotes) { // non-fatal
					CError.parse_error(CError.E_NEWLINE, m_input.m_line_number);
					insinglequotes = indoublequotes = false;
				}
				if(m_input.getLine()) {
					CError.parse_error(CError.E_SYNTAX, m_input.m_line_number);
					return null;
				}
			}
		}

		accept = new CAccept(action, action_index, m_input.m_line_number);

		debug(debugversion) {
			assert(null !is accept);
		}

		if(CUtility.DESCENT_DEBUG) {
			write("Accepting action:");
			writeln(accept.m_action[0..accept.m_action_read]);
		}

		return accept;
	}

	/********************************************************
	 * Function: advance Description: Returns code fornext token.
	 *******************************************************/
	private bool m_advance_stop = false;

	int advance() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"advance");
		bool saw_escape = false;
		int code;

		/*
		 * if(m_input.m_line_index > m_input.m_line_read) {
		 * writeln("m_input.m_line_index = " + m_input.m_line_index);
		 * writeln("m_input.m_line_read = " + m_input.m_line_read);
		 * assert(m_input.m_line_index <= m_input.m_line_read); }
		 */

		if(m_input.m_eof_reached) {
			/*
			 * EOF has already been reached, so return appropriate code.
			 */

			m_spec.m_current_token = END_OF_INPUT;
			m_spec.m_lexeme = '\0';
			return m_spec.m_current_token;
		}

		/*
		 * End of previous regular expression? Refill line buffer?
		 */
		if(EOS == m_spec.m_current_token
		/* ADDED */
		|| m_input.m_line_index >= m_input.m_line_read)
		/* ADDED */
		{
			if(m_spec.m_in_quote) {
				CError.parse_error(CError.E_SYNTAX, m_input.m_line_number);
			}

			while(true) {
				if(false == m_advance_stop
						|| m_input.m_line_index >= m_input.m_line_read) {
					if(m_input.getLine()) {
						/*
						 * EOF has already been reached, so return appropriate
						 * code.
						 */

						m_spec.m_current_token = END_OF_INPUT;
						m_spec.m_lexeme = '\0';
						return m_spec.m_current_token;
					}
					m_input.m_line_index = 0;
				} else {
					m_advance_stop = false;
				}

				while(m_input.m_line_index < m_input.m_line_read
						&& true == CUtility
								.isspace(m_input.m_line[m_input.m_line_index])) {
					++m_input.m_line_index;
				}

				if(m_input.m_line_index < m_input.m_line_read) {
					break;
				}
			}
		}

		debug(debugversion) {
			assert(m_input.m_line_index <= m_input.m_line_read);
		}

		while(true) {
			if(false == m_spec.m_in_quote
					&& '{' == m_input.m_line[m_input.m_line_index]) {
				if(false == expandMacro()) {
					break;
				}

				if(m_input.m_line_index >= m_input.m_line_read) {
					m_spec.m_current_token = EOS;
					m_spec.m_lexeme = '\0';
					return m_spec.m_current_token;
				}
			} else if('\"' == m_input.m_line[m_input.m_line_index]) {
				m_spec.m_in_quote = !m_spec.m_in_quote;
				++m_input.m_line_index;

				if(m_input.m_line_index >= m_input.m_line_read) {
					m_spec.m_current_token = EOS;
					m_spec.m_lexeme = '\0';
					return m_spec.m_current_token;
				}
			} else {
				break;
			}
		}

		if(m_input.m_line_index > m_input.m_line_read) {
			writeln("m_input.m_line_index = " ~ conv!(int,string)(m_input.m_line_index));
			writeln("m_input.m_line_read = " ~ conv!(int,string)(m_input.m_line_read));
			assert(m_input.m_line_index <= m_input.m_line_read);
		}

		/*
		 * Look forbackslash, and corresponding escape sequence.
		 */
		if('\\' == m_input.m_line[m_input.m_line_index]) {
			saw_escape = true;
		} else {
			saw_escape = false;
		}

		if(false == m_spec.m_in_quote) {
			if(false == m_spec.m_in_ccl
					&& CUtility.isspace(m_input.m_line[m_input.m_line_index])) {
				/*
				 * White space means the end of the current regular expression.
				 */

				m_spec.m_current_token = EOS;
				m_spec.m_lexeme = '\0';
				return m_spec.m_current_token;
			}

			/* Process escape sequence, ifneeded. */
			if(saw_escape) {
				m_spec.m_lexeme = expandEscape();
			} else {
				m_spec.m_lexeme = m_input.m_line[m_input.m_line_index];
				++m_input.m_line_index;
			}
		} else {
			if(saw_escape && (m_input.m_line_index + 1) < m_input.m_line_read
					&& '\"' == m_input.m_line[m_input.m_line_index + 1]) {
				m_spec.m_lexeme = '\"';
				m_input.m_line_index = m_input.m_line_index + 2;
			} else {
				m_spec.m_lexeme = m_input.m_line[m_input.m_line_index];
				++m_input.m_line_index;
			}
		}
		/*code = m_tokens[m_spec.m_lexeme];
		if(m_spec.m_in_quote || true == saw_escape) {
			m_spec.m_current_token = L;
		} else {
			if(null is code) {
				m_spec.m_current_token = L;
			} else {
				m_spec.m_current_token = code.intValue();
			}
		}*/

		if(m_spec.m_in_quote || true == saw_escape) {
			m_spec.m_current_token = L;
		} else if(!(m_spec.m_lexeme in m_tokens)) {
			m_spec.m_current_token = L;
		} else {
			m_spec.m_current_token = code = m_tokens[m_spec.m_lexeme];
		}

		
		if(CCL_START == m_spec.m_current_token)
			m_spec.m_in_ccl = true;
		if(CCL_END == m_spec.m_current_token)
			m_spec.m_in_ccl = false;

		if(CUtility.FOODEBUG) {
			writeln("Lexeme: " ~ conv!(int,string)(m_spec.m_lexeme) ~ "\tToken: "
					~ conv!(int,string)(m_spec.m_current_token) ~ "\tIndex: "
					~ conv!(int,string)(m_input.m_line_index));
		}

		return m_spec.m_current_token;
	}

	/***************************************************************
	 * Function: details Description: High level debugging routine.
	 **************************************************************/
	private void details() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"details");
		string[] names;
		string name;
		string def;
		string[] states;
		string state;
		int index;
		int elem;
		int size;

		writeln();
		writeln("\t** Macros **");
		names = m_spec.m_macros.keys();
		//while(names.hasMoreElements()) {
		foreach(it;names) {
			name = it;
			def = m_spec.m_macros[name];

			debug(debugversion) {
				assert(null !is name);
				assert(null !is def);
			}

			writeln("Macro name \"" ~ name ~ "\" has definition \""
					~ def ~ "\".");
		}

		writeln();
		writeln("\t** States **");
		states = m_spec.m_states.keys();
		bool stateFound = false;
		//while(states.hasMoreElements()) {
		foreach(it;states) {
			state = it;
			if(state in m_spec.m_states) {
				stateFound = true;
			}
			index = m_spec.m_states[state];

			debug(debugversion) {
				assert(null !is state);
				//assert(null !is index);
				assert(!stateFound);
			}

			writeln("State \"" ~ state ~ "\" has identifying index " ~ conv!(int,string)(index) ~ ".");
		}

		writeln();
		writeln("\t** Character Counting **");
		if(false == m_spec.m_count_chars) {
			writeln("Character counting is off.");
		} else {
			debug(debugversion) {
				assert(m_spec.m_count_lines);
			}

			writeln("Character counting is on.");
		}

		writeln();
		writeln("\t** Line Counting **");
		if(false == m_spec.m_count_lines) {
			writeln("Line counting is off.");
		} else {
			debug(debugversion) {
				assert(m_spec.m_count_lines);
			}

			writeln("Line counting is on.");
		}

		writeln();
		writeln("\t** Operating System Specificity **");
		if(false == m_spec.m_unix) {
			writeln("Not generating UNIX-specific code.");
			writeln("(This means that \"\\r\\n\" is a newline, rather than \"\\n\".)");
		} else {
			writeln("Generating UNIX-specific code.");
			writeln("(This means that \"\\n\" is a newline, rather than \"\\r\\n\".)");
		}

		writeln();
		writeln("\t** Java CUP Compatibility **");
		if(false == m_spec.m_cup_compatible) {
			writeln("Generating CUP compatible code.");
			writeln("(Scanner implements java_cup.runtime.Scanner.)");
		} else {
			writeln("Not generating CUP compatible code.");
		}

		if(CUtility.FOODEBUG) {
			if(null !is m_spec.m_nfa_states && null !is m_spec.m_nfa_start) {
				writeln();
				writeln("\t** NFA machine **");
				print_nfa();
			}
		}

		if(null !is m_spec.m_dtrans_vector) {
			writeln();
			writeln("\t** DFA transition table **");
			/* print_header(); */
		}

		/*
		 * if(null !is m_spec.m_accept_vector && null != m_spec.m_anchor_array)
		 * { writeln();
		 * writeln("\t** Accept States and Anchor Vector **");
		 * print_accept(); }
		 */
	}

	/***************************************************************
	 * function: print_set
	 **************************************************************/
	void print_set(Vector!(CNfa) nfa_set) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"print_set");
			
		int size;
		int elem;
		CNfa nfa;

		size = nfa_set.getSize();

		if(0 == size) {
			write("empty ");
		}

		for(elem = 0; elem < size; ++elem) {
			nfa = nfa_set.get(elem);
			/* write(m_spec.m_nfa_states.indexOf(nfa) + " "); */
			write(conv!(int,string)(nfa.m_label) ~ " ");
		}
	}

	/***************************************************************
	 * Function: print_header
	 **************************************************************/
	private void print_header() {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"print_header");
		string[] states;
		int i;
		int j;
		int chars_printed = 0;
		CDTrans dtrans;
		int last_transition;
		string str;
		CAccept accept;
		string state;
		int index;

		writeln("/*---------------------- DFA -----------------------");

		states = m_spec.m_states.keys();
		//while(states.hasMoreElements()) {
		foreach(it;states) {
			state = it;
			bool stateFound = false;
			if(state in m_spec.m_states) {
				stateFound = true;
				index = m_spec.m_states[state];
			}

			debug(debugversion) {
				assert(null !is state);
				//assert(null !is index);
				assert(!stateFound);
			}

			writeln("State \"" ~ state ~ "\" has identifying index "
					~ conv!(int,string)(index) ~ ".");

			i = index;
			if(CDTrans.F != m_spec.m_state_dtrans[i]) {
				writeln("\tStart index in transition table: "
						~ conv!(int,string)(m_spec.m_state_dtrans[i]));
			} else {
				writeln("\tNo associated transition states.");
			}
		}

		for(i = 0; i < m_spec.m_dtrans_vector.getSize(); ++i) {
			dtrans = m_spec.m_dtrans_vector.get(i);

			if(null is m_spec.m_accept_vector && null == m_spec.m_anchor_array) {
				if(null is dtrans.m_accept) {
					write(" * State " ~ conv!(int,string)(i) ~ " [nonaccepting]");
				} else {
					write(" * State "
							~ conv!(int,string)(i)
							~ " [accepting, line "
							~ conv!(int,string)(dtrans.m_accept.m_line_number)
							~ " <"
							~ dtrans.m_accept.m_action[0..dtrans.m_accept.m_action_read] ~ ">]");
					if(CSpec.NONE != dtrans.m_anchor) {
						write(" Anchor: " ~ ((0 != (dtrans.m_anchor & CSpec.START)) ? "start " : "")
										~ ((0 != (dtrans.m_anchor & CSpec.END)) ? "end " : ""));
					}
				}
			} else {
				accept = m_spec.m_accept_vector.get(i);

				if(null is accept) {
					write(" * State " ~ conv!(int,string)(i) ~ " [nonaccepting]");
				} else {
					write(" * State "
							~ conv!(int,string)(i)
							~ " [accepting, line "
							~ conv!(int,string)(accept.m_line_number)
							~ " <"
							~ accept.m_action[0..accept.m_action_read] ~ ">]");
					if(CSpec.NONE != m_spec.m_anchor_array[i]) {
						write(" Anchor: "
										~ ((0 != (m_spec.m_anchor_array[i] & CSpec.START)) ? "start " : "")
										~ ((0 != (m_spec.m_anchor_array[i] & CSpec.END)) ? "end " : ""));
					}
				}
			}

			last_transition = -1;
			for(j = 0; j < m_spec.m_dtrans_ncols; ++j) {
				if(CDTrans.F != dtrans.m_dtrans[j]) {
					if(last_transition != dtrans.m_dtrans[j]) {
						writeln();
						write(" *    goto " ~ conv!(int,string)(dtrans.m_dtrans[j]) ~ " on ");
						chars_printed = 0;
					}

					str = interp_int(j);
					write(str);

					chars_printed = chars_printed + str.length;
					if(56 < chars_printed) {
						writeln();
						write(" *             ");
						chars_printed = 0;
					}

					last_transition = dtrans.m_dtrans[j];
				}
			}
			writeln();
		}
		writeln(" */");
		writeln();
	}
}
