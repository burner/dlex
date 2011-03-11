module main;

public class Main
{
  /***************************************************************
    Function: main
    **************************************************************/
  public static void main
    (
     String arg[]
     )
    throws java.io.IOException
      {
	CLexGen lg;

	if (arg.length < 1)
	  {
	    System.out.println("Usage: JLex.Main <filename>");
	    return;
	  }

	/* Note: For debuging, it may be helpful to remove the try/catch
	   block and permit the Exception to propagate to the top level. 
	   This gives more information. */
	try 
	  {	
	    lg = new CLexGen(arg[0]);
	    lg.generate();
	  }
	catch (Error e)
	  {
	    System.out.println(e.getMessage());
	  }
      }
}    
