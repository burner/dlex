/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * jflex 1.4                                                               *
 * Copyright (C) 1998-2009  Gerwin Klein <lsf@jflex.de>                    *
 * All rights reserved.                                                    *
 *                                                                         *
 * This program is free software; you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License. See the file      *
 * COPYRIGHT for more information.                                         *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License along *
 * with this program; if not, write to the Free Software Foundation, Inc., *
 * 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA                 *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

module dflex.packemitter;

import hurt.string.stringbuffer;

/** Encodes <code>int</code> arrays as strings.
 * 
 * Also splits up strings when longer than 64K in UTF8 encoding.
 * Subclasses emit unpacking code.
 * 
 * Usage protocol:
 * <code>p.emitInit();</code><br>
 * <code>for each data: p.emitData(data);</code><br>
 * <code>p.emitUnpack();</code> 
 * 
 * @author Gerwin Klein */
public abstract class PackEmitter {

  /** name of the generated array (mixed case, no yy prefix) */
  protected string name;
    
  /** current UTF8 length of generated string in current chunk */
  private int UTF8LengthVar;

  /** position in the current line */
  private int linepos;
  
  /** max number of entries per line */
  private static immutable maxEntries = 16;
  
  /** output buffer */
  protected StringBuffer!(char) outsb = new StringBuffer!(char)(16);

  /** number of existing string chunks */ 
  protected int chunks;
    
  /** maximum size of chunks */
  // String constants are stored as UTF8 with 2 bytes length
  // field in class files. One Unicode char can be up to 3 
  // UTF8 bytes. 64K max and two chars safety. 
  private static immutable maxSize = 0xFFFF-6;
  
  /** indent for string lines */
  private static immutable indent = "    ";
  
  /**
   * Create new emitter for an array.
   * 
   * @param name  the name of the generated array
   */
  public this(string name) {
    this.name = name;
  }
  
  /**
   * Convert array name into all uppercase internal scanner 
   * constant name.
   * 
   * @return <code>name</code> as a internal constant name.
   * @see PackEmitter#name
   */
  protected string constName() {
    return "ZZ_" ~ name.toUpperCase();
  }
  
  /**
   * Return current output buffer.
   */
  public override string toString() {
    return outsb.toString();
  }

  /**
   * Emit declaration of decoded member and open first chunk.
   */  
  public void emitInit() {
    outsb.append("  private static final int [] ");
    outsb.append(constName());
    outsb.append(" = zzUnpack");
    outsb.append(name);
    outsb.append("();");
    outsb.append("\n");
    nextChunk();
  }

  /**
   * Emit single unicode character. 
   * 
   * Updates length, position, etc.
   *
   * @param i  the character to emit.
   * @prec  0 <= i <= 0xFFFF 
   */   
  public void emitUC(int i) {     
    if (i < 0 || i > 0xFFFF) 
      throw new IllegalArgumentException("character value expected");
  
    // cast ok because of prec  
    char c = cast(char)i;    
     
    printUC(c);
    UTF8Lengthvar += UTF8Length(c);
    linepos++;   
  }

  /**
   * Execute line/chunk break if necessary. 
   * Leave space for at least two chars.
   */  
  public void breaks() {
    if (UTF8Lengthvar >= maxSize) {
      // close current chunk
      outsb.append("\";");
      outsb.append("\n");
      
      nextChunk();
    }
    else {
      if (linepos >= maxEntries) {
        // line break
        outsb.append("\"+");
        outsb.append("\n");
        outsb.append(indent);
        outsb.append("\"");
        linepos = 0;      
      }
    }
  }
  
  /**
   * Emit the unpacking code. 
   */
  public abstract void emitUnpack();

  /**
   *  emit next chunk 
   */
  private void nextChunk() {
    outsb.append("\n");
    outsb.append("  private static final String ");
    outsb.append(constName());
    outsb.append("_PACKED_");
    outsb.append(chunks);
    outsb.append(" =");
    outsb.append("\n");
    outsb.append(indent);
    outsb.append("\"");

    UTF8Length = 0;
    linepos = 0;
    chunks++;
  }
  
  /**
   * Append a unicode/octal escaped character 
   * to <code>out</code> buffer.
   * 
   * @param c the character to append
   */
  private void printUC(char c) {
    if (c > 255) {
      outsb.append("\\u");
      if (c < 0x1000) outsb.append("0");
      outsb.append(Integer.toHexString(c));
    }
    else {
      outsb.append("\\");
      outsb.append(Integer.toOctalString(c));
    }
  } 

  /**
   * Calculates the number of bytes a Unicode character
   * would have in UTF8 representation in a class file.
   *
   * @param value  the char code of the Unicode character
   * @prec  0 <= value <= 0xFFFF
   *
   * @return length of UTF8 representation.
   */
  private int UTF8Length(char value) {
    // if (value < 0 || value > 0xFFFF) throw new Error("not a char value ("+value+")");

    // see JVM spec section 4.4.7, p 111
    if (value == 0) return 2;
    if (value <= 0x7F) return 1;

    // workaround for javac bug (up to jdk 1.3):
    if (value <  0x0400) return 2;
    if (value <= 0x07FF) return 3;

    // correct would be:
    // if (value <= 0x7FF) return 2;
    return 3;
  }

}
