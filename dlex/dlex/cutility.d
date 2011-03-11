module dlex.cutility;

class CUtility {
	/********************************************************
	  Constants
	 *******************************************************/
	static immutable bool DEBUG = true;
	static immutable bool SLOW_DEBUG = true;
	static immutable bool DUMP_DEBUG = true;
	/*static final bool DEBUG = false;
	  static final bool SLOW_DEBUG = false;
	  static final bool DUMP_DEBUG = false;*/
	static immutable bool DESCENT_DEBUG = false;
	static immutable bool OLD_DEBUG = false;
	static immutable bool OLD_DUMP_DEBUG = false;
	static immutable bool FOODEBUG = false;
	static immutable bool DO_DEBUG = false;

	/********************************************************
Constants: Integer Bounds
	 *******************************************************/
	static immutable int INT_MAX = 2147483647;

	static immutable int MAX_SEVEN_BIT = 127;
	static immutable int MAX_EIGHT_BIT = 255;
	static immutable int MAX_SIXTEEN_BIT=65535;

	/********************************************************
Function: enter
Description: Debugging routine.
	 *******************************************************/
	static void enter
		(
		 string descent,
		 char lexeme,
		 int token
		)
		{
			writeln("Entering " + descent 
					+ " [lexeme: " + lexeme 
					+ "] [token: " + token + "]");
		}

	/********************************************************
Function: leave
Description: Debugging routine.
	 *******************************************************/
	static void leave
		(
		 string descent,
		 char lexeme,
		 int token
		)
		{
			writeln("Leaving " + descent 
					+ " [lexeme:" + lexeme 
					+ "] [token:" + token + "]");
		}

	/********************************************************
Function: ASSERT
Description: Debugging routine.
	 *******************************************************/
	static void ASSERT
		(
		 bool expr
		)
		{
			if (DEBUG && false == expr)
			{
				writeln("Assertion Failed");
				throw new Error("Assertion Failed.");
			}
		}

	/***************************************************************
Function: doubleSize
	 **************************************************************/
	static char[] doubleSize
		(
		 char oldBuffer[]
		)
		{
			char newBuffer[] = new char[2 * oldBuffer.length];
			int elem;

			for (elem = 0; elem < oldBuffer.length; ++elem)
			{
				newBuffer[elem] = oldBuffer[elem];
			}

			return newBuffer;
		}

	/***************************************************************
Function: doubleSize
	 **************************************************************/
	static byte[] doubleSize
		(
		 byte oldBuffer[]
		)
		{
			byte newBuffer[] = new byte[2 * oldBuffer.length];
			int elem;

			for (elem = 0; elem < oldBuffer.length; ++elem)
			{
				newBuffer[elem] = oldBuffer[elem];
			}

			return newBuffer;
		}

	/********************************************************
Function: hex2bin
	 *******************************************************/
	static char hex2bin
		(
		 char c
		)
		{
			if ('0' <= c && '9' >= c)
			{
				return c - '0';
			}
			else if ('a' <= c && 'f' >= c)
			{
				return c - 'a' + 10;
			}	    
			else if ('A' <= c && 'F' >= c)
			{
				return c - 'A' + 10;
			}

			CError.impos("Bad hexidecimal digit" + c);
			return 0;
		}

	/********************************************************
Function: ishexdigit
	 *******************************************************/
	static bool ishexdigit
		(
		 char c
		)
		{
			if (('0' <= c && '9' >= c)
					|| ('a' <= c && 'f' >= c)
					|| ('A' <= c && 'F' >= c))
			{
				return true;
			}

			return false;
		}

	/********************************************************
Function: oct2bin
	 *******************************************************/
	static char oct2bin
		(
		 char c
		)
		{
			if ('0' <= c && '7' >= c)
			{
				return c - '0';
			}

			CError.impos("Bad octal digit " + c);
			return 0;
		}

	/********************************************************
Function: isoctdigit
	 *******************************************************/
	static bool isoctdigit
		(
		 char c
		)
		{
			if ('0' <= c && '7' >= c)
			{
				return true;
			}

			return false;
		}

	/********************************************************
Function: isspace
	 *******************************************************/
	static bool isspace
		(
		 char c
		)
		{
			if ('\b' == c 
					|| '\t' == c
					|| '\n' == c
					|| '\f' == c
					|| '\r' == c
					|| ' ' == c)
			{
				return true;
			}

			return false;
		}

	/********************************************************
Function: isnewline
	 *******************************************************/
	static bool isnewline
		(
		 char c
		)
		{
			if ('\n' == c
					|| '\r' == c)
			{
				return true;
			}

			return false;
		}

	/********************************************************
Function: bytencmp
Description: Compares up to n elements of 
byte array a[] against byte array b[].
The first byte comparison is made between 
a[a_first] and b[b_first].  Comparisons continue
until the null terminating byte '\0' is reached
or until n bytes are compared.
Return Value: Returns 0 if arrays are the 
same up to and including the null terminating byte 
or up to and including the first n bytes,
whichever comes first.
	 *******************************************************/
	static int bytencmp
		(
		 byte a[],
		 int a_first,
		 byte b[],
		 int b_first,
		 int n
		)
		{
			int elem;

			for (elem = 0; elem < n; ++elem)
			{
				/*write((char) a[a_first + elem]);
				  write((char) b[b_first + elem]);*/

				if ('\0' == a[a_first + elem] && '\0' == b[b_first + elem])
				{
					/*writeln("return 0");*/
					return 0;
				}
				if (a[a_first + elem] < b[b_first + elem])
				{
					/*writeln("return 1");*/
					return 1;
				}
				else if (a[a_first + elem] > b[b_first + elem])
				{
					/*writeln("return -1");*/
					return -1;
				}
			}

			/*writeln("return 0");*/
			return 0;
		}

	/********************************************************
Function: charncmp
	 *******************************************************/
	static int charncmp
		(
		 char a[],
		 int a_first,
		 char b[],
		 int b_first,
		 int n
		)
		{
			int elem;

			for (elem = 0; elem < n; ++elem)
			{
				if ('\0' == a[a_first + elem] && '\0' == b[b_first + elem])
				{
					return 0;
				}
				if (a[a_first + elem] < b[b_first + elem])
				{
					return 1;
				}
				else if (a[a_first + elem] > b[b_first + elem])
				{
					return -1;
				}
			}

			return 0;
		}
}
